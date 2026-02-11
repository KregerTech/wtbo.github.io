############################################################
#                       PGP-LIB.PL
#
# Summary: PGP stands for Pretty Good Privacy and it
#  is a utility on the internet that allows you to encrypt
#  and decrypt files.  This library interfaces with this
#  3rd party encryption program
#
# This script was written by Gunther Birznieks.
# Date Created: 11-5-96
# Date Last Modified: 11-25-96
#
# Copyright Info: This library was written by Gunther Birznieks    
#       (gunther@clark.net) having been inspired by countless
#       other Perl authors.  Feel free to copy, cite, reference, sample,
#       borrow, resell or plagiarize the contents.  However, if you don't
#       mind, please let me know where it goes so that I can at least     
#       watch and take part in the development of the memes. Information  
#       wants to be free, support public domain freware.  Donations are   
#       appreciated and will be spent on further upgrades and other public
#       domain scripts.
#
# Purpose: Provides a set of library routines to interface with
#   PGP to create an encrypted buffer
#
# MAIN PROCEDURE:
#  make_pgp_file - makes a pgp encrypted file and sends its
#                  contents back to the user
#
# Special Notes: Script ties into the pgp executable whose
#  location is specified in the variables below.
#
# *** THIS VERSION OF PGP-LIB.PL WAS MODIFIED TO WORK WITH PGP version 5
# *** ON LINUX
# 
# VARIABLES:
#  $pgp_path = path to PGP executable
#  $pgp_options = command line options to the PGP program
#  $pgp_public_key_user_id = which key to use for encrypting
#  $pgp_config_files = path where configuration files are located 
#
############################################################

$pgp_path = "/usr/local/bin/pgpe";

$pgp_options = "-atz -f -r";
$pgp_public_key_user_id = "\"Richie Carey <richie\@dial411.com>\"";
$pgp_config_files = "/home/carey/www/commerce/standard/cgi-bin/store/PgpFiles";

############################################################
#
# subroutine: make_pgp_file
#   Usage:
#     &make_pgp_file($output_text, $output_file);
# 
#   Parameters:
#     $output_text = unecrypted text that you want to scramble
#     $output_file = name of a file that you will use to
#                    temporarily create the encryption. It
#                    will be removed after it is created
#                    and its contents are assigned to a buffer.
#
#   Output:
#     $pgp_output = the encrypted text that was stored in
#          the $output_file results of running PGP
############################################################

sub make_pgp_file 
{

local($output_text, $output_file) = @_;  
local($pgp_output);

# Set the PGPPATH environment to tell
# PGP *not* to go to the Web Server User's
# home directory by default to look for key
# files and public keys
#

$ENV{"PGPPATH"} = $pgp_config_files;

# Generate the command that needs to be used
# to execute PGP. This consists of the PGP 
# executable followed by command line options
# which is followed by the user id which you
# want to use a public key for and then output
# the encrypted results to an output file.
#

$pgp_command =  "$pgp_path $pgp_options ";
$pgp_command .= "$pgp_public_key_user_id ";
$pgp_command .= "$pgp_second_options ";

# The command is opened using the special
# file open PIPE command which EXECUTES the
# command and then allows PERL to print to
# it as input for the command.
#
# The path manipulation is to satisfy taint mode
# 
 
local($old_path) = $ENV{"PATH"};
$ENV{"PATH"} = "";

open (SAVEERR, ">&STDERR") || die ("Could not capture STDERR");
open (SAVEOUT, ">&STDOUT") || die ("Could not capture STDOUT");
open (STDOUT, ">$output_file");
open (STDERR, ">&STDOUT");

$pid = open (PGPCOMMAND, "|$pgp_command");
 
$ENV{"PATH"} = $old_path;

# The text you want to encrypt is sent to
# the command.

print PGPCOMMAND $output_text;

close (PGPCOMMAND);

close (STDOUT) || die ("Error closing STDOUT");
close (STDERR) || die ("Error closing STDERR");
open(STDERR,">&SAVEERR") || die ("Could not reset STDERR");
open(STDOUT,">&SAVEOUT") || die ("Could not reset STDOUT");
close (SAVEERR) || die ("Error closing SAVEERR");
close (SAVEOUT) || die ("Error closing SAVEOUT");

# The resulting output file is opened,
# read into $pgp_output and closed.
#

open(PGPOUTPUT, $output_file);

my $insidepgp = 0;

while (<PGPOUTPUT>)
{

$insidepgp = 1 if (/BEGIN PGP/i);

	if ($insidepgp)
	{
	$pgp_output .= $_;
	}
} 

close (PGPOUTPUT);


if (!defined($pid))
{

$pgp_output .= "PGP Never Executed. Something went wrong.\n";

}

if (!$pgp_output)
{
$pgp_output = "No data was returned from PGP.\n";
}

# we remove the temporary file

unlink($output_file);

# we return pgp output

return($pgp_output);

# End of make_pgp_file

}

# We always return TRUE from requiring
# a library file (1;)

1;
