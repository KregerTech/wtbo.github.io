#!/usr/local/bin/perl

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop Diagnostic Plugin Program
# Version 1.0
#
# Copyright (c) 1999, 2000, 2001 by David M. Godwin, All rights reserved
#
# Requires Perlshop 4.2.06 or later.
# 
# This code may not be copied, borrowed, stolen, sold, resold, reused, 
# recycled, plagiarized, modified, or in any way used for anything at
# all without the express written permission of the author.
#

# Don't buffer output
$| = 1;

# Record command line parameters
my ($event, $order_id, $page_name) = @ARGV;

print "Diagnostic Plugin: event = $event, order ID = $order_id, page name = $page_name<br>\n";


