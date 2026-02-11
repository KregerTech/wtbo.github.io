#!/usr/bin/perl

# Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin, All rights reserved
# 
# This code may not be copied, borrowed, stolen, sold, resold, reused, 
# recycled, plagiarized, modified, or in any way used for anything at
# all without the express written permission of the author.


# Don't buffer output
$| = 1;

# Generate the HTTP header
print "Content-type: text/html\n\n";

# Generate the web page
print qq(
<html>
<head>
<title>Perlshop 4 Web Clean</title>
</head>

<body bgcolor="white">
<h2>Perlshop 4 Web Clean</h2>

<p>
Executing the Perlshop 4 CLEAN script...<br>
);

# Execute CLEAN
print qx(./CLEAN);

# Finish the web page
print qq(
<p>
Execution complete.<br>

</body>
</html>
);

