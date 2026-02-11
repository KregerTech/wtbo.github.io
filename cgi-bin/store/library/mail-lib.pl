############################################################
#                       SENDMAIL_LIB.PL
#
# This script was written by Gunther Birznieks. 
# Date Created: 2-22-96
# Date Last Modified: 5-5-96
#
#   You may copy this under the terms of the GNU General Public
#   License or the Artistic License which is distributed with
#   copies of Perl v5.x for UNIX.
#
# Purpose: Provides a set of library routines to send email
# over the internet.  
#
# Main Procedures:
#  real_send_mail - flexible way to send email
#  send_mail - easier to use version of send_mail
#
# Special Notes: Script is UNIX Specific and ties into the 
# Sendmail Program which is usually located in /usr/lib or
# /usr/bin.
# 
# Also, remember to escape @ signs with a backslash (\@) 
# for compatibility with PERL 5.
#
# Change the $mail_program variable to change location of your
# sendmail program
#
############################################################

# $mail_program is the mail program used to send mail
# with the full path.  
#
# The -t flag tells sendmail to
# look for To:, From:, Subject: header lines in the
# mail message to determine the addresses to send to.
#
# NOTE: BY DEFAULT, I AM NOT USING -n and -f flags.
#
# -n is not supported by QMAILs sendmail replacement.
#
# -f is useful for special cases and can be added as needed.
#
# The -n flag tells sendmail not to use the alias list
# for the UNIX server.  We do not want outsiders using
# the alias list of the webserver in most cases.
#
# The -f flag followed by an email address of your choice
# basically tells sendmail that this email address
# should have bounced mails forwarded. Use of this flag
# was suggested by Ignacia Bustamante.
#
$flags = "-t";

# The following code checks for versions of
# sendmail and lets the user know if one of the
# default locations does not exist.
#
# The code for this trick was donated by Scott Wimer
# with some slight modification by Gunther for command
# line flag flexibility at the end

$mailer  = '/usr/lib/sendmail';
$mailer1 = '/usr/bin/sendmail';
$mailer2 = '/usr/sbin/sendmail';
$mailer3 = '/bin/sendmail';
if ( -e $mailer) {
    $mail_program=$mailer;
} elsif( -e $mailer1){
    $mail_program=$mailer1;
} elsif( -e $mailer2){
    $mail_program=$mailer2;
} elsif( -e $mailer3){
    $mail_program=$mailer3;
} else {
    print "Content-type: text/html\n\n";
    print "I can't find sendmail, shutting down...<br>";
    print "Whoever set this machine up put it someplace weird.";
    exit;
}

# Add the command line flags
$mail_program = "$mail_program $flags ";

############################################################
#
# subroutine: real_send_mail 
#   Usage:
#     &send_mail("me@myhouse.com","myhouse.com","you@yourhouse.com",
#     "yourhouse.com", "Mysubject", "My message");
#
#   Parameters:
#     $fromuser = Full Email address of sender
#     $fromsmtp = Full Internet Address of sender's SMTP Server
#     $touser   = Full Email address of receiver
#     $tosmtp   = Full Internet Address of receiver's SMTP Server
#     $subject  = Subject of message
#     $messagebody = Body of message including newlines.
#
#   Output:
#     None
############################################################

sub real_send_mail {
    local($fromuser, $fromsmtp, $touser, $tosmtp, 
      $subject, $messagebody) = @_;

# First we need to start the mail program and open
# a PIPE to the program so that anything 
# we print to the filehandle, goes to the running
# program.

# The path manipulation is to satisfy taint mode

local($old_path) = $ENV{"PATH"};

$ENV{"PATH"} = "";
$ENV{ENV} = "";

open (MAIL, "|$mail_program") || &web_error("Could Not Open Mail Program");

$ENV{"PATH"} = $old_path;

# Print the mail message to the Mail Program
# using the HERE Document method
#

# Note: SOME ISPs may have a faulty
# sendmail implementation that does
# not recognize the From: header unless 
# the order of these is changed from
# To: From: Subject:
# to 
# Subject: To: From: 
#
# This was pointed out by Paul Tate.
#

    print MAIL <<__END_OF_MAIL__;
To: $touser
From: $fromuser
Subject: $subject

$messagebody

__END_OF_MAIL__

    close (MAIL);

} #end of real_send_mail

############################################################
#
# subroutine: send_mail 
#   Usage:
#     &send_mail("me@myhouse.com","you@yourhouse.com",
#     "Mysubject", "My message");
#
#   Parameters:
#     $fromuser = Full Email address of sender
#     $touser   = Full Email address of receiver
#     $subject  = Subject of message
#     $messagebody = Body of message including newlines.
# 
#   Output:
#     None
#
############################################################

sub send_mail {
    local($from, $to, $subject, $messagebody) = @_;

    local($fromuser, $fromsmtp, $touser, $tosmtp);

# This routine takes the simpler parameters of 
# send_mail and breaks them up into the parameters
# to be sent to real_send_mail.
# 
    $fromuser = $from;
    $touser = $to;

#
# Split is used to break the address up into
# user and hostname pairs.  The hostname is the
# 2nd element of the split array, so we reference
# it with a 1 (since arrays start at 0).
#
    $fromsmtp = (split(/\@/,$from))[1];
    $tosmtp = (split(/\@/,$to))[1];

# Actually call the sendmail routine with the
# newly generated parameters
#
    &real_send_mail($fromuser, $fromsmtp, $touser, 
           $tosmtp, $subject, $messagebody);

} # End of send_mail

############################################################
#
# subroutine: web_error
#   Usage:
#     &web_error("File xxx could not be opened");
#
#   Parameters:
#     $error = Description of Web Error
#
#   Output:
#     None
# 
############################################################

sub web_error {
    local ($error) = @_;
    $error = "Error Occured: $error";
    print "$error<p>\n";

# Die exits the program prematurely and prints an error to
# stderr

    die $error;

} # end of web_error

1;

