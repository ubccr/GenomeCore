#!/usr/bin/perl -w

#Generated using perl_script_template.pl 1.39
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Center for Computational Research
#Copyright 2008

#These variables (in main) are used by getVersion() and usage()
my $software_version_number = '1.1';
my $created_on_date         = '11/9/2009';

##
## Start Main
##

use strict;
use Getopt::Long;

#Declare & initialize variables.  Provide default values here.
my($venn_suffix,$seqs_suffix);
my @common_files        = (); #Array of array of associated 'common' files
                              #Out of a set of sequence files, common files
                              #contain a listing of IDs of sequences that are
                              #considered common among the entire set
my @fna_files           = ();
my @faa_files           = ();
my $current_output_file = '';
my $help                = 0;
my $version             = 0;
my $overwrite           = 0;
my $noheader            = 0;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, getCommand, quit, and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;
my $ignore_errors = 0;

my $GetOptHash =
  {'i|common-files=s'   => sub {push(@common_files,  #REQUIRED
				     [sglob($_[1])])},
   'a|faa-files=s'      => sub {push(@faa_files,     #OPTIONAL [none] Req'd if
				     sglob($_[1]))}, #         -n is supplied
   'n|fna-files=s'      => sub {push(@fna_files,     #OPTIONAL [none]
				     sglob($_[1]))},
   'o|venn-suffix=s'    => \$venn_suffix,         #OPTIONAL [undef]
   's|seqs-suffix=s'    => \$seqs_suffix,            #OPTIONAL [undef]
   'force|overwrite'    => \$overwrite,              #OPTIONAL [Off]
   'ignore'             => \$ignore_errors,          #OPTIONAL [Off]
   'verbose:+'          => \$verbose,                #OPTIONAL [Off]
   'quiet'              => \$quiet,                  #OPTIONAL [Off]
   'debug:+'            => \$DEBUG,                  #OPTIONAL [Off]
   'help|?'             => \$help,                   #OPTIONAL [Off]
   'version'            => \$version,                #OPTIONAL [Off]
   'noheader|no-header' => \$noheader,               #OPTIONAL [Off]
  };

#If there are no arguments and no files directed or piped in
if(scalar(@ARGV) == 0 && isStandardInputFromTerminal())
  {
    usage();
    quit(0);
  }

#Get the input options & catch any errors in option parsing
unless(GetOptions(%$GetOptHash))
  {
    error('Getopt::Long::GetOptions reported an error while parsing the ',
	  'command line arguments.  The error should be above.  Please ',
	  'correct the offending argument(s) and try again.');
    usage(1);
    quit(-1);
  }

#Print the debug mode (it checks the value of the DEBUG global variable)
debug('Debug mode on.') if($DEBUG > 1);

#If the user has asked for help, call the help subroutine
if($help)
  {
    help();
    quit(0);
  }

#If the user has asked for the software version, print it
if($version)
  {
    print(getVersion($verbose),"\n");
    quit(0);
  }

#Check validity of verbosity options
if($quiet && ($verbose || $DEBUG))
  {
    $quiet = 0;
    error('You cannot supply the quiet and (verbose or debug) flags ',
	  'together.');
    quit(-2);
  }

#Put standard input into the common_files array if standard input has been redirected in
if(!isStandardInputFromTerminal())
  {
    #Warn the user that STDIN is ignored
    warning("It appears you've supplied input on standard in.  Directing ",
	    "input into this script is not allowed, since multiple input ",
	    "files (--common-files) are required.");

    #Warn users when they turn on verbose and output is to the terminal
    #(implied by no outfile suffix checked above) that verbose messages may be
    #uncleanly overwritten
    if($verbose && isStandardOutputToTerminal())
      {warning('You have enabled --verbose, but appear to possibly be ',
	       'outputting to the terminal.  Note that verbose messages can ',
	       'interfere with formatting of terminal output making it ',
	       'difficult to read.  You may want to either turn verbose off, ',
	       'redirect output to a file, or supply an outfile suffix (-o).')}
  }

#Make sure there is input
if(scalar(grep {scalar(@$_) < 2} @common_files))
  {
    error('Not enough common files were detected in one or more of the',
	  ' groups.  There must be at least 2 in each group.');
    usage(1);
    quit(-3);
  }

if(defined($venn_suffix) && $venn_suffix eq '')
  {
    error("Invalid --venn-suffix: [$venn_suffix].  ",
	  "It may not be an empty string");
    usage(1);
    quit(-5);
  }
if(defined($seqs_suffix) && $seqs_suffix eq '')
  {
    error("Invalid --seqs-suffix: [$seqs_suffix].  ",
	  "It may not be an empty string");
    usage(1);
    quit(-6);
  }

#Check to make sure previously generated output files won't be over-written
#Note, this does not account for output redirected on the command line
if(!$overwrite && defined($venn_suffix))
  {
    my $existing_outfiles = [];
    foreach my $output_file (map {$_ . $venn_suffix} map {@$_} @common_files)
      {push(@$existing_outfiles,$output_file) if(-e $output_file)}
    if(defined($seqs_suffix) && $seqs_suffix ne '')
      {
	#This will look for some files that will not actually get created, but
	#are not likely to otherwise exist.  I'm doing this because otherwise
	#I'd have to parse the common files to figure out whether an overwrite
	#will occur and instead I want a quick check.
	if(scalar(@faa_files))
	  {
	    foreach my $output_file (map {$_ . $seqs_suffix}
				     map {my $x = $_;
					  map {my $y=$_;$y=~s%[^/]+/%%;"$x.$y"}
					    @faa_files}
				     map {@$_}
				     @common_files)
	      {push(@$existing_outfiles,grep {/\S/} glob("$output_file*"))
		 if(scalar(grep {/\S/} glob("$output_file")))}
	  }
	if(scalar(@fna_files))
	  {
	    foreach my $output_file (map {$_ . $seqs_suffix}
				     map {my $x = $_;
					  map {my $y=$_;$y=~s%[^/]+/%%;"$x.$y"}
					    @fna_files}
				     map {@$_}
				     @common_files)
	      {push(@$existing_outfiles,grep {/\S/} glob("$output_file*"))
		 if(scalar(grep {/\S/} glob("$output_file")))}
	  }
      }

    if(scalar(@$existing_outfiles))
      {
	error("The output files: [@$existing_outfiles] already exist.  ",
	      'Use --overwrite to force an overwrite of existing files.  ',
	      "E.g.:\n",getCommand(1),' --overwrite');
	quit(-4);
      }
  }

verbose('Run conditions: ',getCommand(1));

#If output is going to STDOUT instead of output files with different extensions
#or if STDOUT was redirected, output run info once
verbose('[STDOUT] Opened for all output.') if(!defined($venn_suffix));

#Store info. about the run as a comment at the top of the output file if
#STDOUT has been redirected to a file
if(!isStandardOutputToTerminal() && !$noheader)
  {print('#',getVersion(),"\n",
	 '#',scalar(localtime($^T)),"\n",
	 '#',getCommand(1),"\n");}

my $seq_hash = {};

#Fasta hash->{faa file name}->{FNA|FAA}->{defline} = seq
#ID hash->{faa file name}->{FNA|FAA}->{ID} = defline
my($fasta_hash,$id_hash,$fasta_file_hash) =
  getFastaHash(\@faa_files,\@fna_files);

#For each input file
foreach my $common_file_set (@common_files)
  {
    my $common_hash = {};  #common hash->{common file} = {COUNT => num,
                           #                              SEQS  => {faa file =>
                           #                                        {id => 1}}}
    my $fastas_represented = {};
    foreach my $common_file (@$common_file_set)
      {
	#Open the input file
	if(!open(INPUT,$common_file))
	  {
	    #Report an error and iterate if there was an error
	    error("Unable to open input file: [$common_file].\n$!");
	    next;
	  }
	else
	  {verbose("[$common_file] Opened input file.")}

	my $line_num        = 0;
	my $verbose_freq    = 100;
	my $faa_file_subset = {};

	#For each line in the current input file
	while(getLine(*INPUT))
	  {
	    $line_num++;
	    verboseOverMe("[$common_file] Reading line: [$line_num].")
	      unless($line_num % $verbose_freq);

	    next if(/^\s*#/ || /^\s*$/);

	    if(/^Group \d+$/)
	      {$common_hash->{$common_file}->{COUNT}++}
	    elsif(/^\t([^\t]+)\t *(.*?) *$/)
	      {
		my $filename = $1;
		my @ids = grep {/\S/} split(/ *\t+ */,$2);
		foreach my $id (@ids)
		  {$common_hash->{$common_file}->{SEQS}->{$filename}->{$id} =
		     1}
		if(scalar(@ids) == 0)
		  {error("Unable to parse IDs from line $line_num in file: ",
			 "[$common_file].")}
		else
		  {
		    $faa_file_subset->{$filename} = 1;
		    $fastas_represented->{$filename} = 1;
		  }
	      }
	    else
	      {error("Unable to parse line $line_num in file: ",
		     "[$common_file].")}
	  }

	#Error-check to make sure the fasta files referenced are ones that were
	#supplied
	foreach my $filename (keys(%$faa_file_subset))
	  {
	    #If the file is not among the fasta files
	    if(scalar(grep {my $x = quotemeta($_);$x=~s/.*?([^\/]+)$/$1/;
			    /^$x$/} (@faa_files,@fna_files)) == 0)
	      {error("Fasta file: [$filename] found referenced in the common ",
		     "file: [$common_file] was not supplied via either -a or ",
		     "-n.  These were supplied by -a: [",join(',',@faa_files),
		     "] and these were supplied by -n: [",join(',',@fna_files),
		     "].")}
	    else
	      {
		my @error_ids = ();
		foreach my $id (keys(%{$common_hash->{$common_file}->{SEQS}
					 ->{$filename}}))
		  {
		    if(!exists($id_hash->{$filename}->{FAA}->{$id}))
		      {push(@error_ids,$id)}
		  }
		error("IDs: [",join(',',@error_ids),"] found in common file: ",
		      "[$common_file] for fasta file: [$filename] were not ",
		      "found in the fasta file supplied via -a.")
		  if(scalar(@error_ids));
	      }
	  }

	close(INPUT);

	verbose("[$common_file] Input file done.  Time taken: [",
		scalar(markTime()),' Seconds].');
      }

    #Validate the set of common files submitted before continuing
    my $max_size = scalar(keys(%$fastas_represented));
    my $num_ven_numbers = 1;
    foreach my $size (1..($max_size - 1))
      {$num_ven_numbers +=
	 (factorial($max_size) /
	  (factorial($size)*factorial($max_size - $size)))}
    if(scalar(keys(%$common_hash)) != $num_ven_numbers)
      {
	error("Invalid common file input.  You must submit a set of common ",
	      "files with each -i flag that represents all combinations of ",
	      "fasta files.  There are [$max_size] fasta files: [",
	      join(',',keys(%$fastas_represented)),
	      "] among these common files: [",join(',',keys(%$common_hash)),
	      "], but there should be [$num_ven_numbers] common files.  ",
	      "Skipping this common file set.");
      }
    elsif(scalar(grep {scalar(keys(%{$common_hash->{$_}->{SEQS}})) ==
			 $max_size} keys(%$common_hash)) != 1)
      {
	error("Invalid common file input.  You must submit a set of common ",
	      "files with each -i flag that represents all common IDs among ",
	      "all possible combinations of fasta files.  This includes a ",
	      "single file representing common IDs among all fasta files ",
	      "referenced in the common set e.g. [",
	      join(',',keys(%$fastas_represented)),"].  [",
	      scalar(grep {scalar(keys(%{$common_hash->{$_}->{SEQS}})) ==
			     $max_size} keys(%$common_hash)),
	      "] files were submitted containing all these fasta files ",
	      "referenced.  Skipping this common file set.");
      }

    ##
    ## Here's where all the work is done
    ##

    else
      {
	#Prepare an output file
	my $root_file = (grep {scalar(keys(%{$common_hash->{$_}->{SEQS}})) ==
				 $max_size} keys(%$common_hash))[0];

	#If an output file name suffix has been defined
	if(defined($venn_suffix))
	  {
	    ##
	    ## Open and select the next output file
	    ##

	    #Set the current output file name
	    $current_output_file = $root_file . $venn_suffix;

	    #Open the output file
	    if(!open(OUTPUT,">$current_output_file"))
	      {
		#Report an error and iterate if there was an error
		error("Unable to open output file: [$current_output_file].\n",
		      $!);
		next;
	      }
	    else
	      {verbose("[$current_output_file] Opened output file.")}

	    #Select the output file handle
	    select(OUTPUT);

	    #Store info. about the run as a comment at the top of the output
	    #file
	    print('#',getVersion(),"\n",
		  '#',scalar(localtime($^T)),"\n",
		  '#',getCommand(1),"\n") unless($noheader);
	  }

	#Go through the common files in order of descending number of fasta
	#files they reference
	foreach my $common_file
	  (sort {scalar(keys(%{$common_hash->{$b}->{SEQS}})) <=>
		   scalar(keys(%{$common_hash->{$a}->{SEQS}}))}
	   keys(%$common_hash))
	    {
	      #Figure out how many subtractions will be required (i.e. how many
	      #hashes will need to be looked at) so we can make sure the input
	      #is complete
	      my $num_expected_subtractions =
		getNumSubtractions($max_size - scalar(keys(%{$common_hash
							       ->{$common_file}
								 ->{SEQS}})));

	      #We want to take the count of this file and subtract the counts
	      #of other common files which contain all the fasta files
	      #referenced in this file.  So to make the subset of common files,
	      #we search for other common files that have all the fasta files
	      #that this common file references.  We will assume that each one
	      #found will also contain at least one other referenced fasta file
	      my @commons_to_subtract =
		grep {my $x = $_;
		      #This file is not the one we're testing AND
		      $x ne $common_file &&
			#All the fasta files referenced in this common file
			#are referenced in other common files
			scalar(keys(%{$common_hash->{$common_file}->{SEQS}}))
			  == scalar(grep {exists($common_hash->{$common_file}
						 ->{SEQS}->{$_})}
				    keys(%{$common_hash->{$x}->{SEQS}}))
			} keys(%$common_hash);

	      if(scalar(@commons_to_subtract) != $num_expected_subtractions)
		{
		  error("Expected to find [$num_expected_subtractions] ",
			"common files containing these fasta file ",
			"references: [",
			join(',',keys(%{$common_hash->{$common_file}
					  ->{SEQS}})),
			"] for common file: [$common_file], but found [",
			scalar(@commons_to_subtract),"] files: [",
			join(',',@commons_to_subtract),
			"] instead.  Unable to proceed.");
		}
	      else
		{
		  #This will be the number that goes in the venn:
		  #($common_hash->{$common_file}->{UNIQUE}).
		  #It will represent the number of sequences (all paralogs from
		  #one fasta file are considered a single sequence) that are
		  #common to this combination of fasta files and are not
		  #common in any other combination of fasta files
		  $common_hash->{$common_file}->{UNIQUE} =
		    $common_hash->{$common_file}->{COUNT};
		  foreach my $common_to_subtract (@commons_to_subtract)
		    {
		      unless(exists($common_hash->{$common_to_subtract}
				    ->{UNIQUE}))
			{
			  error("The number of sequences common to only ",
				"common file: [$common_to_subtract] has not ",
				"been calculated yet.  This should not have ",
				"happened.  Files representing more pools of ",
				"sequences should have been processed ",
				"first.  If this one has not been processed, ",
				"then perhaps not all combinations of pools ",
				"are represented in the common files.  ",
				"Please read the --help output and inspect ",
				"your common files to see that they conform ",
				"to the requirements.");
			  next;
			}

		      $common_hash->{$common_file}->{UNIQUE} -=
			$common_hash->{$common_to_subtract}->{UNIQUE};
		    }
		  if($common_hash->{$common_file}->{UNIQUE} < 0)
		    {
		      error("The number of groups in common file ",
			    "[$common_file]: [",
			    $common_hash->{$common_file}->{COUNT},
			    "] must be greater than the sum of the number of ",
			    "groups in these files: [@commons_to_subtract]: [",
			    join(' + ',map {$common_hash->{$_}->{UNIQUE}}
				 @commons_to_subtract),
			    " = ",($common_hash->{$common_file}->{COUNT} -
				   $common_hash->{$common_file}->{UNIQUE}),
			    "], but it's less.  There must be a problem ",
			    "with the way the files were constructed.  It is ",
			    "leading to an invalid result.  For example, the ",
			    "number of sequences common between 2 organisms ",
			    "cannot be less than the number they share in ",
			    "common with a third organism.");
		    }

		  my $outstr = reportVenn($common_hash,
					  $common_file,
					  $fastas_represented);
		  print($outstr);

		  outputSeqs($common_hash,
			     $common_file,
			     \@commons_to_subtract,
			     $fasta_hash,
			     $id_hash,
			     $fasta_file_hash,
			     $seqs_suffix) if(defined($seqs_suffix) &&
					      $seqs_suffix ne ''    &&
					      scalar(@faa_files));
		}
	    }

	#If an output file name suffix is set
	if(defined($venn_suffix))
	  {
	    #Select standard out
	    select(STDOUT);
	    #Close the output file handle
	    close(OUTPUT);

	    verbose("[$current_output_file] Output file done.");
	  }
      }
  }

verbose("[STDOUT] Output done.") if(!defined($venn_suffix));

#Report the number of errors, warnings, and debugs on STDERR
if(!$quiet && ($verbose                     ||
	       $DEBUG                       ||
	       defined($main::error_number) ||
	       defined($main::warning_number)))
  {
    print STDERR ("\n",'Done.  EXIT STATUS: [',
		  'ERRORS: ',
		  ($main::error_number ? $main::error_number : 0),' ',
		  'WARNINGS: ',
		  ($main::warning_number ? $main::warning_number : 0),
		  ($DEBUG ?
		   ' DEBUGS: ' .
		   ($main::debug_number ? $main::debug_number : 0) : ''),' ',
		  'TIME: ',scalar(markTime(0)),"s]\n");

    if($main::error_number || $main::warning_number)
      {print STDERR ("Scroll up to inspect errors and warnings.\n")}
  }

##
## End Main
##






























##
## Subroutines
##

sub outputSeqs
  {
    my $common_hash         = $_[0]; #This contains the ID groupings by sets of
                                     #fasta files
    my $common_file         = $_[1]; #This is the common file name/path
    my $commons_to_subtract = $_[2];
    my $fasta_hash          = $_[3]; #This holds the sequences by defline
                                     #fasta_hash->{faafilename}->{FAA}
                                     #  ->{defline} = protein seq
                                     #fasta_hash->{faafilename}->{FNA}
                                     #  ->{defline} = DNA seq
    my $id_hash             = $_[4]; #This holds the deflines by ID
    my $file_hash           = $_[5]; #This holds the full file paths by name
                                     #file_hash->{faafilename}->{FAA} =
                                     #  faa file path
                                     #file_hash->{faafilename}->{FNA} =
                                     #  fna file path
    my $seqs_suffix         = $_[6];

    my $printed      = {}; #printed->{faafilename}->{FAA|FNA}->{defline} = 0|1
    my $outfile_hash = {}; #outfile_hash->{faafilename}->{NAME}   = file path
                           #outfile_hash->{faafilename}->{HANDLE} = file handle

    #Try to shorten the file names
    my $lookup = {};
    my $hash   = {};
    foreach my $key (keys(%$fasta_hash))
      {
	my $abbrev = '';
	if($key =~ /^([^\.]*)/)
	  {$abbrev = $1}
	if($abbrev eq '' || exists($hash->{$abbrev}))
	  {
	    $hash = {};
	    last;
	  }
	else
	  {$hash->{$abbrev} = $key}
      }
    if(scalar(keys(%$hash)) == 0)
      {
	foreach my $file (keys(%$fasta_hash))
	  {
	    $lookup->{$file}->{FAA} = $file;
	    if(exists($file_hash->{$file}->{FNA}) &&
	       $file_hash->{$file}->{FNA} ne '')
	      {
		my $fna_filename = $file_hash->{$file}->{FNA};
		$fna_filename =~ s/.*\///;
		if($fna_filename eq $file)
		  {$fna_filename .= '.fna'}
		$lookup->{$file}->{FNA} = $fna_filename;
	      }
	  }
      }
    else
      {
	foreach my $abbrev (keys(%$hash))
	  {
	    $lookup->{$hash->{$abbrev}}->{FAA} = "$abbrev.faa";
	    if(exists($file_hash->{$hash->{$abbrev}}->{FNA}) &&
	       $file_hash->{$hash->{$abbrev}}->{FNA} ne '')
	      {$lookup->{$hash->{$abbrev}}->{FNA} = "$abbrev.fna"}
	  }
      }

    ##
    ## Open an faa output file for each pool in the common file
    ##

    foreach my $faa_filename (keys(%{$common_hash->{$common_file}->{SEQS}}))
      {
	debug("FAA OUTFILE: [$common_file.$lookup->{$faa_filename}->{FAA}$seqs_suffix].");

	$outfile_hash->{$faa_filename}->{FAA}->{NAME} =
	  "$common_file.$lookup->{$faa_filename}->{FAA}$seqs_suffix";

	#Open the output file
	if(!open($outfile_hash->{$faa_filename}->{FAA}->{HANDLE},
		 ">$outfile_hash->{$faa_filename}->{FAA}->{NAME}"))
	  {
	    #Report an error and iterate if there was an error
	    error("Unable to open output file: [",
		  $outfile_hash->{$faa_filename}->{FAA}->{NAME},"].\n$!");
	    return(1);
	  }
	else
	  {verbose("[$outfile_hash->{$faa_filename}->{FAA}->{NAME}] Opened",
		   " output file.")}

	#Store info. about the run as a comment at the top of the output
	#file
	print {$outfile_hash->{$faa_filename}->{FAA}->{HANDLE}}
	  ('#',getVersion(),"\n",
	   '#',scalar(localtime($^T)),"\n",
	   '#',getCommand(1),"\n") unless($noheader);

	#If an FNA file was supplied
	if(exists($file_hash->{$faa_filename}->{FNA}) &&
	   $file_hash->{$faa_filename}->{FNA} ne '')
	  {
#	    my $fna_filename = $file_hash->{$faa_filename}->{FNA};
#	    $fna_filename =~ s%[^/]+/%%;
#
	    $outfile_hash->{$faa_filename}->{FNA}->{NAME} =
	      "$common_file.$lookup->{$faa_filename}->{FNA}$seqs_suffix";

	    #Open the output file
	    if(!open($outfile_hash->{$faa_filename}->{FNA}->{HANDLE},
		     ">$outfile_hash->{$faa_filename}->{FNA}->{NAME}"))
	      {
		#Report an error and iterate if there was an error
		error("Unable to open output file: [",
		      $outfile_hash->{$faa_filename}->{FNA}->{NAME},"].\n$!");
		return(1);
	      }
	    else
	      {verbose("[$outfile_hash->{$faa_filename}->{FNA}->{NAME}] ",
		       "Opened output file.")}

	    #Store info. about the run as a comment at the top of the output
	    #file
	    print {$outfile_hash->{$faa_filename}->{FNA}->{HANDLE}}
	      ('#',getVersion(),"\n",
	       '#',scalar(localtime($^T)),"\n",
	       '#',getCommand(1),"\n") unless($noheader);
	  }
      }


    foreach my $faa_filename (keys(%{$common_hash->{$common_file}->{SEQS}}))
      {
	foreach my $id
	  (keys(%{$common_hash->{$common_file}->{SEQS}->{$faa_filename}}))
	    {
	      if(#If the ID does not exist in other common hashes that include
		 #the fasta files referenced in common_file
		 scalar(grep {exists($common_hash->{$_}->{SEQS}
				     ->{$faa_filename}) &&
				       exists($common_hash->{$_}->{SEQS}
					      ->{$faa_filename}->{$id})}
			@$commons_to_subtract) == 0 &&
		 #And this sequence has not already been output
		 (!exists($printed->{$faa_filename}->{FAA}
			  ->{$id_hash->{$faa_filename}->{FAA}->{$id}}) ||
		  !$printed->{$faa_filename}->{FAA}
		  ->{$id_hash->{$faa_filename}->{FAA}->{$id}}))
		{
		  #Print to the relevent file handle: the defline & sequence
		  print {$outfile_hash->{$faa_filename}->{FAA}->{HANDLE}}
		    ($id_hash->{$faa_filename}->{FAA}->{$id},"\n",
		     $fasta_hash->{$faa_filename}->{FAA}
		     ->{$id_hash->{$faa_filename}->{FAA}->{$id}},"\n");

		  #Mark the sequence as printed
		  $printed->{$faa_filename}->{FAA}
		    ->{$id_hash->{$faa_filename}->{FAA}->{$id}} = 1;
		}
	      if(#If an fna file was supplied
		 exists($file_hash->{$faa_filename}->{FNA}) &&
		 $file_hash->{$faa_filename}->{FNA} ne ''   &&
		 #And the ID does not exist in other common hashes that include
		 #the fasta files referenced in common_file
		 scalar(grep {exists($common_hash->{$_}->{SEQS}
				     ->{$faa_filename}) &&
				       exists($common_hash->{$_}->{SEQS}
					      ->{$faa_filename}->{$id})}
			@$commons_to_subtract) == 0 &&
		 #And this sequence has not already been output
		 (!exists($printed->{$faa_filename}->{FNA}
			  ->{$id_hash->{$faa_filename}->{FNA}->{$id}}) ||
		  !$printed->{$faa_filename}->{FNA}
		  ->{$id_hash->{$faa_filename}->{FNA}->{$id}}))
		{
		  #Print to the relevent file handle: the defline & sequence
		  print {$outfile_hash->{$faa_filename}->{FNA}->{HANDLE}}
		    ($id_hash->{$faa_filename}->{FNA}->{$id},"\n",
		     $fasta_hash->{$faa_filename}->{FNA}
		     ->{$id_hash->{$faa_filename}->{FNA}->{$id}},"\n");

		  #Mark the sequence as printed
		  $printed->{$faa_filename}->{FNA}
		    ->{$id_hash->{$faa_filename}->{FNA}->{$id}} = 1;
		}
	    }
      }

    foreach my $faa_filename (keys(%{$outfile_hash}))
      {
	close($outfile_hash->{$faa_filename}->{FAA}->{HANDLE});
	close($outfile_hash->{$faa_filename}->{FNA}->{HANDLE})
	  if(exists($outfile_hash->{$faa_filename}->{FNA}));
      }
  }

sub reportVenn
  {
    my $common_hash        = $_[0];
    my $common_file        = $_[1];
    my $fastas_represented = $_[2];

    #Try to shorten the file names
    my $lookup = {};
    my $hash   = {};
    foreach my $key (keys(%$fastas_represented))
      {
	my $abbrev = '';
	if($key =~ /^([^\.]*)/)
	  {$abbrev = $1}
	if($abbrev eq '' || exists($hash->{$abbrev}))
	  {
	    $hash = {};
	    last;
	  }
	else
	  {$hash->{$abbrev} = $key}
      }
    if(scalar(keys(%$hash)) == 0)
      {foreach my $file (keys(%$fastas_represented))
	 {$lookup->{$file} = $file}}
    else
      {foreach my $abbrev (keys(%$hash))
	 {$lookup->{$hash->{$abbrev}} = $abbrev}}

    return(join("\t",
		map {$lookup->{$_}}
		sort {$a cmp $b}
		keys(%{$common_hash->{$common_file}->{SEQS}})) .
	   "\t$common_hash->{$common_file}->{UNIQUE}\n");
  }

sub getNumSubtractions
  {
    my $n = $_[0];
    my $sum = 1;
    if($n == 0)
      {return(0)}
    elsif($n < 0)
      {
	error("Invalid input: [$n].  Must be a positive integer.");
	return(0);
      }

    my $n_fact = factorial($n);

    foreach my $r (1..($n - 1))
      {$sum += $n_fact / (factorial($r) * factorial($n - $r))}

    return($sum);
  }

sub factorial
  {
    my $x = $_[0];
    my $a = 1;
    map {$a *= $_} (2..abs($x));
    return($a);
  }

sub getFastaHash
  {
    my $faa_files  = $_[0];
    my $fna_files  = $_[1];
    my $fasta_hash = {};
    my $id_hash    = {};
    my $file_hash  = {};
    my $cnt        = 0;

    if(scalar(@$fna_files) && scalar(@$fna_files) != scalar(@$faa_files))
      {
	error("The number of faa files: [",scalar(@$faa_files),
	      "] must be the same as the number of fna files: [",
	      scalar(@$fna_files),"].  Unable to proceed.");
	return($fasta_hash,$id_hash);
      }

    foreach my $faa_file (@$faa_files)
      {
	if($faa_file =~ m%([^/]+)$%)
	  {
	    my $name = $1;
	    $file_hash->{$name}->{FAA} = $faa_file;
	    my($rec);
	    if(exists($fasta_hash->{$name}))
	      {
		error("File name in file: [$faa_file] must be unique (even ",
		      "with different paths).  Duplicate name found.  ",
		      "Skipping this file.");
	      }
	    else
	      {
		#Open the input file
		if(!open(INPUT,$faa_file))
		  {
		    #Report an error and iterate if there was an error
		    error("Unable to open input file: [$faa_file].\n$!");
		    next;
		  }
		else
		  {verbose("[$faa_file] Opened input file.")}

		my $cnt = 1;
		#For each line in the current input file
		while($rec = getNextFastaRec(*INPUT))
		  {
		    verboseOverMe("Read Sequence ",$cnt++);
		    unless(scalar(@$rec))
		      {
			error("Empty record encountered in file: ",
			      "[$faa_file].");
			next;
		      }

		    $fasta_hash->{$name}->{FAA}->{$rec->[0]} = $rec->[1];
		    while($rec->[0] =~ /[>\|]\s*(\S+)/g)
		      {$id_hash->{$name}->{FAA}->{$1} = $rec->[0]}
		  }

		close(INPUT);

		verbose("[$faa_file] Input file done.  Time taken: [",
			scalar(markTime()),' Seconds].');
	      }

	    if(scalar(@fna_files))
	      {
		my $fna_file = $fna_files->[$cnt];
		$file_hash->{$name}->{FNA} = $fna_file;
		$cnt++;

		#Open the input file
		if(!open(INPUT,$fna_file))
		  {
		    #Report an error and iterate if there was an error
		    error("Unable to open input file: [$fna_file].\n$!");
		    next;
		  }
		else
		  {verbose("[$fna_file] Opened input file.")}

		my(@missing);
		my $cnt = 0;
		#For each line in the current input file
		while($rec = getNextFastaRec(*INPUT))
		  {
		    verboseOverMe("Read Sequence ",++$cnt);
		    unless(scalar(@$rec))
		      {
			error("Empty record encountered in file: ",
			      "[$fna_file].");
			next;
		      }

		    $fasta_hash->{$name}->{FNA}->{$rec->[0]} = $rec->[1];
		    while($rec->[0] =~ /[>\|]\s*(\S+)/g)
		      {
			$id_hash->{$name}->{FNA}->{$1} = $rec->[0];
			if(!exists($id_hash->{$name}->{FAA}->{$1}))
			  {
			    push(@missing,$1);
#			    $id_hash->{$name}->{FAA}->{$1} = '';
			  }
		      }
		  }

		close(INPUT);

		if(scalar(@missing) == $cnt)
		  {
		    error("None of the IDs in fna file: [$fna_file] were ",
			  "found in the corresponding faa file: ",
			  "[$faa_file].");
		    debug("IDs in FNA file [$fna_file]: [",
			  join(',',keys(%{$id_hash->{$name}->{FNA}})),
			  "].\nIDs in FAA file [$faa_file]: [",
			  join(',',keys(%{$id_hash->{$name}->{FAA}})),"].");
		  }
		elsif(scalar(@missing))
		  {
		    warning("[",scalar(@missing),"] out of [",
			    scalar(keys(%{$id_hash->{$name}->{FNA}})),
			    "] IDs in fna file: ",
			    "[$fna_file] were not found in the corresponding ",
			    "faa file: [$faa_file] which contains [",
			    scalar(keys(%{$id_hash->{$name}->{FAA}})),
			    "] IDs.  This is OK if you did ",
			    "not retain IDs upon reduction.");
		    debug("IDs: [",join(',',@missing),"] in fna file: ",
			 "[$fna_file] were not found in the corresponding ",
			 "faa file: [$faa_file].\n",
			  "IDs in FNA file [$fna_file]: [",
			  join(',',keys(%{$id_hash->{$name}->{FNA}})),
			  "].\nIDs in FAA file [$faa_file]: [",
			  join(',',keys(%{$id_hash->{$name}->{FAA}})),"].");
		  }

		@missing = ();
		foreach my $id (keys(%{$id_hash->{$name}->{FAA}}))
		  {if(!exists($id_hash->{$name}->{FNA}->{$id}))
		     {push(@missing,$id)}}
		if(scalar(@missing))
		  {error("IDs: [",join(',',@missing),"] in faa file: ",
			 "[$faa_file] were not found in the corresponding ",
			 "fna file: [$fna_file].")}

		verbose("[$fna_file] Input file done.  Time taken: [",
			scalar(markTime()),' Seconds].');
	      }
	  }
	else
	  {error("Unable to parse faa file name: [$faa_file].  Skipping.")}
      }

    return($fasta_hash,$id_hash,$file_hash);
  }

#Copied from fetch_cog.pl.pl on 8/6/2008 -Rob
sub getNextFastaRec
  {
#    my $self       = shift(@_);
    my $handle    = $_[0];      #File handle or file name
    my $no_format = $_[1];

    if(exists($main::{FASTABUFFER}) && exists($main::{FASTABUFFER}->{$handle}))
      {
	if(scalar(@{$main::{FASTABUFFER}->{$handle}}) > 0)
	  {
	    if(wantarray)
	      {
		my @array = (@{$main::{FASTABUFFER}->{$handle}});
		@{$main::{FASTABUFFER}->{$handle}} = ();
		return(@array);
	      }
	    return(shift(@{$main::{FASTABUFFER}->{$handle}}));
	  }
	elsif(eof($handle))
	  {return(undef)}
      }

    my $parent_id_check = {};
    my $first_loop = 0;
    my $line_num = 0;
    my $line     = '';
    my $defline  = '';
    my($seq);

    #For each line in the current input file
    while(getLine($handle))
      {
	$line_num = $.;
	$line = $_;

	next if($line !~ /\S/ || $line =~ /^\s*#/);
	if($line =~ />/)
	  {
	    if($defline)
	      {
		my $solidseq =
		  ($no_format ? $seq :
		   formatSequence($seq));
		chomp($solidseq);
		chomp($defline);

		push(@{$main::{FASTABUFFER}->{$handle}},[$defline,$solidseq]);
	      }
	    $defline = $line;

	    my $tmp_id = $defline;
	    $tmp_id =~ s/^\s*>\s*//;
	    $tmp_id =~ s/\s.*//;
	    if($tmp_id eq '')
	      {warning("No Defline ID on line: [$line_num] of current file.  ",
		       " Universal coordinates will be used if some were ",
		       "supplied either via command line arguments of via ",
		       "coordinate file with no parent sequence ID.")}
	    elsif(exists($parent_id_check->{$tmp_id}))
	      {
		error("Two sequences found with the same ID on the ",
		      "defline: [$tmp_id] in current fasta file.  The same ",
		      "pairs of coordinates will be used for each sequence.");
	      }

	    undef($seq);
	  }
	elsif($line =~ /^([^\t]+?) *\t\s*(.*)/)
	  {
	    $defline = $1;
	    $seq     = $2;

	    my $solidseq =
	      ($no_format ? $seq :
	       formatSequence($seq));
	    chomp($solidseq);
	    chomp($defline);

	    push(@{$main::{FASTABUFFER}->{$handle}},[$defline,$solidseq]);

	    undef($seq);
	  }
	else
	  {$seq .= $line}
      }

    #Handle the last sequence (if there were any sequences)
    if(defined($seq))
      {
	my $solidseq =
	  ($no_format ? $seq :
	   formatSequence($seq));
	chomp($solidseq);
	chomp($defline);

	push(@{$main::{FASTABUFFER}->{$handle}},[$defline,$solidseq]);
      }

    #Return the first sequence (if sequence was parsed)
    if(exists($main::{FASTABUFFER}) && exists($main::{FASTABUFFER}->{$handle}))
      {
	if(scalar(@{$main::{FASTABUFFER}->{$handle}}) > 0)
	  {
	    if(wantarray)
	      {
		my @array = (@{$main::{FASTABUFFER}->{$handle}});
		@{$main::{FASTABUFFER}->{$handle}} = ();
		return(@array);
	      }
	    return(shift(@{$main::{FASTABUFFER}->{$handle}}));
	  }
	else
	  {return(undef)}
      }
    else
      {return(undef)}
  }

#Copied from uniqueSeq.pl on11/3/2009 so as to be independent -Rob
sub formatSequence
  {
    #1. Read in the parameters.
    my $sequence          = $_[0];
    my $chars_per_line    = $_[1];
    my $coords_left_flag  = $_[2];
    my $coords_right_flag = $_[3];
    my $start_coord       = $_[4];
    my $coords_asc_flag   = $_[5];
    my $coord_upr_bound   = $_[6];
    my $uppercase_flag    = $_[7];
    my $print_flag        = $_[8];
    my $nucleotide_flag   = $_[9];

    my($formatted_sequence,
       $sub_string,
       $sub_sequence,
       $coord,
       $max_num_coord_digits,
       $line_size_left,
       $lead_spaces,
       $line);
    my $coord_separator = '  ';
    my $tmp_sequence = $sequence;
    $tmp_sequence =~ s/\s+//g;
    $tmp_sequence =~ s/<[^>]*>//g;
    my $seq_len = length($tmp_sequence);

    #2. Error check the parameters and set default values if unsupplied.
    my $default_chars_per_line    = ''; #Infinity
    my $default_coords_left_flag  = 0;
    my $default_coords_right_flag = 0;
    my $default_start_coord       = (!defined($coords_asc_flag) ||
				     $coords_asc_flag ? 1 : $seq_len);
    my $default_coords_asc_flag   = 1;
    my $default_coord_upr_bound   = undef();  #infinity (going past 1 produces
    my $default_uppercase_flag    = undef();  #          negative numbers)
    my $default_print_flag        = 0;

    if(!defined($chars_per_line) || $chars_per_line !~ /^\d+$/)
      {
        if(defined($chars_per_line) &&
	   $chars_per_line !~ /^\d+$/ && $chars_per_line =~ /./)
	  {print("WARNING:seq-lib.pl:formatSequence: Invalid ",
	         "chars_per_line: [$chars_per_line] - using default: ",
		 "[$default_chars_per_line]<BR>\n")}
        #end if(chars_per_line !~ /^\d+$/)
	$chars_per_line = $default_chars_per_line;
      }
    elsif(!$chars_per_line)
      {$chars_per_line = ''}
    #end if(!defined($chars_per_line) || $chars_per_line !~ /^\d+$/)
    if(!defined($coords_left_flag))
      {$coords_left_flag = $default_coords_left_flag}
    #end if(!defined(coords_left_flag))
    if(!defined($coords_right_flag))
      {$coords_right_flag = $default_coords_right_flag}
    #end if(!defined(coords_right_flag))
    if(!defined($start_coord) || $start_coord !~ /^\-?\d+$/)
      {
        if(defined($start_coord) &&
           ($coords_left_flag || $coords_right_flag))
          {print("WARNING:formatSequence.pl:formatSequence: Invalid ",
                 "start_coord: [$start_coord] - using default: ",
                 "[$default_start_coord]\n")}
        #end if($start_coord !~ /^\d+$/)
        $start_coord = $default_start_coord;
      }
    #end if(!defined($start_coord) || $start_coord !~ /^\d+$/)
    if(!defined($coords_asc_flag))
      {$coords_asc_flag = $default_coords_asc_flag}
    #end if(!defined(coords_right_flag))
    if(defined($coord_upr_bound) && $coord_upr_bound !~ /^\d+$/)
      {undef($coord_upr_bound)}
    if(!defined($print_flag))
      {$print_flag = $default_print_flag}
    #end if(!defined($print_flag))

    if(defined($coord_upr_bound) && $start_coord < 1)
      {$start_coord = $coord_upr_bound + $start_coord}
    elsif($start_coord < 1)
      {$start_coord--}
    elsif(defined($coord_upr_bound) && $start_coord > $coord_upr_bound)
      {$start_coord -= $coord_upr_bound}

    #3. Initialize the variables used for formatting.  (See the DATASTRUCTURES
    #   section.)
    if($coords_asc_flag)
      {
        if(defined($coord_upr_bound) &&
           ($seq_len + $start_coord) > $coord_upr_bound)
          {$max_num_coord_digits = length($coord_upr_bound)}
        else
          {$max_num_coord_digits = length($seq_len + $start_coord - 1)}

        $coord = $start_coord - 1;
      }
    else
      {
        if(defined($coord_upr_bound) && ($start_coord - $seq_len + 1) < 1)
          {$max_num_coord_digits = length($coord_upr_bound)}
        elsif(!defined($coord_upr_bound) &&
              length($start_coord - $seq_len - 1) > length($start_coord))
          {$max_num_coord_digits = length($start_coord - $seq_len - 1)}
        else
          {$max_num_coord_digits = length($start_coord)}

        $coord = $start_coord + 1;
      }
    $line_size_left = $chars_per_line;
    $lead_spaces    = $max_num_coord_digits - length($start_coord);

    #5. Add the first coordinate with spacing if coords_left_flag is true.
    $line = ' ' x $lead_spaces . $start_coord . $coord_separator
      if($coords_left_flag);

    #6. Foreach sub_string in the sequence where sub_string is either a
    #   sub_sequence or an HTML tag.
    foreach $sub_string (split(/(?=<)|(?<=>)/,$sequence))
      {
        #6.1 If the substring is an HTML tag
        if($sub_string =~ /^</)
          #6.1.1 Add it to the current line of the formatted_sequence
          {$line .= $sub_string}
        #end if(sub_string =~ /^</)
        #6.2 Else
        else
          {
            $sub_string =~ s/\s+//g;

	    if($nucleotide_flag)
	      {
		my(@errors);
		(@errors) = ($sub_string =~ /([^ATGCBDHVRYKMSWNX])/ig);
		$sub_string =~ s/([^ATGCBDHVRYKMSWNX])//ig;
		if(scalar(@errors))
		  {print STDERR ("WARNING:formatSequence.pl:formatSequence:",
				 scalar(@errors),
				 " bad nucleotide characters were ",
				 "filtered out of your sequence: [",
				 join('',@errors),
				 "].\n")}
	      }

            #6.2.1 If the sequence is to be uppercased
            if(defined($uppercase_flag) && $uppercase_flag)
              #6.2.1.1 Uppercase the sub-string
              {$sub_string = uc($sub_string)}
            #end if(defined($uppercase_flag) && $uppercase_flag)
            #6.2.2 Else if the sequence is to be lowercased
            elsif(defined($uppercase_flag) && !$uppercase_flag)
              #6.2.2.1 Lowercase the sub-string
              {$sub_string = lc($sub_string)}
            #end elsif(defined($uppercase_flag) && !$uppercase_flag)

            #6.2.3 While we can grab enough sequence to fill the rest of a line
            while($sub_string =~ /(.{1,$line_size_left})/g)
              {
                $sub_sequence = $1;
                #6.2.3.1 Add the grabbed sequence to the current line of the
                #        formatted sequence
                $line .= $sub_sequence;
                #6.2.3.2 Increment the current coord by the amount of sequence
                #        grabbed
                my $prev_coord = $coord;
                if($coords_asc_flag)
                  {
                    $coord += length($sub_sequence);
                    if(defined($coord_upr_bound)      &&
                       $prev_coord <= $coord_upr_bound &&
                       $coord > $coord_upr_bound)
                      {$coord -= $coord_upr_bound}
                  }
                else
                  {
                    $coord -= length($sub_sequence);
                    if(defined($coord_upr_bound) &&
                       $prev_coord >= 1 && $coord < 1)
                      {$coord = $coord_upr_bound + $coord - 1}
                    elsif($prev_coord >= 1 && $coord < 1)
                      {$coord--}
                  }
                #6.2.3.3 If the length of the current sequence grabbed
                #        completes a line
                if($line_size_left eq '' ||
		   length($sub_sequence) == $line_size_left)
                  {
                    $lead_spaces = $max_num_coord_digits - length($coord);
                    #6.2.3.3.1 Conditionally add coordinates based on the
                    #          coords flags
                    $line .= $coord_separator . ' ' x $lead_spaces . $coord
                      if($coords_right_flag);

                    #6.2.3.3.2 Add a hard return to the current line of the
                    #          formatted sequence
                    $line .= "\n";

                    #6.2.3.3.3 Add the current line to the formatted_sequence
                    $formatted_sequence .= $line;
                    #6.2.3.3.4 Print the current line if the print_flag is true
                    print $line if($print_flag);

                    #6.2.3.3.5 Start the next line
                    $lead_spaces = $max_num_coord_digits - length($coord+1);
                    $line = '';
                    $line = ' ' x $lead_spaces
                          . ($coords_asc_flag ? ($coord+1) : ($coord-1))
                          . $coord_separator
                      if($coords_left_flag);

                    #6.2.3.3.6 Reset the line_size_left (length of remaining
                    #          sequence per line) to chars_per_line
                    $line_size_left = $chars_per_line;
                  }
                #end if(length($sub_sequence) == $line_size_left)
                #6.2.3.4 Else
                else
                  #6.2.3.4.1 Decrement line_size_left (length of remaining
                  #          sequence per line) by the amount of sequence
                  #          grabbed
                  {$line_size_left -= length($sub_sequence)}
                #end 6.2.3.4 Else
              }
            #end while($sub_string =~ /(.{1,$line_size_left})/g)
          }
        #end 6.2 Else
      }
    #end foreach $sub_string (split(/(?=<)|(?<=>)/,$sequence))
    #7. Add the last coodinate with enough leadin white-space to be lined up
    #   with the rest coordinates if the coords_right_flag is true
    $lead_spaces = $max_num_coord_digits - length($coord);
    $line .= ' ' x $line_size_left . $coord_separator . ' ' x $lead_spaces
          . $coord
      if($coords_right_flag && $line_size_left != $chars_per_line);
    $line =~ s/^\s*\d+$coord_separator\s*$// if($coords_left_flag);

    #8. Add the ending PRE tag to the last line of the formatted sequence
    $line =~ s/\n+$/\n/s;

    #9. Add the last line to the formatted_sequence
    $formatted_sequence .= $line;
    #10. Print the last line if the print_flag is true
    print "$line\n" if($print_flag);

    if($coord < 1 && ($coords_left_flag || $coords_right_flag))
      {print("WARNING: The sequence straddles the origin.  Coordinates are ",
             "inaccurate.")}

    #11. Return the formatted_sequence
    return $formatted_sequence;
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

    #$software_version_number  - global
    #$created_on_date          - global
    $created_on_date = 'UNKNOWN' if($created_on_date eq 'DATE HERE');

    #Print a description of this program
    print << "end_print";

$script version $software_version_number
Copyright 2008
Robert W. Leach
Created: $created_on_date
Last Modified: $lmd
Center for Computational Research
701 Ellicott Street
Buffalo, NY 14203
rwleach\@ccr.buffalo.edu

* WHAT IS THIS: This script takes a set of files containing bidirectional blast
                hits of sequences (e.g. genes) produced by (first blasting
                sequences from different pools [e.g. genomes] against one
                another and then filtering them using)
                bidirectional_hit_filter.pl.  The input files represent all the
                sequences common between all possible combinations of pools, so
                the number of files input must be equal to the number of
                combinations possible for all pools of sequences.  The output
                is the numbers that populate a Venn diagram (of any number of
                dimensions).  The script will optionally output the protein
                (and additionally DNA) sequences representing each portion of
                the venn.  Note that, as a limitation of this script, a protein
                file MUST be supplied if DNA files are desired.

* COMMON INPUT FORMAT: The common files produced by bidirectional_hit_filter.pl
                       can be used as input for this script.  There should be a
                       file for all possible combinations of pools (e.g.
                       genomes).  So if there are 3 genomes in the desired venn
                       diagram, 7 files must be submitted (e.g. for genomes a,
                       b, & c, you'd have a file for each of these
                       combinations: 1. a,b,c; 2. a,b; 3. a,c; 4. b,c; 5. a;
                       6. b; 7. c).  This includes files of each pool blasted
                       against itself containing all unique and paralogous
                       sequences.  The format of the file is a tabbed outline
                       format where the base of the outline is a series of
                       labeled groups of bidirectional sequence IDs between all
                       pools in the combination.  The number of lines under a
                       labeled group represent the number of pools that are
                       compared to one another.  Those lines start with the
                       protein file name that was used in the blast followed by
                       (tab) a series of IDs from that file that represent the
                       paralogs from that pool that bidirectionally hit
                       sequences from the other pools.  Here is an example:

                       Group 1
                       	cc30_endo.faa.reduced	contig03141.3
                       	cc30_bone_joint.faa.reduced	contig02311.4
                       Group 2
                       	cc30_endo.faa.reduced	contig01292.5
                       	cc30_bone_joint.faa.reduced	contig01327.2
                       Group 3
                       	cc30_endo.faa.reduced	contig01084.6
                       	cc30_bone_joint.faa.reduced	contig01746.2

* FAA FORMAT: Fasta protein file where the sequence ID is the first string on
              the defline followed by white space or the end of the line.  The
              file names must be unique regardless of paths and they must match
              the file names in the common files.  See COMMON INPUT FORMAT.

* FNA FORMAT: Fasta DNA file where the sequence ID is the first string on the
              defline followed by white space or the end of the line.  The
              order and number of FAA files submitted must correspond to the
              order and number of FAA files submitted.

* OUTPUT VENN FORMAT: The output will be tab-delimited and will contain the
                      names of the protein sequence files followed by the
                      number of sequences common between the listed pools (e.g.
                      genomes).  Note this is only the number which are not
                      common with any other pools.  The protein sequence files
                      and the trailing number are all tab delimited.  The
                      sequence file may be shortened up to the first dot (.) if
                      it uniquely identifies that sequence file.  Note, the
                      file paths will not be output.  If the --venn-suffix is
                      supplied, it will be appended to the root file in each
                      group of common files.  The root file is the one
                      containing references to all the FAA files in that group.
                      Note, this is a subset of all the FAA files submitted.

* OUTPUT SEQS FORMAT: Fasta format.  Each common file will get the
                      --seqs-suffix appended to it, but it will contain the
                      venn sequences, which is a subset of the common sequences
                      represented in the common file the suffix is appended to.

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
	   grep {$_ ne '-i'}           #Remove REQUIRED params
	   map {my $key=$_;            #Save the key
		$key=~s/\|.*//;        #Remove other versions
		$key=~s/(\!|=.|:.)$//; #Remove trailing getopt stuff
		$key = (length($key) > 1 ? '--' : '-') . $key;} #Add dashes
	   grep {$_ ne '<>'}           #Remove the no-flag parameters
	   keys(%$GetOptHash)) .
	     ']';

    print << "end_print";
USAGE: $script -i "input file(s)" $options
       $script $options < common_file
end_print

    if($no_descriptions)
      {print("`$script` for expanded usage.\n")}
    else
      {
        print << 'end_print';

     -i|--input-file*     REQUIRED Space-separated input file(s inside quotes).
                                   Standard input via redirection is
                                   acceptable.  Perl glob characters (e.g. '*')
                                   are acceptable inside quotes (e.g.
                                   -i "*.txt *.text").  See --help for a
                                   description of the input file format.
                                   *No flag required.
     -o|--outfile-suffix  OPTIONAL [nothing] This suffix is added to the input
                                   file names to use as output files.  See
                                   --help for a description of the output file
                                   format.
     --force|--overwrite  OPTIONAL Force overwrite of existing output files.
                                   Only used when the -o option is supplied.
     --ignore             OPTIONAL Ignore critical errors & continue
                                   processing.  (Errors will still be
                                   reported.)  See --force to not exit when
                                   existing output files are found.
     --verbose            OPTIONAL Verbose mode.  Cannot be used with the quiet
                                   flag.  Verbosity level can be increased by
                                   supplying a number (e.g. --verbose 2) or by
                                   supplying the --verbose flag multiple times.
     --quiet              OPTIONAL Quiet mode.  Suppresses warnings and errors.
                                   Cannot be used with the verbose or debug
                                   flags.
     --help|-?            OPTIONAL Help.  Print an explanation of the script
                                   and its input/output files.
     --version            OPTIONAL Print software version number.  If verbose
                                   mode is on, it also prints the template
                                   version used to standard error.
     --debug              OPTIONAL Debug mode.  Adds debug output to STDERR and
                                   prepends trace information to warning and
                                   error messages.  Cannot be used with the
                                   --quiet flag.  Debug level can be increased
                                   by supplying a number (e.g. --debug 2) or by
                                   supplying the --debug flag multiple times.
     --noheader           OPTIONAL Suppress commented header output.  Without
                                   this option, the script version, date/time,
                                   and command-line information will be printed
                                   at the top of all output files commented
                                   with '#' characters.

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

#    #Ignore the overwrite flag if STDOUT will be mixed in
#    $overwrite_flag = 0 if(isStandardOutputToTerminal());

    #Read in the message
    my $verbose_message = join('',grep {defined($_)} @_);

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
	    warning('Hard returns and tabs cause overwrite mode to not work ',
		    'properly.');
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    #If this message is not going to be over-written (i.e. we will be printing
    #a \n after this verbose message), we can reset verbose_length to 0 which
    #will cause $main::last_verbose_size to be 0 the next time this is called
    if(!$overwrite_flag)
      {$verbose_length = 0}
    #If there were \r's in the verbose message submitted (after the last \n)
    #Calculate the verbose length as the largest \r-split string
    elsif($verbose_message =~ /\r[^\n]*$/)
      {
	my $tmp_message = $verbose_message;
	$tmp_message =~ s/.*\n//;
	($verbose_length) = sort {length($b) <=> length($a)}
	  split(/\r/,$tmp_message);
      }
    #Otherwise, the verbose_length is the size of the string after the last \n
    elsif($verbose_message =~ /([^\n]*)$/)
      {$verbose_length = length($1)}

    #If the buffer is not being flushed, the verbose output doesn't start with
    #a \n, and output is to the terminal, make sure we don't over-write any
    #STDOUT output
    #NOTE: This will not clean up verbose output over which STDOUT was written.
    #It will only ensure verbose output does not over-write STDOUT output
    #NOTE: This will also break up STDOUT output that would otherwise be on one
    #line, but it's better than over-writing STDOUT output.  If STDOUT is going
    #to the terminal, it's best to turn verbose off.
    if(!$| && $verbose_message !~ /^\n/ && isStandardOutputToTerminal())
      {
	#The number of characters since the last flush (i.e. since the last \n)
	#is the current cursor position minus the cursor position after the
	#last flush (thwarted if user prints \r's in STDOUT)
	#NOTE:
	#  tell(STDOUT) = current cursor position
	#  sysseek(STDOUT,0,1) = cursor position after last flush (or undef)
	my $num_chars = sysseek(STDOUT,0,1);
	if(defined($num_chars))
	  {$num_chars = tell(STDOUT) - $num_chars}
	else
	  {$num_chars = 0}

	#If there have been characters printed since the last \n, prepend a \n
	#to the verbose message so that we do not over-write the user's STDOUT
	#output
	if($num_chars > 0)
	  {$verbose_message = "\n$verbose_message"}
      }

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
    my @error_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@error_message,'') unless(scalar(@error_message));
    pop(@error_message) if(scalar(@error_message) > 1 &&
			   $error_message[-1] !~ /\S/);

    $main::error_number++;
    my $leader_string = "ERROR$main::error_number:";

    #Assign the values from the calling subroutines/main
    my(@caller_info,$line_num,$caller_string,$stack_level,$script);
    if($DEBUG)
      {
	$script = $0;
	$script =~ s/^.*\/([^\/]+)$/$1/;
	@caller_info = caller(0);
	$line_num = $caller_info[2];
	$caller_string = '';
	$stack_level = 1;
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
	$leader_string .= "$script:$caller_string";
      }

    $leader_string .= ' ';

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Put location information at the beginning of the first line of the message
    #and indent each subsequent line by the length of the leader string
    print STDERR ($leader_string,
		  shift(@error_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $error_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@error_message)
      {print STDERR (' ' x $leader_length,
		     $line,
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size  = 0;
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
    my @warning_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@warning_message,'') unless(scalar(@warning_message));
    pop(@warning_message) if(scalar(@warning_message) > 1 &&
			     $warning_message[-1] !~ /\S/);

    my $leader_string = "WARNING$main::warning_number:";

    #Assign the values from the calling subroutines/main
    my(@caller_info,$line_num,$caller_string,$stack_level,$script);
    if($DEBUG)
      {
	$script = $0;
	$script =~ s/^.*\/([^\/]+)$/$1/;
	@caller_info = caller(0);
	$line_num = $caller_info[2];
	$caller_string = '';
	$stack_level = 1;
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
	$leader_string .= "$script:$caller_string";
      }

    $leader_string .= ' ';

    #Figure out the length of the first line of the error
    my $warning_length = length(($warning_message[0] =~ /\S/ ?
				 $leader_string : '') .
				$warning_message[0]);

    #Put leader string at the beginning of each line of the message
    #and indent each subsequent line by the length of the leader string
    print STDERR ($leader_string,
		  shift(@warning_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $warning_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@warning_message)
      {print STDERR (' ' x $leader_length,
		     $line,
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size  = 0;
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
			 warning('Carriage returns were found in your file ',
				 'and replaced with hard returns.');
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
		     warning('Carriage returns were found in your file ',
			     'and replaced with hard returns.');
		   }
		 split(/(?<=\n)/,$_);
	       } <$file_handle>);
      }

    #If the file handle's buffer is empty, put more on
    if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) == 0)
      {
	my $line = <$file_handle>;
	#The following is to deal with files that have the eof character at the
	#end of the last line.  I may not have it completely right yet.
	if(defined($line))
	  {
	    if($line =~ s/\r\n|\n\r|\r/\n/g &&
	       !exists($main::infile_line_buffer->{$file_handle}->{WARNED}))
	      {
		$main::infile_line_buffer->{$file_handle}->{WARNED} = 1;
		warning('Carriage returns were found in your file and ',
			'replaced with hard returns.');
	      }
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} =
	      split(/(?<=\n)/,$line);
	  }
	else
	  {@{$main::infile_line_buffer->{$file_handle}->{FILE}} = ($line)}
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
    my @debug_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@debug_message,'') unless(scalar(@debug_message));
    pop(@debug_message) if(scalar(@debug_message) > 1 &&
			   $debug_message[-1] !~ /\S/);

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
    print STDERR ($leader_string,
		  shift(@debug_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $debug_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@debug_message)
      {print STDERR (' ' x $leader_length,
		     $line,
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
	error('Supplied time mark index is larger than the size of the ',
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


sub getVersion
  {
    my $full_version_flag = $_[0];
    my $template_version_number = '1.39';
    my $version_message = '';

    #$software_version_number  - global
    #$created_on_date          - global
    #$verbose                  - global

    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    if($created_on_date eq 'DATE HERE')
      {$created_on_date = 'UNKNOWN'}

    $version_message  = join((isStandardOutputToTerminal() ? "\n" : ' '),
			     ("$script Version $software_version_number",
			      " Created: $created_on_date",
			      " Last modified: $lmd"));

    if($full_version_flag)
      {
	$version_message .= (isStandardOutputToTerminal() ? "\n" : ' - ') .
	  join((isStandardOutputToTerminal() ? "\n" : ' '),
	       ('Generated using perl_script_template.pl ' .
		"Version $template_version_number",
		' Created: 5/8/2006',
		' Author:  Robert W. Leach',
		' Contact: robleach@ccr.buffalo.edu',
		' Company: Center for Computational Research',
		' Copyright 2008'));
      }

    return($version_message);
  }

#This subroutine is a check to see if input is user-entered via a TTY (result
#is non-zero) or directed in (result is zero)
sub isStandardInputFromTerminal
  {return(-t STDIN || eof(STDIN))}

#This subroutine is a check to see if prints are going to a TTY.  Note,
#explicit prints to STDOUT when another output handle is selected are not
#considered and may defeat this subroutine.
sub isStandardOutputToTerminal
  {return(-t STDOUT && select() eq 'main::STDOUT')}

#This subroutine exits the current process.  Note, you must clean up after
#yourself before calling this.  Does not exit is $ignore_errors is true.  Takes
#the error number to supply to exit().
sub quit
  {
    my $errno = $_[0];
    if(!defined($errno))
      {$errno = -1}
    elsif($errno !~ /^[+\-]?\d+$/)
      {
	error("Invalid argument: [$errno].  Only integers are accepted.  Use ",
	      "error() or warn() to supply a message, then call quit() with ",
	      "an error number.");
	$errno = -1;
      }

    debug("Exit status: [$errno].");

    exit($errno) if(!$ignore_errors || $errno == 0);
  }
