
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 self-test related subroutines
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

use strict;
no strict 'vars';


sub ExecuteTest
{
	my ($name, $error, $condition) = @_;

	if ($action eq 'SELFTEST')
	{
		print "Test: $name - " . ($condition ? 'pass' : $error) . "\n";
	}

	elsif (!$condition)
	{
		error_trap("$name - $error");
	}
}


sub TestDiscountTable
{
 	my ($prev_Disc_Min, $prev_Disc_Max, $prev_Disc_Amt);
	my ($Disc_Min, $Disc_Max, $Disc_Amt);

	# Set the discount precision value
	if (($discount_type eq 'price') or (lc $allow_fractional_qty eq 'yes'))
		{$discount_precision = 0.01;}
	else
		{$discount_precision = 1;}	

	# Get the data from the first table entry
 	($prev_Disc_Min, $prev_Disc_Max, $prev_Disc_Amt) = @{$Discount_Rates[0]};

	# Check all subsequent table entries
	foreach my $index (1..$#Discount_Rates) 
	{
		($Disc_Min, $Disc_Max, $Disc_Amt) = @{$Discount_Rates[$index]};
	
		return 'The Discount Rates table does not cover the full range of 0..99999999'
			if $Disc_Min != ($prev_Disc_Max + $discount_precision);
				
		($prev_Disc_Min, $prev_Disc_Max, $prev_Disc_Amt) = @{$Discount_Rates[$index]};
	}

	return 'The last value in the Discount Rates table is not equal to 99999999'
		    if $prev_Disc_Max != 99999999;

	return '';
}


sub TestShippingTable
{
	my $index;
	my ($Ship_Country, $Shipper, $Ship_Desc, 
	    $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt);
	my ($prev_Ship_Country, $prev_Shipper, $prev_Ship_Desc, 
	    $prev_Ship_Min, $prev_Ship_Max, $prev_Ship_Mul, $prev_Ship_Amt);
	my $has_ALL_entry = 0;

	# If we accept shipping to any country, check the final table entry to see if it is for "OTHER"
	if ($accept_any_country eq 'yes') 
	{
		($Ship_Country, $Shipper, $Ship_Desc, $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = 
		     @{$Shipping_Rates[$#Shipping_Rates]};		

		return '$accept_any_country = "yes", but no "OTHER" entry exists in the shipping table'
			    unless uc $Ship_Country eq 'OTHER';
	}

	# Validate the shipping precision
	$shipping_precision = ($shipping_type eq 'price' ? 0.01 : 1)
		if $shipping_precision <= 0;


	# Get the first shipping table entry
	($prev_Ship_Country, $prev_Shipper, $prev_Ship_Desc, 
	 $prev_Ship_Min, $prev_Ship_Max, $prev_Ship_Mul, $prev_Ship_Amt) = 
	    @{$Shipping_Rates[0]};

	# Check to see if it for "ALL" countries
	$has_ALL_entry = 1
		if uc $prev_Ship_Country eq 'ALL';

	# Check for valid use of the '%' operator
	return 'You cannot have a "%" with shipping type = "price" in the shipping table'
		if ($prev_Ship_Mul eq '%') && ($shipping_type ne 'price');

	# Check the lower range of the entry
	return "The first value in range for $prev_Ship_Country is not equal to zero"
		if $prev_Ship_Min != 0;


	# Check all other shipping table enties
	foreach $index (1..$#Shipping_Rates) 
	{
		# Get the table entry data
		($Ship_Country, $Shipper, $Ship_Desc, $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = 
		    @{$Shipping_Rates[$index]};

		if (($Ship_Country eq $prev_Ship_Country) && ($Shipper eq $prev_Shipper))
		{
			return qq(
Shipping range error between $prev_Ship_Max and $Ship_Min 
for $Ship_Country + $Shipper.<br>
The expected minimum value for the shipping table entry that starts with $Ship_Min is 
) . ($prev_Ship_Max + $shipping_precision)
				unless $Ship_Min == ($prev_Ship_Max + $shipping_precision);
		}

		else
		{
			return "The first value in range for $Ship_Country is not equal to zero"
				if $Ship_Min != 0;

			return "The last value in range for $prev_Ship_Country is not equal to 99999999"
				if $prev_Ship_Max != 99999999;
		}

		return 'You cannot have a "%" with shipping type = "price" in the shipping table'
			if ($Ship_Mul eq '%') && ($shipping_type ne 'price');

		$has_ALL_entry = 1
			if uc $Ship_Country eq 'ALL';

		($prev_Ship_Country, $prev_Shipper, $prev_Ship_Desc,
		 $prev_Ship_Min, $prev_Ship_Max, $prev_Ship_Mul, $prev_Ship_Amt) = 
		    @{$Shipping_Rates[$index]};
	}
	
	if ($accept_any_country eq 'yes')
	{
		($Ship_Country, $Shipper, $Ship_Desc, 
		 $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = 
		    @{$Shipping_Rates[$#Shipping_Rates]};	

		return 'accept_any_country = "yes", but no "OTHER" or "ALL" entry exists in shipping table'
			if (uc $Ship_Country ne 'OTHER') && ($has_ALL_entry == 0);
	}

	return '';
}


sub SelfTest 
{
	my $result;
	my $plugins;

	# Test SHA function
	ExecuteTest('SHA encryption function', 'Fail',
		    SHA("squeamish ossifrage\n") eq '82055066_4cf29679_2b38d164_7a4d8c0e_1966af57');

	# Check for valid date format setting
	ExecuteTest('Date format check', "Invalid date format: $date_format, must be mmddyy or ddmmyy",
		    (($date_format =~ 'mmddyy') or ($date_format =~ 'ddmmyy')));

	# Check for valid email configuration setting
	ExecuteTest('Email configuration check', "Invalid email mechanism: $mail_via",
		    ((lc $mail_via eq 'blat') or 
		     (lc $mail_via eq 'dv') or
		     (lc $mail_via eq 'html_sendmail') or
		     (lc $mail_via eq 'html_smtp') or
		     (lc $mail_via eq 'sendmail') or 
		     (lc $mail_via eq 'sockets')));

	# Check for valid discount setting
	$discount_type = lc $discount_type;
	ExecuteTest('Discount configuration check', "Invalid discount type: $discount_type",
			(($discount_type eq 'plugin') or
		     ($discount_type eq 'price') or
		     ($discount_type eq 'quantity') or
		     ($discount_type eq 'none')));

	# Check for valid discount table
	if ($discount_type ne 'none') 
	{	
		$result = TestDiscountTable();
		ExecuteTest('Discount table validation', $result, ($result eq ''));
	}
	
	# Check for valid shipping setting
	$shipping_type = lc $shipping_type;
	ExecuteTest('Shipping configuration check', "Invalid shipping type: $shipping_type",
		    (($shipping_type eq 'price') or
		     ($shipping_type eq 'quantity') or
		     ($shipping_type eq 'weight') or
		     ($shipping_type eq 'none') or
		     ($shipping_type eq 'included')));
	
	# Check for valid shipping table
	if (($shipping_type ne 'included') && ($shipping_type ne 'none'))
	{
		$result = TestShippingTable();
		ExecuteTest('Shipping table validation', $result, ($result eq ''));
	}
}


sub PluginModuleSelfTest
{
	my ($plugin) = @_;
	my $method;
	my $module;
	my $result;
	my $version;

	# Load the module for this plugin
	unless (eval "require '$plugins{$plugin}->{'module'}'")
	{
		print "Could not find plugin module $plugins{$plugin}->{'module'} :\n$@\n";
		return;
	}

	# Get the raw module name
	($module) = split(/\./, $plugins{$plugin}->{'module'});

	$version = '$' . $module . '::VERSION';
	print "\nPlugin Module Version: " . eval($version) . "\n";

	# Generate the plugin module self-test method name
	$method = '&' . $module . '::SelfTest';

	# Return now if the plugin module self-test method doesn't exist
	return unless eval("defined($method)");

	# Attempt to execute the plugin module self-test method
	if ($result = eval($method))
	{
		# Display test self-test results
		print "\nPlugin Module Self Test:\n$result\n";
	}

	else
	{
		# Display the error message
		print "\nPlugin Module Self Test error:\n$@";
	}
}


sub ReportPSDBI
{
	# Attempt to load the PSDBI module
	if (eval "require 'PSDBI.pm'")
	{
		# Display WSDBI module version	
		print qq(

PSDBI Package is installed:
-------
PSDBI module version $PSDBI::VERSION
);

		# Display PSDBS module version	
		print "PSDBS module version $PSDBS::VERSION\n"
			if (eval "require 'PSDBS.pm'");

		# Display WSDBI module version	
		print "WSDBI module version $WSDBI::VERSION\n"
			if (eval "require 'WSDBI.pm'");
	}
}


sub ReportPlugins
{
	my $plugins = keys %plugins;

	print "\n\nNo plugins are installed.\n" if $plugins == 0;

	print "\n\nInstalled plugins:";

	foreach my $plugin (sort keys %plugins)
	{
		print "\n-------\nName  : <b>$plugin</b>\n";

		print "Event : $plugins{$plugin}->{'event'}\n"
			if defined($plugins{$plugin}->{'event'});

		print "Type  : file     --  $plugins{$plugin}->{'file'}\n"
			if defined($plugins{$plugin}->{'file'});
			
		print "Type  : module   --  $plugins{$plugin}->{'module'}\n"
			if defined($plugins{$plugin}->{'module'});
			
		print "Type  : program  --  $plugins{$plugin}->{'program'}\n"
			if defined($plugins{$plugin}->{'program'});
			
		print "Type  : text\n"
			if defined($plugins{$plugin}->{'text'});

		# Test for plugin file
		print "\nChecking for plugin file: File " .
		      (-f $plugins{$plugin}->{'file'} ? 'located' : 'NOT FOUND') .
		      ".\n" 
			if defined($plugins{$plugin}->{'file'});

		# Test for program file
		print "\nChecking for plugin program: File " .
		      (-f $plugins{$plugin}->{'program'} ? 'located' : 'NOT FOUND') .
		      ".\n" 
			if defined($plugins{$plugin}->{'program'});

		# Execute module internal test
		PluginModuleSelfTest($plugin)
			if defined($plugins{$plugin}->{'module'});
	}
}


sub ExecuteSelfTest
{
	# Get the local time on the web server
	my $now = StoreTime(time());

	# Complete the http header
	print "\n";

	print qq(
<head>
<title>Perlshop Self-Test</title>
</head>
<body>
<h1>Perlshop Self-Test</h1>

<pre>
Store name       : $company_name
Server address   : $server_address
);

	print "Secure address   : $secure_server_address"
		if lc $use_secure_server eq 'yes';

	print qq(
Local time       : $now
Software version : $PerlShop_version
);

	print qq(

Executing Internal Self-Test:
-------
);

	# Execute self-test
	SelfTest();

	# Report on the PSDBI packages
	ReportPSDBI();

	# Display installed plugins
	ReportPlugins();

	print qq(
</pre>

Self-Test complete.

</body>
</html>
);
}


##############################
# Library file return code
1;


