#!/usr/local/bin/perl

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 Data Encryption Utility Program
# Version 1.0
#
# Copyright (c) 2002 by David M. Godwin, All rights reserved
#
# Requires Perlshop 4.4.01 or later.
# 
# This code may not be copied, borrowed, stolen, sold, resold, reused, 
# recycled, plagiarized, modified, or in any way used for anything at
# all without the express written permission of the author.
#
#
# Version History
#
#	Version 1.0
#	- Initial version
#
#


# This program requires perl version 5.004 or higher
require 5.004;

use CGI;

# Force all fatal error messages to go the browser.
use CGI::Carp qw(fatalsToBrowser);


# Don't buffer output
$| = 1;

#
# Global variables
my $debug = 0;

# Generate the HTTP header
print "Content-type: text/html\n\n";

# Generate the web page
print qq(
<html>
<head>
<title>Perlshop 4 Data Encryption Test</title>
</head>

<body bgcolor="white">
<h2 align="center" style="color:darkblue">Perlshop 4 Data Encryption Test</h2>
<small>
);

# Load the Perlshop configuration file
LoadLibrary('ps.cfg');

# Load the Perlshop encryption library
LoadLibrary('ps_encryption.pl');


# Is encryption enabled?
my $state = (($encryption_index eq '')
	? "Data encryption is not currently enabled.\n"
	: "Your current data encryption setting is '$encryption_index'.\n");

# List the available encryption modes
my $list = join(', ', sort keys %encryption_table);
$list = 'None defined'
	if $list eq '';


# Report on the basics
print qq(
The Encryption Library has been successfully loaded.<br>
$state<br>

<p>
Available encryption settings: $list.
);

# Test all modes
TestEncryptions(defined CGI::param('plain') ? CGI::param('plain') : 'abcdefghijklmnopqrstuvwxyz');

EndPage();


sub TestEncryptions
{
	my ($plain) = @_;

	my $decoded;
	my $encoded;
	my $module;
	my $result;

	# Test each mode
	foreach my $key (sort keys %encryption_table)
	{
		# Configure to use this mode
		$encryption_index = $key;

		$module = (defined $encryption_table{$key}->{'cipher'} ? $encryption_table{$key}->{'cipher'} : 'RC4');

		print qq(
<p>
<hr>
<b>Testing encryption mode $key using $module cipher module.</b><br>
Plain text is "$plain".<br>
);

		# Encode, decode, and compare
		$encoded = encrypt_data($plain);
		$decoded = decrypt_data($encoded);
		$result = (($decoded eq $plain) 
			? '<span style="color:green">Pass</span>' 
			: '<span style="color:red">Fail</span>');

		print qq(
Encoded data is "$encoded".<br>
Decoded data is "$decoded".<br>
<p>
Test result: <b>$result</b><br>
);
	}
}


sub EndPage
{
	print qq(
</small>
</body>
</html>
);
}


sub LoadLibrary
{
	my ($library_name) = @_;

	# Attempt to load the specified Perlshop 4 library file
	unless (eval 'require $library_name')
	{	
		print "Could not load library $library_name :<br>\n$@<br>\n";
		exit;
	};
}


