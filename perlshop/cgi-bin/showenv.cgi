#!/usr/local/bin/perl

# Copyright (c) 2003 by David M. Godwin, All rights reserved
# 
# This code may not be copied, borrowed, stolen, sold, resold, reused, 
# recycled, plagiarized, modified, or in any way used for anything at
# all without the express written permission of the author.

use Cwd;


# Don't buffer output
$| = 1;

# Ask for server name and information
chomp($hostname = `hostname`);
chomp($uname = `uname -a`);

# Ask system for user name
chomp($user = `/usr/bin/whoami`);

# Ask system for user id and group id for this user
($uid, $gid) = (getpwnam($user))[2, 3];

# Get the current working directory
$cwd = cwd();

# Get path for sendmail program
chomp($sendmail = `which sendmail`);

#
# Generate the complete form
#
print "Content-type: text/html\n\n";

print qq(
<html>
<head>
<title>CGI Environment</title>
</head>

<body bgcolor="white">
<b>
Host name is $hostname.<br>
System description is $uname.<br>

<p>
CGI programs execute as user $user ($uid, $gid).<br>
Current execution directory is $cwd.<br>
</b>
<hr>

<h2 align="center">CGI Environment</h2>
<p>
<br>
SERVER_SOFTWARE = $ENV{'SERVER_SOFTWARE'}<br>
SERVER_NAME = $ENV{'SERVER_NAME'}<br>
GATEWAY_INTERFACE = $ENV{'GATEWAY_INTERFACE'}<br>
SERVER_PROTOCOL = $ENV{'SERVER_PROTOCOL'}<br>
SERVER_PORT = $ENV{'SERVER_PORT'}<br>
REQUEST_METHOD = $ENV{'REQUEST_METHOD'}<br>
HTTP_FROM = $ENV{'HTTP_FROM'}<br>
HTTP_ACCEPT = $ENV{'HTTP_ACCEPT'}<br>
HTTP_USER_AGENT = $ENV{'HTTP_USER_AGENT'}<br>
HTTP_REFERER = $ENV{'HTTP_REFERER'}<br>
PATH_INFO = $ENV{'PATH_INFO'}<br>
PATH_TRANSLATED = $ENV{'PATH_TRANSLATED'}<br>
SCRIPT_NAME = $ENV{'SCRIPT_NAME'}<br>
QUERY_STRING = $ENV{'QUERY_STRING'}<br>
REMOTE_HOST = $ENV{'REMOTE_HOST'}<br>
REMOTE_ADDR = $ENV{'REMOTE_ADDR'}<br>
REMOTE_USER = $ENV{'REMOTE_USER'}<br>
REMOTE_IDENT = $ENV{'REMOTE_IDENT'}<br>
AUTH_TYPE = $ENV{'AUTH_TYPE'}<br>
CONTENT_TYPE = $ENV{'CONTENT_TYPE'}<br>
CONTENT_LENGTH = $ENV{'CONTENT_LENGTH'}<br>
<p>
<hr>
<p>
<h2 align="center">Complete Environment</h2>
);

foreach $key (sort keys %ENV)
{
	print "$key = $ENV{$key}<br>\n";
}

print qq(
<h2 align="center">System Programs</h2>
Sendmail program path : $sendmail

</body>
</html>
);

