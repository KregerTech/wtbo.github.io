#!/usr/local/bin/perl

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4
#
# Version 4.5.00 Development 4
#
# Copyright (c) 2004 by David M. Godwin
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


#----------------------------------------

# This program requires perl version 5.004 or higher
require 5.004;


# Language directives
use strict 'refs';
use strict 'subs';


# Load standard Perl library modules
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use FindBin;


# Add Perlshop directories to the library search list.
# This is to help badly configured web servers find the 
# perlshop configuration file and support libraries.
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/../lib";
use lib 'cgi-bin';
use lib 'library';


# Don't buffer output
$| = 1;		   			


# Signal trapping armor
$SIG{CHLD} = 'IGNORE';
$SIG{HUP}  = 'IGNORE';
$SIG{INT}  = 'IGNORE';
$SIG{QUIT} = 'IGNORE';
$SIG{TERM} = 'IGNORE';


# Get all cookie values
%Cookies = map split (/=/), split (/; /,$ENV{HTTP_COOKIE});   


#----------------------------------------

$PerlShop_version = '4.5.00 Development 4';

$copyright = qq(
This is PerlShop version $PerlShop_version.
Copyright (c) 2003 by David M. Godwin.
Visit us at http://www.WaveriderSystems.com.
);


# Default Perlshop logo file
$perlshop_logo = 'perllogo.gif';

# Name of perlshop configuration file
$config_file_name = 'ps.cfg';

# Default values for built-in search function
$searchCatalogPage = '';
$searchResultBorder = 1;
$searchResultColumns = 2;

# Default values for order related settings
$card_security_code = 'no';
$cart_content_caption = 'Your Current Order Selections';
@countries_requiring_state = ('AU', 'CA', 'US');
$disc_rate;
$found_tax = 0;
$offer_restart_on_return = 'yes';
$orderFormPage = '';
$shipping_precision = 0;
$store_timezone_offset = 0;
$tax_on_handling = 'no';
$tax_on_shipping = 'no';

# Default values for security related settings
$cache_control = 1;
$form_submission_method = 'POST';
$link_secure = 0;

# Default values for email related settings
$email_to_customer	= 'yes';
$email_to_store		= 'yes';
$email_title_line	= 'SALES INVOICE';
$email_invoice_term	= 'invoice';


# This is the html used as the cart content display table caption.
$cart_content_caption = '<big>Your Current Order Selections</big>';

$product_image_in_cart = 'no';
$product_id_in_cart = 'yes';


# Default setting for the final checkout message html.
$view_cart_instructions = qq(
<li>Press the <nobr><font color="navy">CONTINUE SHOPPING</font></nobr> button to see more items.<br>

<p>
<li>When you are satisfied with your order, please press 
<nobr><font color="navy">CHECK OUT</font></nobr> to enter your payment and delivery information.<br>
);


# Default setting for the cart display message html.
$final_preview_cart_instructions = qq(
<div align="center">
If you are satisfied with your order, press the 
<nobr><font color="navy">PLACE ORDER</font></nobr> button now<br>
and your order will be securely transmitted to our office staff.
</div>
);


# Default html page titles for various Perlshop actions.
%page_title =
(
	'ADD'		=> 'Your Current Order',
	'SECURE SUBMIT'	=> 'Final Order Verification',
	'SUBMIT'	=> 'Final Order Verification',
	'UPDATE'	=> 'Your Current Order',
	'VIEW ORDERS'	=> 'Your Current Order'
);


#---------- Get the Current Directory and program title ----------
# Are we running on Windows?
if (index($0, '\\') != -1)
{	
	$program_title = substr($0, rindex($0, '\\') + 1);
	$curr_dir = substr($0,0,-(length($0) - rindex($0, '\\') - 1));
	$windows = 1;
}

# We're running on some flavor of Unix
else
{
	$program_title = substr($0, rindex($0, '/') + 1);
	$curr_dir = '';
	$windows = 0;
} 


# Process the perlshop configuration file
unless (eval 'require $config_file_name')
{	
	# Generate a diagnostics message if the config file could not be loaded
	print "Content-type:text/plain\n\n";
	print "Could not load $config_file_name file :\n$@\n\n";
	exit;
};


# Test mode switch.  If set to 'yes', deletes customer and order files
# after order has been placed.
$testing = 'no';


# Table of credit card image information
%credit_images =
(
	'American Express'	=>
	{
		'image'	=>	'credit/amex.gif',
		'width'	=>	91,
		'height'	=>	61
	},

	'Discover'			=>
	{
		'image'	=>	'credit/disc.gif',
		'width'	=>	91,
		'height'	=>	61
	},

	'JCB'				=>
	{
		'image'	=>	'credit/jcb.gif',
		'width'	=>	91,
		'height'	=>	61
	},

	'MasterCard'		=>
	{
		'image'	=>	'credit/mcard.gif',
		'width'	=>	91,
		'height'	=>	61
	},

	'Solo'			=>
	{
		'image'	=>	'credit/solo.gif',
		'width'	=>	49,
		'height'	=>	61
	},

	'Switch'			=>
	{
		'image'	=>	'credit/switch.gif',
		'width'	=>	49,
		'height'	=>	61
	},

	'Visa'			=>
	{
		'image'	=>	'credit/visa.gif',
		'width'	=>	91,
		'height'	=>	61
	},

	'PayPal'			=>
	{
		'image'	=>	'credit/paypal.gif',
		'width'	=>	91,
		'height'	=>	61
	}
);


# Shipping units that corespond to the shipping type
%shipping_unit = 
(
	'price'		=>	$local_currency,
	'quantity'	=>	'items',
	'weight'	=>	$local_weight,
	'included'	=>	'items',
	'none'		=>	'items'
);


@item_data_field = ('id', 'name', 'price', 'weight', 
					'option1', 'option2', 'option3',
					'shiptype', 'taxtype',
					'qty', 'qtymin', 'qtymax');


# Initialize global variables
$item_index = '';
$menu_bar = '';    
$using_psdbi = 0;
%psdbi_parameters = ();

$add_page_header = $generate_page_header;

$add_page_footer = $generate_page_footer;

# This is the name of the catalog page file to process
$catalog_page = '';

# Text buffer for optional cart information
$cart_view_message = '';

# Text for real-time transaction approval note
$card_approval_note = '';

# Text for payment type note
$payby_note = '';

# Offset value used with item_shiptype tag
$shipping_offset = 0;

# Initialize shopping cart totals
$total_items    = 0;
$total_quantity = 0;
$total_price    = 0;
$total_weight   = 0;

# Text for invoice page header
$email_invoice_address	= "$company_name<br>$company_address";


###--------For Secure Server Setup----------------------------
# Are we using cgiwrap?
if ($use_cgiwrap eq 'yes')
{
	# make readable/writeable by owner only
	umask 077;

	$cgi_prog_location = $server_address . $cgiwrap_directory . 
						 "/$program_title";

	$secure_prog_location = 
		"$secure_server_address$cgiwrap_directory/$program_title";
}

# Not using cgiwrap
else
{
	$cgi_prog_location = $server_address . $cgi_directory . "/$program_title";

	$secure_prog_location = 
		"$secure_server_address$secure_cgi_directory/$program_title";
}

$secure_image_location= "$secure_server_address$secure_image_directory"; 

$checkout_url = (($use_secure_server eq 'yes')
					? $secure_prog_location 
					: 'http://' . $cgi_prog_location);


# Process program CGI parameters
ProcessCGI();


# Decode redirection URL string.
$input{'REDIRECT_URL'} =~ s/%(..)/pack("C", hex($1))/eg;
$redirect_decoded = $input{'REDIRECT_URL'};

# Create a URL encoded version of the redirection URL string
$redirect_encoded = URLEncode($redirect_decoded);


# Record command parameter value, removing trailing white space
$action = uc $input{'ACTION'};
$action =~ s/\s+$//;


# Remove invalid characters from the THISPAGE parameter
$input{'THISPAGE'} =~ s/[|()<>;&]//g;


# If we're using a secure link, make sure we're using the correct images
# directory
if (($use_secure_server eq 'yes') and
	(($action =~ /SECURE/i)	or
	 ($action =~ /CHECK/i)  or
	 ($action =~ /PLACE/i)	or
	 ($action =~ /ONLINE_VERIFICATION_RESULT/i)))
{
	$link_secure = 1;
	$image_location = $secure_image_location
}


# Did we receive a back-end cart creation command?
if ($action eq 'CREATE CART')
{
	# Create the shopping cart
	CreateToken();

	# Redirect to the specified front-end URL
	print "Location:$create_cart_redirection_url&order_id=$unique_id\n\n";

	exit;
}

# Are we doing a back-end continue to a front-end URL?
elsif (($action =~ /^CONTINUE/) && ($input{'REDIRECT_URL'} ne ''))
{
	# Redirect to the store URL
	print "Location:$redirect_decoded\n\n";

	exit;
}

# Are we doing a CONTINUE SHOPPING command via plugin?
elsif (($action =~ /^CONTINUE/) && ($input{'PLUGIN'} ne ''))
{
	$action = 'PLUGIN';
}


# Generate the http page header
print "Content-type: text/html\n";

# Since catalog pages are dynamically generated,
# don't allow them to be cached by the browser.
# Allow the order form page to be cached in case
# the customer has to go back and change a field.
# Allow the final invoice screen to be cached to
# allow stupid browsers to print the page.
if ($cache_control && ($action ne 'CHECK OUT') && ($action ne 'PLACE ORDER'))
{
	print "CacheControl: no-cache\n";
	print "Pragma: no-cache\n";
	print "Expires: Thu, 01 Jan 1980 00:00:00 GMT\n";
}

# Generate the end of header marker unless we have cookie
# stuff to deal with later.
print "\n"
	unless (lc $use_cookies eq 'yes');


# When using cgiwrap, this script's permissions should be set to 700 
# so that the script would not even run unless cgiwrap were used, 
# but in case you forgot to set the permission to 700, the following 
# fail-safe check is used.
if (($< == 65534) && ($use_cgiwrap eq 'yes')) 
{
	print "\n\nAttempt to bypass Cgiwrap!\n";
	exit;
}


#-----------------------------------------------------------

# Default action is self-test
$action = 'SELFTEST'
	if ($action eq '') and ($input{'THISPAGE'} eq '') and 
	   ($input{'ORDER_ID'} eq '') and ($input{'CUSTID'} eq '');


# Did we receive a plugin self-init command?
if ($action eq 'INIT_PLUGIN')
{
	# Include Perlshop plugin support library
	LoadLibrary('ps_plugin.pl');

	InitializePlugins();

	exit;
}

# Did we receive a self-test command?
elsif ($action eq 'SELFTEST')
{
	# Include Perlshop self-test library
	LoadLibrary('ps_selftest.pl');

	ExecuteSelfTest();

#print qq(
#<p>
#Bin = $FindBin::Bin<br>
#Script = $FindBin::Script<br>
#RealBin = $FindBin::RealBin<br>
#RealScript = $FindBin::RealScript<br>
#);

#print "<hr>\nCookies:<br>\n";
#foreach my $cookie (sort keys %Cookies)
#{
#	print "$cookie: $Cookies{$cookie}<br>\n";
#}

	exit;
}

# Have we received a command to enter the store for the first time?
elsif ((substr($action, 0, 5) eq 'ENTER') or
       (substr($action, 0, 5) eq 'GO TO') or
       (substr($action, 0, 2) eq '->')    or
       (substr($action, 0, 1) eq '[')) 
{
	EnterShop();

	ExecutePlugins('after_enter_shop', $unique_id);

	# Do we have a specific enter action to perform?
	$action = uc $input{'ENTERACTION'}
		if $input{'ENTERACTION'} ne '';
}

# Are we performing a one-shot QuickBuy?
elsif ($action eq 'QUICKBUY')
{
	QuickBuy();

	ExecutePlugins('after_enter_shop', $unique_id);
}

# We're performing some action for a customer that is already in the store
else 
{		
	ValidateCustomer();
}


#-----------------------------------------------------------

# Generate the names of the directories we'll be using
$order_file_name    = "$temp_orders_directory/$unique_id";
$customer_file_name = "$temp_customers_directory/$unique_id";
$token_file_name    = "$token_directory/$unique_id";


# Do we have an invoice note to record?
AddNote($input{'NOTE'})
	if $input{'NOTE'} ne '';


# Execute any pre-action plugins
ExecutePlugins('before_execute_action', $unique_id, $action);

# Did we get a command to add items to a shopping cart?
if (($action =~ /^ADD/i)		||
	($action =~ /^BUY/i)		||
	($action =~ /^ORDER/i)		||
	($action =~ /^PURCHASE/i)	||
	($action =~ /^PUT/i)		||
	($action =~ /^REGISTER/i))
{
	# Ensure common use of action value
	$action = 'ADD';

	ExecutePlugins('before_add_item', $unique_id);

	# Include Perlshop cart support library
	LoadLibrary('ps_cart.pl');

	# Add the new items to the orders file 
	AddItemsToCart();

	ExecutePlugins('after_add_item', $unique_id);
}

# Did we get a command to view a shopping cart?
elsif ($action eq 'VIEW ORDERS') 
{
	# Display the shopping cart
	ViewCart();

	exit;
}

# Did we get a command to update a shopping cart
elsif ($action eq 'UPDATE') 
{
	check_if_orders_exist();

	# Include Perlshop cart support library
	LoadLibrary('ps_cart.pl');

	UpdateShoppingCart();
}

# Did we get a command to perform a customer checkout?
elsif ($action eq 'CHECK OUT')
{ 
	check_if_orders_exist();

	# Make sure the minimum purchase limits have been reached
	CheckMinimumPrice();
	CheckMinimumQuantity();

	# Call any external order pre-processing plugins
	ExecutePlugins('before_check_out', $unique_id);

	# Are we using the default Perlshop checkout form?
	if ($orderFormPage eq '')
	{
		# Include Perlshop checkout library
		LoadLibrary('ps_checkout.pl');

		# Have Perlshop generate the order form
		GenerateOrderForm();

		exit;
	}

	# We are using a custom order form
	else
	{
		# Prepare to load the custom order form just like any other catalog page
		$input{'THISPAGE'} = $orderFormPage;

		# Don't display the "Check Out" button on the order form page
		$button_data{'CHECK OUT'}->{'visible'} = 0;
	}
}

# Did we get a command to handle a customer information form?
elsif ($action =~ /SUBMIT$/)
{
	# Call any external order pre-processing plugins
	ExecutePlugins('before_submit_customer', $unique_id);

	# Loaded needed libraries
	LoadLibrary('ps_checkout.pl');
	LoadLibrary('ps_selftest.pl');

	SubmitCustomerInformation();

	# Call any external order post-processing plugins
	ExecutePlugins('after_submit_customer', $unique_id);

	exit;
}

# Did we get a command to place an order?
elsif ($action eq 'PLACE ORDER') 
{
	# Make sure the minimum purchase limits have been reached
	CheckMinimumPrice();
	CheckMinimumQuantity();

	# Call any external order pre-processing plugins
	ExecutePlugins('before_place_order', $unique_id);

	# Include Perlshop checkout library
	LoadLibrary('ps_checkout.pl');

	PlaceOrder();

	# Call any external order post-processing plugins
	ExecutePlugins('after_place_order', $unique_id);

	exit;
}	

# Did we get a command to display the shipping rates table?
elsif ($action eq 'SHIPPING RATES')
{
	ShowShippingRates();

	exit;
}

# Did we get a command to display the search interface?
elsif ($action eq 'SEARCH')
{
	# Do we use the standard search interface?
	if ($searchCatalogPage eq '')
	{
		# Include Perlshop search library
		LoadLibrary('ps_search.pl');

		PageHeader('Search the Catalog');
		add_menu_bar('CONTINUE SHOPPING');
		add_company_header();	
		add_search_screen();
		add_company_footer();

		exit;
	}

	# Load the custom search interface screen
	else
	{
		$useInternalSearch = 'no';
		$input{'THISPAGE'} = $searchCatalogPage;
	}
}

# Did we get a command to perform a catalog search?
elsif (($action eq 'SEARCH CATALOG') || 
	   ($input{'DOSEARCH'} eq 'SEARCH CATALOG'))
{
	# Include Perlshop search library
	LoadLibrary('ps_search.pl');

	ExecuteCatalogSearch();

	exit;
}

# Did we get a command to perform an order restart?
elsif ($action eq 'RESTART')
{
	# Destroy the current order file
	unlink $order_file_name;
}

# Did we get a request to generate a web page via external plugin?
elsif ($action eq 'PLUGIN')
{
	# Execute the external plugin call
	HandlePlugin();

	exit;
}

# Did we get a request to load a PSDBI page?
elsif ($action eq 'PSDBI')
{
	# Prepare to process a standard psdbi page
	HandlePSDBI('file', $input{'THISPAGE'}, "$catalog_directory/psdbi");

	# Update the value of the 'thispage' parameter so that all prev and next
	# page links work correctly
	$input{'THISPAGE'} = "psdbi/$input{'THISPAGE'}";

	# Generate the web page
	GenerateCatalogPage();

	exit;
}

# Did we get a request to load a page template?
elsif ($action eq 'TEMPLATE')
{
	# Prepare to handle a psdbi template page
	HandlePSDBI('name', $input{'THISPAGE'}, "$catalog_directory/template");

	# Generate the web page
	GenerateCatalogPage();

	exit;
}


# Do we need to generate the page content using a plugin?
# (Custom search interface page is exempted)
# (Custom order form interface page is exempted)
if (defined($input{'PLUGIN'}) && ($action ne 'SEARCH') && ($action ne 'CHECK OUT'))
{
	$action = 'PLUGIN';

	# Execute the external plugin call
	HandlePlugin();
}

# Has a specific catalog page file been requested?
elsif (defined($input{'THISPAGE'})) 
{   
	# Is a psdbi catalog page being asked for?
	# (The name reference will begin with 'psdbi/'.)
	if ($input{'THISPAGE'} =~ m:^psdbi/:)
	{
		# Prepare to handle a standard psdbi page
		HandlePSDBI('file', $input{'THISPAGE'}, $catalog_directory);
	}

	# Is a psdbi template page being asked for ?
	# (The name reference will contain no '.' character.)
	elsif ($input{'THISPAGE'} !~ /\./)
	{
		# Prepare to handle a psdbi template page
		HandlePSDBI('name', $input{'THISPAGE'}, "$catalog_directory/template");
	}

	# Use a static web page file
	else
	{
		$catalog_page = "$catalog_directory/$input{'THISPAGE'}";	
	}

	# Generate the web page
	GenerateCatalogPage();
}

# Terminate program
exit;


#------------------------------------------------------------------
sub ParseFile 
{
	my ($catalog_page) = @_;
	my ($result_page, $item_id, $item_price, $item_qty, $item_name, 
		$item_weight, $item_taxtype, $item_shiptype, $item_code,
		$qty_min, $qty_max);
	my $sizefmt = 'bytes';
	my $timefmt = "%c";
	my $ssi_errmsg = '[An error occurred while processing this directive]';
	my $added_nav = 0;
	my $content;
	my $work;
	my %pstagAttributes;

	my @catalog_page_text;
	my $catalog_page_index;
	my $catalog_page_lines;

	local $_;


# Nested subroutine for performing XSSI command emulation
my $Emulate_SSI = sub
{
	local $_;
	my $nowtime;
	my $ssi_command = lc $1;
	my $ssi_arg = lc $3;
	my $size;
	my $t;
	my @lines;
	my $external_command;

	if (lc $2 eq 'file')
		{$ssi_arg = "$catalog_directory/$ssi_arg";}	
	elsif (lc $2 eq 'virtual')
		{$ssi_arg = "$ENV{'DOCUMENT_ROOT'}$ssi_arg";}				

	if ( ((lc $2 eq 'file' || lc $2 eq 'virtual')) && (! -e $ssi_arg) )
		{
		$result_page = $ssi_errmsg;
		}

	elsif ($ssi_command eq 'include')
		{
		$result_page .= ParseFile($ssi_arg);
		}

	elsif ($ssi_command eq 'fsize')
		{
		$size = -s $ssi_arg;			
		if (lc $sizefmt eq 'abbrev')
			{$result_page .= int(($size / 1024) + 1) . ' Kbytes';}
		else
			{$result_page .= "$size bytes";}
		}

	elsif ($ssi_command eq 'flastmod')
		{
		($t,$t,$t,$t,$t,$t,$t,$t,$t,$nowtime,$t,$t,$t)=stat($ssi_arg);
		$result_page .= &format_time($nowtime, $timefmt, 1);
		}

	elsif ($ssi_command eq 'config')
		{
		if ($2 eq 'errmsg')
			{$ssi_errmsg = $ssi_arg;}
		elsif ($2 eq 'sizefmt')
			{
			if ($ssi_arg eq 'bytes' || $ssi_arg eq 'abbrev')
				{$sizefmt = $ssi_arg;}
			else
				{$result_page .= $ssi_errmsg;} 
			}
		elsif ($2 eq 'timefmt')
			{$timefmt = $ssi_arg;}
		else
			{$result_page .= $ssi_errmsg;} 
		}

	elsif ($ssi_command eq 'echo')
		{
		if ($ssi_arg eq 'document_name')
			{$result_page .= $input{'THISPAGE'};}
		elsif ($ssi_arg eq 'document_uri')
			{$result_page .= $catalog_page;}
		elsif ($ssi_arg eq 'date_local')
			{$result_page .= &format_time(time(), $timefmt, 1);}
		elsif ($ssi_arg eq 'date_gmt')
			{$result_page .= &format_time(time(), $timefmt, 0);}
		elsif ($ssi_arg eq 'last_modified')
			{
			($t,$t,$t,$t,$t,$t,$t,$t,$t,$nowtime,$t,$t,$t)=stat($catalog_page);
			$result_page .= &format_time($nowtime, $timefmt, 1);
			}
		}

	elsif (($ssi_command eq 'exec') && (lc $allow_ssi_cgi eq 'yes'))
		{
		# Get the external command string from the SSI call
		$external_command = $3;

		# If the external command does not start with a slash, 
		# prepend a local path reference to it.
		$external_command = "./$external_command"
			unless ($3 =~ /^\//);

		$result_page .= "<!-- SSI execute.  Command is '$external_command' -->\n";
		@lines = qx($external_command);
		$result_page .= join('', @lines);
		}

	elsif ($ssi_command eq 'printenv')
	{
		foreach my $var (sort keys %ENV)
		{
			$result_page .= "$var = $ENV{$var}\n";
		}
	}
};


# Nested subroutine for performing ITEM_DATA tag parsing
my $ParseItemData = sub
{
	my ($item_data) = @_;
	my @list = split(/\|/, $item_data);
	my $element;
	my $name;
	my $value;

	for ($element = 0; $element <= $#list; $element++)
	{
		if ($list[$element] =~ /:/)
		{
			($name, $value) = split(/:/, $list[$element], 2);
		}

		else
		{
			$name = $item_data_field[$element];
			$value = $list[$element];
		}

		if (($name eq 'id') || ($name eq 'i'))
		{
			$item_id = $value;
		}

		elsif (($name eq 'name') || ($name eq 'n'))
		{
			$item_name = $value;
		}

		elsif (($name eq 'price') || ($name eq 'p'))
		{
			$item_price = $value;
		}

		elsif (($name eq 'weight') || ($name eq 'w'))
		{
			$item_weight = $value;
		}

		elsif (($name eq 'shiptype') || ($name eq 's'))
		{
			$item_shiptype = $value;
		}

		elsif (($name eq 'taxtype') || ($name eq 't'))
		{
			$item_taxtype = $value;
		}

		elsif (($name eq 'qty') || ($name eq 'q'))
		{
			$item_qty = $value;
		}

		elsif (($name eq 'qtymin') || ($name eq 'qn'))
		{
			$qty_min = $value;
		}

		elsif (($name eq 'qtymax') || ($name eq 'qx'))
		{
			$qty_max = $value;
		}

		elsif ($name eq 'ci')
		{
			$confirm_item_code = $value;
		}
	}
};


########################
# Start of sub ParseFile
#
	# Check for valid catalog file name
	if (check_file_title($catalog_page) == 0)
	{
		print $error_msg;
		exit;
	}

	# Remove all invalid characters
	$catalog_page =~ s/[()<>;&]//g;

	# Remove quotes and pipe unless they are specifically allowed
	$catalog_page =~ s/["|]//g
		unless ($action eq 'PLUGIN') or $using_psdbi;

	# Do we have a valid catalog page identifier?
	if (($catalog_page =~ /\|$/) or 		# External plugin call
		($catalog_page eq 'PSDBI') or		# PSDBI call
		(-e $catalog_page))					# Static catalog page
	{
		# Does the token file exist?
		if (-e $token_file_name) 
		{
			open(token_file, $token_file_name) or
				error_trap("cannot open token file $token_file_name : $!");
			$token = <token_file>;
			chop($token);
		}		

		# Initialize all tracking variables
		$item_id = ''; 
		$item_name = ''; 
		$item_price = ''; 
		$item_shiptype = '';
		$item_taxtype = ''; 
		$item_weight = 0; 
		$item_qty = ''; 
		$qty_min = ''; 
		$qty_max = ''; 
 	        
		# Clear the output buffer
		$result_page = '';

		# Are we using the PSDBI module to generate the page text?
		if ($catalog_page eq 'PSDBI')
		{
			LoadLibrary('PSDBI.pm');
			@catalog_page_text = PSDBI::GeneratePage(\%psdbi_parameters);
		}

		# We're loading a static catalog page file
		else
		{
			# Read in the catalog page file
			open(PAGE_FILE, $catalog_page) or
				error_trap("cannot open template file $catalog_page : $!");
			@catalog_page_text = <PAGE_FILE>;
			close PAGE_FILE;
		}

		# Remember the number of lines of text we need to process
		$catalog_page_lines = scalar @catalog_page_text;

		# Process the catalog page file text
		for ($catalog_page_index = 0; 
			 $catalog_page_index < $catalog_page_lines;
			 $catalog_page_index++)
		{	
			$_ = $catalog_page_text[$catalog_page_index];

			# Is there a pstag on this line?
			if (/<(!--)?PSTAG\s+(.*?)\s*(--)?>/i)
			{
				# Get the attribute list content from the pstag
				$content = $2;

				# Initialize the attribute storage table
				%pstagAttributes = ();
			
				# Parse all unquoted attribute values
				$work = $content;
				$work =~ s/(\w+)=([^\s]+)/$pstagAttributes{$1} = $2/eg;
			
				# Parse all quoted attribute values
				$work = $content;
				$work =~ s/(\w+)="([^"]*)"/$pstagAttributes{$1} = $2/eg;
			
				# Record prev page file name, if given
				$prev_page = $pstagAttributes{'prevpage'}
					unless $pstagAttributes{'prevpage'} eq '';
			
				# Record next page file name, if given
				$next_page = $pstagAttributes{'nextpage'}
					unless $pstagAttributes{'nextpage'} eq '';

				# Do we have specific header instructions for this page?
				if ($pstagAttributes{'header'} ne '')
				{
					$add_page_header = 
						(($pstagAttributes{'header'} eq 'on') ? 1 : 0);
				}
 
				# Do we have specific footer instructions for this page?
				if ($pstagAttributes{'footer'} ne '')
				{
					$add_page_footer = 
						(($pstagAttributes{'footer'} eq 'on') ? 1 : 0);
				}

				# Case: There are items in the cart, and the order form has
				# not yet been filled out.
				if ((-e $order_file_name) && (! -z _) && 
					(!(-e $customer_file_name)))
				{
					add_menu_bar('VIEW ORDERS', 'CHECK OUT', 'SEARCH');
				}
			
				# Case: There are items in the cart, and the order form has
				# been filled out.
				elsif ((-e $order_file_name) && (! -z _) && 
					   (-e $customer_file_name))
				{
					add_menu_bar('VIEW ORDERS', 'PLACE ORDER', 'SEARCH');
				}
			
				# Case: There are no items in the shopping cart.
				else
				{
					add_menu_bar('SEARCH');
				}
			}

			# Look for SSI directives
			if ( /\<!\-\-\#(include|fsize|flastmod|config|echo|exec)\s+(file|virtual|errmsg|sizefmt|timefmt|var|cmd|cgi)\s*\=\s*\"(.*?)\"\s+\-\-\>/i )
			{
				&$Emulate_SSI();
			}

			# Look for embedded plugin execution tags
			if (/\<!\-\-\#plugin\s+(.*?)\s+\-\-\>/i)
			{
				$result_page .= EmbeddedPlugin($1);
			}

			# Is this the start of the selection form for this page?
			if (/<form{1}?\s+?/i) 
			{
				# Substitute for the MYURL symbol
				s/(\"?)!MYURL!(\"?)/\"http\:\/\/$cgi_prog_location\"/ig;

				# Append this line to the outgoing result page
				$result_page .= $_;

				# Read the next line from the template
				$_ = $catalog_page_text[++$catalog_page_index];
					
				# Initialize the tracking variables
				$item_index = '';
				$item_code = '';

				# Loop until we hit the end of the form
				do 
				{
					# Is this an SSI directive?
					if ( /\<!\-\-\#(include|fsize|flastmod|config|echo|exec)\s+(file|virtual|errmsg|sizefmt|timefmt|var|cmd|cgi)\s*\=\s*\"(.*?)\" \-\-\>/i )
					{
						&$Emulate_SSI();
					}

					# Look for embedded plugin execution tags
					elsif (/\<!\-\-\#plugin\s+(.*?)\s+\-\-\>/i)
					{
						$result_page .= EmbeddedPlugin($1);
					}

					# Is this an ITEM_DATA field?
					elsif ( /ITEM_DATA{1}?\"?\s+VALUE\s*?=\s*?\"?([^\"]+)\"?/i)
					{
						&$ParseItemData($1);

						s/ITEM_DATA/ITEM_DATA$item_index/i;
					}		

					# Is this an ITEM_ID field?
					elsif ( /ITEM_ID{1}?\"?\s+VALUE\s*?=\s*?\"?([^\"]+)\"?/i)
					{
						$item_id = $1;
						s/ITEM_ID/ITEM_ID$item_index/i;
					}		

					# Is this an ITEM_PRICE field?
					elsif ( /ITEM_PRICE{1}?\"?\s+VALUE\s*?=\s*?\"?([^\"]+)\"?/i)
					{
						$item_price = UnCurrency($1);
						if ($item_price !~ /(\d+\.\d{1,2}|\d+\.?|\.\d{1,2}|!\w+!){1}/)
						{
							error_trap("ITEM_PRICE ($1) format is not valid");
						}

						s/ITEM_PRICE/ITEM_PRICE$item_index/i;
					}

					# Is this an ITEM_NAME field?
					elsif ( /ITEM_NAME{1}?\"?\s+VALUE\s*?=\s*?\"?([^\"]+)\"?/i)
					{
						$item_name=$1;
						s/ITEM_NAME/ITEM_NAME$item_index/i;
					}

					# Is this an QTY field?
       				elsif ( /NAME\s*?=\s*?\"?QTY{1}?\"?\s+VALUE\s*?=\s*?\"?(\d+\.\d+|\d+\.?|\.\d+){1}\"?/i)
					{					
						$item_qty = $1;
						s/NAME\"?\s*?=\s*?(\")?QTY/NAME=$1QTY$item_index/i;
					}			

					# Is this an QTY_MIN field?
       				elsif ( /NAME\s*?=\s*?\"?QTY_MIN{1}?\"?\s+VALUE\s*?=\s*?\"?(\d+){1}\"?/i)
					{					
						$qty_min = $1;
						s/NAME\"?\s*?=\s*?(\")?QTY_MIN/NAME=$1QTY_MIN$item_index/i;
					}			

					# Is this an QTY_MAX field?
       				elsif ( /NAME\s*?=\s*?\"?QTY_MAX{1}?\"?\s+VALUE\s*?=\s*?\"?(\d+){1}\"?/i)
					{					
						$qty_max = $1;
						s/NAME\"?\s*?=\s*?(\")?QTY_MAX/NAME=$1QTY_MAX$item_index/i;
					}			

					# Is this an ITEM_WEIGHT field?
					elsif ( /ITEM_WEIGHT{1}?\"?\s+VALUE\s*?=\s*?\"?(\d+\.\d+|\d+\.?|\.\d+){1}\"?/i)					
					{
						$item_weight = $1;
						s/ITEM_WEIGHT/ITEM_WEIGHT$item_index/i;
					}

					# Is this an ITEM_TAXTYPE field?
					elsif ( /ITEM_TAXTYPE{1}?\"?\s+VALUE\s*?=\s*?\"?(\w+)\"?/i)
					{
						$item_taxtype = $1;
						s/ITEM_TAXTYPE/ITEM_TAXTYPE$item_index/i;
					}

					# Is this an ITEM_SHIPTYPE field?
					elsif ( /ITEM_SHIPTYPE{1}?\"?\s+VALUE\s*?=\s*?\"?(\w+)\"?/i)
					{
						$item_shiptype = $1;
						s/ITEM_SHIPTYPE/ITEM_SHIPTYPE$item_index/i;
					}

					# Is this an ITEM_OPTION field?
					elsif ($_ =~ s/ITEM_OPTION(\d)/ITEM_OPTION$1$item_index/gi)
					{
					}

					error_trap("Found opening &lt;form...&gt; tag with no closing &lt;/form...&gt; tag")
						if /<form{1}?\s+?/i;

					# Once we have ID, name, price, and quantity, we can
					# compute the signature for this item
					if (($item_id ne '') &&
						($item_price ne '') &&
						($item_qty ne '') &&
						($item_name ne ''))
					{										
						$item_code .= $item_id . $item_price . $item_weight . 
									  $item_taxtype;

$_ .= qq(
<!--
Code   : |$item_code|
ID     : |$item_id|
Name   : |$item_name|
Price  : |$item_price|
Ship   : |$item_shiptype|
Tax    : |$item_taxtype|
Weight : |$item_weight|
Qty    : |$item_qty|
Qtymin : |$qty_min|
Qtymax : |$qty_max|
-->
);
						
						# Reset all tracking variables
						$item_id = '';
						$item_name = '';
						$item_price = '';
						$item_shiptype = '';
						$item_taxtype = '';
						$item_weight = 0;
						$item_qty = '';
						$qty_min = '';
						$qty_max = '';

						# Increment item index
						$item_index = ($item_index eq '') ? 1 : $item_index + 1;
					}				
			
					if (/!ITEMCODE!/i)
					{			
						if ($item_code eq '')
						{
#							error_trap(qq(
#!ITEMCODE! found before one of: ITEM_ID, ITEM_PRICE, QTY, ITEM_NAME.<br>
#Tags may be in wrong order, or each tag may not be completely on a line 
#by itself.<br><br></center>
#ITEM_ID=$item_id<br>
#ITEM_PRICE=$item_price<br>
#ITEM_NAME=$item_name<br>
#QTY=$item_qty<center>));
						} 		

						else
						{
							# Generate the ITEMCODE value.
							# This is done by SHA encoding a string which is
							# composed of the customer IP address, the
							# computed item code string for this catalog
							# page, and the session token value

							if ($confirm_customer_ip)
							{
$_ .= "<!-- Computing SHA with RA -->\n";
								$item_code = SHA($ENV{'REMOTE_ADDR'} . 
												 $item_code . $token);
							}

							else
							{
$_ .= "<!-- Computing SHA -->\n";
								$item_code = SHA($item_code . $token);
							}
$_ .= "<!-- SHA is |$item_code| -->\n";

							# Replace all ITEMCODE symbols
							$_ =~ s/!ITEMCODE!/$item_code/igeo;

							$_ .= "\n<INPUT TYPE=HIDDEN NAME=MULTIPART VALUE=TRUE>"
								if $item_index > 1;
						}
					}						
		
					# Append this line to the result page
					$result_page .= $_;		
				
					error_trap("Unexpected EOF in file: $catalog_page. &lt;form&gt; without matching &lt;/form&gt;?<br>\n")
						if $catalog_page_index >= $catalog_page_lines;

					# Read the next line from the template
					$_ = $catalog_page_text[++$catalog_page_index];

				#do	
				} until (m|</form{1}?|i);					

			} #if 

			# Append this line from the catalog page to the output buffer
			$result_page .= $_;
	
			# If needed, add top-of-page navigation stuff
			if (!$added_nav && ($add_navigation eq 'yes') && 
				($result_page =~ /<BODY[^<]*>\s+$/ios))
			{
				$result_page .= add_company_header(1, 1);
				$added_nav = 1;
			}

		} #while

	}	

	# If the file is missing, send error message back.
	else
	{	
		PageHeader('Page Not Available');
		print qq(
<body id="$errorPageStyle">
<h3 align="center">The page ($catalog_page) you have requested is not available.</h3>
);

		$catalog_page = '';
		add_button_bar();

		print qq(
</body>
</html>
);

		exit;
	}

	# Replace all ORDERID symbols with the actual Order ID
	$result_page =~ s/!ORDERID!/$unique_id/igms;

	# Replace all MYWWW symbols with the actual Server URL
	$result_page =~ s/(\"?)!MYWWW!([\.\-\_\/\w]*)(\"?)/\"http\:\/\/$server_address$2\"/igms;

	# Replace all MYWWW symbols with the actual CGI URL
	$result_page =~ s/(\"?)!MYURL!(\"?)/${1}http\:\/\/$cgi_prog_location$2/igms;

	return $result_page;
}


sub ViewRebates
{
	my ($colspan, $show_subtotal) = @_;

	return if keys(%rebate_table) == ();

	if ($show_subtotal)
	{
		print qq(
<tr align="right">
<td colspan=$colspan>Sub Total:</td>
<td>$pre_rebate_grand_total</td>
</tr>
);
	}

	foreach my $rebate (sort keys %rebate_table)
	{
		$rebate_cur = Currency($rebate_table{$rebate}->{'amount'});

		print qq(
<tr align="right">
<td class="rebateRow" colspan=$colspan>
$rebate_table{$rebate}->{'description'}:</td>
<td valign="bottom">$rebate_cur</td>
</tr>
);
	}
}


sub ViewCart
{
	# Include Perlshop cart display library
	LoadLibrary('ps_cart.pl');

	DisplayCartContents();
}


sub add_company_footer
{
	my $address = '';
	my $result = '';

	# Skip if we're suppressing the page footer
	return
		unless $add_page_footer;

	$result .= ExecutePlugins('above_page_footer', $unique_id) . "<p>\n";
	
	# Display company logo image at bottom of page
	if ($bottom_center_logo ne '')
	{
		$result .= qq(
<div align="center">
<img src="$image_location/$bottom_center_logo" border=0><br>
</div>
);
	}

	# Display company address
	if ($address_in_footer)
	{
		$address .= "$company_name<br>"
			if ($company_name ne '');

		$address .= "$company_address<br>"
			if ($company_address ne '');

		$address .= "$company_hours<br>"
			if ($company_hours ne '');

		$address .= qq(<a href="mailto:$company_email" title="Send us mail">$company_email</a>\n)
			if ($company_email ne '');

		$result .= qq(
<div align="center">
<b><small><address>
$address
</address></small></b>
</div>
);
	}

	# Include content warning
	if ($show_content_warning eq 'yes')
	{
		$result .= qq(
<hr width="90%">
<table align="center" width="90%" border=0>
<tr><td align="center">
<small><small>
<i>
All content, including prose, images, HTML, and JavaScript, are the sole
property of $company_name, and may not be used for any purpose without
express written permission.
</i>
</small></small>
</td></tr>
</table>
);
	}

	$result .= ExecutePlugins('below_page_footer', $unique_id) . "<p>\n";

	# Display perlshop logo at bottom of page
	if ($display_ps_logo eq 'yes')
	{
		$result .= qq(
<div align="center">
<a href="http://www.waveridersystems.com" target="_blank">
<img src="$image_location/waverider.jpg" align="center"
	alt="Perlshop 4 from Waverider Systems" border=0 height=52 width=73></a>
</div>
);
	}

	$result .= qq(
</body>
</html>
);

	print $result;
}


#------------------------------------------------------------------#
sub add_company_header 
{
	my ($skip_body, $skip_print, $style) = @_;
	
	my $result_line = '';
	my $body;
	
	$style = $catalogPageStyle
		if $style eq '';

	# Are we adding content to the body tag ?
	if (!$skip_body)
	{
		$body = '';
		
		$body .= "text=\"$text_color\" "
			if ($text_color ne '');
		
		$body .= "bgcolor=\"$background_color\" "
			if ($background_color ne '');
		
		$body .= "link=\"$link_color\" "
			if ($link_color ne '');
		
		$body .= "vlink=\"$vlink_color\" "
			if ($vlink_color ne '');
		
		$body .= "alink=\"$alink_color\" "
			if ($alink_color ne '');
		
		$body .= "background=\"$image_location/$background\" "
			if ($background ne '');
	
		$body .= qq(id="$style" )
			if ($style ne '');

		$result_line .= "\n<body $body>\n";
	}

	$result_line .= ExecutePlugins('header_above_banner', $unique_id);

	# Are we adding an automatic header to each page?
	if ($add_page_header)
	{
		# Include the menu bar
		$result_line .= "$menu_bar\n\n";
		
		# If we have a banner, include it
		if ($banner ne '')
		{		
			$result_line .= "<div align=$align>"
				if ($align ne '');
	
			$banner = "<img alt=\"Logo\" src=\"$image_location/$banner\" ";
			if ($hspace ne '')	{ $banner .= "hspace=$hspace ";}
			if ($vspace ne '')	{ $banner .= "vspace=$vspace ";}		
			if ($border ne '')	{ $banner .= "border=$border ";}
			if ($height ne '')	{ $banner .= "height=$height ";}
			if ($width  ne '')	{ $banner .= "width=$width ";}
			$banner .= ">\n";
	
			$banner .= "</div>\n\n"
				if ($align ne '');
	
			$result_line .= $banner;
		}
	}
	
	$result_line .= ExecutePlugins('header_below_banner', $unique_id);

	print $result_line 
		unless $skip_print;
	
	return $result_line;
}


#------------------------------------------------------------------#
sub check_if_orders_exist 
{
	if ((not -e $order_file_name) or (-z $order_file_name)) 
	{   
		# File not found or is empty
		PageHeader('No Items Ordered');

		add_company_header();

		print qq(
<div align="center">
<b>
);

		print scalar ((-z $order_file_name) 
			? 'All items have been deleted.' 
			: 'No items have been ordered yet.');

		# Force page footer to be visible
		$add_page_footer = 1;

		add_button_bar('CONTINUE SHOPPING');	

		add_company_footer();

		print qq(
</b>
</div>
</body>
</html>
);

		exit;
	}
}


sub ShippingAmount
{
	my ($amount) = @_;
	my ($price, $text) = split(/\s+/, $amount, 2);

	$text =~ s/[\$_]/ /g;

	return Currency($price) . " $text";
}


#------------------------------------------------------------------#
sub Currency 
{
	my $price = $_[0];

	# Format the number
	$price = sprintf('%0.2f', $price);

	# Replace decimal with correct symbol as needed
	$price =~ s/\./$currency_decimal/
		if ($currency_decimal ne '.');

	# Add correct currency separators
	while ($price =~ s/(\d)(\d\d\d)(?!\d)/$1$currency_separator$2/g) 
	{}

	# Add currency prefix symbol
	$price = $currency_symbol . $price;

	return $price;
}


#------------------------------------------------------------------#
sub UnCurrency 
{
	my $price  = $_[0];
	$price =~ tr/0-9.$,/0-9./d;
	return $price;
}


#------------------------------------------------------------------#
### Check for valid input data (user can only change quantity).
### Must be a valid integer, and be greater than zero (unless UPDATE pressed).
sub Check_Valid_Quantity 
{
	my $num = $_[0]; 
	my $item = $_[1];

	return if $num eq '';

	if ((lc $allow_fractional_qty eq 'no' && ($num !~ /^\s*\d+\s*$/)) or
	    (lc $allow_fractional_qty eq 'yes' && ($num !~ /(\d+\.\d+|\d+\.?|\.\d+){1}/)) or 
            (($action ne 'UPDATE') && ($input{'MULTIPART'} ne 'TRUE') && 
             ($num !~ /^\s*\d+\s*$/)))
	{
		PageHeader('Invalid Quantity Value');

		print qq(
<body id="$errorPageStyle">
<b>
The quantity value "$num" is not valid for the item named "$item".<br>
<p>
Please press your browser's BACK button to return to the page and enter a valid quantity.
</b>
</body>
</html>
);

		exit;
	}
}	

#------------------------------------------------------------------#
sub Transmission_error 
{
	my ($errorNumber, $errorMessage, $suppress_report) = @_;

	print qq(
<p>
Invalid Transmission $errorNumber received from customer IP 
$ENV{'REMOTE_ADDR'}<br>
If your connection was interrupted, you must enter the shop from the beginning.

<p>
$errorMessage
);

	Report_Error("Transmission Error $errorNumber : $errorMessage")
		unless $suppress_report;

	exit;
}


#------------------------------------------------------------------#
sub UnQuote 
{
	my $param = $_[0];
	
	# Remove surrounding Quotation marks
	if ($param ne '')
	{
		$_[0] = substr($param, 1, length($param) - 2);
	}
}


sub Quote
{
	my ($dataField, $delimitter) = @_;

	return '"' . $dataField . '"' . $delimitter;
}


#------------------------------------------------------------------#
sub LoadOrders
{
	my ($skip_error) = @_;
	my $found;

	# Attempt to open the order file
	if (!open(order_file, $order_file_name))
	{
		# Is not having an order file OK?
		return if ($skip_error);

		# The order file is missing
		error_trap("Cannot open $order_file_name for reading : $!\n");
	}

	# Read in all shopping cart data
	@shopping_cart = <order_file>;

	close order_file;


	$total_items    = 0;
	$total_quantity = 0;
	$total_price    = 0;
	$total_weight   = 0;

	$index = 0;
	@taxtypes = ();      

	$shipping_offset = 0;    

	# Load the orders file into an array
	foreach my $item_data (sort @shopping_cart)
	{
		chomp $item_data;		

		($order_id, $item_id, $item_name, $price, $quantity, $weight, 
		 $item_taxtype, $option1, $option2, $option3,
		 $qty_min, $qty_max, $item_shiptype) = split(/$delim/, $item_data);

		UnQuote($order_id); 
		UnQuote($item_id); 
		UnQuote($item_name); 
		UnQuote($price); 
		UnQuote($quantity); 
		UnQuote($weight); 
		UnQuote($item_taxtype); 
		UnQuote($option1); 
		UnQuote($option2); 
		UnQuote($option3);
		UnQuote($qty_min);
		UnQuote($qty_max);
		UnQuote($item_shiptype);

		$orders[$index] = [($order_id, $item_id, $item_name, $price, $quantity, 
							$weight, $item_taxtype, 
							$option1, $option2, $option3,
							$qty_min, $qty_max, $item_shiptype)];	
		$total_quantity += $quantity;
		$total_price    += $price * $quantity;
		$total_weight   += $weight * $quantity;

		$total_items++;

		# If shipping on this item is free, don't count it towards the shipping fee
		if (lc $item_shiptype eq 'free')
		{
			if (lc $shipping_type eq 'quantity')
			{
				$shipping_offset += $quantity;
			}

			elsif (lc $shipping_type eq 'price')
			{
				$shipping_offset += $price * $quantity;
			}

			else
			{
				$shipping_offset += $weight * $quantity;
			}
		}

		$found = 0;
		foreach $taxtype (@taxtypes)
		{
			$found = 1
				if (lc $item_taxtype eq $taxtype);
		} 
		push(@taxtypes, lc $item_taxtype)
			if ($found == 0);

		$index++;
	}
}


#------------------------------------------------------------------#
sub center
{
	my $field = $_[0];
	
	$padlen = ($line_length / 2) - (length($field) / 2);
	
	$padding = ' ' x $padlen;

	return  $padding . $field;
}


#------------------------------------------------------------------#
sub right
{
	my $field = $_[0];
	my $field_size = $_[1];        
	
	$padlen = $field_size - length($field);
	
	$padding = ' ' x $padlen;

	return $padding . $field;
}


#------------------------------------------------------------------#
sub left
{
	my $field = $_[0];
	my $field_size = $_[1];        
	my $result;

	# If the text is too big for the field, trim it
	if (length($field) > $field_size) 
	{	
		$result =  substr($field,0,$field_size); 
	}

	# If the text is too short for the field, pad it
	elsif (length($field) < $field_size)
	{
		$padlen = $field_size - length($field);
		$padding = ' ' x $padlen;
		$result = $field . $padding;
	}

	# Does this string have anything in it other than spaces?
	if ($result =~ /[^\s]/)
	{
		# Shift left and fill until there is no leading space
		while (substr($result, 0, 1) eq ' ')
		{
			$result = substr($result, 1) . ' ';
		}
	}

	return $result;
}


#------------------------------------------------------------------#
sub zero_fill 
{
	my $field = $_[0];
	my $field_size = $_[1];        

	if (length($field) > $field_size) 
	{	
		return substr($field, 0, $field_size); 
	}

	else	
	{
		$padlen = $field_size - length($field);
		$padding = '0' x $padlen;
		return $field . $padding;
	}
}


#------------------------------------------------------------------#
sub check_file_title
{
	my $file_title = $_[0];

	if ($file_title eq '')
		{
		$error_msg = "Missing File Title\n";
		return 0;
		}
	 
	if ($file_title !~ /\.\./ )
		{
    		return 1;
		}
	else	{		
		$error_msg = "File Title '$file_title' is Invalid - Cannot contain '..' \n";
		return 0; 
		} 		
}


sub SHA
### This algorithm is based on the implementation of SHA
### written by: John Allen (allen@grumman.com).
### &SHA("squeamish ossifrage\n");
### Should return 82055066 4cf29679 2b38d164 7a4d8c0e 1966af57
{

no strict 'refs';

my ($msg, $p, $l) = @_;      #$p=0; $l=0
my $sha_result;
local $_;

$temp = 'D9T4C`>_-JXF8NMS^$#)4=L/2X?!:@GF9;MGKH8\;O-S*8L\'6';
$m = 4294967296;
###$m=1+~0;

@A = unpack('N*', unpack('u', $temp));

@K = splice(@A, 5, 4);

sub M{($x=pop)-($m)*int$x/$m};
sub L{$n=pop;($x=pop)<<$n|2**$n-1&$x>>32-$n}

@F=(sub{$b&($c^$d)^$d},$S=sub{$b^$c^$d},sub{($b|$c)&$d|$b&$c},$S);

do{
$msg=~s/.{0,64}//s;$_=$&;
$l+=$r=length;
$r++,$_.="\x80"if$r<64&&!$p++;@W=unpack('N16' ,$_."\0"x7);$W[15]=$l*8
if$r<57; for(16..79){push@W,L$W[$_
-3]^$W[$_-8]^$W[$_-14]^$W[$_-16],1}($a,$b,$c,$d,$e)=@A;
for(0..79){$t=M&{$F[$_/ 20]}+$e+$W[$_]+$K[$_/20]+L$a,5; $e=$d; $d=$c;
$c=L$b,30; $b=$a; $a=$t}$v='a'; @A=map{ M$_+${$v++}}@A
}while$r>56;

$sha_result = sprintf('%8x ' x 4 . '%8x', @A);
$sha_result =~ s/\s+/_/g;

return $sha_result;
}
 

sub calculate_tax  
{
	my $tax_zip;

	$tax = 0;
	$found_tax = 0;

	# No tax?  We're done.
	return 0 if (lc $taxtype eq 'none');

	# Start with the existing discounted item total 
	$tax_total = $discount_total;

	# Only calculate taxes for billing addresses that are located in the
	# same country as the store.
	if ((uc $country) eq (uc $catalog_country))
	{
		# If our tax table is in a separate file, load it now
		LoadLibrary($external_tax_file)
			if ($external_tax_file ne '');

		# Check out each state entry in the tax table
		foreach my $Tax_State_Rate (@Tax_States) 
		{
			# Separate state name from taxation rate
			($Tax_State, $Tax_Rate) = split(/ /, $Tax_State_Rate);

			# Is there an optional zipcode along with the state name?
			($Tax_State, $tax_zip) = split(/:/, $Tax_State);

			# Use billing zip if no zip was given in tax table
			$tax_zip = $zip
				if $tax_zip eq '';

			# Is the billing address in this state and zip code,
			# or is this a default entry for all states?
			if (((uc $state eq $Tax_State) and ($zip =~ /^$tax_zip/)) or ($Tax_State eq 'OTHER'))
			{
				# We've found the applicable tax rate for this order
				$found_tax = 1;

				# Compute tax
				$tax = $tax_total * ($Tax_Rate / 100);	
				$tax = sprintf('%1.2f', $tax);
				$tax_currency = Currency($tax);

				# Add this amount to the tax total
				$tax_total += $tax;	

				# Add this amount to the order total	
				$order_total += $tax;

				# We're done
				last;
			}	
		}
	}

	return $tax;
} 


#------------------------------------------------------------------
sub CalculateHandling
{
	my ($country) = @_;
	my $handling_country;
	my $handling_amount;

	# Check each handling table entry
	foreach my $index (0..$#Handling_table)
	{
		($handling_country, $handling_amount) = @{$Handling_table[$index]};

		# Is this the country we're looking for?
		return eval($handling_amount)
			if uc($country) eq uc($handling_country);
	}

	# Country not found in table.  Is there an OTHER entry?
	($handling_country, $handling_amount) =  @{$Handling_table[$#Handling_table]};
	return eval($handling_amount)
		if uc($handling_country) eq 'OTHER';

	# We have no handling fee defined for this country
	return 0;
}


sub calculate_shipping
{ 
	my ($event) = @_;
	my ($Ship_Country, $Shipper, $Ship_Desc, 
		$Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt);

	$additional_taxes = 0;
	$shipping = 0;
	$grand_total = $order_total;	

	# Add shipping charges for all shipping modes except
	# 'included' and 'none'.
	if (($shipping_type ne 'included') && ($shipping_type ne 'none'))
	{
		# Do we charge shipping based on quantity?
		if ($shipping_type eq 'quantity')
		{
			# The shipping factor is the number of items
			$ship_amount = $total_quantity;
			$ship_unit = 'items';
		}

		# Do we charge shipping based on weight?
		elsif ($shipping_type eq 'weight')
		{
			# The shipping factor is the total weight of all items
			$ship_amount = $total_weight;
			$ship_unit = $local_weight;
		}

		# We are shipping based on price
		else
		{
			# The shipping factor is the total price of all items
			$ship_amount = $total_price;
			$ship_unit = $local_currency;
		}

		# Subtract any shipping offset
		$ship_amount -= $shipping_offset;

		# Ensure the shipping amount does not go negative
		$ship_amount = 0
			if $ship_amount < 0;
			
		$country_uc = ($ship_same ? uc($country) : uc($ship_country));
		$country_found = 0;

		# Look for the ship-to country in the shipping table
		foreach $index (0..$#Shipping_Rates) 
		{
			($Ship_Country, $Shipper, $Ship_Desc, 
			 $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = 
			    @{$Shipping_Rates[$index]};

			if (uc $Ship_Country =~ /$country_uc/)
			{
				$country_found = 1;
				last;
			}
		}

		# We did find the ship-to country, so use the OTHER entry 
		$country_uc = 'OTHER'
			if !$country_found;

		# Check each entry in the shipping table
		foreach $index (0..$#Shipping_Rates) 
		{
			# Break up the elements of this table entry
			($Ship_Country, $Shipper, $Ship_Desc, 
			 $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = 
			    @{$Shipping_Rates[$index]};

			# We need to find an entry that matches our ship-to country
			# (or the ALL entry), and matches our chosen shipper,
			# and covers the shipping amount we've calculated
			if ((((uc $Ship_Country =~ /$country_uc/) || (uc $Ship_Country eq 'ALL')) && 
			     ($Shiptype eq $Shipper)) &&
			    ($ship_amount >= $Ship_Min) &&
			    ($ship_amount <= $Ship_Max))				
			{
				# Evaluate the shipping equation
				$Ship_Amt = eval($Ship_Amt);

				# Are we adding this shipping amount ?
				if ($Ship_Mul eq '+')
				{
					$shipping = $Ship_Amt;
				}
			
				# Are we multiplying by this shipping amount ?
				elsif ($Ship_Mul eq '*') 
				{
					$shipping = $ship_amount * $Ship_Amt;
				}

				# This is a percentage equation
				else
				{
					$shipping = $ship_amount * ($Ship_Amt / 100);
				}

				# Do we tax shipping?
				$additional_taxes += $shipping * ($Tax_Rate / 100)
					if $found_tax and (lc $tax_on_shipping eq 'yes');
	
				# Format the shipping value as a monetary value
				$shipping = sprintf('%.2f', $shipping);
				$shipping_currency = Currency($shipping);

				# Calculate totals
				$shipping_total = $order_total + $shipping;
				$grand_total = $shipping_total;

				last;
			} #if	
		} # Foreach
	} #if


	# If we're paying by COD, add in COD charge
	if ($Payby eq 'COD') 
	{
		$grand_total += $cod_charge;
		$cod_currency = Currency($cod_charge);	
	}	


	# Do we need to add a handling charge?
	$Handling = CalculateHandling($country);
	$Handling_currency = Currency($Handling);

	# Do we tax handling?
	$additional_taxes += $Handling * ($Tax_Rate / 100)
		if $found_tax and (lc $tax_on_handling eq 'yes');
	
	# Calculate totals
	$grand_total += $Handling + $additional_taxes;

	
	# Do we need to subtract any rebate amounts?
	$pre_rebate_grand_total = Currency($grand_total);
	$total_rebate = 0;

	foreach my $rebate (sort keys %rebate_table)
	{
		$total_rebate += $rebate_table{$rebate}->{'amount'};
	}
	$grand_total += $total_rebate;
	$rebate_currency = Currency($total_rebate);	

	
	ExecutePlugins($event, $unique_id);


	# Ensure grand total does not go negative
	$grand_total = 0
		if $grand_total < 0;
	$grand_total_currency = Currency($grand_total);


	$Additional_currency = Currency($additional_taxes);


	# Return the shipping fee total
	return $shipping;
}


#------------------------------------------------------------------#
sub calculate_discount 
{ 
	my $discount;
	my $discount_amount;

	$order_total += $sub_total;

	# Are we doing discount by quantity?
	if (lc $discount_type eq 'quantity')
	{
		# Discount is based on total cart quantity
		$discount = Compute_Discount($total_quantity);
	}

	# Are we doing discount by price?
	elsif (lc $discount_type eq 'price')
	{
		# Discount is based on total cart price
		$discount = Compute_Discount($total_price);
	}

	# Are we doing discount by plugin computation?
	elsif (lc $discount_type eq 'plugin')
	{
		# Give the plugin data to work with
		LoadOrders();

		# Discount is based on plugin computation
		$discount = ExecutePlugins('compute_discount', $unique_id);
	}

	# We don't have a valid discount type
	else 
	{
		$discount = 0;
	}

	# Discount total is the item subtotal plus the discount
	$discount_total = $sub_total + $discount;

	# Add the discount to the order total
	$order_total += $discount;

	# Add this discount to the total discount
	$total_discount += $discount;

	# Format the discount amount as currency
	$discount_currency = Currency($discount);
		
	return $discount;
}


sub Compute_Discount
{
	my ($discount_amount) = @_;

	my $disc_max;
	my $disc_min;

	# Check each entry in the discount table
	foreach my $index (0..$#Discount_Rates)
	{
		($disc_min, $disc_max, $disc_rate) = @{$Discount_Rates[$index]};

		if (($discount_amount >= $disc_min) && ($discount_amount <= $disc_max))		
	 	{
			# Compute the discount as a negative monetary value
			return sprintf("%.2f", -($disc_rate * $discount_amount / 100));
		}
	}

	return 0;
}


#------------------------------------------------------------------#    
sub ShowShippingRates 
{
	my $shipping_text;
	my ($Ship_Country, $Shipper, $Ship_Desc, 
		$Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt);

	PageHeader("$company_name -- Shipping Rates");
	add_menu_bar('CONTINUE SHOPPING');
	add_company_header();

	print qq(<div align="center">\n);

	if ($shipping_policy ne '')
	{
		print qq(
<h3>Shipping Policy</h3>
<table align="center">
<tr><td>
<small><b>
$shipping_policy
</b></small>
</td></tr>
</table>
);
	}

	ExecutePlugins('before_shipping_table', $unique_id);

	print qq(
<p><br>
<h3>Shipping Rates (based on $shipping_type)</h3>

<table border=1 bgcolor="white" cellpadding=3 cellspacing=3>
<tr class="shippingHeaderRow">
<th>Country</th>
<th>Shipper</th>
<th>Total $shipping_unit{$shipping_type}</th>
<th>Function</th>
<th>Amount</th>
</tr>
);

	$examples = 0;
	foreach $index(0..$#Shipping_Rates) 
	{
		($Ship_Country, $Shipper, $Ship_Desc, 
		 $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) =
			@{$Shipping_Rates[$index]};

		if ($Ship_Mul eq '%') 
			{$Ship_Amt = sprintf("%.2f", $Ship_Amt)  . '%';}
		else
			{$Ship_Amt = &ShippingAmount($Ship_Amt) . ' ';}

		# Skip display if range is 0..0
		next if ($Ship_Min <= 0) && ($Ship_Max == 0);

		if (($Ship_Min <= 0) && ($Ship_Max > 10000))
		{
			$shipping_text = 'Any number of ';
		}

		elsif ($Ship_Max > 10000)
		{
			$shipping_text = "$Ship_Min or more ";
		}

		elsif ($Ship_Min == $Ship_Max)
		{
			$shipping_text = $Ship_Min;
		}

		else
		{
			$shipping_text = "Between $Ship_Min and $Ship_Max ";
		}

		print qq(
<tr class="shippingItemRow">
<td><small>$Ship_Country</td>
<td><small>$Shipper $Ship_Desc</td>
<td><small>$shipping_text $shipping_unit{$shipping_type}</td>
<td align="center"><small>$Ship_Mul</td>
<td align="right"><small>$Ship_Amt</td>
</tr>

);

		if (($Ship_Mul eq '+' && $has_plus == 0) || 
			($Ship_Mul eq '*' && $has_mul == 0) || 
			($Ship_Mul eq '%' && $has_percent == 0)) 
		{
			$example[$examples] = qq(
For example: If the Country is $Ship_Country and the Shipper is $Shipper 
and the total $shipping_type ordered was between $Ship_Min and $Ship_Max
);

			if ($shipping_type eq 'quantity')
				{$example[$examples] .= 'items';}
			elsif ($shipping_type eq 'price')
				{$example[$examples] .= $local_currency;}
			elsif ($shipping_type eq 'weight')
				{$example[$examples] .= $local_weight;}

			$example[$examples] .= ', then you would ';

			if ($Ship_Mul eq '+') 
			{
				$example[$examples] .= "add $Ship_Amt to your order.";
				$has_plus = 1;
			}

			elsif ($Ship_Mul eq '*')
			{
				$example[$examples] .= "multiply the $shipping_type times $Ship_Amt and add it to your order.";
				$has_mul = 1;
			}

			elsif ($Ship_Mul eq '%') 
			{
				$example[$examples] .= "take $Ship_Amt of the $shipping_type and add it to your order.";
				$has_percent = 1;		
			}

			$examples += 1;
		}		
	}

	print qq(
</table>
</div><br>);

	ExecutePlugins('after_shipping_table', $unique_id);

	print qq(
<table border=0 align="center">
<tr><td><b><small>Function</small></b></td>
<td><small>'+'</td>
<td><small>means add the Amount shown.</td>
);

	print qq(
<tr><td><small>&nbsp</td>
<td><small>'*'</td>
<td><small>means multiply the Quantity ordered times the Amount Shown.</td></tr>)
	if ($shipping_type eq 'quantity');

	print qq(
<tr><td><small>&nbsp</td>
<td><small>'%'</td>
<td><small>means take the given percentage (shown as Amount) 
of the total order price.</td</tr>)
	if ($shipping_type eq 'price');

	print qq(
<tr><td><small>&nbsp</td>
<td><small>'*'</td>
<td><small>means multiply the total Weight times the Amount Shown.</td></tr>
<tr><td><small>&nbsp</td>
<td><small>'%'</td>
<td><small>means take the given percentage (shown as Amount) 
of the total weight.</td></tr>)
	if ($shipping_type eq 'weight');
	
	print qq(
</table>

<p>
<table border=0 align="center" width="75%">
<tr><td>
<b><small>
);
	
	map(print("<br>$example[$_]<br>\n"), 0..$examples);
		 
	print qq(
The rate shown for Country 'OTHER' applies to any country not 
explicitly listed.<br>
Shipping rates for countries not listed can vary widely.
Please contact us for the exact amount required for your purchase.<br>
</small></b>
</td></tr>
</table>
<br>
);

	add_company_footer();
}


#------------------------------------------------------------------#    
sub add_button_bar 
{
	my @buttons = @_;
	my $formName;
	my $program_location;
	my $suppressAction = 0;

	return 
		unless $add_page_footer;

	print qq(
<p>
<div align="center">
<table border=0>
<tr>
);

	foreach my $button (@buttons) 
	{
		# Do we use our built-in search capability?
		next if (!$button_data{uc $button}->{'visible'}) ||
				 (($button eq 'SEARCH') && ($useInternalSearch eq 'no'));

		$formName = $button_data{uc $button}->{'base'} . 'Form';

		# Make sure we have the correct checkout url
		if ($button eq 'CHECK OUT')
		{
			$program_location = $checkout_url;
		}

		else
		{
			$program_location = "http://$cgi_prog_location";
		}

		# Start the form object
		print qq(
<td>
<form name="$formName" method=GET
	action="$program_location">
<input type=hidden name="ORDER_ID" value="$unique_id">
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);

		# Add in redirection data, if needed
		if ($input{'REDIRECT_URL'} ne '')
		{
			print qq(
<input type=hidden name="redirect_url" value="$redirect_decoded">
);
		}

		# If order form has been filled out, PLACE ORDER == VIEW ORDERS
		if (($button eq 'PLACE ORDER') && (-e $customer_file_name))
		{
		 	$suppressAction = 1;

		 	print qq(
<input type=hidden name=action value="VIEW ORDERS">
);
		}

		# Add the button
		AddButton($button, $suppressAction);

		# Finish the form
		print qq(
</form>
</td>
);
	}

	print qq(
</tr>
</table>
	
<table border=0>
<tr>
);
	
	# Do we need to add a Prev button?
	if (($prev_page ne '') && ($catalog_page ne '') && 
		($prev_page ne $input{'THISPAGE'}))
	{
		print qq(
<td>
<form name="prevForm" method=GET 
	action="http://$cgi_prog_location">
<input type=hidden name="ORDER_ID" value="$unique_id">
<input type=hidden name="thispage" value="$prev_page">
);

		AddButton('PREV PAGE');

		print "</form>\n</td>\n";
	}
	
	# Add optional home button
	if ($home_page ne '')
	{
		print qq(
<td>
<form name="homeForm" method=GET target="_top"
	action="http://$server_address$catalog_home/$home_page">
);

		AddButton('HOME');

		print qq(
</form>
</td>
);
	}

	# Do we need to add a Next button?
	if (($next_page ne '') && ($catalog_page ne '') && 
		($next_page ne $input{'THISPAGE'})) 
	{
		print qq(
<td>
<form name="nextForm" method=GET 
	action="http://$cgi_prog_location">
<input type=hidden name="ORDER_ID" value="$unique_id">
<input type=hidden name="thispage" value="$next_page">
);

		AddButton('NEXT PAGE');
	
		print qq(
</form>
</td>
);
	}
	
	print qq(
</tr>
</table>
</div>
</p><br>
);

}


#------------------------------------------------------------------#    
sub add_menu_bar 
{
	my @menus = @_;
	my $menu_name;
	my $program_location;
	my $encoded_parameter;

	$menu_bar = '';

	# Set up positioning information
	$left_col   = "<th align=left><small><b>\n";
	$center_col = "<th align=center><small><b>\n";
	$right_col  = "<th align=right><small><b>\n";
	$closer     = "</b></small></th>\n";
	
	$menu_bar .= qq(
<img src="$image_location/$top_logo" alt="Logo" border=0 align="center">
<br>
)
		if ($top_logo ne '');

	# Start the table containing the menu bar
	$menu_bar .= qq(
<div align="center">
);

	# Display logo in upper left corner, if requested
	$menu_bar .= qq(
<img src="$image_location/$upper_left_logo" alt="Logo" border=0 align="left">)
		if ($upper_left_logo ne '');
	
	# Display logo in upper right corner, if requested
	$menu_bar .= qq(
<img src="$image_location/$upper_right_logo" alt="Logo" border=0 align="right">)
		if ($upper_right_logo ne '');
	
	$menu_bar .= qq(
<table align="center" border=0 cellpadding=5 cellspacing=5>
<tr>
);

	# If we need one, make a Prev link
#print "<!-- cp = $catalog_page, pp = $prev_page, i = $input{'THISPAGE'} -->\n";
	if (($catalog_page ne '') && ($prev_page ne '') &&
		($prev_page ne $input{'THISPAGE'}))
	{
		$menu_bar .= qq(
$left_col
<a href="http://$cgi_prog_location?ACTION=push&thispage=$prev_page&ORDER_ID=$unique_id"
	class="menuAction"
	title="$button_data{'PREV PAGE'}->{'text'}">
Prev Page</a>
$closer
);
	}

	# Create menu entries
	foreach $menu (@menus) 
	{
		# Do we use our built-in search capability?
		next if (!$button_data{uc $menu}->{'visible'}) ||
				($menu eq 'SEARCH') && ($useInternalSearch eq 'no');

		# Make sure we have the correct checkout url
		if ($menu eq 'CHECK OUT')
		{
			$program_location = $checkout_url;
		}

		else
		{
			$program_location = "http://$cgi_prog_location";
		}

		$menu_name = $menu;
		$menu =~ tr / /+/; # URL encode	

		$menu_bar .= "$center_col\n";

		# If we are redirecting, set the URL directly
		if (($menu =~ /^CONTINUE/) && ($input{'REDIRECT_URL'} ne ''))
		{
			$menu_bar .= qq(
<a href="$redirect_decoded"
);
		}

		else
		{
			# If order form has been filled out, PLACE ORDER == VIEW ORDERS
			$menu = 'VIEW+ORDERS'
				if ($menu eq 'PLACE+ORDER') && (-e $customer_file_name);

			# Generate the start of the html link
			$menu_bar .= qq(
<a href="$program_location?ACTION=$menu&thispage=$input{'THISPAGE'}&);

			# Add the redirect parameter to the link, if needed
			$menu_bar .= "redirect_url=$redirect_encoded&"
				if ($input{'REDIRECT_URL'} ne '');

			# Add any optional parameters to link
			foreach $param (sort keys %input)
			{
				# Is this a plugin related parameter?
				if (($param =~ /plugin|^temp_param/i) && ($input{$param} ne ''))
				{
					# URL encode the parameter value
					$encoded_parameter = URLEncode($input{$param});

					# Add the encoded parameter to the link
					$menu_bar .= qq($param=$encoded_parameter&);
				}
			}
	
			# Finish the link
			$menu_bar .= qq(ORDER_ID=$unique_id"\n);
		}

		$menu_bar .= qq(
	class="menuAction"
	title="$button_data{$menu_name}->{'text'}">
$menu_name</a>
$closer
);
	}

	# If we need one, make a home link
	if ($home_page ne '')
	{
		$menu_bar .= "$center_col";
		$menu_bar .= "<a href=\"http://$server_address$catalog_home/$home_page\">";
		$menu_bar .= "HOME</a> ";
	}

	# If we need one, make a Next link
	if (($catalog_page ne '') && ($next_page ne '') &&
		($next_page ne $input{'THISPAGE'}))
	{
		$menu_bar .= qq(
$right_col
<a href="http://$cgi_prog_location?ACTION=push&thispage=$next_page&ORDER_ID=$unique_id"
	class="menuAction"
	title="$button_data{'NEXT PAGE'}->{'text'}">
Next Page</a>
$closer
);
	}

	# Finish the table
	$menu_bar .= "</tr>\n</table>\n</div><br>\n";
}


#------------------------------------------------------------------#    
sub ProcessCGI
{
	my @names;

	# Was Perlshop was called from the command line ?
	unless (defined $ENV{'REQUEST_METHOD'})
	{  
		print "\n\n$copyright\n";

		# Include Perlshop self-test library
		LoadLibrary('ps_selftest.pl');

		# Execute self-test
		$action = 'SELFTEST';
		SelfTest();

		# Report on plugins, if requested
		if ($ARGV[0] eq '-p')
		{
			ReportPSDBI();
			ReportPlugins();
		}

		exit;
	} 

	# Record all CGI parameter values
	@names = CGI::param;
	foreach my $name (@names)
	{
		$input{uc $name} = CGI::param($name);
	}
}


#------------------------------------------------------------------#    
sub create_cookie 
{
	my ($cookie_name, $cookie_value, $expire_days) = @_;  
	my $cookie;
			
	$expiration_date = &create_expire_date($expire_days);

	if ($use_cgiwrap eq 'yes')
	{
		$minimum_cookie_path = $cgiwrap_directory;
	}

	else
	{
		$minimum_cookie_path = $cgi_directory;
	}
	              
	$cookie = "Set-Cookie: $cookie_name=$cookie_value; " .
			  "expires=$expiration_date; " .
			  "path=$minimum_cookie_path; " .
			  "domain=$server_address;";
	
	print "$cookie\n";
}


#------------------------------------------------------------------#    
sub create_expire_date 
{

	my ($expire_days) = @_;  
	my (@day_of_week)  = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
	my (@day_of_month) = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

	if ($expire_days < 0)
	{
		$expiration_date = "Thu, 01-Jan-1970 00:00:01 GMT";
	}

	else
	{
		$newtime = 86400 * $expire_days + time;

		my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($newtime);
		Year2000($year);

		$expiration_date = "$day_of_week[$wday], $mday-$day_of_month[$mon]-$year 23:59:59 GMT";
	}

	return $expiration_date;
}


#------------------------------------------------------------------#
sub Year2000 
{
	my $year  = $_[0];
	
	if ($year < 1900) 
	{
		$_[0] += 1900;
	}
}


#------------------------------------------------------------------#
sub create_log 
{
	my $logfile  = shift(@_);
	my $seconds_waited = 0;
	
	# Open the logfile for exclusive use, use a lock file as a semaphore
	$locktitle = "$log_directory/$logfile.lock";

	# Is the lock file currently in use?
	while (-e $locktitle) 		    
	{
		# Wait for 1 second, and then check again
		sleep 1;

		$seconds_waited++;

		# If we've waited for longer than 10 seconds, something is probably
		# wrong with the log file.  If so, abort the log entry and continue.
		return if ($seconds_waited > 10)
	} 

	# Create the lock file
	open(LOCKFILE, ">$locktitle") ||
		error_trap("Cannot open $locktitle for creation : $!\n");

	# Open the log file
	open(log_file, ">>$log_directory/$logfile") || 
		error_trap("Cannot open log $log_directory/$log_file_name for writing : $!\n");

	# Get the current time
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = 
	   StoreTime(time());
	$mon++;
	$year += 1900;

	# Write all parameters to the log file
	while (defined ($loginfo = shift(@_)))
	{
		print(log_file qq("$loginfo",));
	}

	# Write the timestamp and IP address to the log file
	print(log_file qq("$mon/$mday/$year","$ENV{'REMOTE_ADDR'}"\n));	

	# Close the log file
	close log_file;

	# Destroy the lock file
	close LOCKFILE;
	unlink $locktitle;
}


#------------------------------------------------------------------#
# Used with SSI commands
sub format_time 
{
	my $nowtime  = $_[0];
	local $_     = $_[1];
	my $timetype = $_[2];

$x = "%A, %d-%b-%y";
$X = "%H:%M:%S %Z";
$c = "%A, %d-%b-%y %H:%M:%S %Z";
s/%x/$x/;
s/%c/$c/;
s/%X/$X/;

 @sday=('Mon','Tue','Wed','Thu','Fri','Sat','Sun');
 @lday=('Monday','Tuesday','Wednesday',
        'Thursday','Friday','Saturday','Sunday');
 @smon=('Jan','Feb','Mar','Apr','May','Jun',
       'Jul','Aug','Sep','Oct','Nov','Dec');
 @lmon=('January','February','March','April','May','June',
       'July','August','September','October','November','December');

if ($timetype == 0)
 	{($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($nowtime);}
else
	{($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=StoreTime($nowtime);}

if ($hour > 12)
	{
	$ampm = 'pm';
	$hour12 = $hour - 12;	
	}
else	{
	$ampm = 'am';
	if ($hour == 0)
		{$hour12 = 12;}
	else 
		{$hour12 = $hour;}
	}

$yr2000 = &Year2000($year);
$yr = substr($year, 2);
$dweek = $yday / 7;
$dweek = sprintf("%u", $dweek);

s/%a/$sday[$day]/;
s/%A/$lday[$day]/;
s/%b/$smon[$mon]/;
s/%B/$lmon[$mon]/;
s/%d/$mday/;
s/%H/$hour/;
s/%I/$hour12/;
s/%j/$yday/;
s/%m/$mon/;
s/%M/$min/;
s/%p/$ampm/; 
s/%S/$sec/;
s/%w/$wday/;
s/(%U|%W)/$dweek/;
s/%y/$yr/;
if ($timetype == 0)
	{s/%Z/GMT/;}
else
	{s/%Z/$local_time/;}
s/%Y/$yr2000/;

return $_;
}


#------------------------------------------------------------------#
sub error_trap 
{
	my ($errorMessage, $suppressReport) = @_;

	print qq(
<div align="center">
<b>
A serious error has occured.<br>
Please contact: 
<a href="mailto:$company_email">$company_email</a>
and tell them the error message below, and the exact sequence of events 
that led to the error.<br>

<p>
Thank you.<br>

<p>
<i>$errorMessage</i>

</b>
</div>
);

	Report_Error("Error Trap : $errorMessage")
		unless $suppressReport;

	exit;
}


sub AddBookmark
{
	my $company = $company_name;

	# Replace single quotes with HTML character entities
	$company =~ s/'/&#39;/g;

	print qq(
<script language="JavaScript">
<!--
if ((navigator.appVersion.indexOf("MSIE") > 0) && 
	(parseInt(navigator.appVersion) >= 4)) 
{
	document.writeln("<p>To make your next visit to us easier, please");
	document.writeln("<u><span style='color:blue; cursor:hand;'");
	document.writeln("onclick='window.external.AddFavorite(\\\"http://$server_address\\\", \\\"$company\\\");'>");
	document.writeln("add $company_name to your favorites list</span></u>.");
	document.writeln("<br><p>");
}
//-->
</script>
);
}


sub DisplayPrintButton
{
	print qq(
<div align="center">
<p>
<form name="printForm" method=get target="_top" 
	onSubmit="javascript:return PrintPage();">
);
	AddButton('Print This Invoice');

	print qq(
</form>
</div>
);
}


sub DisplayContinueButton
{
	my $homeURL = "http://$server_address$catalog_home";

	print qq(
<div align="center">
<p>
<form name="homeForm" method=get target="_top" 
	onSubmit="javascript:window.location.href = '$homeURL'; return false;">
);
	AddButton($home_button);

	print qq(
</form>
</div>
);
}


sub PageHeader
{
	my ($pageTitle, $scriptFileName, $scriptFileName2, $suppress_print) = @_;

	my $cssURL = ($link_secure)
			? $secure_server_address . $secure_css_directory
			: "http://$server_address" . $css_directory;

	my $scriptURL = ($link_secure)
			? $secure_server_address . $secure_script_directory
			: "http://$server_address" . $script_directory;

	my $output = '';

#	$output .= "<!--\n";
#	foreach my $param (sort keys %input)
#	{
#		$output .= "$param : $input{$param}\n";
#	}
#	$output .= "-->\n\n";

	# Print out doctype and title
	$output .= qq(
<!-- 
Page generated by Perlshop version $PerlShop_version by Waverider Systems.
http://www.WaveriderSystems.com
-->

<!DOCTYPE HTML PUBLIC 
	"-//W3C//DTD HTML 4.0 Transitional//EN" 
	"http://www.w3.org/TR/REC-html40/loose.dtd">

<html>

<!-- 
All source code, including HTML and JavaScript, is the sole property
of $company_name, and may not be used for any purpose without
express written permission.
-->

<head>
<title>$pageTitle</title>

);

	# Print out the global style sheet reference, if we have one defined
	$output .= qq(
<link rel=stylesheet type="text/css" 
	href="$cssURL/$global_style">

) if ($global_style ne '');

	# Print out script reference 1, if we have it defined
	$output .= qq(
<script type="text/javascript" language="JavaScript1.1" 
	src="$scriptURL/$scriptFileName">
</script>

) if ($scriptFileName ne '');

	# Print out script reference 2, if we have it defined
	$output .= qq(
<script type="text/javascript" language="JavaScript1.2" 
	src="$scriptURL/$scriptFileName2">
</script>

) if ($scriptFileName2 ne '');

	$output .= "</head>\n\n";

	print $output
		unless $suppress_print;

	return $output;
}


sub AddButton
{
	my ($buttonName, $suppressAction) = @_;
	my $result = '';
	my $param;
	my $mouseOver = '';
	my $formName;
	my $imageName;
	my $button = $button_data{$buttonName};
	my $action = ($suppressAction ? '' : 'name=ACTION');

	# If this button is disabled, we're done
	return 
		if $button->{'visible'} == 0;

	# Add in all plugin and template related parameters
	if ($buttonName ne 'CLEAR')
	{
		foreach $param (sort keys %input)
		{
			$result .= 
				qq(<input type=hidden name="$param" value="$input{$param}">\n)
					if ($param =~ /plugin|^temp_param/i);
		}
	}

	# Are we generating a normal form button?
	if ($button->{'image'} eq '')
	{
		# Generate a standard for input object
		$result .= qq(
<input type="$button->{'type'}" $action
	value="$buttonName"
	class="buttonNormal"
	title="$button->{'text'}"
	onMouseOver="this.className = 'buttonOver';"
	onMouseDown="this.className = 'buttonDown';"
	onMouseOut="this.className = 'buttonOut';"
);

		# If we have a specified onClick handler, add it
		$result .= qq(onClick="$button->{'onClick'}"\n)
			if ($button->{'onClick'} ne '');

		$result .= ">\n";
	}

	# We're generating a graphical button
	else
	{
		# Generate the name of the form object
		$formName = $button->{'base'} . 'Form';

		# Generate the name of the image object
		$imageName = (($button->{'name'} ne '')
						? $button->{'name'}
						: $button->{'base'} . 'Image');

		# If this is a command button, generate the hidden field for the command
		$result .= qq(<input type=hidden name="ACTION" value="$buttonName">\n)
			if ($button->{'type'} eq 'submit') && (!$suppressAction);

		# Start the hyperlink for this image
		$result .= 
			qq(<a href="javascript:document.$formName.$button->{'type'}()"\n);

		# If we have a mouseover image, add the necessary event handlers
		if ($button->{'mouseOverImage'} ne '')
		{
			$result .= qq(
onMouseOver="document.images.$imageName.src = '$image_location/$button->{'mouseOverImage'}'"
onMouseOut="document.images.$imageName.src = '$image_location/$button->{'image'}'"
);
		}

		# If we have a specified onClick handler, add it
		$result .= qq(onClick="$button->{'onClick'}"\n)
			if ($button->{'onClick'} ne '');

		# Close the hyperlink and add the image
		$result .= qq(
>
<img border=0 name="$imageName"
	alt="$button->{'text'}"
	src="$image_location/$button->{'image'}"></a>
);
	}

	print $result;

	return $result;
}


sub ProcessItemData
{
	my ($index) = @_;
	my @list;
	my $element;
	my $name;
	my $value;

	@list = split(/\|/, $input{'ITEM_DATA' . $index});

	for ($element = 0; $element <= $#list; $element++)
	{
		if ($list[$element] =~ /:/)
		{
			($name, $value) = split(/:/, $list[$element], 2);
		}

		else
		{
			$name = $item_data_field[$element];
			$value = $list[$element];
		}

		if (($name eq 'id') || ($name eq 'i'))
		{
			$input{'ITEM_ID' . $index} = $value;
		}

		elsif (($name eq 'name') || ($name eq 'n'))
		{
			$input{'ITEM_NAME' . $index} = $value;
		}

		elsif (($name eq 'price') || ($name eq 'p'))
		{
			$input{'ITEM_PRICE' . $index} = $value;
		}

		elsif (($name eq 'weight') || ($name eq 'w'))
		{
			$input{'ITEM_WEIGHT' . $index} = $value;
		}

		elsif (($name eq 'option1') || ($name eq 'o1'))
		{
			$input{'ITEM_OPTION1' . $index} = $value;
		}

		elsif (($name eq 'option2') || ($name eq 'o2'))
		{
			$input{'ITEM_OPTION2' . $index} = $value;
		}

		elsif (($name eq 'option3') || ($name eq 'o3'))
		{
			$input{'ITEM_OPTION3' . $index} = $value;
		}

		elsif (($name eq 'shiptype') || ($name eq 's'))
		{
			$input{'ITEM_SHIPTYPE' . $index} = $value;
		}

		elsif (($name eq 'taxtype') || ($name eq 't'))
		{
			$input{'ITEM_TAXTYPE' . $index} = $value;
		}

		elsif (($name eq 'qty') || ($name eq 'q'))
		{
			$input{'QTY' . $index} = $value;
		}

		elsif (($name eq 'qtymin') || ($name eq 'qn'))
		{
			$input{'QTY_MIN' . $index} = $value;
		}

		elsif (($name eq 'qtymax') || ($name eq 'qx'))
		{
			$input{'QTY_MAX' . $index} = $value;
		}
	}
}


sub ExpandItemData
{
	# Examine each input field
	foreach my $key (sort keys %input)
	{
		# Is this an item_data field ?
		next unless $key =~ /^item_data(\d+)?/i;

		# Expand it
		ProcessItemData($1);
	}
}


sub GenerateCatalogPage
{
	$prev_page = '';
	$next_page = '';

	$input{'THISPAGE'} = $input{'NEXTPAGE'}
		if defined($input{'NEXTPAGE'});

	# Call any before-page-load plugins
	ExecutePlugins('before_page_load', $unique_id, $input{'THISPAGE'});

	# Output the catalog page html
	print ParseFile($catalog_page);

	# Do we add the shopping cart display to the end of each page?
	if ($add_cart == 1)
	{
		print qq(<br><hr width="75%">\n);
		ViewCart();

		add_button_bar('SEARCH');
	}

	# Case: There are items in the cart, and the order form has
	# not yet been filled out.
	elsif ((-e $order_file_name) && (! -z _) && (!(-e $customer_file_name)))
	{
		add_button_bar('VIEW ORDERS', 'CHECK OUT', 'SEARCH');
	}

	# Case: There are items in the cart, and the order form has
	# been filled out.
	elsif ((-e $order_file_name) && (! -z _) && (-e $customer_file_name))
	{
		add_button_bar('VIEW ORDERS', 'PLACE ORDER', 'SEARCH');
	}

	# No items have been placed in the shopping cart
	else
	{
		add_button_bar('SEARCH');
	}

	add_company_footer();

	# Is the internal page logger enabled?
	create_log('PageHits', $input{'THISPAGE'})
		if ($create_page_log eq 'yes');

	# Call any after-page-load plugins
	ExecutePlugins('after_page_load', $unique_id, $input{'THISPAGE'});
}


# Create a unique order ID for each user to pass along to each form
# and to use as the file title to store the items ordered
sub EnterShop
{
	# If no order ID was given, assign the default value
	$input{'ORDER_ID'} = '!ORDERID!'
		unless defined($input{'ORDER_ID'});

	# Validate order id value
	Transmission_error(1, qq(
Invalid order ID value when entering store : $input{'ORDERID'}<br>
), 1)
		unless ($input{'ORDER_ID'} eq '!ORDERID!');

	# Assume that we have no token file
	$token_exists = 0;

	# Has an order ID been recorded as a cookie?
	if ((lc $use_cookies eq 'yes') && ($Cookies{'orderid'} ne ''))
	{
		# Remember the order ID
		$unique_id = $Cookies{'orderid'};

		# Make sure the order ID is of the correct form
		if ($unique_id !~ /\d{$id_length}?/)
		{
			# Complete the http header
			print "\n";

			# The order id from the cookie is invalid
			Transmission_error(0, qq(
<h3 align="center">Browser cookie error</h3>
Your browser type is <b>$ENV{'HTTP_USER_AGENT'}</b>.<br>
The cookie value supplied by your browser is <b>$ENV{'HTTP_COOKIE'}</b>.<br>
The invalid order ID number is <b>$unique_id</b>.<br>
<p>
Your web browser may not correctly support web cookies.<br>
));
		}

		# Generate the needed directory names
		$token_file_name = "$token_directory/$unique_id";
		$order_file_name = "$temp_orders_directory/$unique_id";
		$customer_file_name = "$temp_customers_directory/$unique_id";

		# Check for the token file
		if (-e $token_file_name)
		{
			# We already have a token file
			$token_exists = 1;

			# If we have an unfinished order recorded, tell the customer,
			# and offer to start a new shopping session
			OfferRestart()
				if (-e $order_file_name) && 
				   (lc $offer_restart_on_return eq 'yes');
		}
						
	} # using cookies and have a cookie
	
	# Create a token file if we need one
	CreateToken()
		unless $token_exists;
	
	# If we're generating cookies, do it now
	create_cookie('orderid', $unique_id, $cookie_expire_days)
		if (lc $use_cookies eq 'yes');

	# Complete the http header
	print "\n";				
}


sub QuickBuy
{
	# If no order ID was given, assign the default value
	$input{'ORDER_ID'} = '!ORDERID!'
		unless defined($input{'ORDER_ID'});

	# Complete the http header
	print "\n";				

	# Is this the first time we're entering the store?
	if ($input{'ORDER_ID'} eq '!ORDERID!')
	{
		# Create token file and unique id
		CreateToken();
	}

	# Use the existing order id value
	else
	{
		CreateToken($input{'ORDER_ID'});
	}

	# Generate the needed directory names
	$token_file_name = "$token_directory/$unique_id";
	$order_file_name = "$temp_orders_directory/$unique_id";
	$customer_file_name = "$temp_customers_directory/$unique_id";

	ExecutePlugins('before_add_item', $unique_id);

	# Include Perlshop cart support library
	LoadLibrary('ps_cart.pl');

	# Load the shopping cart
	AddItemsToCart();

	# Re-enter normal program flow
	$action = ($input{'SHOWCART'} == 1) ? 'VIEW ORDERS' : 'CHECK OUT';
}


sub CheckForVerificationResult
{
	# Check for VeriSign processing response fields
	if ((lc $online_credit_verify eq 'verisign') || 
	    (lc $online_check_verify eq 'verisign'))
	{
		# Assume this is a verification result unless otherwise stated
		$action = 'ONLINE_VERIFICATION_RESULT'
			if ($action eq '');

		# Assume this is the invoice ID unless otherwise stated
		$unique_id = $input{'CUSTID'}
			if ($input{'CUSTID'} ne '');
	}

	# Check for ECML data
	elsif (defined($input{'IOC_MERCHANT_ORDER_ID'}))
	{
		# Extract invoice ID
		$unique_id = $input{'IOC_MERCHANT_ORDER_ID'};
	}
}


sub ValidateCustomer
{
	# Get the order ID value
	$unique_id = $input{'ORDER_ID'};

	CheckForVerificationResult();

	# Has Perlshop been called to process the results of an on-line
	# verification?
	if ($action eq 'ONLINE_VERIFICATION_RESULT')
	{
		# Include Perlshop real-time result processing library
		LoadLibrary('ps_transact.pl');

		HandleOnlineVerificationResult();
	}

	# Validate order id cookie ?
	elsif ((lc $use_cookies eq 'yes') and ($Cookies{'orderid'} ne $unique_id))
	{
	}

	# Validate the order ID value
	if (($unique_id eq '!ORDERID!') || ( $unique_id !~ /\d{$id_length}?/ ))
	{
		# Complete http header
		print "\n";

		# Perform a diagnostic dump
		#foreach $key (sort keys %input)
		#{
		#	print "Input $key is $input{$key}<br>\n";
		#}

		#Transmission_error(3, "Internal error: Order ID is '$unique_id'.", 1);

		PageHeader('Invalid Order ID', 'ps_utilities.js');

		print qq(<body id="$errorPageStyle">\n) .
			ExecutePlugins('header_above_banner', $unique_id) .
			qq(
<h3>The Order ID you have provided is invalid.</h3>
<b>
<p>
Press the button below if you wish to start a new shopping session.<br>

);

		$unique_id = '!ORDERID!';
		add_button_bar();

		DisplayContinueButton();

		print qq(
</body>
</html>
);

		exit;
	}

	# Are we using cookies?
	if (lc $use_cookies eq 'yes') 
	{	
		## Reset cookie expiration date on restart
		if ($action eq 'RESTART')  
		{
			create_cookie('orderid', $unique_id, $cookie_expire_days);
		} 

		## Delete cookie when order is placed
		elsif ($action eq 'PLACE ORDER')
		{
			create_cookie('orderid', $unique_id, -1);
		}

		# Complete the http header
		print "\n";
	}

	# Generate the name of the token file for the order id stored in the cookie
	$token_file_name = "$token_directory/$unique_id";

	# Make sure this order is still active
	if (!(-e $token_file_name)) 
	{
		# We have no token file.  Are we completing an old order ?
		if ((-e "$temp_orders_directory/$unique_id") && ($action eq 'PLACE ORDER'))
		{
			# We have a temp order file.  Allow the PLACE ORDER command to continue.
		}

		# We have no token file or temp order file
		else
		{
			PageHeader('You Have Already Checked Out', 'ps_utilities.js');

			print qq(<body id="$errorPageStyle">\n) .
				ExecutePlugins('header_above_banner', $unique_id) .
				qq(
<h3>You cannot revise an order after checking out.</h3>
<b>
You must enter the shop again if you wish to order more items.<br>
Please contact the the merchant directly if you need to cancel an order.<br>

<p>
Press the button below if you wish to start a new shopping session.<br>

);

			$unique_id = '!ORDERID!';
			add_button_bar();

			DisplayContinueButton();

			print qq(
</body>
</html>
);

			exit;	
		}
	}
}


sub OfferRestart
{
	# Destroy any previous customer file
	unlink $customer_file_name;

	PageHeader("Previous Order Selections");
	add_menu_bar('CONTINUE SHOPPING');
	add_company_header();				

	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, 
	$size, $atime, $mtime, $ctime) = stat($order_file_name);

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, 
	    $yday, $isdst) = StoreTime($ctime);
	$mon++;
	$year += 1900;

	print qq(
<div align="center">
<b>
<span style="color:red">
You have an incomplete order placed on $mon/$mday/$year, as detailed below.<br>
</span>
If you do <i>not</i> want to complete this order, please press the 
<span style="color:darkblue">RESTART</span> button to delete it.<br>
</b>

<form name="restartForm" method=GET 
	action="http://$cgi_prog_location">
<input type=hidden name="ORDER_ID" value=$unique_id>
);

	AddButton('RESTART');

	print qq(
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
</form>
</div>
);

	$add_cart = 1;
	$resuming_order = 1;

	ViewCart();

	add_button_bar('CONTINUE SHOPPING');
	add_company_footer();

	exit;
}


sub CreateToken
{
	my ($order_id) = @_;
	my $test_customer_file_name;
	my $test_order_file_name;

	# Has a specific order id value been given?
	if (defined($order_id))
	{
		# Use the order ID we've been given
		$unique_id = $order_id;
	}

	# Do we have a plugin that generates our order IDs?
	elsif (defined $plugins{'orderid'})
	{
		# The order ID will be generated by the plugin
		$unique_id = ExecutePlugins('orderid');
		$unique_id =~ s/\s//g;
	}

	# We need to create a unique order id
	else
	{
		# Seed the random number generator using time and process number
		srand(time() ^ ($$ + ($$ << 15)));

		# Compute the highest possible order ID value
		$rand_len = '9' x ($id_length - 3);   	

		# Generate random order ID numbers until we get one that is:
		#	1.	Not currently in use (no current token file)
		#	2.	Not used in the past (no existing customer or order file)
		do	
		{
			# Generate a potential order ID
			$unique_id = zero_fill(abs($$), 3) . zero_fill(int(rand($rand_len)), $id_length - 3);

  	 	} until (!((-e "$token_directory/$unique_id") ||
			   (-e "$customers_directory/$unique_id") ||
			   (-e "$orders_directory/$unique_id"))); 
	}

	# Generate the name of the token file for this order ID
	$token_file_name = "$token_directory/$unique_id";

	# Create a random token value to use with SHA signature
	$token = int(rand(1000000));

	# Create the token file
	open(token_file, ">$token_file_name") or
		error_trap("Cannot open token $token_file_name for writing : $!\n");
	print token_file "$token\n";	  
	close token_file;	
}


# Called to execute a Perlshop CGI plugin call
sub HandlePlugin
{
	my $plugin;
	my $plugin_command;
	my $plugin_name;
	my $plugin_parameter;
	my $param_index;
	my %parameter_list;

	# Make sure a plugin name was specified
	Transmission_error(8, 'No plugin name was specified')
		if ($input{'PLUGIN'} eq '');

	# Look the specified plugin up in the plugin table
	Transmission_error(9, "Unrecognized plugin name: $input{'PLUGIN'}")
		if (!$plugins{$input{'PLUGIN'}});

	# Does the specified plugin have a program reference?
	Transmission_error(12, "No program file is specified for plugin: $input{'PLUGIN'}")
		if (!$plugins{$input{'PLUGIN'}}->{'program'});

	# Start with the plugin program command line call
	$catalog_page = "./$plugins{$input{'PLUGIN'}}->{'program'}";


	# Examine each attribute of the plugin definition
	foreach my $name (keys %{$plugins{$input{'PLUGIN'}}})
	{
		# Is this attribute a parameter default value?
		if ($name =~ /^param(\d+)$/)
		{
			$param_index = sprintf('%04d', $1);

			# Add the default value to the parameter list
			$parameter_list{$param_index} = eval($plugins{$input{'PLUGIN'}}->{$name});
		}
	}


	# Examine each input parameter
	foreach my $name (keys %input)
	{
		# Is this a plugin parameter value?
		if ($name =~ /^PLUGIN_PARAM(\d+)$/)
		{
			$param_index = sprintf('%04d', $1);

			# Add the parameter value to the list
			$parameter_list{$param_index} = $input{$name};
		}
	}


	# Process all parameter values
	foreach my $name (sort keys %parameter_list)
	{
		$param = $parameter_list{$name};

		# Remove all invalid characters
		$param =~ s/["()<>;&|]//g;

		# Make sure this value contains only legal characters
		Transmission_error(10, "Invalid plugin parameter value: $param")
			if $param =~ /[\(\)\<\>\;\&\|]/;

		# Append this parameter value to the command
		$catalog_page .= ' "' . $param . '"';
	}


	# Append a pipe symbol to the command string
	$catalog_page .= ' |';

	# Use the specified plugin to generate a catalog page on the fly
	GenerateCatalogPage();
}


# Called to internally execute Perlshop plugins
sub ExecutePlugins
{
	my ($plugin_event, @parameters) = @_;
	my $module;
	my $command;
	my $result;
	my $plugin_output = '';
	my $plugin_result = '';

	# Scan the plugin table
	foreach my $plugin (sort keys %plugins)
	{
		# Skip this plugin if no event type is specified
		next if $plugins{$plugin}->{'event'} eq '';

		# Skip this plugin unless it executes in response to this event
		next unless ($plugin_event =~ /$plugins{$plugin}->{'event'}/);

		# Clear the plugin result buffer;
		$result = '';

		# If this plugin has a conditional, evaluate it
		if ($plugins{$plugin}->{'condition'} ne '')
		{
			# Skip this plugin unless the condition is true
			next unless eval(qq($plugins{$plugin}->{'condition'}));
		}

		# If this plugin has a direct module call, use it
		if ($plugins{$plugin}->{'module'} ne '')
		{
			# Load the module for this plugin
			LoadLibrary($plugins{$plugin}->{'module'});

			# Get the raw module name
			($module) = split(/\./, $plugins{$plugin}->{'module'});

			# Generate the plugin module Dispatch method name
			$command = $module . "::Dispatch('$plugin_event'";
			map {$command .= ", '$_'"} @parameters;
			$command .= ');';

			# Execute the plugin module Dispatch method
			$result = eval($command);
			Transmission_error(11, "Could not access $module plugin Dispatch method : $@")
				unless defined $result;
		}

		# Otherwise, if this plugin has an external program, use it
		elsif ($plugins{$plugin}->{'program'} ne '')
		{
			# Prepare the plugin external program call
			$command = "$plugins{$plugin}->{'program'} $plugin_event";
			map {$command .= qq( "$_")} @parameters;

			# Does this plugin need to execute in the background?  (Unix only)
			if ($plugins{$plugin}->{'background'} eq 'yes')
			{
				# Execute the external plugin program via command line system call
				system "./$command &";
			}
	
			# Execute the external plugin program via the command shell
			else
			{
				$result = qx "./$command";
			}
		}

		# Otherwise, if this plugin is actually an external file, include it
		elsif ($plugins{$plugin}->{'file'} ne '')
		{
			$result = ParseFile($plugins{$plugin}->{'file'});

			# Evaluate as Perl code in local context, if requested
			$result = eval("qq($result)")
					if $plugins{$plugin}->{'eval'};
		}

		# Otherwise, if this plugin is actually a piece of static text, include it
		elsif ($plugins{$plugin}->{'text'} ne '')
		{
			$result = $plugins{$plugin}->{'text'};

			# Evaluate as Perl code in local context, if requested
			$result = eval("qq($result)")
					if $plugins{$plugin}->{'eval'};
		}

		# If plugin output is enabled, append this output the buffer
		$plugin_output .= $result
			unless (lc $plugins{$plugin}->{'display'} eq 'no');

		$plugin_result .= $result;
	}

	# Display the out result all plugins
	print $plugin_output;

	return $plugin_result;
}


sub EmbeddedPlugin
{
	my ($data) = @_;
	my ($event, @params) = split(/\s+/, $data);

	return "<!-- Plugin event '$event' -->\n" . 
	       ExecutePlugins($event, @params) . "\n";
}


sub HandlePSDBI
{
	my ($param, $object, $dir) = @_;
	my $input_parameter;

	$using_psdbi = 1;

	# Summon the psdbi program to generate a web page on the fly
	$catalog_page = 'PSDBI';
	$psdbi_parameters{dir} = $dir;
	$psdbi_parameters{$param} = $object;

	# Add in any template parameters that might be present
	foreach $input_parameter (sort keys %input)
	{
		$psdbi_parameters{lc $input_parameter} = $input{$input_parameter}
			if ($input_parameter =~ /^temp_param\d?$/i);
	}
}


sub URLEncode
{
	my ($buffer) = @_;

	$buffer =~ s/(\W)/sprintf('%%%02X', ord($1))/eg;

	return $buffer;
}


sub LoadLibrary
{
	my ($library_name) = @_;

	# Attempt to load the specified Perlshop 4 library file
	unless (eval 'require $library_name')
	{	
		print "\n\n";

		PageHeader('Could Not Load Library');
		error_trap("Could not load library $library_name :\n$@\n\n",
		           $library_name eq 'ps_email.pl');
		exit;
	};
}


sub Report_Error
{
	my ($message) = @_;
	my $text;
	my $now;

	# Skip out if no webmaster email address has been specified
	return if ($webmaster_email eq '');

	# Get the local time on the web server
	$now = StoreTime(time());

	# Generate the body of the report email
	$text = qq(
This is a Perlshop internal error report.

Store name       : $company_name
Server address   : $server_address
Local time       : $now
Software version : $PerlShop_version

------------------------------------
The following error occured while Perlshop
was processing order ID $unique_id:

$message

------------------------------------
Perlshop input variables at the time
of the error:
);

	# Add all current environment settings to the email
	foreach my $var (sort keys %input)
	{
		$text .= "$var = $input{$var}\n";
	}

	$text .= qq(
------------------------------------
Perlshop environment settings at the time
of the error:
);

	# Add all current environment settings to the email
	foreach my $var (sort keys %ENV)
	{
		$text .= "$var = $ENV{$var}\n";
	}

	# Load the email support library
	LoadLibrary('ps_email.pl');

	# Send error report email to store webmaster
	SendEmail($webmaster_email, $company_email, 'Perlshop Error Report', $text);          
}


sub AddRebate
{
	my ($name, $description, $amount) = @_;

	$rebate_table{$name} = 
		{'description' => $description, 'amount' => $amount};
}


# This function returns the local time at the store, which
# may be different from that of the time at the web server.
sub StoreTime
{
	my ($time_value) = @_;

	# Offset the given time value by the number of hours
	# specified in the ps.cfg file
	$time_value += ($store_timezone_offset * 3600);

	# Return the time
	return localtime($time_value);
}


sub CheckMinimumPrice
{
	LoadOrders();

	return if $total_price >= $minimum_price;

	PageHeader('Minimum Order Requirements', 'ps_utilities.js');

	print qq(
<body id="$errorPageStyle">
<div align="center">
<h3>The minimum order requirement is $currency_symbol$minimum_price$local_currency.</h3>
Please continue shopping until you have reached reached this minimum.<br>
$minimum_price_note
<p>
<form name="continueForm" method=GET 
	action="http://$cgi_prog_location">
<input type=hidden name="ORDER_ID" value="$unique_id">
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);

	AddButton('CONTINUE SHOPPING');

	print qq(
</form>
</div>
</body>
</html>
);

	exit;
}


sub CheckMinimumQuantity
{
	LoadOrders();

	return if $total_quantity >= $minimum_quantity;

	PageHeader('Minimum Order Requirements', 'ps_utilities.js');

	print qq(
<body id="$errorPageStyle">
<div align="center">
<h3>The minimum order requirement is $minimum_quantity items.</h3>
Please continue shopping until you have reached reached this minimum.<br>
$minimum_quantity_note
<p>
<form name="continueForm" method=GET 
	action="http://$cgi_prog_location">
<input type=hidden name="ORDER_ID" value="$unique_id">
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);

	AddButton('CONTINUE SHOPPING');

	print qq(
</form>
</div>
</body>
</html>
);

	exit;
}


sub AddNote
{
	my ($message) = @_;
	my $note_file_dir = $customers_directory;
	my $note_file_name;
	my $now = StoreTime(time());

	# The notes directory will be right next to the customers directory
	$note_file_dir =~ s/customers$/notes/;

	# Does the notes directory exist ?
	if (-e $note_file_dir)
	{
		# Generate the note file name
		$note_file_name .= "$note_file_dir/$unique_id";

		# Open the note file for appending
		if (open(NOTEFILE, ">>$note_file_name"))
		{
			# Add the note
			print NOTEFILE "$now\n$message\n\n";
			close NOTEFILE;
		}
	}
}


