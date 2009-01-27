#!/usr/bin/perl -w

#bidirectional_blast.pl
#Generated using perl_script_template.pl 1.33
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Created on 4/21/2008
#Center for Computational Research
#Copyright 2007

#These variables (in main) are used by printVersion()
my $template_version_number = '1.33';
my $software_version_number = '1.0';

##
## Start Main
##

use strict;
use Getopt::Long;

#Declare & initialize variables.  Provide default values here.
my($outfile_suffix); #Not defined so a user can overwrite the input file
my @input_files         = ();
my $current_output_file = '';
my $help                = 0;
my $version             = 0;
my $force               = 0;
my $blast_command       = 'blastall';
my $format_command      = 'formatdb';
my $blast_params        = '-v 20 -b 20 -e 100 -F F';
my $program             = 'blastp';
my $parse_only          = 0;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, printVersion, getCommand and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;

my $GetOptHash =
  {'p|blast-program=s'  => \$program,                #OPTIONAL [blastn]
   'b|blast-params=s'   => \$blast_params,           #OPTIONAL [-v 20 -b 20
                                                     # -e 100 -F F]
   'parse-only!'        => \$parse_only,             #OPTIONAL [Off]
   'i|input-file=s'     => sub {push(@input_files,   #REQUIRED unless <> is
				     sglob($_[1]))}, #         supplied
   '<>'                 => sub {push(@input_files,   #REQUIRED unless -i is
				     sglob($_[0]))}, #         supplied
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
  {verbose("NOTE: VerboseOverMe functionality has been altered to yield ",
	   "clean STDOUT output.")}

verbose("Run conditions: ",getCommand(1),"\n");

#If output is going to STDOUT instead of output files with different extensions
if(!defined($outfile_suffix))
  {verbose("[STDOUT] Opened for all output.")}

my $hit_hash           = {};
my $combo_array        = [];
my $error_flag         = 0;
my $command            = '';
my $check_file_names   = {};
my $dupe_id_error      = 0;
my $defline_hash       = {};
my $blast_result_files = {};

foreach my $input_file (@input_files)
  {
    my $protein_bool = ($program eq 'blastp' || $program eq 'blastx' ?
			'T' : 'F');
    $command = "$format_command -p $protein_bool -i $input_file";
    verbose($command,"\n");
    `$command`;
    if($?)
      {
	$error_flag = 1;
	error("Format of [$input_file] failed with message: [$!].  The ",
	      "command executed was: [$command].");
      }

    verbose("BLASTING $input_file against $input_file") unless($parse_only);
    my $file_name    =  $input_file;
    $file_name       =~ s/.*\///;
    $blast_result_files->{"$input_file.$file_name.br"} =
      [$file_name,$file_name];

    if(!$parse_only && !$force && -e "$input_file.$file_name.br")
      {
	error("The blast results file: [$input_file.$file_name.br] already ",
	      "exists.  Use -f to force overwrite.  E.g.\n\t",
	      getCommand(1),' --force');
      }
    elsif(!$parse_only)
      {
	$command  = "$blast_command -i $input_file -d $input_file -p ";
	$command .= "$program $blast_params -o $input_file.$file_name.br";
	verbose($command,"\n");
	`$command`;
	if($?)
	  {
	    $error_flag = 1;
	    error("Blast of [$input_file -> $input_file] failed with ",
		  "message: [$!].  The command executed was: [$command].");
	  }
      }

    #Make sure the file names are unique
    my $file_name = $input_file;
    $file_name =~ s/.*\///;
    $check_file_names->{$file_name}++;

    #Make sure the sequence IDs are unique
    my $check_ids = {};
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

    my $line_num = 0;

    #For each line in the current input file
    while(getLine(*INPUT))
      {
	$line_num++;
	verboseOverMe("[",
		      ($input_file eq '-' ? 'STDIN' : $input_file),
		      "] Reading line: [$line_num].");

	if(/>\s*(\S+)/)
	  {
	    my $id = $1;
	    $check_ids->{$id}++;
	    if(/>\s*(\S.*)$/)
	      {$defline_hash->{$file_name}->{$id} = $1}
	  }
      }

    close(INPUT);

    verbose("[",
	    ($input_file eq '-' ? 'STDIN' : $input_file),
	    '] Input file done.  Time taken: [',
	    scalar(markTime()),
	    " Seconds].");

    if(scalar(grep {$_ > 1} values(%$check_ids)))
      {
	$dupe_id_error = 1;
	error("You have duplicate keys in fasta file: [$input_file]: [",
	      join(',',grep {$check_ids->{$_} > 1} keys(%$check_ids)),
	      "].");
      }
  }

if($dupe_id_error)
  {
    error("Please edit your fasta files to remove the duplicate IDs ",
	  "indicated above.");
    exit(3);
  }

#See if we need to use full paths in the hash keys
if(scalar(grep {$_ > 1} values(%$check_file_names)))
  {
    error("Your file names (not including the file path) must be unique.  ",
	  "There are multple files with these names: [",
	  join(',',grep {$check_file_names->{$_} > 1}
	       keys(%$check_file_names)),
	  "].");
    exit(3);
  }

$error_flag  = 0;
while(GetNextCombo($combo_array,2,scalar(@input_files)))
  {
    verbose("BLASTING ",
	    join(" against ",(map {$input_files[$_]} @$combo_array)),
	    "\n") unless($parse_only);
    my $query_file   =  $input_files[$combo_array->[0]];
    my $subject_file =  $input_files[$combo_array->[1]];
    my $file_name    =  $subject_file;
    $file_name       =~ s/.*\///;
    my $file_name2   =  $query_file;
    $file_name2      =~ s/.*\///;
    $blast_result_files->{"$query_file.$file_name.br"} =
      [$file_name2,$file_name];

    if(!$parse_only && !$force && -e "$query_file.$file_name.br")
      {
	error("The blast results file: [$query_file.$file_name.br] already ",
	      "exists.  Use -f to force overwrite.  E.g.\n\t",
	      getCommand(1),' --force');
      }
    elsif(!$parse_only)
      {
	$command  = "$blast_command -i $query_file -d $subject_file -p ";
	$command .= "$program $blast_params -o $query_file.$file_name.br";
	verbose($command,"\n");
	`$command`;
	if($?)
	  {
	    $error_flag = 1;
	    error("Blast of [$query_file -> $subject_file] failed with ",
		  "message: [$!].  The command executed was: [$command].");
	  }
      }

    verbose("BLASTING ",
	    join(" against ",reverse(map {$input_files[$_]} @$combo_array)),
	    "\n") unless($parse_only);
    $query_file   = $input_files[$combo_array->[1]];
    $subject_file = $input_files[$combo_array->[0]];
    $file_name    = $subject_file;
    $file_name =~ s/.*\///;
    $file_name2   = $query_file;
    $file_name2 =~ s/.*\///;
    $blast_result_files->{"$query_file.$file_name.br"} =
      [$file_name2,$file_name];

    if(!$parse_only && !$force && -e "$query_file.$file_name.br")
      {
	error("The blast results file: [$query_file.$file_name.br] already ",
	      "exists.  Use -f to force overwrite.  E.g.\n\t",
	      getCommand(1),' --force');
      }
    elsif(!$parse_only)
      {
	$command  = "$blast_command -i $query_file -d $subject_file -p ";
	$command .= "$program $blast_params -o $query_file.$file_name.br";
	verbose($command,"\n");
	`$command`;
	if($?)
	  {
	    $error_flag = 1;
	    error("Blast of [$query_file -> $subject_file] failed with ",
		  "message: [$!].  The command executed was: [$command].");
	  }
      }
  }

##
## Now store all the blast results in a hash
##

#my $result_hash = {};

foreach my $blast_result_file (keys(%$blast_result_files))
  {
    #Open the input file
    if(!open(INPUT,$blast_result_file))
      {
	#Report an error and iterate if there was an error
	error("Unable to open input file: [$blast_result_file]\n$!");
	next;
      }
    else
      {verboseOverMe("[$blast_result_file] Opened input file.")}

    my($query_id,
       $query_length,
       $subject_id,
       $subject_length,
       $match_length,
       $evalue,
       $identity,
       $last_added);
    my $alignment_count = 0;
    my $line_num = 0;

    #For each line in the current input file
    while(getLine(*INPUT))
      {
	$line_num++;
	verboseOverMe("[$blast_result_file] Reading line: [$line_num].");

	if(/Query=\s*(\S+)/)
	  {
	    if(defined($last_added) && !$last_added)
	      {
		addResult($blast_result_files->{$blast_result_file}->[0],#Query
			  $blast_result_files->{$blast_result_file}->[1],#Subje
			  0,
			  $query_id,
			  $query_length,
			  '',
			  '',
			  '',
			  '',
			  '');
	      }
	    $query_id = $1;
	  }
	elsif(/^\s+\((\d+) letters\)\s*$/)
	  {$query_length = $1}
	elsif(/^\s*>\s*(\S+)/)
	  {
	    $subject_id = $1;
	    $alignment_count = 0;
	  }
	elsif(/^\s+Length = (\d+)\s*$/)
	  {$subject_length = $1}
	elsif(/Expect = (\S+)/)
	  {
	    $evalue = $1;
	    $alignment_count++;
	  }
	elsif(/^\s*Identities = \d+\/(\d+) \((\d+)/)
	  {
	    $match_length = $1;
	    $identity = $2;

	    addResult(#$result_hash,               #The hash we'll be adding to
		      $blast_result_files->{$blast_result_file}->[0], #Query
		      $blast_result_files->{$blast_result_file}->[1], #Subject
		      $alignment_count,            #Number hit to this subject
		      $query_id,
		      $query_length,
		      $subject_id,
		      $subject_length,
		      $match_length,
		      $evalue,
		      $identity);
	  }
      }

    close(INPUT);

    verbose("[$blast_result_file] Input file done.  Time taken: [",
	    scalar(markTime()),
	    " Seconds].");
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

sub addResult
  {
#    my $hash_result     = $_[0];
    my $query_file      = $_[0];
    my $subject_file    = $_[1];
    my $alignment_count = $_[2];
    my $query_id        = $_[3];
    my $query_length    = $_[4];
    my $subject_id      = (defined($_[5]) ? $_[5] : '');
    my $subject_length  = (defined($_[6]) ? $_[6] : '');
    my $match_length    = (defined($_[7]) ? $_[7] : '');
    my $evalue          = (defined($_[8]) ? $_[8] : '');
    my $identity        = (defined($_[9]) ? $_[9] : '');

    #Assume that the first alignment is the best & longest
    return if($alignment_count > 1);

    my $larger_length = ($query_length > $subject_length ?
			 $query_length : $subject_length);

#    $hash_result->{$query_file}->{$subject_file}->{$query_id}->{$subject_id} =
#      {LENGTHRATIO => ($match_length / $larger_length),
#       EVALUE      => $evalue,
#       IDENTITY    => $identity};

    print(join("\t",($query_file,
		     $subject_file,
		     $query_id,
		     $subject_id,
		     ($match_length / $larger_length),
		     $evalue,
		     $identity)),"\n");
  }


##
##Copied from ordered_digit_increment 4/21/2008 -Rob
##
#This subroutine takes a current Combination, the size of the combination set,
#and the pool size.  It returns a new combination that hasn't been returned
#before.  This is an n_choose_r iterator.  It returns true if it was able to
#create an unseen combination, false if there are no more/
sub GetNextCombo
  {
    #Read in parameters
    my $combo     = $_[0];  #An Array of numbers
    my $set_size  = $_[1];  #'r' from (n choose r)
    my $pool_size = $_[2];  #'n' from (n choose r)

    #return false and report error if the combo is invalid
    if(@$combo > $pool_size)
      {
	print STDERR ("ERROR:GetNextCombo:Combination cannot be bigger than ",
		      "the pool size!");
	return(0);
      }

    #Initialize the combination if it's empty (first one) or if the set size
    #has increased since the last combo
    if(scalar(@$combo) == 0 || scalar(@$combo) != $set_size)
      {
	#Empty the combo
	@$combo = ();
	#Fill it with a sequence of numbers starting with 0
        foreach(0..($set_size-1))
          {push(@$combo,$_)}
	#Return true
        return(1);
      }

    #Define an upper limit for the last number in the combination
    my $upper_lim = $pool_size - 1;
    my $cur_index = $#{@$combo};

    #Increment the last number of the combination if it is below the limit and
    #return true
    if($combo->[$cur_index] < $upper_lim)
      {
        $combo->[$cur_index]++;
        return(1);
      }

    #While the current number (starting from the end of the combo and going
    #down) is at the limit and we're not at the beginning of the combination
    while($combo->[$cur_index] == $upper_lim && $cur_index >= 0)
      {
	#Decrement the limit and the current number index
        $upper_lim--;
        $cur_index--;
      }

    #Increment the last number out of the above loop
    $combo->[$cur_index]++;

    #For every number in the combination after the one above
    foreach(($cur_index+1)..$#{@$combo})
      {
	#Set its value equal to the one before it plus one
	$combo->[$_] = $combo->[$_-1]+1;
      }

    #If we've exceded the ppol size on the last number of the combination
    if($combo->[-1] > $pool_size)
      {
	#Return false
	return(0);
      }

    #Return true
    return(1);
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
Created on 4/21/2008
Last Modified on $lmd
Center for Computational Research
701 Ellicott Street
Buffalo, NY 14203
rwleach\@ccr.buffalo.edu

* WHAT IS THIS: This script takes a series of fasta files and blasts each one
                against every other.  Blast result files are produced, as well
                as a file of hit data.

* INPUT FORMAT: Fasta file (default format: nucleotide - See -p in the usage
                output to change to protein).

* OUTPUT FORMAT: The blast files produced will be named like this:

                   <query_file>.<subject_file>.br

                 The hit data output will consist of 7 tab-delimited columns
                 like this:

                   queryFile	subjectFile	queryID	subjectID	matchLengthRatio	eValue	percentIdentity

                 The match length ratio is the length of the match area (i.e.
                 the number of alignment characters in the subject sequence -
                 including gaps) divided by the larger of the two aligned
                 sequences.  Note, this could potentially produce a ratio
                 greater than 1.

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

     -i|--input-file*     REQUIRED Space-separated fasta file(s inside quotes).
                                   *No flag required.  Standard input via
                                   redirection is acceptable.  Perl glob
                                   characters (e.g. '*') are acceptable inside
                                   quotes.
     -p|--blast-program   OPTIONAL [blastn] (blastn,blastp,tblastn,...)  See
                                   usage of the blastall executable.
     -b|--blast-params    OPTIONAL [-v 20 -b 20 -e 100 -F F] Optional
                                   parameters to supply to the blastall
                                   executable.  Note: Do not supply -i, -d, and
                                   -p via this option.
     --parse-only         OPTIONAL [Off] Supplying this option will cause blast
                                   and formatdb to not run, but will still
                                   parse the output files.  This is meant to be
                                   used if you have run this script once before
                                   already and want to generate a hit table
                                   using a subset of input files.  You still
                                   supply the fasta files as input and the
                                   blast file names will be reconstructed.
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
    error("\@_ is not initialized!") if(scalar(grep {!defined($_)} @_));
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

#This subroutine is a check to see if input is user-entered via a TTY (result
#is non-zero) or directed in (result is zero)
sub isStandardInputFromTerminal
  {return(-t STDIN || eof(STDIN))}

#This subroutine is a check to see if prints are going to a TTY.  Note,
#explicit prints to STDOUT when another output handle is selected are not
#considered and may defeat this subroutine.
sub isStandardOutputToTerminal
  {return(-t STDOUT && select() eq 'main::STDOUT')}
