#!/usr/bin/perl -w

#bidirectional_hit_filter.pl
#Generated using perl_script_template.pl 1.33
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Created on 4/22/2008
#Center for Computational Research
#Copyright 2007

#These variables (in main) are used by printVersion()
my $template_version_number = '1.33';
my $software_version_number = '1.1';

##
## Start Main
##

use strict;
use Getopt::Long;

#Declare & initialize variables.  Provide default values here.
my($outfile_suffix,$paralogs_suffix); #Not defined so a user can overwrite the
                                      #input file
my @input_files         = ();
my $current_output_file = '';
my $help                = 0;
my $version             = 0;
my $force               = 0;
my $evalue_cutoff       = 10**-30;
my $length_ratio_cutoff = .9;
my $percent_identity_cutoff = 10;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, printVersion, getCommand and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;

my $GetOptHash =
  {'e|evalue-cutoff=s'  => \$evalue_cutoff,          #OPTIONAL [10^-30]
   'l|length-ratio-cutoff=s' => \$length_ratio_cutoff,      #OPTIONAL [0.9]
   'p|percent-identity-cutoff=s' => \$percent_identity_cutoff, #OPTIONAL [10]
   'i|input-file=s'     => sub {push(@input_files,   #REQUIRED unless <> is
				     sglob($_[1]))}, #         supplied
   '<>'                 => sub {push(@input_files,   #REQUIRED unless -i is
				     sglob($_[0]))}, #         supplied
   'u|uniques-suffix=s' => \$paralogs_suffix,        #OPTIONAL [undef]
   'o|outfile-suffix=s' => \$outfile_suffix,         #OPTIONAL [undef]
   'f|force!'           => \$force,                  #OPTIONAL [Off]
   'v|verbose!'         => \$verbose,                #OPTIONAL [Off]
   'q|quiet!'           => \$quiet,                  #OPTIONAL [Off]
   'h|help!'            => \$help,                   #OPTIONAL [Off]
   'debug!'             => \$DEBUG,                  #OPTIONAL [Off]
   'version!'           => \$version,                #OPTIONAL [Off]
  };

#If there are no arguments and no files directed or piped in
if(scalar(@ARGV) == 0 && isStandardInputFromTerminal())
  {
    usage();
    exit(0);
  }

#Get the input options
GetOptions(%$GetOptHash);

#Print the debug mode (it checks the value of the DEBUG global variable)
debug("Debug mode on.");

#If the user has asked for help, call the help subroutine
if($help)
  {
    help();
    exit(0);
  }

#If the user has asked for the software version, print it
if($version)
  {
    printVersion();
    exit(0);
  }

#Check validity of verbosity options
if($verbose && $quiet)
  {
    $quiet = 0;
    error("You cannot supply verbose and quiet flags at the same time.");
    exit(1);
  }

#Put standard input into the input_files array if standard input has been redirected in
if(!isStandardInputFromTerminal())
  {
    push(@input_files,'-');

    #Warn the user about the naming of the outfile when using STDIN
    if(defined($outfile_suffix))
      {warning("Input on STDIN detected along with an outfile suffix.  Your ",
	       "output file will be named STDIN$outfile_suffix")}
  }

#Make sure there is input
if(scalar(@input_files) == 0)
  {
    error("No input files detected.");
    usage(1);
    exit(2);
  }

#Check to make sure previously generated output files won't be over-written
if(!$force && defined($outfile_suffix))
  {
    my $existing_outfiles = [];
    foreach my $output_file (map {($_ eq '-' ? 'STDIN' : $_) . $outfile_suffix}
			     @input_files)
      {push(@$existing_outfiles,$output_file) if(-e $output_file)}

    if(scalar(@$existing_outfiles))
      {
	error("The output files: [@$existing_outfiles] already exist.  ",
	      "Use -f to force overwrite.  E.g.\n\t",
	      getCommand(1),' --force');
	exit(3);
      }
  }

if(isStandardOutputToTerminal() && !defined($outfile_suffix))
  {verbose("NOTE: VerboseOverMe functionality has been altered to yield clean STDOUT ",
	   "output.")}

verbose("Run conditions: ",getCommand(1),"\n");

#If output is going to STDOUT instead of output files with different extensions
if(!defined($outfile_suffix))
  {verbose("[STDOUT] Opened for all output.")}

my $genomes_done_hash = {};

#For each input file
foreach my $input_file (@input_files)
  {
    my $hit_hash = {};

    my $parent_dir = $input_file;
    $parent_dir =~ s/[^\/]+$//;

    #If an output file name suffix has been defined
    if(defined($outfile_suffix))
      {
	##
	## Open and select the next output file
	##

	#Set the current output file name
	$current_output_file = ($input_file eq '-' ? 'STDIN' : $input_file)
	  . $outfile_suffix;

	#Open the output file
	if(!open(OUTPUT,">$current_output_file"))
	  {
	    #Report an error and iterate if there was an error
	    error("Unable to open output file: [$current_output_file]\n$!");
	    next;
	  }
	else
	  {verboseOverMe("[$current_output_file] Opened output file.")}

	#Select the output file handle
	select(OUTPUT);
      }

    #Open the input file
    if(!open(INPUT,$input_file))
      {
	#Report an error and iterate if there was an error
	error("Unable to open input file: [$input_file]\n$!");
	next;
      }
    else
      {verboseOverMe("[",
		     ($input_file eq '-' ? 'STDIN' : $input_file),
		     "] Opened input file.")}

    my $line_num             = 0;
    my $num_length_warnings  = 0;
    my $num_sim_warnings     = 0;
    my $fragment_check       = {};
    my $indirect_recip_check = {};

    #For each line in the current input file
    while(getLine(*INPUT))
      {
	$line_num++;
	verboseOverMe("[",
		      ($input_file eq '-' ? 'STDIN' : $input_file),
		      "] Reading line: [$line_num].");

	my($query_file,$subject_file,$query_id,$subject_id,$match_length_ratio,
	   $evalue,$percent_identity,$link_id);
	($query_file,$subject_file,$query_id,$subject_id,$match_length_ratio,
	 $evalue,$percent_identity,$link_id) = split(/ *\t */,$_);
	$link_id = '' unless(defined($link_id));

	#If the match length ratio was given as a percent instead of fractional
	#value, convert it to a fraction.  This could fail if 2% was ever
	#expected as a valid percent match length, but that's very unlikely to
	#ever be desireable
	if($match_length_ratio > 2)
	  {
	    $match_length_ratio /= 100;
	    $num_length_warnings++;
	  }

	#If the percent similarity was given as a fractional value instead of a
        #percent, convert it to a percent.  This could fail if 2% was ever
	#expected as a valid percent match length, but that's very unlikely to
	#ever be desireable
	if($percent_identity < 2)
	  {
	    $percent_identity *= 100;
	    $num_sim_warnings++;
	  }

	$evalue = '1' . $evalue if($evalue =~ /^e/i);

	if(#This hit meets all the cutoffs AND
	   $match_length_ratio >= $length_ratio_cutoff     &&
	   $evalue             <= $evalue_cutoff           &&
	   $percent_identity   >= $percent_identity_cutoff &&

	   #This hit pair does not yet exist OR
	   (!exists($hit_hash->{$query_file}) ||
	    !exists($hit_hash->{$query_file}->{$subject_file}) ||
	    !exists($hit_hash->{$query_file}->{$subject_file}->{$query_id}) ||
	    !exists($hit_hash->{$query_file}->{$subject_file}->{$query_id}
		    ->{$subject_id}) ||

	    #This hit pair does exist AND
	    (exists($hit_hash->{$query_file}->{$subject_file}->{$query_id}
		    ->{$subject_id}) &&

	     #It's a more-authentic hit OR
	     (($hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{LINKID} ne '' && $link_id eq '') ||

	      #It's an authentic hit that is simply all-around better
	      ($link_id eq '' &&
	       $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{LENGTHRATIO} <= $match_length_ratio &&
	       $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{EVALUE} >= $evalue &&
	       $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id}->{IDENTITY} <= $percent_identity)))))
	   {
	     $hit_hash->{$query_file}->{$subject_file}->{$query_id}
	       ->{$subject_id} =
		 {LENGTHRATIO => $match_length_ratio,
		  EVALUE      => $evalue,
		  IDENTITY    => $percent_identity,
		  LINKID      => $link_id};
	   }

	#If this is an indirect link between two fragments (This assumes
	#there's no more than 2 lines with the same combination of files and
	#IDs)
	if($link_id ne '')
	  {
	    #If the reciprocal has already been recorded
	    if(exists($indirect_recip_check->{$subject_file}) &&
	       exists($indirect_recip_check->{$subject_file}->{$query_file}) &&
	       exists($indirect_recip_check->{$subject_file}->{$query_file}
		      ->{$subject_id}) &&
	       exists($indirect_recip_check->{$subject_file}->{$query_file}
		      ->{$subject_id}->{$query_id}))
	      {
		#Delete it
		delete($indirect_recip_check->{$subject_file}->{$query_file}
		       ->{$subject_id}->{$query_id});
		if(scalar(keys(%{$indirect_recip_check->{$subject_file}
				   ->{$query_file}->{$subject_id}})) == 0)
		  {
		    delete($indirect_recip_check->{$subject_file}
			   ->{$query_file}->{$subject_id});
		    if(scalar(keys(%{$indirect_recip_check->{$subject_file}
				       ->{$query_file}})) == 0)
		      {
			delete($indirect_recip_check->{$subject_file}
			       ->{$query_file});
			if(scalar(keys(%{$indirect_recip_check
					   ->{$subject_file}})) == 0)
			  {delete($indirect_recip_check->{$subject_file})}
		      }
		  }
	      }
	    else #Record it
	      {$indirect_recip_check->{$query_file}->{$subject_file}
		 ->{$query_id}->{$subject_id} = 0}
	  }

	#Check to see if this is a direct hit between two fragments that meets
	#the length match ratio cutoff but not one or both of the others
	if($match_length_ratio >= $length_ratio_cutoff    &&
	   ($evalue > $evalue_cutoff ||
	    $percent_identity < $percent_identity_cutoff) &&
	   $link_id eq '')
	  {
	    #Keep this hit for later to check to see if it should trump an
	    #indirect hit between the same two fragments
	    $fragment_check->{$query_file}->{$subject_file}->{$query_id}
	      ->{$subject_id} =
		{LENGTHRATIO => $match_length_ratio,
		 EVALUE      => $evalue,
		 IDENTITY    => $percent_identity,
		 LINKID      => $link_id};
	  }
      }

    if($num_length_warnings)
      {warning("It appears as though [$input_file] has $num_length_warnings ",
	       'lines that have the match length ratio in percentage format ',
	       'instead of in the expected fractional format.  The data has ',
	       'been converted.')}
    if($num_sim_warnings)
      {warning("It appears as though [$input_file] has $num_sim_warnings ",
	       'lines that have the percent similarity in fractional format ',
	       'instead of in the expected percentage format.  The data has ',
	       'been converted.')}

    #Check to see that indirect hits were entered correctly (i.e. that
    #bidirectional hits were entered)
    if(keys(%$indirect_recip_check))
      {
	my $err_string = '';
	foreach my $query_file (keys(%$indirect_recip_check))
	  {foreach my $subject_file (keys(%{$indirect_recip_check
					      ->{$query_file}}))
	     {foreach my $query_id (keys(%{$indirect_recip_check
					     ->{$query_file}
					       ->{$subject_file}}))
		{foreach my $subject_id (keys(%{$indirect_recip_check
						  ->{$query_file}
						    ->{$subject_file}
						      ->{$query_id}}))
		   {$err_string .= $indirect_recip_check->{$query_file}
		      ->{$subject_file}->{$query_id}->{$subject_id}->{LINKID} .
			','}}}}
	$err_string =~ s/,$//;
	error('It appears that 1 or more indirect hits to a reference set of ',
	      "sequences was not entered into the input file: [$input_file] ",
	      'in a bidirecdtional manner.  Either this script should be ',
	      'updated to add the reciprocal hit automatically or you need ',
	      'to include the reciprocal entries in your input file.  Here ',
	      'are the indirect link IDs (from the last column of the input ',
	      "data) without reciprocal hits: [$err_string].");
	undef($indirect_recip_check);
      }

    close(INPUT);

    verbose("[",
	    ($input_file eq '-' ? 'STDIN' : $input_file),
	    '] Input file done.  Time taken: [',
	    scalar(markTime()),
	    " Seconds].");

    #If there were indirect hits in the file
    #Go through the hit_hash

    #Go through the fragment_check hash to see if it should trump any indirect
    #hits.  We are assuming here that the hits in this hash are bad for one
    #reason or another, but that they meet the length match ratio requirement
    foreach my $query_file (keys(%$fragment_check))
      {
	next unless(exists($hit_hash->{$query_file}));
	foreach my $subject_file (keys(%{$fragment_check->{$query_file}}))
	  {
	    next unless(exists($hit_hash->{$query_file}->{$subject_file}));
	    foreach my $query_id (keys(%{$fragment_check->{$query_file}
					   ->{$subject_file}}))
	      {
		next unless(exists($hit_hash->{$query_file}->{$subject_file}
				   ->{$query_id}));
		foreach my $subject_id (keys(%{$fragment_check->{$query_file}
						 ->{$subject_file}
						   ->{$query_id}}))
		  {
		    next unless(exists($hit_hash->{$query_file}
				       ->{$subject_file}->{$query_id}
				       ->{$subject_id}));

		    #If the recorded hit is an indirect one that hits a
		    #reference sequence link
		    if($fragment_check->{$query_file}->{$subject_file}
		       ->{$query_id}->{$subject_id}->{LINKID} ne '')
		      {
			#Remove it from the hit hash
			delete($hit_hash->{$query_file}->{$subject_file}
				       ->{$query_id}->{$subject_id});
			if(scalar(keys(%{$hit_hash->{$query_file}
					   ->{$subject_file}->{$query_id}})) ==
			   0)
			  {
			    delete($hit_hash->{$query_file}->{$subject_file}
				   ->{$query_id});
			    if(scalar(keys(%{$hit_hash->{$query_file}
					       ->{$subject_file}})) == 0)
			      {
				delete($hit_hash->{$query_file}
				       ->{$subject_file});
				if(scalar(keys(%{$hit_hash->{$query_file}})) ==
				   0)
				  {delete($hit_hash->{$query_file})}
			      }
			  }
		      }
		  }
	      }
	  }
      }

    undef($fragment_check);

#    #If an output file name suffix is set
#    if(defined($outfile_suffix))
#      {
#	#Select standard out
#	select(STDOUT);
#	#Close the output file handle
#	close(OUTPUT);
#
#	verbose("[$current_output_file] Output file done.");
#      }
#  }

    my $seed_query_genome = (keys(%$hit_hash))[0];
    my $seed_subject_genome = (keys(%{$hit_hash->{$seed_query_genome}}))[0];
    my @seed_gene_set =
      keys(%{$hit_hash->{$seed_query_genome}->{$seed_subject_genome}});
    my $num_genomes = scalar(keys(%$hit_hash));

    #Keep an array of groups which should each contain n arrays - one for each
    #genome.  In each genome's array will be the genome's file name followed by
    #all the genes in the group.  Here's an example:
    # [[[genome1,gene1],[genome2,gene1]...]...].  This array contains 1 group.
    #Two genomes are depicted and they each have 1 gene in the group
    my $common_groups = [];

    my $seen_hash = {};

    verbose("Building candidate set of common genes...");

    foreach my $seed_query_gene (@seed_gene_set)
      {
	verboseOverMe("Trying seed gene: [$seed_query_gene].");

	next if(exists($seen_hash->{$seed_query_gene}));

	#Try to build a set
	my @paralogs = (grep {exists($hit_hash->{$seed_query_genome} #bidirect.
				     ->{$seed_query_genome}->{$_}    #check
				     ->{$seed_query_gene})}
			keys(%{$hit_hash->{$seed_query_genome}
				 ->{$seed_query_genome}->{$seed_query_gene}}));

	#Update the seen hash so we can skip them later
	foreach my $paralog (@paralogs)
	  {$seen_hash->{$paralog} = 1}

	#Keep a candidate array of arrays of genes which have been hit where
	#the first member is the genome the genes are being added from
	my @common_candidates = ([$seed_query_genome,@paralogs]);

	#Skip this gene if it doesn't contain hits to all other genomes
	if(($num_genomes - 1) >
	   scalar(grep {$_ ne $seed_query_genome}
		  keys(%{$hit_hash->{$seed_query_genome}})))
	  {next}

	#See if every subject genome has non-empty string keys for this query
	#gene or its paralogs
	my $all_hit = 1;
	my $hit_a_subject_genome = 0;
	foreach my $subject_genome (grep {$_ ne $seed_query_genome}
				    keys(%{$hit_hash->{$seed_query_genome}}))
	  {
	    $hit_a_subject_genome = 1;

	    #See if there's a bidirectional hit from any query paralog to each
	    #subject genome
	    my $hit = 0;
	    push(@common_candidates,[$subject_genome]);
	    my $subject_genes_hash = {};
	    foreach my $paralog (@paralogs)
	      {
		foreach my $hitk
		  (grep {$_ ne ''}
		   grep {exists($hit_hash->{$subject_genome} #bidirectional
				->{$seed_query_genome}       #check
				->{$_}->{$paralog})}
		   keys(%{$hit_hash->{$seed_query_genome}
			    ->{$subject_genome}->{$paralog}}))
		  {$subject_genes_hash->{$hitk} = 1}

		#If the hits marked are good (assumes first one in the hash is
		#sufficient), say that there is a hit to this subject genome
		if(scalar(keys(%$subject_genes_hash)) &&
		   (keys(%$subject_genes_hash))[0] =~ /\S/)
		  {$hit = 1}
#The code below was leading to duplicate paralogs when multiple seeds were
#hitting the same genes in the subject genomes, so I implemented the code above
#and in the else below this loop to make the subject list of genes unique
#	    push(@{$common_candidates[-1]},
#		 grep {$_ ne ''}
#		 grep {exists($hit_hash->{$subject_genome}  #bidirectional
#			      ->{$seed_query_genome}        #check
#			      ->{$_}->{$paralog})}
#		 keys(%{$hit_hash->{$seed_query_genome}->{$subject_genome}
#			  ->{$paralog}}));
#	    if(scalar(@{$common_candidates[-1]}) > 1 &&
#	       $common_candidates[-1][1] =~ /\S/)
#	      {$hit = 1}
	      }

	    #If there was not a bidirectional hit to this subject genome, we
	    #can stop, because everything must hit everything
	    if(!$hit)
	      {
		$all_hit = 0;
		last;
	      }
	    else
	      {push(@{$common_candidates[-1]},keys(%$subject_genes_hash))}
	  }

	#If the seed gene bidirectionally hits everything
	if($all_hit && $hit_a_subject_genome)
	  {push(@$common_groups,[@common_candidates])}
	#Or if there's only one genome and we're gathering paralogous sets to
        #simulate a core-genome for comparison purposes
	elsif(scalar(keys(%$hit_hash)) == 1 && scalar(@paralogs))
	  {push(@$common_groups,[@common_candidates])}
	elsif(scalar(keys(%$hit_hash)) == 1 && scalar(@paralogs) == 0)
	  {warning("This gene in [$seed_query_genome]: [$seed_query_gene] ",
		   "did not appear to hit itself bidirectionally.  It's ",
		   "either short or there are a bunch of copies of it (thus ",
		   "it dropped off the list of hits).")}
      }

    verbose("Found ",scalar(@$common_groups),
	    " candidate sets of common genes.  Validating...");

    #Now make sure everything hits everything, accounting for paralogs
    my $group_num     = 0;
    my $commons_found = 0;
    foreach my $common_group (@$common_groups)
      {
	$group_num++;
	my $all_bidirectional = 1;
	foreach my $genome (@$common_group)
	  {
	    verboseOverMe("Evaluating genome [$genome->[0]] in group ",
			  "[$group_num].");
	    if(!isGenomeBidirectional($genome,$common_group,$hit_hash))
	      {
		$all_bidirectional = 0;
		last;
	      }
	  }
	if($all_bidirectional)
	  {
	    $commons_found++;
	    outputGroup($common_group,$commons_found);
	  }
      }

    verbose("Found $commons_found common genes.");

    #Output paralogs if the paralogs suffix has been supplied
    if(defined($paralogs_suffix) && $paralogs_suffix eq '')
      {
	error("The paralogs output file suffix must either not be supplied ",
	      "(to not produce paralog files) or be a non-empty value.  You ",
	      "supplied: [$paralogs_suffix], so paralogs will not be output.");
      }
    elsif(defined($paralogs_suffix) && $paralogs_suffix ne '')
      {
	foreach my $query_genome (keys(%$hit_hash))
	  {
	    #Skip genomes done from other input files (assuming the files all
	    #share a common set of starting genomes)
	    if(exists($genomes_done_hash->{$query_genome}))
	      {next}
	    else
	      {$genomes_done_hash->{$query_genome} = 1}

	    #Open the output paralog file
	    my $outfile = $parent_dir . $query_genome . $paralogs_suffix;
	    if(open(PARALOG,">$outfile"))
	      {
		verboseOverMe("[$outfile] Opened uniques output file.");
		select(PARALOG);
	      }
	    else
	      {
		error("Unable to write to file: [$outfile].");
		next;
	      }

	    #Get all the query genes
	    my @gene_set = keys(%{$hit_hash->{$query_genome}
				    ->{$query_genome}});
	    my $seen_hash = {};

	    #Go through each query gene
	    foreach my $query_gene (@gene_set)
	      {
		#Skip paralogs already printed
		next if(exists($seen_hash->{$query_gene}));

		#Obtain bidirectional hit paralogs (including hits to self)
		my @paralogs = (grep {exists($hit_hash->{$query_genome} #bidir.
					     ->{$query_genome}->{$_}    #check
					     ->{$query_gene})}
				keys(%{$hit_hash->{$query_genome}
					 ->{$query_genome}->{$query_gene}}));

		#Update the seen hash so we can skip them later
		foreach my $paralog (@paralogs)
		  {$seen_hash->{$paralog} = 1}

		if(scalar(@paralogs) == 0)
		  {
		    $seen_hash->{$query_gene} = 1;
		    push(@paralogs,$query_gene);
		  }

		#Print the set of paralogs on one line (which may be a unique
		#non-paralogous gene)
		print(join("\t",@paralogs),"\n");
	      }

	    select(STDOUT);
	    close(PARALOG);
	    verbose("[$outfile] Output file done.");
	  }
      }

    #If an output file name suffix is set
    if(defined($outfile_suffix))
      {
	#Select standard out
	select(STDOUT);
	#Close the output file handle
	close(OUTPUT);

	verbose("[$current_output_file] Output file done.");
      }
  }



#Report the number of errors, warnings, and debugs
verbose("Done.  EXIT STATUS: [",
	"ERRORS: ",
	($main::error_number ? $main::error_number : 0),
	" WARNINGS: ",
	($main::warning_number ? $main::warning_number : 0),
	($DEBUG ?
	 " DEBUGS: " . ($main::debug_number ? $main::debug_number : 0) : ''),
        " TIME: ",scalar(markTime(0)),"s]");
if($main::error_number || $main::warning_number)
  {verbose("Scroll up to inspect errors and warnings.")}

##
## End Main
##






























##
## Subroutines
##


sub isGenomeBidirectional
  {
    my $gene_list    = $_[0];
    my $common_group = $_[1];
    my $hit_hash     = $_[2];

    my $genome1 = $gene_list->[0];
    my $genes1  = [@{$gene_list}[1..$#{$gene_list}]];
    my $is_bidirectional = 1;

    foreach my $gene_array (@$common_group)
      {
	my $genome2 = $gene_array->[0];
	my $genes2  = [@{$gene_array}[1..$#{$gene_array}]];
	my $forward_hit_exists    = 0;
	my $reciprocal_hit_exists = 0;

	next if($genome1 eq $genome2);

	#See if there is a hit from a paralog in genome 1 to a paralog in
	#genome 2 and if there is a hit from a paralog in genome 2 to a paralog
	#in genome 1
	foreach my $gene1 (@$genes1)
	  {
	    foreach my $gene2 (@$genes2)
	      {
		if(exists($hit_hash->{$genome1}->{$genome2}) &&
		   exists($hit_hash->{$genome1}->{$genome2}
			  ->{$gene1}->{$gene2}))
		  {$forward_hit_exists = 1}
		if(exists($hit_hash->{$genome2}->{$genome1}) &&
		   exists($hit_hash->{$genome2}->{$genome1}
			  ->{$gene2}->{$gene1}))
		  {$reciprocal_hit_exists = 1}
		last if($forward_hit_exists && $reciprocal_hit_exists);
	      }
	    last if($forward_hit_exists && $reciprocal_hit_exists);
	  }
	unless($forward_hit_exists && $reciprocal_hit_exists)
	  {
	    $is_bidirectional = 0;
	    last;
	  }
      }

    return($is_bidirectional);
  }

sub outputGroup
  {
    my $common_group = $_[0];
    my $group_number = $_[1];
    print("Group $group_number\n");
    foreach my $array (@$common_group)
      {print("\t",join("\t",@$array),"\n")}
  }

##
## This subroutine prints a description of the script and it's input and output
## files.
##
sub help
  {
    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Print a description of this program
    print << "end_print";

$script
Copyright 2007
Robert W. Leach
Created on 4/22/2008
Last Modified on $lmd
Center for Computational Research
701 Ellicott Street
Buffalo, NY 14203
rwleach\@ccr.buffalo.edu

* WHAT IS THIS: This script takes a table of blast results generated by
                bidirectional_blast.pl and a series of cutoffs and generates
                sets of "common genes" among all the blasted genomes which all
                hit one another.

* INPUT FORMAT: Generate input files using the standard output from
                bidirectional_blast.pl.  Optionally, an additional column may
                be added to indicate that the association between the two
                sequences was generated by a means other than by directly
                blasting the pair together.  This is to be able to deal with
                fragmentary data from a sequencer.  Each pool of fragments can
                be blasted against a reference set of unique sequences (a
                uniref cluster is recommended) and then fragments that hit the
                same reference sequence can be put on the same line (twice -
                reversing the order on the other to simulate a bidirectional
                pair of hits).  In the last optional column, you can add the
                reference sequence ID that they both hit.  It is also
                recommended that you place the worst blast scores (evalue,
                match length ratio, and percent similarity) of one of the hits
                to the uniref sequence on each line.  You should also only
                blast fragments to uniref that are of a minimum length that
                will ensure a unique hit.  Note that results will be subject to
                an undetermined degree of error introduced by an situation
                where a fragment hits a reference sequence that is not actually
                where the fragment belongs.  If the last column is empty, the
                hit will be assumed to be the result of a direct blast between
                fragments.  Note that this script will prefer a direct blast
                result over an indirect blast result.

* OUTPUT FORMAT: Multi-line formatted output like this:

                   Group 1
                        fasta_file_name1     gene_id1
                        fasta_file_name2     gene_id2     gene_id3
                   ...

                 where each fasta file name represents the genome the gene(s)
                 following it are from.  There will be multiple genes on a line
                 if the genome contains paralogs.

* OUTPUT UNIQUES FORMAT: Each line contains a tab-delimited set of bi-
                         directional paralogous gene ID's.  The number of lines
                         is the number of unique genes.  Example:

                           gene_id1
                           gene_id2     gene_id3
                           ...

                         These output files are only generated if a uniques
                         file suffix is supplied on the command line (-u).
                         The file name will consist of the unique contents of
                         the first column of the input blast table with the
                         appended suffix.  (e.g. -u .unique yields
                         genome1.uniques.)

end_print

    return(0);
  }

##
## This subroutine prints a usage statement in long or short form depending on
## whether "no descriptions" is true.
##
sub usage
  {
    my $no_descriptions = $_[0];

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Grab the first version of each option from the global GetOptHash
    my $options = '[' .
      join('] [',
	   grep {$_ ne '-i'}        #Remove REQUIRED params
	   map {my $key=$_;         #Save the key
		$key=~s/\|.*//;     #Remove other versions
		$key=~s/(\!|=.)$//; #Remove trailing getopt stuff
		$key = (length($key) > 1 ? '--' : '-') . $key;} #Add dashes
	   grep {$_ ne '<>'}        #Remove the no-flag parameters
	   keys(%$GetOptHash)) .
	     ']';

    print << "end_print";
USAGE: $script -i "input file(s)" $options
       $script $options < input_file
end_print

    if($no_descriptions)
      {print("Execute $script with no options to see a description of the ",
             "available parameters.\n")}
    else
      {
        print << 'end_print';

     -i|--input-file*     REQUIRED Space-separated input hit table(s inside
                                   quotes) generated by bidirectional_blast.pl.
                                   *No flag required.  Standard input via
                                   redirection is acceptable.  Perl glob
                                   characters (e.g. '*') are acceptable inside
                                   quotes.
     -e|--evalue-cutoff   OPTIONAL [10**-30] (10**-30 means 10 to the negative
                                   thirtieth).  Cutoff E-Value under which a
                                   blast hit must score to be retained.
                                   Inclusive.
     -l|--length-ratio-   OPTIONAL [0.9] The minimum match length ratio a hit
        cutoff                     must be as compared to the longer gene in
                                   order to be retained.  Inclusive.
     -p|--percent-        OPTIONAL [10] The minimum percent identity a blast
        identity-cutoff            hit must be to be retained.  Inclusive.
     -u|--uniques-suffix  OPTIONAL [nothing] This suffix is added to genome
                                   file names to output files containing all
                                   the unique genes in each genome.  Paralogous
                                   sets are reported on the same line.
     -o|--outfile-suffix  OPTIONAL [nothing] This suffix is added to the input
                                   file names to use as output files.
                                   Redirecting a file into this script will
                                   result in the output file name to be "STDIN"
                                   with your suffix appended.
     -f|--force           OPTIONAL [Off] Force overwrite of existing output
                                   files (generated from previous runs of this
                                   script).  Only used when the -o option is
                                   supplied.
     -v|--verbose         OPTIONAL [Off] Verbose mode.  Cannot be used with the
                                   quiet flag.
     -q|--quiet           OPTIONAL [Off] Quiet mode.  Turns off warnings and
                                   errors.  Cannot be used with the verbose
                                   flag.
     -h|--help            OPTIONAL [Off] Help.  Use this option to see an
                                   explanation of the script and its input and
                                   output files.
     --version            OPTIONAL [Off] Print software version number.  If
                                   verbose mode is on, it also prints the
                                   template version used to standard error.
     --debug              OPTIONAL [Off] Debug mode.

end_print
      }

    return(0);
  }


##
## Subroutine that prints formatted verbose messages.  Specifying a 1 as the
## first argument prints the message in overwrite mode (meaning subsequence
## verbose, error, warning, or debug messages will overwrite the message
## printed here.  However, specifying a hard return as the first character will
## override the status of the last line printed and keep it.  Global variables
## keep track of print length so that previous lines can be cleanly
## overwritten.
##
sub verbose
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 1 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

    #Ignore the overwrite flag if STDOUT will be mixed in
    $overwrite_flag = 0 if(isStandardOutputToTerminal());

    #Read in the message
    my $verbose_message = join('',@_);

    $overwrite_flag = 1 if(!$overwrite_flag && $verbose_message =~ /\r/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\n|\t/)
	  {
	    warning("Hard returns and tabs cause overwrite mode to not work ",
		    "properly.");
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    if(!$overwrite_flag)
      {$verbose_length = 0}
    elsif($verbose_message =~ /\n([^\n]*)$/)
      {$verbose_length = length($1)}
    else
      {$verbose_length = length($verbose_message)}

    #Overwrite the previous verbose message by appending spaces just before the
    #first hard return in the verbose message IF THE VERBOSE MESSAGE DOESN'T
    #BEGIN WITH A HARD RETURN.  However note that the length stored as the
    #last_verbose_size is the length of the last line printed in this message.
    if($verbose_message =~ /^([^\n]*)/ && $main::last_verbose_state &&
       $verbose_message !~ /^\n/)
      {
	my $append = ' ' x ($main::last_verbose_size - length($1));
	unless($verbose_message =~ s/\n/$append\n/)
	  {$verbose_message .= $append}
      }

    #If you don't want to overwrite the last verbose message in a series of
    #overwritten verbose messages, you can begin your verbose message with a
    #hard return.  This tells verbose() to not overwrite the last line that was
    #printed in overwrite mode.

    #Print the message to standard error
    print STDERR ($verbose_message,
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }

sub verboseOverMe
  {verbose(1,@_)}

##
## Subroutine that prints errors with a leading program identifier containing a
## trace route back to main to see where all the subroutine calls were from,
## the line number of each call, an error number, and the name of the script
## which generated the error (in case scripts are called via a system call).
##
sub error
  {
    return(0) if($quiet);

    #Gather and concatenate the error message and split on hard returns
    my @error_message = split("\n",join('',@_));
    pop(@error_message) if($error_message[-1] !~ /\S/);

    $main::error_number++;

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Assign the values from the calling subroutines/main
    my @caller_info = caller(0);
    my $line_num = $caller_info[2];
    my $caller_string = '';
    my $stack_level = 1;
    while(@caller_info = caller($stack_level))
      {
	my $calling_sub = $caller_info[3];
	$calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	$calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	$caller_string .= "$calling_sub(LINE$line_num):"
	  if(defined($line_num));
	$line_num = $caller_info[2];
	$stack_level++;
      }
    $caller_string .= "MAIN(LINE$line_num):";

    my $leader_string = "ERROR$main::error_number:$script:$caller_string ";

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Put location information at the beginning of each line of the message
    foreach my $line (@error_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $error_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that prints warnings with a leader string containing a warning
## number
##
sub warning
  {
    return(0) if($quiet);

    $main::warning_number++;

    #Gather and concatenate the warning message and split on hard returns
    my @warning_message = split("\n",join('',@_));
    pop(@warning_message) if($warning_message[-1] !~ /\S/);

    my $leader_string = "WARNING$main::warning_number: ";

    #Figure out the length of the first line of the error
    my $warning_length = length(($warning_message[0] =~ /\S/ ?
				 $leader_string : '') .
				$warning_message[0]);

    #Put leader string at the beginning of each line of the message
    foreach my $line (@warning_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $warning_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that gets a line of input and accounts for carriage returns that
## many different platforms use instead of hard returns.  Note, it uses a
## global array reference variable ($infile_line_buffer) to keep track of
## buffered lines from multiple file handles.
##
sub getLine
  {
    my $file_handle = $_[0];

    #Set a global array variable if not already set
    $main::infile_line_buffer = {} if(!defined($main::infile_line_buffer));
    if(!exists($main::infile_line_buffer->{$file_handle}))
      {$main::infile_line_buffer->{$file_handle}->{FILE} = []}

    #If this sub was called in array context
    if(wantarray)
      {
	#Check to see if this file handle has anything remaining in its buffer
	#and if so return it with the rest
	if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) > 0)
	  {
	    return(@{$main::infile_line_buffer->{$file_handle}->{FILE}},
		   map
		   {
		     #If carriage returns were substituted and we haven't
		     #already issued a carriage return warning for this file
		     #handle
		     if(s/\r\n|\n\r|\r/\n/g &&
			!exists($main::infile_line_buffer->{$file_handle}
				->{WARNED}))
		       {
			 $main::infile_line_buffer->{$file_handle}->{WARNED}
			   = 1;
			 warning("Carriage returns were found in your file ",
				 "and replaced with hard returns");
		       }
		     split(/(?<=\n)/,$_);
		   } <$file_handle>);
	  }
	
	#Otherwise return everything else
	return(map
	       {
		 #If carriage returns were substituted and we haven't already
		 #issued a carriage return warning for this file handle
		 if(s/\r\n|\n\r|\r/\n/g &&
		    !exists($main::infile_line_buffer->{$file_handle}
			    ->{WARNED}))
		   {
		     $main::infile_line_buffer->{$file_handle}->{WARNED}
		       = 1;
		     warning("Carriage returns were found in your file ",
			     "and replaced with hard returns");
		   }
		 split(/(?<=\n)/,$_);
	       } <$file_handle>);
      }

    #If the file handle's buffer is empty, put more on
    if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) == 0)
      {
	my $line = <$file_handle>;
	if(!eof($file_handle))
	  {
	    if($line =~ s/\r\n|\n\r|\r/\n/g &&
	       !exists($main::infile_line_buffer->{$file_handle}->{WARNED}))
	      {
		$main::infile_line_buffer->{$file_handle}->{WARNED} = 1;
		warning("Carriage returns were found in your file and ",
			"replaced with hard returns");
	      }
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} =
	      split(/(?<=\n)/,$line);
	  }
	else
	  {
	    #Do the \r substitution for the last line of files that have the
	    #eof character at the end of the last line instead of on a line by
	    #itself.  I tested this on a file that was causing errors for the
	    #last line and it works.
	    $line =~ s/\r/\n/g if(defined($line));
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} = ($line);
	  }
      }

    #Shift off and return the first thing in the buffer for this file handle
    return($_ = shift(@{$main::infile_line_buffer->{$file_handle}->{FILE}}));
  }

##
## This subroutine allows the user to print debug messages containing the line
## of code where the debug print came from and a debug number.  Debug prints
## will only be printed (to STDERR) if the debug option is supplied on the
## command line.
##
sub debug
  {
    return(0) unless($DEBUG);

    $main::debug_number++;

    #Gather and concatenate the error message and split on hard returns
    my @debug_message = split("\n",join('',@_));
    pop(@debug_message) if($debug_message[-1] !~ /\S/);

    #Assign the values from the calling subroutine
    #but if called from main, assign the values from main
    my($junk1,$junk2,$line_num,$calling_sub);
    (($junk1,$junk2,$line_num,$calling_sub) = caller(1)) ||
      (($junk1,$junk2,$line_num) = caller());

    #Edit the calling subroutine string
    $calling_sub =~ s/^.*?::(.+)$/$1:/ if(defined($calling_sub));

    my $leader_string = "DEBUG$main::debug_number:LINE$line_num:" .
      (defined($calling_sub) ? $calling_sub : '') .
	' ';

    #Figure out the length of the first line of the error
    my $debug_length = length(($debug_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $debug_message[0]);

    #Put location information at the beginning of each line of the message
    foreach my $line (@debug_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $debug_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## This sub marks the time (which it pushes onto an array) and in scalar
## context returns the time since the last mark by default or supplied mark
## (optional) In array context, the time between all marks is always returned
## regardless of a supplied mark index
## A mark is not made if a mark index is supplied
## Uses a global time_marks array reference
##
sub markTime
  {
    #Record the time
    my $time = time();

    #Set a global array variable if not already set to contain (as the first
    #element) the time the program started (NOTE: "$^T" is a perl variable that
    #contains the start time of the script)
    $main::time_marks = [$^T] if(!defined($main::time_marks));

    #Read in the time mark index or set the default value
    my $mark_index = (defined($_[0]) ? $_[0] : -1);  #Optional Default: -1

    #Error check the time mark index sent in
    if($mark_index > (scalar(@$main::time_marks) - 1))
      {
	error("Supplied time mark index is larger than the size of the ",
	      "time_marks array.\nThe last mark will be set.");
	$mark_index = -1;
      }

    #Calculate the time since the time recorded at the time mark index
    my $time_since_mark = $time - $main::time_marks->[$mark_index];

    #Add the current time to the time marks array
    push(@$main::time_marks,$time)
      if(!defined($_[0]) || scalar(@$main::time_marks) == 0);

    #If called in array context, return time between all marks
    if(wantarray)
      {
	if(scalar(@$main::time_marks) > 1)
	  {return(map {$main::time_marks->[$_ - 1] - $main::time_marks->[$_]}
		  (1..(scalar(@$main::time_marks) - 1)))}
	else
	  {return(())}
      }

    #Return the time since the time recorded at the supplied time mark index
    return($time_since_mark);
  }

##
## This subroutine reconstructs the command entered on the command line
## (excluding standard input and output redirects).  The intended use for this
## subroutine is for when a user wants the output to contain the input command
## parameters in order to keep track of what parameters go with which output
## files.
##
sub getCommand
  {
    my $perl_path_flag = $_[0];
    my($command);

    #Determine the script name
    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Put quotes around any parameters containing un-escaped spaces or astericks
    my $arguments = [@$preserve_args];
    foreach my $arg (@$arguments)
      {if($arg =~ /(?<!\\)[\s\*]/ || $arg eq '')
	 {$arg = "'" . $arg . "'"}}

    #Determine the perl path used (dependent on the `which` unix built-in)
    if($perl_path_flag)
      {
	$command = `which $^X`;
	chomp($command);
	$command .= ' ';
      }

    #Build the original command
    $command .= join(' ',($0,@$arguments));

    #Note, this sub doesn't add any redirected files in or out

    return($command);
  }

##
## This subroutine checks to see if a parameter is a single file with spaces in
## the name before doing a glob (which would break up the single file name
## improperly).  The purpose is to allow the user to enter a single input file
## name using double quotes and un-escaped spaces as is expected to work with
## many programs which accept individual files as opposed to sets of files.  If
## the user wants to enter multiple files, it is assumed that space delimiting
## will prompt the user to realize they need to escape the spaces in the file
## names.
##
sub sglob
  {
    my $command_line_string = $_[0];
    return(-e $command_line_string ?
	   $command_line_string : glob($command_line_string));
  }


sub printVersion
  {
    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;
    print(($verbose ? "$script Version " : ''),
	  $software_version_number,
	  "\n");
    verbose("Generated using perl_script_template.pl\n",
	    "Version $template_version_number\n",
	    "Robert W. Leach\n",
	    "robleach\@lanl.gov\n",
	    "5/8/2006\n",
	    "Los Alamos National Laboratory\n",
	    "Copyright 2006");
    return(0);
  }

#This subroutine is a check to see if input is user-entered via a TTY (result is non-
#zero) or directed in (result is zero)
sub isStandardInputFromTerminal
  {return(-t STDIN || eof(STDIN))}

#This subroutine is a check to see if prints are going to a TTY.  Note, explicit prints
#to STDOUT when another output handle is selected are not considered and may defeat this
#subroutine.
sub isStandardOutputToTerminal
  {return(-t STDOUT && select() eq 'main::STDOUT')}
