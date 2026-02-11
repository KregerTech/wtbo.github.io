############################################################
#                       SMTPMAIL_LIB.PL
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
# over the internet.  It communicates using TCP/IP Sockets directly
# to SMTP (Simple Mail Transfer Protocol)
#  
# Modified by Gunther Birznieks 3-19-96 to run on PERL 5 for Windows NT
# as well as the Solaris system it was originally written under
#
# Main Procedures:
#  real_send_mail - flexible way to send email
#  send_mail - easier to use version of real_send_mail
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
# Set the $mail_os variable equal to NT if you are on Windows NT perl
# Set it to UNIX for normal UNIX operations.
#
# If you do not have a version of PERL with the Socket.pm, you
# can manually define $AF_INET and $SOCK_STREAM to 2 and 1 respectively.
# On some systems, SOCK_STREAM may be 2.
#
# NOTE: This program does not support MX DNS records which is
# an important part of the internet mail standard.  Use sendmail_lib.pl
# if you can since the sendmail daemon on unix supports MX records.
############################################################

# Use the Sockets library for TCP/IP Communications
use Socket;
$mail_os = "UNIX";

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
    local($ipaddress, $fullipaddress, $packconnectip);
    local($packthishostip);
    local($AF_INET, $SOCK_STREAM, $SOCK_ADDR);
    local($PROTOCOL, $SMTP_PORT);
    local($buf);
# We start off by making the message that will be sent 
# By combining the subject with the message body text
#
    $messagebody = "Subject: $subject\n\n" . $messagebody;

# The following variables are set using values defined in
# The sockets.pm library.  If your version of perl (v4) does
# not have the sockets library, you can substitute some 
# default values such as 2 for AF_INIT, and 1 for SOCK_STREAM.
# if 1 does not work for SOCK_STREAM, try using 2.
#
# AF_INET defines the internet class of addressing
#
# SOCK_STREAM is a variable telling the program to use
# a socket connection.  This varies from using SOCK_DGRAM
# which would send UDP datagrams using a connectionless paradigm
# instead.
# 
# PROTOCOL is TCPIP (6).
#
# PORT is 25 for SMTP service.
#
# SOCK_ADDR is the packeted format of the full socket address
# including the AF_INIT value, SMTP_PORT, and IP ADDRESS in that order
#


    $AF_INET = AF_INET;
    $SOCK_STREAM = SOCK_STREAM;

    $SOCK_ADDR = "S n a4 x8";

# The following routines get the protocol information
#

    $PROTOCOL = (getprotobyname('tcp'))[2];
    $SMTP_PORT = (getservbyname('smtp','tcp'))[2];

    $SMTP_PORT = 25 unless ($SMTP_PORT =~ /^\d+$/);
    $PROTOCOL = 6 unless ($PROTOCOL =~ /^\d+$/);

# Ip address is the Address of the host that we need to connect
# to
    $ipaddress = (gethostbyname($tosmtp))[4];

    $fullipaddress = join (".", unpack("C4", $ipaddress));

    $packconnectip = pack($SOCK_ADDR, $AF_INET, 
		   $SMTP_PORT, $ipaddress);
    $packthishostip = pack($SOCK_ADDR, 
			 $AF_INET, 0, "\0\0\0\0");

# First we allocate the socket
    socket (S, $AF_INET, $SOCK_STREAM, $PROTOCOL) || 
	&web_error( "Can't make socket:$!\n");

# Then we bind the socket to the local host
    bind (S,$packthishostip) || 
	&web_error( "Can't bind:$!\n");
# Then we connect the socket to the remote host
    connect(S, $packconnectip) || 
	&web_error( "Can't connect socket:$!\n");

# The following selects the socket handle and turns off
# output buffering
#
    select(S);
    $| = 1;
    select (STDOUT);

# The following sends the information to the SMTP Server.

# The first connect should give us information about the SMTP
# server

    $buf = read_sock(S, 6);

    print S "HELO $fromsmtp\n";

    $buf = read_sock(S, 6);

    print S "MAIL From:<$fromuser>\n";
    $buf = read_sock(S, 6);

    print S "RCPT To:<$touser>\n";
    $buf = read_sock(S, 6);

    print S "DATA\n";
    $buf = read_sock(S, 6);

    print S $messagebody . "\n";

    print S ".\n";
    $buf = read_sock(S, 6);

    print S "QUIT\n";

    close S;

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

sub send_mail
{
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
# subroutine: read_sock
#   Usage:
#     &read_socket(SOCKET_HANDLE, $timeout);
#
#   Parameters:
#     SOCKET_HANDLE = Handle to an allocated Socket
#     $timeout = amount of time read_sock is allowed to
#                wait for input before timing out
#                (measured in seconds)
#
#   Output:
#     Buffer containing what was read from the socket
# 
############################################################

sub read_sock {
    local($handle, $endtime) = @_;
    local($localbuf,$buf);
    local($rin,$rout,$nfound);

# Set endtime to be time + endtime.
    $endtime += time;

# Clear buffer
    $buf = "";

# Clear $rin (Read Input variable)
    $rin = '';
# Set $rin to be a vector of the socket file handle
    vec($rin, fileno($handle), 1) = 1;

# nfound is 0 since we have not read anything yet
    $nfound = 0;

# Loop until we time out or something was read 
read_socket: 
while (($endtime > time) && ($nfound <= 0)) {
# Read 1024 bytes at a time
    $length = 1024;
# Preallocate buffer
    $localbuf = " " x 1025;
	# NT does not support select for polling to see if 
	# There are characters to be received.  This is important
	# Because we dont want to block if there is nothing
	# being received.
    $nfound = 1;
    if ($mail_os ne "NT") {
# The following polls to see if there is anything in the input
# buffer to read.  If there is, we will later call the sysread routine
	$nfound = select($rout=$rin, undef, undef,.2);
	    }
}
	
# If we found something in the read socket, we should
# get it using sysread.
    if ($nfound > 0) {
	$length = sysread($handle, $localbuf, 1024);
	if ($length > 0) {
	    $buf .= $localbuf;
	    }
    }

# Return the contents of the buffer
$buf;
}

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

sub web_error
{
local ($error) = @_;
$error = "Error Occured: $error";
print "$error<p>\n";

# Die exits the program prematurely and prints an error to
# stderr

die $error;

} # end of web_error

1;

