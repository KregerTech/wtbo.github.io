
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 email transmission related subroutines
#
# Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
# Version 1.1
#	- Added support for DV Mail for Windows 2000
#
# Version 1.2
#	- Added support for MIME::Lite
#
# Version 1.3
#	- Added Cc and Bcc parameters
#


sub SendEmail
{
	my ($to, $from, $subject, $body, $html_body, $cc, $bcc) = @_;

#	print qq(
#<!--
#Sending Email
#To : $to
#Cc : $cc
#Bcc : $bcc
#From : $from
#Subject : $subject
#-->
#);

	# Send mail via sendmail ?
	if (lc $mail_via eq 'sendmail')   
	{
		open(MAIL, "|$sendmail_loc -t -oi")
			or &error_trap("Can't open $sendmail_loc!\n");

		print MAIL qq(To: $to
From: $from
Cc: $cc
Bcc: $bcc
Subject: $subject

$body

);

		close MAIL;
	}

	# Send mail via blat ?
	elsif (lc $mail_via eq 'blat') 
	{
		open(MAIL, qq(|$blat_loc - -t "$to" -i "$from" -s "$subject" -q))
			or &error_trap("Can't open $blat_loc!\n");

		print MAIL "$body\n\x1a";

		close MAIL;
	}

	# Send mail via DevMailer ?
	elsif (lc $mail_via eq 'dv')
	{
		dv_mail($to, $from, $subject, $body);
	}

	# Send mail via MIME_Lite ?
	elsif ((lc $mail_via eq 'html_sendmail') ||
		   (lc $mail_via eq 'html_smtp'))
	{
		mime_mail($to, $from, $cc, $bcc, $subject, $body, $html_body);
	}

	# Send mail via sockets
	else
	{
		$err = &sockets_mail($to, $from, $cc, $bcc, $subject, $body); 
		if ($err < 1)
			{print "<br>\nSendmail error # $err<br>\n";}			
	}	
}


#------------------------------------------------------------------#
sub sockets_mail
{
    my ($to, $from, $cc, $bcc, $subject, $message) = @_;

    my ($replyaddr) = $from;
   
    if (!$to) { return -8; }

    my ($proto, $port, $smtpaddr);

    my ($AF_INET)     =  2;
    my ($SOCK_STREAM) =  1;

    $proto = (getprotobyname('tcp'))[2];
    $port  = 25;

    $smtpaddr = ($smtp_addr =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
                    ? pack('C4',$1,$2,$3,$4)
                    : (gethostbyname($smtp_addr))[4];

    if (!defined($smtpaddr)) { return -1; }

    if (!socket(S, $AF_INET, $SOCK_STREAM, $proto))             { return -2; }
    if (!connect(S, pack('Sna4x8', $AF_INET, $port, $smtpaddr))) { return -3; }

    my($oldfh) = select(S); $| = 1; select($oldfh);

    $_ = <S>; if (/^[45]/) { close S; return -4; }

    print S "helo localhost\r\n";
    $_ = <S>; if (/^[45]/) { close S; return -5; }

    print S "mail from: $from\r\n";
    $_ = <S>; if (/^[45]/) { close S; return -5; }
   
    print S "rcpt to: $to\r\n";
    $_ = <S>; if (/^[45]/) { close S; return -6; }
    

    print S "data\r\n";
    $_ = <S>; if (/^[45]/) { close S; return -5; }

    print S "X-Mailer: PerlShop Sendmail \r\n";
    print S "Mime-Version: 1.0\r\n";
    print S "Content-Type: text/plain; charset=us-ascii\r\n";
    print S "To: $to\r\n";
    print S "From: $from\r\n";
    print S "Cc: $cc\r\n";
    print S "Bcc: $bcc\r\n";
    print S "Reply-to: $replyaddr\r\n" if $replyaddr;
    print S "Subject: $subject\r\n\r\n";
    print S "$message";
    print S "\r\n.\r\n";

    $_ = <S>; if (/^[45]/) { close S; return -7; }

    print S "quit\r\n";
    $_ = <S>;

    close S;
    return 1;
}


# DevMailer code taken from DevMailer example at http://www.geocel.com
sub dv_mail
{
	my ($to, $from, $subject, $body) = @_;
	my $DevMailer;

	# Load the Windows OLE support library
	LoadLibrary('OLE');

	# Create an OLE connection to the DV mailer
	$DevMailer = CreateObject OLE 'Geocel.Mailer';
	$DevMailer->AddServer($smtp_addr, $smtp_port);

	# Construct the email
	$DevMailer->AddRecipient($to, '');    
	$DevMailer->{FromName} = '';
	$DevMailer->{FromAddress} = $from;
	$DevMailer->{Subject} = $subject;
	$DevMailer->{Body} = $body;
	$DevMailer->ClearAllAttachments();
	
	# Send the email
	$DevMailer->Send()
		or error_trap("Could not send message, please check C:\\TEMP\\GEOCEL.LOG for more information.\n");
}


sub mime_mail
{
	my ($to, $from, $cc, $bcc, $subject, $body, $html_body) = @_;
	my $msg;
	my $plain;
	my $html;

	# Load the MIME::Lite Perl module
	LoadLibrary('MIME/Lite.pm');

	# If there's no HTML body, just send plain text
	if ($html_body eq '')
	{
		# Construct the email
		$msg = MIME::Lite->new(To      => $to,
					     From    => $from,
					     Cc	 => $cc,
					     Bcc	 => $bcc,
					     Subject => $subject,
					     Type    => 'text/plain',
					     Data    => [$body]);
	}

	# Generate a multipart/alternative email with both
	# plain text and html text parts.
	else
	{
		# Construct the email container
		$msg = MIME::Lite->new(To      => $to,
					     From    => $from,
					     Cc	 => $cc,
					     Bcc	 => $bcc,
					     Subject => $subject,
					     Type    => 'multipart/alternative');
	
		# Add the plain text alternative
		$plain = $msg->attach(Type => 'text/plain',
					    Data => [$body]);
	
		# Add the html text alternative
		$html = $msg->attach(Type => 'text/html',
					   Data => [$html_body]);
	}

	if ($mail_via eq 'html_sendmail')
	{
		# Transmit message via sendmail
		$msg->send('sendmail', $sendmail_loc);
	}

	else
	{
		# Transmit message via smtp call
		$msg->send('smtp', $smtp_addr);
	}
}


##############################
# Library file return code
1;


