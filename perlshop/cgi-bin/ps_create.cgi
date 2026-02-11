#!/usr/bin/perl

# Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin, All rights reserved
# 
# This code may not be copied, borrowed, stolen, sold, resold, reused, 
# recycled, plagiarized, modified, or in any way used for anything at
# all without the express written permission of the author.


# Don't buffer output
$| = 1;

my @dirs = 
(
'catalog',
'catalog/psdbi',
'catalog/template',
'customers',
'customers/deleted',
'log',
'notes',
'notes/deleted',
'orders',
'orders/deleted',
'plugins',
'plugins/files',
'status',
'status/deleted',
'temp_customers',
'temp_customers/deleted',
'temp_orders',
'temp_orders/deleted',
'tokens'
);


# Generate the HTTP header
print "Content-type: text/html\n\n";

# Generate the web page
print qq(
<html>
<head>
<title>Perlshop 4 Web Create</title>
</head>

<body bgcolor="white">
<h2>Perlshop 4 Web Create</h2>

<p>
Creating Perlshop 4 directories...<br>
);

# Execute CREATE
foreach my $dir (sort @dirs)
{
	if (-e $dir)
	{
		print "Directory $dir already exists.<br>\n";
	}
	
	else
	{
		mkdir($dir, 0700)
			or die "Error: could not create directory $dir.<br>\n";
		print "Created directory $dir.<br>\n";
	}
}

# Finish the web page
print qq(
<p>
Execution complete.<br>

</body>
</html>
);

