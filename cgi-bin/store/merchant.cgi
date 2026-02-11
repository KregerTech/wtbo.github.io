#!/usr/bin/perl -T

$| = 1;

$time = time;

&require_supporting_libraries (__FILE__, __LINE__,
		"./admin_files/commerce_user_lib.pl");		

&require_supporting_libraries (__FILE__, __LINE__,
		"./admin_files/$sc_gateway_name-user_lib.pl");

&require_supporting_libraries (__FILE__, __LINE__,
	       "./library/commerce.setup.db");

&require_supporting_libraries (__FILE__, __LINE__,
	       "./library/commerce_order_lib.pl");

&require_supporting_libraries (__FILE__, __LINE__, 
		"$sc_cgi_lib_path",
		"$sc_html_setup_file_path", 
		"$sc_mail_lib_path",
		"$sc_cookie_lib",
		"$sc_commerce_subs_path",
		"$sc_process_order_lib_path");

&read_and_parse_form_data;

&get_cookie;

&require_supporting_libraries (__FILE__, __LINE__,
	       "./library/special_library.pl");

$page = $form_data{'page'};
$page =~ /([\w\-\=\+\/]+)\.(\w+)/;
$page = "$1.$2";
$page = "" if ($page eq ".");
$page =~ s/^\/+//; # Get rid of any residual / prefix

$webURL = "http://$sc_domain_name_for_cookie$sc_path_for_cookie";

$search_request = $form_data{'search_request_button'};
$cart_id = $form_data{'cart_id'};

&error_check_form_data;

if ($cookie{'cart_id'} eq "" && $form_data{'cart_id'} eq "")

{
&delete_old_carts;
&assign_a_unique_shopping_cart_id;
}

if ($form_data{'cart_id'} eq "")

{
$cart_id = $cookie{'cart_id'};
$sc_cart_path = "$sc_user_carts_directory_path/${cart_id}.cart";
$sc_cart_path =~ /([\w\-\=\+\/]+)\.(\w+)/;
$sc_cart_path = "$1.$2";
$sc_cart_path = "" if ($sc_cart_path eq ".");
$sc_cart_path =~ s/^\/+//; # Get rid of any residual / prefix
}

else

{
$cart_id = $form_data{'cart_id'};
$sc_cart_path = "$sc_user_carts_directory_path/${cart_id}.cart";
$sc_cart_path =~ /([\w\-\=\+\/]+)\.(\w+)/;
$sc_cart_path = "$1.$2";
$sc_cart_path = "" if ($sc_cart_path eq ".");
$sc_cart_path =~ s/^\/+//; # Get rid of any residual / prefix
}

print "Content-type: text/html\n\n";

# Make sure that the cart_id starts with a digit. 
if (substr($cart_id, 0, 1) =~ /\D/) 
{ 
print "Invalid Cart ID!\n"; 
exit; 
} 

$are_any_query_fields_filled_in = "no";
foreach $query_field (@sc_db_query_criteria)
{
@criteria = split(/\|/, $query_field);

	if ($form_data{$criteria[0]} ne "")
	{
	$are_any_query_fields_filled_in = "yes";
	}
}

if ($form_data{'add_to_cart_button.x'} ne "")
{
&add_to_the_cart;
exit;
}

elsif ($form_data{'modify_cart_button.x'} ne "")
{
&display_cart_contents;
exit;
}

elsif ($form_data{'change_quantity_button.x'} ne "")
{
&output_modify_quantity_form;
exit;
}

elsif ($form_data{'submit_change_quantity_button.x'} ne "")
{
&modify_quantity_of_items_in_cart;
exit;
}

elsif ($form_data{'delete_item_button.x'} ne "")
{
&output_delete_item_form;
exit;
}

elsif ($form_data{'submit_deletion_button.x'} ne "")
{   
&delete_from_cart;
exit;
}

elsif ($form_data{'order_form_button.x'} ne "")
{
&require_supporting_libraries (__FILE__, __LINE__, "$sc_order_lib_path"); 
&display_order_form;
exit;
}

elsif ($form_data{'submit_order_form_button'} ne "")
{
&require_supporting_libraries (__FILE__, __LINE__, "$sc_order_lib_path"); 
&process_order_form;
exit;
}

elsif (($page ne "" || $form_data{'search_request_button'} ne ""
				|| $form_data{'continue_shopping_button'}
				|| $are_any_query_fields_filled_in =~ /yes/i) &&
				($form_data{'return_to_frontpage_button'} eq "")) 

{
&display_products_for_sale;
exit;
}

# gateway
if ($form_data{'authcode'})
{

$cart_id = $form_data{'p5'};
$sc_cart_path = "$sc_user_carts_directory_path/$cart_id.cart";
$sc_cart_path =~ /([\w\-\=\+\/]+)\.(\w+)/;
$sc_cart_path = "$1.$2";
$sc_cart_path = "" if ($sc_cart_path eq ".");
$sc_cart_path =~ s/^\/+//; # Get rid of any residual / prefix
&processOrder;
exit;
}

# Offline
elsif ($form_data{'process_order'})
{

$cart_id = $form_data{'cart_id'};
$sc_cart_path = "$sc_user_carts_directory_path/$cart_id.cart";
$sc_cart_path =~ /([\w\-\=\+\/]+)\.(\w+)/;
$sc_cart_path = "$1.$2";
$sc_cart_path = "" if ($sc_cart_path eq ".");
$sc_cart_path =~ s/^\/+//; # Get rid of any residual / prefix
&processOrder;
exit;
}

else
{
&output_frontpage;
exit;
}

#######################################################################
#                       Require Supporting Libraries.		          #
#######################################################################

		# require_supporting_libraries is used to read in some of
		# the supporting files that this script will take
		# advantage of.
		#
		# require_supporting_libraries takes a list of arguments
		# beginning with the current filename, the current line
		# number and continuing with the list of files which must
		# be required using the following syntax:
		#
		# &require_supporting_libraries (__FILE__, __LINE__,
		#				"file1", "file2",
		#				"file3"...);
		#
		# Note: __FILE__ and __LINE__ are special Perl variables
		# which contain the current filename and line number
		# respectively.  We'll continually use these two variables
		# throughout the rest of this script in order to generate
		# useful error messages.

sub require_supporting_libraries
{

		# The incoming file and line arguments are split into
		# the local variables $file and $line while the file list
		# is assigned to the local list array @require_files.
		#
		# $require_file which will just be a temporary holder
		# variable for our foreach processing is also defined as a
		# local variable.

local ($file, $line, @require_files) = @_;
local ($require_file);

		# Next, the script checks to see if every file in the
		# @require_files list array exists (-e) and is readable by
		# it (-r). If so, the script goes ahead and requires it.

foreach $require_file (@require_files)
{
if (-e "$require_file" && -r "$require_file")
{
require "$require_file";
}

		# If not, the scripts sends back an error message that
		# will help the admin isolate the problem with the script.

else
{

print "I am sorry but I was unable to require $require_file at line
$line in $file.  Would you please make sure that you have the
path correct and that the permissions are set so that I have
read access?  Thank you.";

exit;
}

} # End of foreach $require_file (@require_files)
} # End of sub require_supporting_libraries

#######################################################################
#                     Read and Parse Form Data.			          #
#######################################################################

		# read_and_parse_form_data is a short subroutine 
		# responsible for calling the ReadParse subroutine in
		# cgi-lib.pl to parse the incoming form data.  The script 
		# also tells cgi-lib to prepare that information in the
		# associative array named %form_data which we will be able
		# to use for the rest of this script.
		#
		# read_and_parse_form_data takes no arguments and is
		# called with the following syntax:
		#
		# &read_and_parse_form_data;

sub read_and_parse_form_data

{

&ReadParse(*form_data);

}

#######################################################################
#                     Error Check Form Data.                          #   
####################################################################### 

		# error_check_form_data is responsible for checking to
		# make sure that only authorized pages are viewable using
		# this application. It takes no arguments and is called
		# with the following syntax:
		#
		# &error_check_form_data;
		#
		# The routine simply checks to make sure that if
		# the page variable extension is not one that is defined
		# in the setup file as an appropriate extension like .html
		# or .htm, or there is no page being requestd (ie: the
		# store front is being displayed) it will send a warning
		# to the user, append the error log, and exit.
		#
		# @acceptable_file_extensions_to_display is an array of
		# acceptable file extensions defined in the setup file.
		# To be more or less restrictive, just modify this list.
		#
		# Specifically, for each extension defined in the setup
		# file, if the value of the page variable coming in from
		# the form ($page) is like the extension (/$file_extension/) 
		# or there is no value for page (eq ""), we will set
		# $valid_extension equal to yes.  
		
sub error_check_form_data
{

foreach $file_extension (@acceptable_file_extensions_to_display)
{
	if ($page =~ /$file_extension/ || $page eq "")
	{
	$valid_extension = "yes";
	}
}

		# Next, the script checks to see if $valid_extension has
		# been set to "yes".
		#
		# If the value for page satisfied any of the extensions 
		# in @acceptable_file_extensions_to_display, the script
		# will set $valid_extension equal to yes. If the value 
		# is set to yes, the subroutine will go on with it's work.
		# Otherwise it will exit with a warning and write to the
		# eror log if appropriate
		#
		# Notice that we pass three parameters to the
		# update_error_log subroutine which will be discussed
		# later. The subroutine gets a warning, the
		# name of the file, and the line number of the error.
		#
		# $sc_page_load_security_warning is a variable set in
		# commerce.setup.db  If you want to give a more or less
		# informative error message, you are welcome to change the
		# text there.

if ($valid_extension ne "yes")

{

print "$sc_page_load_security_warning";
&update_error_log("PAGE LOAD WARNING", __FILE__, __LINE__);
exit;

}        

}

#######################################################################
#                        Delete Old Carts. 	                      #
#######################################################################

		# delete_old_carts is a subroutine which is used to prune
		# the carts directory, cleaning out all the old carts
		# after some time interval defined in the setup file.  It
		# takes no argumnetes and is called with the following
		# syntax:
		#
		# &delete_old_carts;

sub delete_old_carts
{

		# The subroutine begins by grabbing a listing of all of
		# the client created shoppping carts in the User_carts
		# directory.
		#
		# It then opens the directory and reads the contents using
		# grep to grab every file with the extension .cart. Then
		# it closes the directory.  
		#
		# If the script has any trouble opening the directory,
		# it will output an error message using the
		# file_open_error subroutine discussed later.  To the
		# subroutine, it will pass the name of the file which had
		# trouble, as well as the current routine in the script
		# having trouble , the filename and the current line
		# number.

opendir (USER_CARTS, "$sc_user_carts_directory_path") || &file_open_error("$sc_user_carts_directory_path", "Delete Old Carts", __FILE__, __LINE__);
@carts = grep(/\.[0-9]/,readdir(USER_CARTS));
closedir (USER_CARTS);
      
		# Now, for every cart in the directory, delete the cart if
		# it is older than half a day.  The -M file test returns
		# the number of days since the file was last modified.
		# Since the result is in terms of days, if the value is
		# greater than the value of $sc_number_days_keep_old_carts
		# set in commerce.setup.db, we'll delete the file.

foreach $cart (@carts)
{

if (-M "$sc_user_carts_directory_path/$cart" > $sc_number_days_keep_old_carts)
{
$sc_cart_path = "$sc_user_carts_directory_path/$cart";
$sc_cart_path =~ /([\w\-\=\+\/]+)\.(\w+)/;
$sc_cart_path = "$1.$2";
$sc_cart_path = "" if ($sc_cart_path eq ".");
$sc_cart_path =~ s/^\/+//; # Get rid of any residual /prefix
unlink("$sc_cart_path");
print "$sc_cart_path";
}

}# end of foreach

}# End of sub delete_old_carts

#######################################################################
#                        Assign a Shopping Cart.                      #   
#######################################################################  

		# assign_a_unique_shopping_cart_id is a subroutine used to
		# assign a unique cart id to every new clinet.  It takes
		# no argumnets and is called with the following syntax:
		#
		# &assign_a_unique_shopping_cart_id;

sub assign_a_unique_shopping_cart_id
{

		# First we will check to see if the admin has asked us to
		# log all new clients.  If so, we will get the current
		# date using the get_date subroutine discussed later, open the 
		# access log file for appending, and print to the access
		# log file all of the environment variable values as well
		# as the current date and time.  
		#
		# However, we will protect ourselves from multiple,
		# simultaneous writes to the access log by using the
		# lockfile routine documented at the end of this file,
		# passing it the name of a temporary lock file to use.
		#
		# Remember that there may be multimple simultaneous
		# executions of this script because there may be many
		# people shopping all at once.  It would not do if one
		# customer was able to overwrite the information of
		# another customer if they accidentally wanted to acccess
		# the log file at the same exact time.


$date = &get_date;


srand (time|$$);

$cart_id = int(rand(10000000));
$cart_id .= ".$$";
$cart_id =~ s/-//g;

$sc_cart_path = "$sc_user_carts_directory_path/${cart_id}.cart";

		# However, before we can be absolutely sure that we have
		# created a unique cart, the script must check the existing
		# list of carts to make sure that there is not one with
		# the same value.
		#
		# It does this by checking to see if a cart with the
		# randomly generated ID number already exists in the Carts
		# directory.  If one does exit (-e), the script grabs
		# another random number using the same routine as
		# above and checks again.  
		#
		# Using the $cart_count variable, the script executes this
		# algorithm three times.  If it does not succeede in finding
		# a unique cart id number, the script assumes that there is
		# something seriously wrong with the randomizing routine
		# and exits, warning the user on the web and the admin
		# using the update_error_log subroutine discussed later.

$cart_count = 0;

while (-e "$sc_cart_path")
{
	if ($cart_count == 3)
	{
	print "$sc_randomizer_error_message";
	&update_error_log("COULD NOT CREATE UNIQUE CART ID", __FILE__, __LINE__);
	exit;
	}

$cart_id = int(rand(10000000));
$cart_id .= "_$$";    
$cart_id =~ s/-//g;
$sc_cart_path = "$sc_user_carts_directory_path/${cart_id}.cart";
$cart_count++;

} # End of while (-e $sc_cart_path)
       
		# Now that we have generated a truly unique id
		# number for the new client's cart, the script may go
		# ahead and create it in the User_carts sub-directory.  
		#
		# If there is a problem opening the new cart, we'll output
		# an error message with the file_open_error subroutine
		# discussed later.

&SetCookies;

}

#######################################################################   
#                       Output Frontpage.                             #
#######################################################################  

		# output_frontpage is used to display the frontpage of the
		# store.  It takes no argumnets and is accessed with the
		# following syntax:
		#
		# &output_frontpage;
		#
		# The subroutine simply utilizes the display_page
		# subroutine which is discussed later to output the
		# frontpage file, the location of which, is defined
		# in commerce.setup.db.  display_page takes four arguments:
		# the cart path, the routine calling it, the current
		# filename and the current line number.

sub output_frontpage
{

&display_page("$sc_store_front_path", "Output Frontpage", __FILE__, __LINE__);

}

#######################################################################
#                    Add to Shopping Cart                             #
#######################################################################

		# The add_to_the_cart subroutine is used to add items to
		# the customer's unique cart.  It is called with no
		# arguments with the following syntax:
		#
		# &add_to_the_cart;

sub add_to_the_cart
{

&checkReferrer;

		# the script first opens the user's shopping cart with read/write access,
		# creating it if for some reason it is not already there. If there is a
		# problem opening the file, it will call file_open_error subroutine
		# to handle the error reporting.

open (CART, "+>>$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);

		# The script then retrieves the highest item number of the items already
		# in the cart (if any). The item number is an arbitrary number used to
		# uniquely identify each item, as described below.

# init highest item number (start at 100)
$highest_item_number = 100; 

# make sure we're positioned at top of file
seek (CART, 0, 0); 

# loop on cart contents, if any
while (<CART>) 

{

# get rid of terminating newline
chomp $_;

# split cart row into fields
my @row = split (/\|/, $_); 

# get item number of row (last field)
my $item_number = pop (@row);

$highest_item_number = $item_number if ($item_number > $highest_item_number);

}

		# $highest_item_number is now either the highest item number,
		# or 0 if the cart was empty. Position the file pointer to the
		# end of the cart, in preparation for appending the new items later.

# position to end of file
seek (CART, 0, 2);

		# The script must first figure out what the client has
		# ordered.
		#
		# It begins by using the %form_data associative array
		# given to it by cgi-lib.pl.  It takes all of the keys
		# of the form_data associative array and drops them into
		# the @items_ordered array.
		#
		# Note: An associative array key is like a variable name
		# whereas an associative array value is the
		# value associated with that variable name. The
		# benefit of an associative array is that you can have
		# many of these key/value pairs in one array.
		# Conveniently enough, you'll notice that input fields on
		# HTML forms will have associated NAMES and VALUES
		# corresponding to associative array KEYS and VALUES.
		#
		# Since each of the text boxes in which the client could
		# enter quantities were associated with the database id
		# number of the item that they accompany, (as defined
		# in the display_page routine at the end of this
		# script), the HTML should read
		#
		#         <INPUT TYPE = "text" NAME = "1234">
		#
		# for the item with database id number 1234 and
		#
		#         <INPUT TYPE = "text" NAME = "5678">
		#
		# for item 5678.
		#
		# If the client orders 2 of 1234 and 9 of 5678, then
		# @incoming_data will be a list of 1234 and 5678 such that
		# 1234 is associated with 2 in %form_data associative
		# array and 5678 is associated with 9.  The script uses
		# the keys function to pull out just the keys.  Thus,
		# @items_ordered would be a list like (1234, 5678, ...).

@items_ordered = keys (%form_data);

		# Next it begins going through the list of items ordered
		# one by one.

foreach $item (@items_ordered)
{

		# However, there are some incoming items that don't need
		# to be processed. Specifically, we do not care about cart_id,
		# page, keywords, add_to_cart, or whatever incoming
		# administrative variables exist because these are all
		# values set internally by this script. They will be
		# coming in as form data just like the client-defined
		# data, and we will need them for other things, just not
		# to fill up the user's cart. In order to bypass all of
		# these administrartive variables, we use a standard
		# method for denoting incoming items.  All incoming items
		# are prefixed with the tag "item-".  When the script sees
		# this tag, it knows that it is seeing an item to be added
		# to the cart.
		#
		# Similarly, items which are actually options info are
		# denoted with the "option" keyword.  We will also accept
		# those for further processing.
		#
		# And fo course, we will not need to worry about any items
		# which have empty values.  If the shopper did not enter a
		# quantity, then we won't add it to the cart.

if (($item =~ /^item-/i || $item =~ /^option/i) && $form_data{$item} ne "")
{

		# Once the script has determined that the current element
		# ($item) of @items_ordered is indeeed a non-admin item,
		# it must separate out the items that have been ordered
		# from the options which modify those items.  If $item
		# begins with the keyword "option", which we set
		# specifically in the HTML file, the script will add
		# (push) that item to the array called @options.  However,
		# before we make the check, we must strip the "item-"
		# keyword off the item so that we have the actual row
		# number for comparison.

$item =~ s/^item-//i;

if ($item =~ /^option/i)
{
push (@options, $item);
}

		# On the other hand, if it is not an option, the script adds
		# it to the array @items_ordered_with_options, but adds
		# both the item and its value as a single array element.
		#
		# The value will be a quantity and the item will be
		# something like "item-0001|12.98|The letter A" as defined in
		# the HTML file.  Once we extract the initial "item-"
		# tag from the string using regular expressions ($item =~
		# s/^item-//i;), the resulting string would be something
		# like the following:
		#
		#           2|0001|12.98|The letter A
		#
		# where 2 is the quantity.
		#
		# Firstly, it must be a digit ($form_data{$item} =~ /\D/).
		# That is, we do not want the clients trying to enter
		# values like "a", "-2", ".5" or "1/2".  They might be
		# able to play havok on the ordering system and a sneaky
		# client may even gain a discount because you were not
		# reading the order forms carefully.
		#
		# Secondly, the script will dissallow any zeros
		# ($form_data{$item} == 0).  In both cases the client will
		# be sent to the subroutine bad_order_note located in
		# commerce_html_lib.pl.

else
{

	if (($form_data{"item-$item"} =~ /\D/) || ($form_data{"item-$item"} == 0))
	{
	&bad_order_note;
	}

	else
	{
	$quantity = $form_data{"item-$item"};
	push (@items_ordered_with_options, "$quantity\|$item\|");
	}

}

# End of if ($item ne "$variable" && $form_data{$item} ne "")
}

#End of foreach $item (@items_ordered)
}


		# Now the script goes through the array
		# @items_ordered_with_options one item at a time in order
		# to modify any item which has had options applied to it.
		# Recall that we just built the @options array with all
		# the options for all the items ordered.  Now the script
		# will need to figure out which options in @options belong
		# to which items in @items_ordered_with_options.

foreach $item_ordered_with_options (@items_ordered_with_options)

{

		# First, clear out a few variables that we are going to
		# use for each item.
		#
		# $options will be used to keep track of all of the
		# options selected for any given item.
		#
		# $option_subtotal will be used to determine the total
		# cost of each option.
		#
		# $option_grand_total will be used to calculate the
		# total cost of all ordered options.
		#
		# $item_grand_total will be used to calculate the total
		# cost of the item ordered factoring in quantity and
		# options.

$options = "";
$option_subtotal = "";
$option_grand_total = "";
$item_grand_total = "";

# Now split out the $item_ordered_with_options into it's
# fields.  Note that we have defined the index location of
# some important fields in commerce.setup.db  Specifically,
# the script must know the index of quantity, item_id and
# item_price within the array.  It will need these values
# in particular for further calculations.  Also, the
# script will change all occurances of "~qq~" to a double
# quote (") character, "~gt~" to a greater than sign (>)
# and "~lt~" to a less than sign (<).  The reason that
# this must be done is so that any double quote, greater
# than, or less than characters used in URLK strings can
# be stuffed safely into the cart and passed as part of
# the NAME argumnet in the "add item" form.  Consider the
# following item name which must include an image tag.
#
# <INPUT TYPE = "text"
#	 NAME = "item-0010|Vowels|15.98|The letter A|~lt~IMG SRC = ~qq~Html/Images/a.jpg~qq~ ALIGN = ~qq~left~qq~~gt~"
#
# Notice that the URL must be edited. If it were not, how
# would the browser understand how to interpret the form
# tag?  The form tag uses the double quote, greater
# than, and less than characters in its own processing.

$item_ordered_with_options =~ s/~qq~/\"/g;
$item_ordered_with_options =~ s/~gt~/\>/g;
$item_ordered_with_options =~ s/~lt~/\</g;

@cart_row = split (/\|/, $item_ordered_with_options);
$item_quantity = $cart_row[$sc_cart_index_of_quantity];
$item_id_number = $cart_row[$sc_cart_index_of_item_id];
$item_price = $cart_row[$sc_cart_index_of_price];
$item_shipping = $cart_row[6];

		# Then for every option in @options, the script splits up
		# each option into it's fields.
		#
		# Once it does both splits, the script can compare the name
		# of the item with the name associated with the option.
		# If they are the same, it knows that this is an option
		# which was meant to enhance this item.

foreach $option (@options)
{
($option_marker, $option_number, $option_item_number) = split (/\|/, $option);

		# If the script finds a match, it records the option
		# information contained in the $option variable.

if ($option_item_number eq "$item_id_number")
{

		# Since it must apply this option to this item, the script
		# splits out the value associated with the option and
		# appends it to $options.  Once it has gone through all of
		# the options, using .=, the script will have one big string
		# containing all the options so that it can print them
		# out. Note that in the form on which the client chooses
		# options, each option is denoted with the form
		#
		#            NAME = "a|b|c" VALUE = "d|e"
		#
		# where
		#
		# a is the option marker "option"
		# b is the option number (you might have multiple options
		#	which all modify the same item.  Option number
		#	identifies each option uniquely)
		# c is the option item number (the unique item id number
		#	which the option modifies)
		# d is the option name (the descriptive name of the
		#	option)
		# e is the option price.
		#
		# For example, consider this option from the default
		# Vowels.html file which modifies item number 0001:
		#
		#      <INPUT TYPE = "radio" NAME = "option|2|0001"
                #             VALUE = "Red|0.00" CHECKED>Red<BR>
		#
		# This is the second option modifying item number 0001.
		# When displayed in the display cart sscreen, it will read
		# "Red 0.00, and will not affect the cost of the item.

($option_name, $option_price) = split (/\|/,$form_data{$option});
if($option_name)
{
$options .= "$option_name $option_price<br>";
}
		# But the script must also calculate the cost changes with
		# options. To do so, it will take the current value of
		# $option_grand_total and add to it the value of the
		# current option.  It will then format the result to
		# two decimal places using the format_price subroutine
		# discussed later and assign the new result to
		# $option_grand_total

$unformatted_option_grand_total = $option_grand_total + $option_price;
$option_grand_total = &format_price($unformatted_option_grand_total);

# End of if ($option_item_number eq "$item_id_number")
}

# End of foreach $option (@options)
}

		# Next, calculate $item_number which the script can use to
		# identify a shopping cart item absolutely.  This must be done so
		# that when we modify and delete from the cart, we will
		# know exactly which item to affect. We cannot rely simply
		# on the unique database id number because a client may
		# purchase two of the same item but with different
		# options. Unless there is a separate, unique cart row id
		# number, how would the script know which to delete if the
		# client asked to delete one of the two. Add 1 to
		# $highest_item_number, which was set at the beginning of the subroutine.

$item_number = ++$highest_item_number;

		# Finally, the script makes the last price calculations
		# and appends every ordered item to $cart_row
		#
		# A completed cart row might look like the following:
		# 2|0001|Vowels|15.98|Letter A|Times New Roman 0.00|15.98|161

$unformatted_item_grand_total = $item_price + $option_grand_total;
$item_grand_total = &format_price("$unformatted_item_grand_total");

foreach $field (@cart_row)
{
$cart_row .= "$field\|";
}

$cart_row .= "$options\|$item_grand_total\|$item_number\n";

# End of foreach $item_ordered_with_options.....
}

		# When it is done appending all the items to $cart_row,
		# the script appends the new items to the end of the
		# shopping cart, which was opened at the beginning of the subroutine.

if (-e "$sc_cart_path")
{
open (CART, ">>$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);

print CART "$cart_row";

close (CART);
}

else
{
open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Add to Shopping Cart", __FILE__, __LINE__);

print CART "$cart_row";

close (CART);
}

		# Then, the script sends the client back to a previous
		# page.  There are two pages that the customer can be sent
		# of course, the last product page they were on or the
		# page which displays the customer's cart.  Which page the
		# customer is sent depends on the value of
		# $sc_should_i_display_cart_after_purchase which is defined
		# in commerce.setup.db  If the customer should be sent to
		# the display cart page, the script calls
		# display_cart_contents, otherwise it calls display_page
		# if this is an HTML-based cart or
		# create_html_page_from_db if this is a database-based
		# cart.

if ($sc_use_html_product_pages eq "yes")
{

	if ($sc_should_i_display_cart_after_purchase eq "yes")
	{
	&display_cart_contents;
	}

	else
	{
	&display_page("$sc_html_product_directory_path/$page",	"Display Products for Sale");
	}
}

else
{
	if ($sc_should_i_display_cart_after_purchase eq "yes")
	{
	&display_cart_contents;
	}

	elsif ($are_any_query_fields_filled_in =~ /yes/i)
	{
	$page = "";
	&display_products_for_sale;
	}

	else
	{
	&create_html_page_from_db;
	}
}


} 

#######################################################################
#                  Output Modify Quantity Form                        #
#######################################################################

		# output_modify_quantity_form is the subroutine
		# responsible for displaying the form which customers can
		# use to modify the quantity of items in their cart.  It
		# is called with no argumnets with the following syntax:
		#
		# &output_modify_quantity_form;

sub output_modify_quantity_form
{

		# The subroutine begins by outputting the HTML header
		# using standard_page_header, adds the modify form using
		# display_cart_table and finishes off the HTML page with
		# modify_form_footer. All of these subrotuines are
		# discussed in commerce_html_lib.pl

&standard_page_header("Change Quantity");
&display_cart_table("changequantity");
&modify_form_footer;
}

#######################################################################
#                Modify Quantity of Items in the Cart                 #
#######################################################################

		# The modify_quantity_of_items_in_cart subroutine is
		# responsible for making quantity modifications in the
		# customer's cart.  It takes no arguments and as called
		# with the following syntax:
		#
		# &modify_quantity_of_items_in_cart;

sub modify_quantity_of_items_in_cart
{

&checkReferrer;

		# First, the script gathers the keys as it did for the
		# add_to_cart routine previously, checking to make
		# sure the customer entered a positive integer (not
		# fractional and not less than one).

@incoming_data = keys (%form_data);

foreach $key (@incoming_data)
{

if ((($key =~ /[\d]/) && ($form_data{$key} =~ /\D/)) || $form_data{$key} eq "0")
{
&update_error_log("BAD QUANTITY CHANGE", __FILE__, __LINE__);
&bad_order_note("change_quantity_button");
}

		# Just as the script did in the add to cart routine
		# previuosly, it will create an array (@modify_items) of
		# valid keys.

unless ($key =~ /[\D]/ && $form_data{$key} =~ /[\D]/)
{
	if ($form_data{$key} ne "")
        {
        push (@modify_items, $key);
        }
}

# End of foreach $key (@incoming_data)
}

		# Then, the script must open up the client's cart and go
		# through it line by line.  File open problems are
		# handled by file_open_error as usual.

open (CART, "<$sc_cart_path") || &file_open_error("$sc_cart_path", "Modify Quantity of Items in the Cart", __FILE__, __LINE__);

		# As the script goes through the cart, it will split each
		# row into its database fields placing them as elements in
		# @database_row.  It will then grab the unique cart row
		# number and subsequently replace it in the array.
		#
		# The script needs this number to check the current line
		# against the list of items to be modified. Recall that
		# this list will be made up of all the cart items which
		# are being modified.
		#
		# The script also grabs the current quantity of that row.
		# Since it is not yet sure if it wants the current
		# quantity, it will hold off on adding it back to the
		# array.  Finally, the script chops the newline character
		# off the cart row number.

while (<CART>)
{
@database_row = split (/\|/, $_);
$cart_row_number = pop (@database_row);
push (@database_row, $cart_row_number);
$old_quantity = shift (@database_row);
chop $cart_row_number;

		# Next, the script checks to see if the item number
		# submitted as form data is equal to the number of the
		# current database row.
 
foreach $item (@modify_items)
{

if ($item eq $cart_row_number)
{

		# If so, it means that the script must change the quantity
		# of this item.  It will append this row to the
		# $shopper_row variable and begin creating the modified
		# row.  That is, it will replace the old quantity with the
		# quantity submitted by the client ($form_data{$item}).
		# Recall that $old_quantity has already been shifted off
		# the array.

$shopper_row .= "$form_data{$item}\|";

		# Now the script adds the rest of the database row to
		# $shopper_row and sets two flag variables.
		#
		# $quantity_modified lets us know that the current row
		# has had a quantity modification for each iteration of
		# the while loop.  

foreach $field (@database_row)
{
$shopper_row .= "$field\|";
}

$quantity_modified = "yes";
chop $shopper_row; # Get rid of last pipe symbol but not the
			   # newline character

# End of if ($item eq $cart_row_number)
}

# End of foreach $item (@modify_items)
}

		# If the script gets this far and $quantity_modified has
		# not been set to "yes", it knows that the above routine
		# was skipped because the item number submitted from the
		# form was not equal to the curent database id number. 
		#
		# Thus, it knows that the current row is not having its
		# quantity changed and can be added to $shopper_row as is.
		# Remember, we want to add the old rows as well as the new
		# modified ones.

if ($quantity_modified ne "yes")
{
$shopper_row .= $_;
}

		# Now the script clears out the quantity_modified variable
		# so that next time around it will have a fresh test.

$quantity_modified = "";

# End of while (<CART>)
}

close (CART);

		# At this point, the script has gone all the way through
		# the cart.  It has added all of the items without
		# quantity modifications as they were, and has added all
		# the items with quantity modifications but made the
		# modifications.
		# 
		# The entire cart is contained in the $shopper_row
		# variable.  
		#
		# The actual cart still has the old values, however.  So
		# to change the cart completely the script must overwrite
		# the old cart with the new information and send the
		# client back to the view cart screen with the
		# display_cart_contents subroutine which will be discussed
		# later. Notice the use of the write operator (>) instead
		# of the append operator (>>).

open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Modify Quantity of Items in the Cart", __FILE__, __LINE__);

print CART "$shopper_row";

close (CART);

&display_cart_contents;

# End of if ($form_data{'submit_change_quantity'} ne "")
}

#######################################################################
#                 Output Delete Item Form                             #
#######################################################################

		# The output_delete_item_form subroutine is responsible
		# for displaying the HTML form which the customer can use
		# to delete items from their cart.  It takes no arguments
		# and is called with the following syntax:
		#
		# &output_delete_item_form;

sub output_delete_item_form
{

		# As it did when it printed the modification form, the
		# script uses several subroutines in commerce_html_lib.pl
		# to generate the header, body and footer of the delete
		# form.

&standard_page_header("Delete Item");
&display_cart_table("delete");
&delete_form_footer;

# End of if ($form_data{'delete_item'} ne "")
}

#######################################################################
#                 Delete Item From Cart                               #
#######################################################################

		# The job of delete_from_cart is to take a set of items
		# submitted by the user for deletion and actually delete
		# them from the customer's cart.  The subroutine takes no
		# arguments and is called with the following syntax:
		#
		# &delete_from_cart;

sub delete_from_cart
{

&checkReferrer;

		# As with the modification routines, the script first 
		# checks for valid entries. This time though it only needs
		# to make sure that it filters out the extra form
		# keys rather than make sure that it has a positive
		# integer value as well because unlike with a text entry,
		# clients have less ability to enter bad values with
		# checkbox submit fields.

@incoming_data = keys (%form_data);
foreach $key (@incoming_data)
{

		# We still want to make sure that the key is a cart row
		# number though and that it has a value associated with
		# it. If it is actually an item which the user has asked to
		# delete, the script will add it to the delete_items
		# array.

unless ($key =~ /[\D]/)
{
if ($form_data{$key} ne "")
{
push (@delete_items, $key);
}

# End of unless ($key =~ /[\D]/...
}

# End of foreach $key (@incoming_data)
}

		# Once the script has gone through all the incomming form
		# data and collected the list of all items to be deleted,
		# it opens up the cart and gets the $cart_row_number,
		# $db_id_number, and $old_quantity as it did in the
		# modification routines previously.

open (CART, "<$sc_cart_path") || &file_open_error("$sc_cart_path", "Delete Item From Cart", __FILE__, __LINE__);

while (<CART>)
{
@database_row = split (/\|/, $_);
$cart_row_number = pop (@database_row);
$db_id_number = pop (@database_row);
push (@database_row, $db_id_number);
push (@database_row, $cart_row_number);
chop $cart_row_number;
$old_quantity = shift (@database_row);

		# Unlike modification however, for deletion all we need to
		# do is check to see if the current database row matches
		# any submitted item for deletion.  If it does not match
		# the script adds it to $shopper_row.  If it is equal,
		# it does not. Thus, all the rows will be added to
		# $shopper_row except for the ones that should be deleted.

$delete_item = "";
foreach $item (@delete_items)
{

if ($item eq $cart_row_number)
{
$delete_item = "yes";
}

# End of foreach $item (@add_items)
}

if ($delete_item ne "yes")
{
$shopper_row .= $_;
}

# End of while (<CART>)
}

close (CART);

		# Then, as it did for modification, the scipt overwrites
		# the old cart with the new information and
		# sends the client back to the view cart page with the
		# display_cart_contents subroutine which will be discussed
		# later.

open (CART, ">$sc_cart_path") || &file_open_error("$sc_cart_path", "Delete Item From Cart", __FILE__, __LINE__);

print CART "$shopper_row";
close (CART);

&display_cart_contents;

# End of if ($form_data{'submit_deletion'} ne "") 
}

#######################################################################
#                    Display Products for Sale                        #
#######################################################################

		# display_products_for_sale is used to generate
		# dynamically the "product pages" that the client will
		# want to browse through.  There are two cases within it
		# however.  
		#
		# Firstly, if the store is an HTML-based store, this
		# routine will either display the requested page
		# or, in the case of a search, perform a search on all the
		# pages in the store for the submitted keyowrd.
		#
		# Secondly, if this is a database-based store, the script
		# will use the create_html_page_from_db to output the
		# product page requested or to perform the search on the
		# database.
		#
		# The subroutine takes no arguments and is called with the
		# following syntax:
		#
		# &display_products_for_sale;

sub display_products_for_sale
{

		# The script first determines which type of store this is.
		# If it turns out to be an HTML-based store, the script
		# will check to see if the current request is a keyword
		# search or simply a request to display a page.  If it is
		# a keyword search, the script will require the html
		# search library and use the html_search subroutine with
		# in it to perform the search.

if ($sc_use_html_product_pages eq "yes")
{

if ($form_data{'search_request_button'} ne "")
{
&standard_page_header("Search Results");
require "$sc_html_search_routines_library_path";
&html_search;
&html_search_page_footer;
exit;
}

		# If the store is HTML-based and there is no current
		# keyword however, the script simply displays the page as
		# requested with display_page which will be discussed
		# shortly.
	 
&display_page("$sc_html_product_directory_path/$page", "Display Products for Sale", __FILE__, __LINE__);
}

		# On the other hand, if $sc_use_html_product_pages was set to
		# no, it means that the admin wants the script to generate
		# HTML product pages on the fly using the format string
		# and the raw database rows.  The script will do so
		# using the create_html_page_from_db subroutine which will
		# be discussed next.

else
{
&create_html_page_from_db;
}

}

#######################################################################   
#                   create_html_page_from_db Subroutine               #  
#######################################################################   

		# create_html_page_from_db is used to genererate the
		# navigational interface for database-base stores.  It is
		# used to create both product pages and "list of products"
		# pages.  The subroutine takes no arguments and is called
		# with the following syntax:
		#
		# &create_html_page_from_db;

sub create_html_page_from_db
{

		# First, the script defines a few working variables which
		# will remain local to this subroutine.

local (@database_rows, @database_fields, @item_ids, @display_fields);
local ($total_row_count, $id_index, $display_index);
local ($row, $field, $empty, $option_tag, $option_location, $output);

		# Next the script checks to see if there is actually a
		# page which must be displayed.  If there is a value for
		# the page variable incoming as form data, (ie: list of 
		# product page) the script will simply display that page
		# with the display_page subroutine and exit.

if ($page ne "" && $form_data{'search_request_button'} eq "" && $form_data{'continue_shopping_button'} eq "")

{
&display_page("$sc_html_product_directory_path/$form_data{'page'}", "Display Products for Sale", __FILE__, __LINE__);
exit;
}
		
		# If there is no page value, then the script knows that it
		# must generate a dynamic product page using the value of
		# the product form variable to query the database.
		#
		# First, the script uses the product_page_header
		# subroutine in order to dynamically generate the product
		# page header.  We'll pass to the subroutine the value of
		# the page we have been asked to display so that it can
		# display something useful in the <TITLE></TITLE> area.
		#
		# The product_page_header subroutine is located in
		# commerce_html_lib.pl and $sc_product_display_title is
		# defined in the setup file.

&product_page_header($sc_product_display_title);

if ($form_data{'add_to_cart_button.x'} ne "" && $sc_shall_i_let_client_know_item_added eq "yes")

{
print "$sc_item_ordered_message";
}

		# Next the database is querried for rows containing the
		# value of the incoming product variable in the correct
		# category as defined in commerce.setup.db  The script uses
		# the submit_query subroutine in commerce_db_lib.pl
		# passing to it a reference to the list array 
		# database_rows.  
		# 
		# submit_query returns a descriptive status message  
		# if there was a problem and a total row count
		# for diagnosing if the maximum rows returned
                # variable was exceeded.

if (!($sc_db_lib_was_loaded =~ /yes/i))

{
&require_supporting_libraries (__FILE__, __LINE__, "$sc_db_lib_path"); 
}

($status,$total_row_count) = &submit_query(*database_rows);

		# Now that the script has the database rows to be
		# displayed, it will display them.
		#
		# Firstly, the script goes through each database row
		# contained in @database_rows splitting it into it's
		# fields.
		#
		# For the most part, in order to display the database
		# rows, the script will simply need to take each field
		# from the database row and substitute it for a %s in the
		# format string defined in commerce.setup.db  
		#
		# However, in the case of options which will modify a
		# product, the script must grab the code from an options
		# file.
		#
		# The special way that options are denoted in the database
		# are by using the format %%OPTION%%option.html in the
		# data file.  This string includes two important bits of
		# information.  
		#
		# Firstly, it begins with %%OPTION%%.  This is a flag
		# which will let the script know that it needs to deal
		# with this database field as if it were an option.  When
		# it sees the flag, it will then look to the bit after the
		# flag to see which file it should load. Thus, in this
		# example, the script would load the file option.html for
		# display.
		#
		# Why go through all the trouble?  Well basically, we need
		# to create a system which will handle large chunks of
		# HTML code within the database that are very likely to be
		# similar.  If there are options on product pages, it is
		# likely that they are going to be repeated fairly
		# often.  For example, every item in a database might have
		# an option like tape, cd or lp.  By creating one
		# options.html file, we could easily put all the code into
		# one shared location and not need to worry about typing
		# it in for every single database entry.

$nextCount = $form_data{'next'}+$sc_db_max_rows_returned;
$prevCount = $form_data{'next'}-$sc_db_max_rows_returned;

$minCount = $form_data{'next'};
$maxCount = $form_data{'next'}+$sc_db_max_rows_returned;

foreach $row (@database_rows)
{
$rowCount++;

$prevHits = $sc_db_max_rows_returned;
$nextHits = $sc_db_max_rows_returned;

if ($rowCount > $minCount && $rowCount <= $maxCount)
{

@database_fields = split (/\|/, $row);
foreach $field (@database_fields)

{

		# For every field in every database row, the script simply
		# checks to see if it begins (^) with %%OPTION%%.  If so,
		# it splits out the string into three strings, one
		# empty, one equal to OPTION and one equal to the location
		# of the option to be used.  Then the script resets the
		# field to null because it is about to overwrite it.

if ($field =~ /^%%OPTION%%/)
{
($empty, $option_tag, $option_location) = split (/%%/, $field);
$field = "";

		# The option file is then opened and read.  Next, every
		# line of the option file is appended to the $field
		# variable and the file is closed again.  However, the
		# current product id number is substituted for the
		# %%PRODUCT_ID%% flag

open (OPTION_FILE, "<$sc_options_directory_path/$option_location") ||
&file_open_error ("$sc_options_directory_path/$option_location", "Display Products for Sale", __FILE__,__LINE__);

while (<OPTION_FILE>)
{
s/%%PRODUCT_ID%%/$database_fields[$sc_db_index_of_product_id]/g;

$field .= $_;
}

close (OPTION_FILE);

# End of if ($field =~ /^%%OPTION%%/)
}

# End of foreach $field (@database_fields)

}


		# Finally, the database fields (including the option field
		# which has been recreated) are stuffed into the format
		# string, $sc_product_display_row and the entire formatted
		# string is printed to the browser along with the footer.
		#
		# First, however, we must format the fields correctly.
		# Initially, @display_fields is created which contains the
		# values of every field to be displayed, including a
		# formatted price field.

@display_fields = ();
@temp_fields = @database_fields;
foreach $display_index (@sc_db_index_for_display) 

{

if ($display_index == $sc_db_index_of_price)

{  
$temp_fields[$sc_db_index_of_price] =
&display_price($temp_fields[$sc_db_index_of_price]);
}

push(@display_fields, $temp_fields[$display_index]);
}

		# Then, the elements of the NAME field are created so that
		# customers will be able to specify an item to purchase.
		# We are careful to substitute double quote marks ("), and
		# greater and less than signs (>,<) for the tags ~qq~,
		# ~gt~, and ~lt~. The reason that this must be done is so
		# that any double quote, greater than, or less than
		# characters used in URL strings can be stuffed safely
		# into the cart and passed as part of the NAME argumnet in
		# the "add item" form.  Consider the following item name
		# which must include an image tag.
		#
		# <INPUT TYPE = "text" 
		#	 NAME = "item-0010|Vowels|15.98|The letter A|~lt~IMG SRC = ~qq~Html/Images/a.jpg~qq~ ALIGN = ~qq~left~qq~~gt~"
		#
		# Notice that the URL must be edited. If it were not, how
		# would the browser understand how to interpret the form
		# tag?  The form tag uses the double quote, greater
                # than, and less than characters in its own processing.

@item_ids = ();

foreach $id_index (@sc_db_index_for_defining_item_id) 
{
$database_fields[$id_index] =~ s/\"/~qq~/g;
$database_fields[$id_index] =~ s/\>/~gt~/g;
$database_fields[$id_index] =~ s/\</~lt~/g;

push(@item_ids, $database_fields[$id_index]);
	


}

		# Finally, $sc_product_display_row is created with the two
		# arrays using printf to apply the formatting.
		# 
$itemID = join("\|",@item_ids);
$sc_product_display_row = &displayProductPage;

# End of foreach $row (@database_rows)
}

}

&product_page_footer($status,$total_row_count);

print <<ENDOFTEXT;

<CENTER>
<INPUT TYPE = "submit" NAME = "add_to_cart_button" VALUE = "Add Items to my Cart">
</CENTER>

ENDOFTEXT

exit;

}

#######################################################################   
#                   display_cart_contents Subroutine                  #  
#######################################################################   

		# display_cart_contents is used to display the current
		# contents of the customer's cart.  It takes no arguments
		# and is called with the following syntax:
		#
		# &display_cart_contents;

sub display_cart_contents
{

		# The subroutine begins by defining some working variables
		# as local to the subroutine.

local (@cart_fields);
local ($field, $cart_id_number, $quantity, $display_number,
$unformatted_subtotal, $subtotal, $unformatted_grand_total,
$grand_total);
    
		# Next, as when we created the modification and deletion
		# forms for cart manipulation, we will use the routines in
		# commerce_html_lib.pl to generate the header, body and
		# footer of the cart page.  However, unlike with the
		# modification and deletion forms, we will not need an
		# extra table cell for the checkbox or text field.  Thus,
		# we will not pass anything to display_cart_table.  We
		# will simply get a table representing the current
		# contents of the customer's cart.

&standard_page_header("View/Modify Cart");    
&display_cart_table("");
&cart_footer;
exit;

# End of sub display_cart_contents
}

#######################################################################
#                    file_open_error Subroutine                       #
#######################################################################

		# If there is a problem opening a file or a directory, it
		# is useful for the script to output some information
		# pertaining to what problem has occurred.  This
		# subroutine is used to generate those error messages.
		# 
		# file_open_error takes four arguments: the file or
		# directory which failed, the section in the code in which
		# the call was made, the current file name and
		# line number, and is called with the following syntax:
		#
		# &file_open_error("file.name", "ROUTINE", __FILE__,
		#		   __LINE__);

sub file_open_error
{

		# The subroutine simply uses the update_error_log
		# subroutine discussed later to modify the error log and
		# then uses CgiDie in cgi-lib.pl to gracefully exit the
		# application with a useful debugging error message sent
		# to the browser window.

local ($bad_file, $script_section, $this_file, $line_number) = @_;
&update_error_log("FILE OPEN ERROR-$bad_file", $this_file, $line_number);

open(ERROR, $error_page);

while (<ERROR>)

{  
print $_;
}
  
close (ERROR);

}


#######################################################################
#                     display_page Subroutine                         #
#######################################################################

		# display_page is used to filter HTML pages through the
		# script and display them to the browser window. 
		#
                # display_page takes  four arguments: the file or      
                # directory which failed, the section in the code in which
                # the erroneous call was made, the current file name and
                # line number, and is called with the following syntax:
                #
                # &file_open_error("file.name", "ROUTINE", __FILE__,
                #                  __LINE__);
                #
                # (notice the two special Perl variables __FILE__, which
                # equals the current filename, and __LINE__ which equals
                # the current line number).

sub display_page
{
local ($page, $routine, $file, $line) = @_;

		# the subroutine begins by opening the requested file for
		# reading, exiting with file_open_error if there is a
		# problem as usual.

&StoreHeader;
open (PAGE, "<$page") || &file_open_error("$page", "$routine", $file, $line);

		# It then reads in the file one line at a time.  However,
		# on every line it looks for special tag sequences which
		# it knows it must modify in order to maintain the state
		# information necessary for the workings of this script.
		# Specifically, every form must include a page and a
		# cart_id value and every url hyperlink must have a
		# cart_id value added to it.
		#
		# Raw administratively pre-designed HTML pages must
		# include the follwoing tag lines if they are to filter
		# properly and pass along this necesary state information.
		#
		# All forms must include two hidden field lines with the
		# "tags" tobe substituted for imbedded as follows:
		#
		# <INPUT TYPE = "hidden" NAME = "cart_id" VALUE = "%%cart_id%%">
		# <INPUT TYPE = "hidden" NAME = "page" VALUE = "%%page%%">
		#
		# When the script reads in these lines, it will see the
		# tags "%%cart_id%%" and"%%page%%" and substitute them for
		# the actual page and cart_id values which came in as form
		# data.
		#
		# Similarly it might see the following URL reference:
		#
		# <A HREF = "merchant.cgi?page=Letters.html&cart_id=">
		#
		# In this case, it will see the cartid= tag and
		# substitute in the correct and complete
		# "cartid=some_number".
		
$pagesfile2 = "admin_files/pages_lib.data";
open (CHECKSKU, "$pagesfile2") || die "Can't Open $pagesfile2";

while(<CHECKSKU>)

{
$row=$_;
@user = split(/\|/,$row);

if ($user[0] eq "1")
	{
	{$frontpage ="$user[2]";}
	}

if ($user[0] eq "2")
	{
	{$aboutus ="$user[2]";}
	}
	
if ($user[0] eq "3")
	{
	{$customerservice ="$user[2]";}
	}	

if ($user[0] eq "4")
	{
	{$refundpolicy ="$user[2]";}
	}	

if ($user[0] eq "5")
	{
	{$contactus ="$user[2]";}
	}	

}

while (<PAGE>)

{

s/%%cart_id%%/$cart_id/g;
s/%%page%%/$form_data{'page'}/g;
s/%%date%%/$date/g;
s/%%URLofImages%%/$URL_of_images_directory/g;
s/%%colorcode%%/$colorcode/g;

#########Pages

s/%%frontpage%%/$frontpage/g;
s/%%aboutus%%/$aboutus/g;
s/%%customerservice%%/$customerservice/g;
s/%%refundpolicy%%/$refundpolicy/g;
s/%%contactus%%/$contactus/g;


		# Next, it checks to see if the add_to_cart_button button
		# has been clicked.  if so, it means that we have just
		# added an item and are returning to the display of the
		# product page.  In this case, we will sneak in an  addition
		# confirmation message right after the <FORM> tag line.

if ($form_data{'add_to_cart_button'} ne "" &&
    $sc_shall_i_let_client_know_item_added eq "yes")

{

if ($_ =~ /<FORM/)
{
print "$_";
print "$sc_item_ordered_message";
}


}

		# If it is any other line, simply print it out to the
		# browser window.  Once we have gone through all of the
		# lines in the file, the HTML will be complete and
		# filtered.

print $_;

}
  
close (PAGE);
&StoreFooter;

# End of sub display_page
}


sub display_page2
{
&StoreHeader;

local ($page, $routine, $file, $line) = @_;

		# the subroutine begins by opening the requested file for
		# reading, exiting with file_open_error if there is a
		# problem as usual.

open (PAGE, "<$page") || &file_open_error("$page", "$routine", $file, $line);

while (<PAGE>)

{  

s/%%cart_id%%/$cart_id/g;
s/%%page%%/$form_data{'page'}/g;
s/%%date%%/$date/g;
s/%%URLofImages%%/$URL_of_images_directory/g;


		# Next, it checks to see if the add_to_cart_button button
		# has been clicked.  if so, it means that we have just
		# added an item and are returning to the display of the
		# product page.  In this case, we will sneak in an  addition
		# confirmation message right after the <FORM> tag line.

if ($form_data{'add_to_cart_button'} ne "" &&
    $sc_shall_i_let_client_know_item_added eq "yes")

{

if ($_ =~ /<FORM/)
{
print "$_";
print "$sc_item_ordered_message";
}


}

		# If it is any other line, simply print it out to the
		# browser window.  Once we have gone through all of the
		# lines in the file, the HTML will be complete and
		# filtered.

print $_;

}

close (PAGE);
&StoreFooter;

# End of sub display_page2
}



#################################################################
#                  update_error_log Subroutine                  #
#################################################################

		# update_error_log is used to append to the error log if
		# there has been a process executing this script and/or
		# email the admin. 
		#
		# The subroutine takes three arguments, the type of error,
		# the current filename and current line number and is
		# called with the following syntax:
		#
		# &update_error_log("WARNING", __FILE__, __LINE__);

sub update_error_log
{
	
		# The subroutine begins by assigning the incoming
		# argumnets to local variables and defining some other
		# local variables to use during its work.
		#
		# $type_of_error will be a text string explaining what
		# kind of error is being logged.
		#
		# $file_name is the current filename of this script.
		#
		# $line_number is the line number on which the error
		# occurred.  Note that it is essential that the line
		# number, stored in __LINE__ be passed through all levels
		# of subroutines so that the line number value will truly
		# represent the line number of the error and not the
		# line number of some subroutine for error handling.

local ($type_of_error, $file_name, $line_number) = @_;
local ($log_entry, $email_body, $variable, @env_vars);

		# The list of the HTTP environment variables are culled
		# into the @env_vars list array and get_date is used to
		# assign the current date to $date

@env_vars = keys(%ENV);
$date = &get_date;

		# Now, if the admin has instructed the script to log
		# errors by setting $sc_shall_i_log_errors in
		# commerce.setup.db, the script will create an error log
		# entry.

if ($sc_shall_i_log_errors eq "yes")
{

		# First, the new log entry row is created as a pipe
		# delimited list beginning with the error type, filename,
		# line number and current date.

$log_entry = "$type_of_error\|FILE=$file_name\|LINE=$line_number\|";
$log_entry .= "DATE=$date\|";

		# Then the error log file is opened securely by using the
		# lock file routines in get_file_lock discussed later.

&get_file_lock("$sc_error_log_path.lockfile");
open (ERROR_LOG, ">>$sc_error_log_path") || &CgiDie ("The Error Log could not be opened");

		# Now, the script adds to the log entry row, the values
		# associated with all of the HTTP environment variables
		# and prints the whole row to the log file which it then
		# closes and opens for use by other instances of this
		# script by removing the lock file.

foreach $variable (@env_vars)

{
$log_entry .= "$ENV{$variable}\|";
}  

print ERROR_LOG "$log_entry\n";
close (ERROR_LOG);  

&release_file_lock("$sc_error_log_path.lockfile");

# End of if ($sc_shall_i_log_errors eq "yes")
}

		# Next, the script checks to see if the admin has
		# instructed it to also send an email error notification
		# to the admin by setting the $sc_shall_i_email_if_error
		# in commerce.setup.db
		#
		# If so, it prepares an email with the same info contained
		# in the log file row and mails it to the admin using the
		# send_mail routine in mail-lib.pl.  Note that a common
		# sourse of email errors lies in the admin not setting the
		# correct path for sendmail in mail-lib.pl on line 42.
		# Make sure that you set this variable there if you are
		# not receiving your mail and you are using the sendmail
		# version of the mail-lib package.

if ($sc_shall_i_email_if_error eq "yes")

{
$email_body = "$type_of_error\n\n";
$email_body .= "FILE = $file_name\n";
$email_body .= "LINE = $line_number\n";
$email_body .= "DATE=$date\|"; 

foreach $variable (@env_vars)
{
$email_body .= "$variable = $ENV{$variable}\n";
}  

&send_mail("$sc_admin_email", "$sc_admin_email", "Web Store Error", "$email_body");

# End of if ($sc_shall_i_email_if_error eq "yes")
}


}

#################################################################
#                      get_date Subroutine                      #   
#################################################################

		# get_date is used to get the current date and time and
		# format it into a readable form.  The subroutine takes no
		# arguments and is called with the following syntax:
		#
		# $date = &get_date;
		#
		# It will return the value of the current date, so you
		# must assign it to a variable in the calling routine if
		# you are going to use the value.

sub get_date
{

		# The subroutine begins by defining some local working
		# variables

local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$date);
local (@days, @months); 
 
@days = ('Sunday','Monday','Tuesday','Wednesday','Thursday', 'Friday','Saturday');

@months = ('January','February','March','April','May','June','July',
           'August','September','October','November','December');

		# Next, it uses the localtime command to get the current
		# time, from the value returned by the time
		# command, splitting it into variables.

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

		# Then the script formats the variables and assign them to
		# the final $date variable.  Note that $sc_current_century
		# is defined in commerce.setup.db  Since the 20th centruy
		# is really 1900-1999, we'll need to subtract 1 from this
		# value in order to format the year correctly.

if ($hour < 10) 

{ 
$hour = "0$hour"; 
}

if ($min < 10) 

{ 
$min = "0$min"; 
}

if ($sec < 10) 

{
$sec = "0$sec"; 
}

$year += 1900;
$date = "$days[$wday], $months[$mon] $mday, $year at $hour\:$min\:$sec";

return $date;

}       

#################################################################
#                     display_price Subroutine                  #
#################################################################

		# display_price is used to format the price string so that
		# the store can take into account differing methods for
		# displaying prices. For example, some countries use
		# "$xxx.yyy".  Others may use "xx.yy UNIT".  This
		# subroutine will  use the $sc_money_symbol_placement and
		# the $sc_money_symbol variables defined in
		# commerce.setup.db to format the entire price string for
		# display.  The subroutine takes one argument, the price
		# to be formatted, and is called with the following
		# syntax:
		#
		# $price = &display_price(xx.yy);
		#
		# Where xx.yy is some number like 23.99.
		#
		# Note that the main routine calling this subroutine must
		# prepare a variable for the returned formatted price to
		# be assigned to.

sub display_price

{
local ($price) = @_;
local ($format_price);
        
if ($sc_money_symbol_placement eq "front")
{
$format_price = "$sc_money_symbol $price";
}

else
{
$format_price = "$price $sc_money_symbol";
}

return $format_price;
}

#######################################################################
#                            get_file_lock                            #
#######################################################################

		# get_file_lock is a subroutine used to create a lockfile.
		# Lockfiles are used to make sure that no more than one
		# instance of the script can modify a file at one time.  A
		# lock file is vital to the integrity of your data.
		# Imagine what would happen if two or three people
		# were using the same script to modify a shared file (like
		# the error log) and each accessed the file at the same
		# time.  At best, the data entered by some of the users
		# would be lost.  Worse, the conflicting demands could
		# possibly result in the corruption of the file.
		#
		# Thus, it is crucial to provide a way to monitor and
		# control access to the file.  This is the goal of the
		# lock file routines.  When an instance of this script
		# tries to  access a shared file, it must first check for
		# the existence of a lock file by using the file lock
		# checks in get_file_lock.
		#
		# If get_file_lock determines that there is an existing
		# lock file, it instructs the instance that called it to
		# wait until the lock file disappears.  The script then
		# waits and checks back after some time interval.  If the
		# lock file still remains, it continues to wait until some 
		# point at which the admin has given it permissios to just
		# overwrite the file because some other error must have
		# occurred.
		#
		# If, on the other hand, the lock file has dissappeared,
		# the script asks get_file_lock to create a new lock file
		# and then goes ahead and edits the file.
		#
		# The subroutine takes one argumnet, the name to use for
		# the lock file and is called with the following syntax:
		#
		# &get_file_lock("file.name");

sub get_file_lock 

{

local ($lock_file) = @_;
local ($endtime);
$endtime = 20;
$endtime = time + $endtime;

		# We set endtime to wait 20 seconds.  If the lockfile has
		# not been removed by then, there must be some other
		# problem with the file system.  Perhaps an instance of
		# the script crashed and never could delete the lock file.
    
while (-e $lock_file && time < $endtime) 
{
sleep(1);
}

open(LOCK_FILE, ">$lock_file") || &CgiDie ("I could not open the lockfile - check your permission settings");

		# Note: If flock is available on your system, feel free to
		# use it.  flock is an even safer method of locking your
		# file because it locks it at the system level.  The above
		# routine is "pretty good" and it will server for most
		# systems.  But if youare lucky enough to have a server 
		# with flock routines built in, go ahead and uncomment
		# the next line and comment the one above.

# flock(LOCK_FILE, 2); # 2 exclusively locks the file

} 

#######################################################################
#                            release_file_lock                        #
#######################################################################

		# release_file_lock is the partner of get_file_lock.  When
		# an instance of this script is done using the file it
		# needs to manipulate, it calls release_file_lock to
		# delete the lock file that it put in place so that other
		# instances of the script can get to the shared file.  It
		# takes one argument, the name of the lock file, and is
		# called with the following syntax:
		#
                # &release_file_lock("file.name");
    
sub release_file_lock 
{
local ($lock_file) = @_;
    
# flock(LOCK_FILE, 8); # 8 unlocks the file

		# As we mentioned in the discussion of get_file_lock,
		# flock is a superior file locking system.  If your system
		# has it, go ahead and use it instead of the hand rolled
		# version here.  Uncomment the above line and comment the
		# two that follow.

close(LOCK_FILE);
unlink($lock_file);

} 

#######################################################################
#                            format_price                             #
#######################################################################

		# format_price is used to format prices to two decimal
		# places. It takes one argumnet, the price to be formatted
		# and is called with the following syntax:
		#
		# $price =&format_price(xxx.yyyyy);
		#
		# Notice that the main calling routine must assign the
		# returned formatted price to some variable for its own
		# use.
		#
		# Also notice that this routine takes a value even if it
		# is longer than two decimal places and formats it with
		# rounding.  Thus, you can utilize price calculations such
		# as 12.99 * 7.985 (where 7.985 might be some tax value.
  
sub format_price
{

		# The incoming price is set to a local variables and a few
		# wroking local variables are defined.

local ($unformatted_price) = @_;
local ($formatted_price);

		# The script then uses the rounding method in EXCEL. If
		# the 3rd decimal place is > 4, then we round the 2nd
		# decimal place up 1. Otherwise, we leave the number
		# alone.  Notice that we will use the substr function to
		# pull off the last value in the three decimal place
		# number and compare it using the EXCEL logic.
		#
		# Basically, the routine uses the rounding rules of
		# sprintf.

		# The unformatted_price is rounded to 
		# to two decimal places and returned to the calling
		# routine.
$formatted_price = sprintf ("%.2f", $unformatted_price);
return $formatted_price;

}

############################################################
#
# subroutine: format_text_field
#   Usage:
#       $formatted_value =
#         &format_text_field($value, [$width]);
#
#   Parameters:
#     $value = text value to format.
#     $width = optional field width. Defaults to 25.
#
#     This routine takes the value and appends enough
#     spaces so that the field width is 25 spaces.
#     in order to justify the fields that are stored
#     eventually in the $text_of_cart.
#
#   Output:
#     The formatted value
#
############################################################

sub format_text_field 

{

local($value, $width) = @_;
$width = 25 if (!$width);

                # Very simple. We return the value in
                # $value plus a string of 25 spaces which
                # has been truncated by the length of
                # the $value string.
                #
                # This results in a left justified
                # field of width = 25.
                #
return ($value . (" " x ($width - length($value))));

#End of format_text_field
}

############################################################


sub specials
{

open (DATABASE, "data_files/data.file") || die "Can't Open datafile";
while(<DATABASE>)

	{

chop;
$databaserow=$_;
@databaserow = split(/\|/,$databaserow);

if ($databaserow[7] ne "") {

$databaserow[4] =~ s/%%URLofImages%%/$URL_of_images_directory/g;

$image = $databaserow[4];

$speciallinks .= "<TR><TD><DIV align=\"center\">\n";
$speciallinks .= "<A href=\"merchant.cgi?cart_id=$cart_id&itemnumber=$databaserow[0]\">$image<br><FONT face=\"Verdana, Arial\" size=\"1\"><BR>$databaserow[3]</A><br><font color=red>only \$ $databaserow[2]</font></FONT></DIV>\n";
$speciallinks .= "</TD></TR><TR><TD><hr width=\"125\" height=\"1\" noshade></TD></TR>\n";

}#end for each loop

}#end while database

}#subroutine


sub checkReferrer
{
# BEGIN REFERRING SITE VALIDATION
local ($referringDomain, $acceptedDomain);

$referringDomain = $ENV{'HTTP_REFERER'};
$acceptedDomain = $sc_domain_name_for_cookie;

$referringDomain =~ s/\?.*//g;
$referringDomain =~ s/http:\/\///g;
$referringDomain =~ s/\/.*//g;
$referringDomain =~ s/\/merchant.cgi//g;

if ($referringDomain =~ "^w*\.")
{
$referringDomain =~ s/^w*\.//i;
}

if ($acceptedDomain =~ "^w*\.")
{
$acceptedDomain =~ s/^w*\.//i;
}

if ($referringDomain ne $acceptedDomain)
{
print "$acceptedDomain is the accepted referrer.<br>";
print "$referringDomain is not a valid referrer<br>";
print "Refering Site Authentication Failed!";
exit;	
}
# END REFERRING SITE VALIDATION
}