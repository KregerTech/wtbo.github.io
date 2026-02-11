#######################################################################
#                    product_page_header Subroutine                   #
#######################################################################

		# product_page_header is used to display the shared
		# HTML header used for database-based product pages.  It
		# takes one argument, $page_title, which will be used to
		# fill the data between the <TITLE> and </TITLE>.
		# Typically, this value is determined by 
		# $sc_product_display_title in web_store.setup.
		# 
		# The subroutine is called with the following syntax:
		#
		# &product_page_header("Desired Title");

sub product_page_header
{

		# First, the script assigns the incoming argument to the
		# local variable $page_title

local ($page_title) = @_;

		# Then, it assigns the text of all of the hidden fields 
		# that may need to be passed as state information to
		# $hidden_fields using the make_hidden_fields subroutine
		# which will be discussed later.

local ($hidden_fields) = &make_hidden_fields;

		# Next, the HTML code is sent to the browser including the
		# page title and the hidden fields dynamically inserted.

print qq~
~;

&StoreHeader;

		# Next, we will grab $sc_product_display_header which is a
		# preformatted string defined in web_store.setup and use
		# printf to put the entire contents of
		# @sc_db_display_fields in place of the format tags (%s).
		# The function of this will be to display the header
		# categories which products will follow.
		#
		# Consider the following example from web_store.setup.db:
		# $sc_product_display_header = qq!
		#
		#  <TABLE BORDER = "0">
		#  <TR>
		#  <TH>Quantity</TH>
		#  <TH>%s</TH>
		#  <TH>%s</TH>
		#  </TR>
		#  <TR>
		#  <TD COLSPAN = "3"><HR></TD>
		#  </TR>!;
		#
		# @sc_db_display_fields = ("Image (If appropriate)",
		#                          "Description");
		#
		# In this case, the strings "Image (If appropriate)" and
		# "Description" will be substituted by the printf
		# function for the two %s's in the TABLE header defined in
		# $sc_product_display_header.

printf($sc_product_display_header, @sc_db_display_fields);

}

#######################################################################
#                    product_page_footer Subroutine                   #   
#######################################################################

		# product_page_footer is used to generate the HTML page
		# footer for database-based product pages.  It takes two
		# arguments, $db_status and $total_rows_returned and is
		# called with the following syntax:
		# 
		# &product_page_footer($status,$total_row_count);

sub product_page_footer

{
local($keywords);
$keywords = $form_data{'keywords'};

$keywords =~ s/ /+/g;

		# $db_status gives us the status returned from the database
		# search engine and $total_rows_returned gives us the
		# actual number of rows returned.  $warn_message which
		# is first initialized, will be used to generate a warning
		# that the user should narrow their search in case
		# too many rows were returned.

local($db_status, $total_rows_returned) = @_;
local($warn_message);
$warn_message = "<DIV ALIGN=CENTER>";

		# If the database returned a status, the script checks to
		# see if it was like the string "max.*row.*exceed".  If
		# so, it lets the user know that they need to narrow their
		# search.

if ($db_status ne "") 
{

	if ($db_status =~ /max.*row.*exceed.*/i) 
	{

		if($form_data{'next'} > "0")
		{
		$warn_message .= qq!
		<a href=merchant.cgi?product=$form_data{'product'}&keywords=$keywords&next=$prevCount>Previous $prevHits Matches</a> &nbsp;&nbsp;
		!;
		}

		if ($maxCount == $rowCount-1)
		{
			$nextHits = (@database_rows-$maxCount);
			if ($nextHits == 1)
			{
			$warn_message .= qq!
			<a href=merchant.cgi?product=$form_data{'product'}&keywords=$keywords&next=$maxCount>Last Match</a>	
			!;
			}

		}

	if ($maxCount < $rowCount && $maxCount != $rowCount-1)
	{

		if ($maxCount >= $rowCount-$nextHits )
		{
		$lastCount = $rowCount-$maxCount;
		$warn_message .= qq!
		<a href=merchant.cgi?product=$form_data{'product'}&keywords=$keywords&next=$maxCount>Last $lastCount Matches</a>	
		!;
		}
		else
		{
		$warn_message .= qq!
		<a href=merchant.cgi?product=$form_data{'product'}&keywords=$keywords&next=$maxCount>Next $nextHits Matches</a>	
		!;
		}
	
	}

	$warn_message .= "</DIV>";

	}

}

		# Then the script displays the footer information defined
		# with $sc_product_display_footer in web-store.setup and
		# adds the final basic HTML footer.  Notice that one of the
		# submit buttons, "Return to Frontpage" is isolated into
		# the $sc_no_frames_button variable.  This is because in
		# the frames version, we do not want that option as it
		# will cause an endlessly fracturing frame system.  Thus,
		# in a frame store, you would simply set 
		# $sc_no_frames_button to "" and nothing would print here.
		# Otherwise, you may include that button in your footer
		# for ease of navigation.  The variable itself is defined
		# in web_store.setup.  The script also will print the
		# warning message if there is a value for it.

print qq~
$sc_product_display_footer
<P>
$warn_message~;

&StoreFooter;

print qq~
~;
exit;

}

#######################################################################
#                 html_search_page_footer Subroutine                  #
#######################################################################

		# html_search_page_footer is used to generate the HTML
		# footer for HTML-based product pages when the script
		# must perform a keyword search and generate a list of
		# hits. It is called with no argumnets with the following
		# syntax:
		#
		# &html_search_page_footer;
		#
		# Notice again the use of $sc_no_frames_button in place of
		# the "Return to Frontpage" button as discussed in the
		# last section.

sub html_search_page_footer
{

print qq!

<CENTER>
<INPUT TYPE = "submit" NAME = "modify_cart_button" VALUE = "View/Modify Cart">
$sc_no_frames_button
<INPUT TYPE = "submit" NAME = "order_form_button" VALUE = "Checkout Stand">
</FORM>
</CENTER>  
!;

}

#######################################################################
#                    standard_page_header Subroutine                  #   
#######################################################################

		# standard_page_header is used to generate a standard HTML
		# header for pages within either the HTML-based or
		# Database-based stores.  It takes a single argumnet, the
		# title of the page to be displayed and is called with the
		# following syntax:
		#
		# &standard_page_header("TITLE");
		#
		# Note, as in the case of product_page_header, all state
		# variables must be passed as hidden fields.  These hidden
		# fields are generate by make_hidden_fields discussed
		# later.

sub standard_page_header   

{

local($type_of_page) = @_;
local ($hidden_fields) = &make_hidden_fields;

print qq!

!;

}

#######################################################################
#                    modify_form_footer Subroutine                    #   
#######################################################################

		# modify_form_footer is used to generate the HTML footer
		# code for the "modify quantity of items in the cart" form
		# page.  It takes no arguments and is called with the
		# following syntax:
		#
		# &modify_form_footer;
		#
		# As usual, we will admit the "Return to Frontpage" button
		# only if we are not using frames by defining it with the
		# $sc_no_frames_button in web_store.setup.

sub modify_form_footer

{
open (MODIFYFOOTER, "html/html-templates/change_quantity_footer.inc") ||
&file_open_error("$sc_cart_path", "cartfooter", __FILE__, __LINE__);

while (<MODIFYFOOTER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;

print $_;

}
close MODIFYFOOTER;

&StoreFooter;

}

#######################################################################
#                    delete_form_footer Subroutine                    #
#######################################################################

		# delete_form_footer is used to generate the HTML footer
		# code for the "delete items from the cart" form
		# page.  It takes no arguments and is called with the
		# following syntax:
		#
		# &delete_form_footer;
		#
		# As usual, we will admit the "Return to Frontpage" button
		# only if we are not using frames by defining it with the
		# $sc_no_frames_button in web_store.setup.

sub delete_form_footer

{

open (DELETEFOOTER, "html/html-templates/delete_items_footer.inc") ||
&file_open_error("$sc_cart_path", "cartfooter", __FILE__, __LINE__);

while (<DELETEFOOTER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;

print $_;

}
close DELETEITEMS;

&StoreFooter;

}

#######################################################################
#                       cart_footer Subroutine                        #
#######################################################################

		# cart_footer is used to generate the HTML footer
		# code for the "view items in the cart" form
		# page.  It takes no arguments and is called with the
		# following syntax:
		#
		# &cart_footer;
		#
		# As usual, we will admit the "Return to Frontpage" button
		# only if we are not using frames by defining it with the
		# $sc_no_frames_button in web_store.setup.

sub cart_footer
{
local($offlineSecureURL);

if($sc_gateway_name eq "Offline")
{
$offlineSecureURL =
"</FORM>
<FORM METHOD\=POST ACTION\=\"$sc_order_script_url\">
<INPUT TYPE\=HIDDEN NAME\=\"cart_id\" VALUE\=\"$cart_id\">";
}

open (CARTFOOTER, "html/html-templates/cart_footer.inc") ||
&file_open_error("$sc_cart_path", "cartfooter", __FILE__, __LINE__);

while (<CARTFOOTER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;
s/%%cart_id%%/$cart_id/g;
s/%%sc_order_script_url%%/$sc_order_script_url/g;
s/%%offlineSecureURL%%/$offlineSecureURL/g;

print $_;

}
close CARTFOOTER;

&StoreFooter;

}

#######################################################################
#                    bad_order_note Subroutine                        #
#######################################################################

		# bad_order_note generates an error message for the user
		# in the case that they have not submitted a valid number
		# for a quantity.  It takes no argumnets and is called
		# with the following syntax:
		# 
		# &bad_order_note;

sub bad_order_note

{

local($button_to_set) = @_;
$button_to_set = "try_again" if ($button_to_set eq "");

&standard_page_header("Error");

&StoreHeader;

print qq!
<CENTER>
<TABLE>
<TR>
<TD>
<FONT FACE="ARIAL">
<P>
<BR>
I'm sorry, it appears that you did not enter a valid numeric
quantity (whole numbers greater than zero). Please use your 
browser's Back button and try again. Thanks\!<BR>
<P>
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
!;
&StoreFooter;
exit;

}

#######################################################################
#                    cart_table_header Subroutine                     #
#######################################################################

		# cart_table_header is used to generate the header
		# HTML for views of the cart.  It takes one argument, the
		# type of view we are requesting and is called with the
		# following syntax:
		# 
		# &cart_table_header(TYPE OF REQUEST);

sub cart_table_header

{
local ($modify_type) = @_;

		# We take modify_type and make it into a table header if
		# it has a value. If it does not have a value, then we
		# don't want to output a needless column.  There are
		# really only four values that modify type should be
		# equal to:
		#
		# 1. "" (View/Modify Cart or Order Form Screen)
		# 2. "New Quantity" (Change Quantity Form)
		# 3. "Delete Item" (Delete Item Form)
		# 4. "Process Order" (Order Form Process Confirmation)
		# 
		# These four types distinguish the five types of pages on
		# which a cart will be displayed.  We need to know these
		# values in order to determine if there will be an extra
		# table header in the cart display.  In the case of
		# quantity changes or delete item forms, there must be an
		# extra table cell for the checkbox and textfield inputs
		# so that the customer can select items.  In the
		# View/Modify cart screen ($modify_type ne ""), no extra
		# cell is necessary.

if ($modify_type ne "") 

{
$modify_type = "<TH>$cart_font_style\&nbsp\;$modify_type\&nbsp\;</FONT></TH>";
}

if (($sc_gateway_name eq "Offline") && (($reason_to_display_cart =~ /orderform/i) || ($reason_to_display_cart =~ /verify/i)))
{
&StoreHeader;
}
else
{
&StoreHeader;
}

print qq!

<FORM METHOD="POST" ACTION="$sc_main_script_url">
<INPUT TYPE="HIDDEN" NAME="product" VALUE="$form_data{'product'}">
<INPUT TYPE="HIDDEN" NAME="keywords" VALUE="$form_data{'keywords'}">
<INPUT TYPE="HIDDEN" NAME="cart_id" VALUE="$cart_id">

<CENTER>
<TABLE BORDER = "0" CELLPADDING="4" class="boxborder">
<TR bgcolor=$colorcode>
$cart_font_style
$modify_type
!;

		# @sc_cart_display_fields is the list of all of the table
		# headers to be displayed in the cart display table and is
		# defined in web_store.setup.

foreach $field (@sc_cart_display_fields)
{
print qq!
<TH>$cart_font_style&nbsp;$field&nbsp;</FONT></TH>\n!;
}

		# We'll also add on table headers for Quantity and
		# Subtotal.

}

#######################################################################
#                    display_cart_table Subroutine                    #
#######################################################################

		# The job of display_cart_table is to display the current
		# contents of the user's cart for several diffferent
		# types of screens which all display the cart in some form
		# or another.  The subroutine takes one argumnet, the
		# reason that the cart is being displayed, and is called
		# with the following syntax:
		#
		# &display_cart_table("reason");
		#
		# There are really only five values that
		# $reason_to_display_cart should be equal to:
		#
		# 1. "" (View/Modify Cart Screen)
		# 2. "changequantity" (Change Quantity Form)
		# 3. "delete" (Delete Item Form)
		# 4. "orderform" (Order Form)
		# 5. "process order" (Order Form Process Confirmation)
		# 
		# Notice that this corresponds closely to the list in
		# cart_table_header because the goal of this subroutine is
		# to fill in the actual cells of the table created by
		# cart_table_header

sub display_cart_table 
{

		# Working variables are initialized and defined as local
		# to this subroutine.  Don't mess with these definitions.

local($reason_to_display_cart) = @_;
local(@cart_fields);
local($cart_id_number);
local($quantity);
local($unformatted_subtotal);
local($subtotal);
local($unformatted_grand_total);
local($grand_total);
local($price);
local($text_of_cart);
local($total_quantity) = 0;
local($total_measured_quantity) = 0;
local($display_index);
local($counter);
local($hidden_field_name);
local($hidden_field_value);
local($display_counter);
local($product_id, @db_row);

		# Next the script determines which type of cart display it
		# is being asked to produce.  It uses pattern matching to
		# look for key phrases in the ($reason_to_display_cart
		# defined as an incoming argument.  Whatever the case, the
		# subroutine calls cart_table_header to begin outputting
		# the HTML cart display.
 
if ($reason_to_display_cart =~ /change*quantity/i) 
{
&cart_table_header("New Quantity");
} 

elsif ($reason_to_display_cart =~ /delete/i) 
{
&cart_table_header("Delete Item");
} 

else 
{
&cart_table_header("");
}

		# Next, the client's cart is read line by line (file open
		# errors handled by file_open_error as usual).
$bgcolor1 = "#E4E4E4";
$bgcolor2 = "#F5F5F5";
open (CART, "$sc_cart_path") ||
&file_open_error("$sc_cart_path", "display_cart_contents", __FILE__, __LINE__);

while (<CART>)
{

		# Since every line in the cart will be displayed as a cell
		# in an HTML table, we begin by outputting an opening
		# <TR> tag.
	if ($bgcount > 1)
	{$bgcolor=$bgcolor2;$bgcount=1;}
	else
	{$bgcolor=$bgcolor1;$bgcount=2;}
print "<TR bgcolor=$bgcolor>";	
      
		# Next, the current line has it's final newline charcater
		# chopped off.

chop;    

		# Then, the script splits the row in the client's cart
		# and grabs the unique product ID number, the unique cart
		# id number, and the quantity. We will use those values
		# while processing the cart.  

@cart_fields = split (/\|/, $_);
$cart_row_number = pop(@cart_fields);
push (@cart_fields, $cart_row_number);
  
$quantity = $cart_fields[0];
$product_id = $cart_fields[1];

		# Next we will need to begin to distinguish between types
		# of displays we are being asked for because each type of
		# display is slightly different. For example, if we are
		# being asked to display a cart for the delete item
		# form, we will need to add a checkbox before each item so
		# that the customer can select which items to delete.  If,
		# on the other hand, we are being asked for modify the
		# quantity of an item form, we need to add a text field
		# instead, so that the customer can enter a new quantity.
		#
		# The first case we will handle is if we are being asked
		# to display the cart as part of order processing.

if (($reason_to_display_cart =~ /orderform/i) && ($sc_order_check_db =~ /yes/i)) 

{

                # If we are displaying the cart for order
                # processing AND we are checking the 
                # database to make sure that the product being
                # ordered is OK, then we need to load the
                # database libraries if they have not been
                # required already.

if (!($sc_db_lib_was_loaded =~ /yes/i)) 

{
&require_supporting_libraries (__FILE__, __LINE__, "$sc_db_lib_path");
}             

                # Then, we call the check_db_with_product_id
                # in the database library. If it returns
                # false, then we output a footer
                # complaining about the problem and
                # exit the program.

if (!(&check_db_with_product_id($product_id,*db_row))) 
{

print qq~
</TR>
</TABLE>

<DIV ALIGN=CENTER>
<TABLE>
<TR>
<TD>
&nbsp;
</TD>
</TR>
<TR>
<TD>
<P>
<FONT FACE=ARIAL>
I'm sorry, Product ID: $product_id was not found in 
the database. Your order cannot be processed without 
this validation. Please contact the 
<a href=mailto:$sc_admin_email>site administrator</a>.
</FONT>
</TD>
</TR>
</TABLE>
</DIV>

~;
exit;

} 

                # Otherwise, we check the returned row
                # with the price of the product in the 
                # cart. If the prices do not match
                # then another complaint message is printed
                # and we exit the program.

else 

{

	if ($db_row[$sc_db_index_of_price] ne $cart_fields[$sc_cart_index_of_price]) 
	{
	print qq~
	</TR>
	</TABLE>
	<DIV ALIGN=CENTER>
	<TABLE>
	<TR>
	<TD>
	<P>
	<FONT FACE=ARIAL>
	Price for product id:$product_id did not match
	database! Your order will NOT be processed without 
	this validation!
	</TD>
	</TR>
	</TABLE>
	</DIV>
~; 
	exit;
	}
# End of Else
}

# End of if (($reason_to_display_cart =~ /process.*order/i)...
}

                # Remember, we need to use the display_table_cart
                # to keep track of totals such as quantity, subtotal,
                # and total measured quantity.
                # 
                # Directly below, we keep track of total quantity.

$total_quantity += $quantity;
  
		# In the case of a quantity change form, we will need to
		# create a cell for the text field in which the customer
		# can input a new quantity.  The NAME value is set equal
		# to the unique cart id number of the current item so that
		# when we submit this information, the items will be
		# associated with the new quantities.
    
if ($reason_to_display_cart =~ /change*quantity/i) 
{
print qq!
<TD ALIGN = "center">
<INPUT TYPE = "text" NAME = "$cart_row_number" SIZE ="3">
</TD>!;
} 

		# Similarly, in the case of a delete item form, we must
		# include a cell with a checkbox so that the customer can
		# select items to delet efrom their cart.  The NAME value
		# is set equal to the unique cart id number of the
		# current item so that when we submit this information,
		# the items will be associated with the checked
		# checkboxes.

elsif ($reason_to_display_cart =~ /delete/i) 
{
print qq!
<TD ALIGN = "center">
<INPUT TYPE = "checkbox" NAME = "$cart_row_number">
</TD>
!;
}

		# $display_counter is set equal to zero.  This variable
		# will be used for
		#
		# $text_of_cart is initialized with two newlines.  This
		# variable will be used to hold the entire formatted cart
		# contents in one string so that we will be able to send a
		# nicely formatted copy of the cart as plain ASCII to a
		# log file or as email to the admin.  We'll be using the
		# ".=" operator to append to the variable rather than
		# overwrite it.
    
$display_counter = 0;
$text_of_cart .= "\n\n";

		# Now, for every item in the cart row which should be
		# displayed as defined in the setup file, we'll do two
		# things.  First, we'll append the data to the
		# $text_of_cart variable (formatting it nicely). Then we
		# will display the data as a table cell.
		#
		# However, there are three types of data which must be
		# displayed in table cells but which must be formatted
		# slightly differently.
		# 
		# The first type of cell is a cell with no data.  To give
		# the table a nice three dimensional look to it, we will
		# substitute all occurances of no data for the &nbsp;
		# character in order to get a blank but indented table
		# cell.  Of course, this routine simply overwrites the
		# empty value of the data with the &nbsp; character, it
		# does not actually display the cell...instead, it passes
		# that job on to the next if test.
		#
		# Another case is when a table cell must reflect a price.
		# In that case we must format the data with the monetary
		# symbol defined in web_store.setup using display_price
		# discused in web_store.cgi.
		#
		# Finally, non proce table cells are displayed (including
		# those passed down from the first case.	

foreach $display_index (@sc_cart_index_for_display)
{ 

		# Reformat blank cells.

if ($cart_fields[$display_index] eq "")
{

                # The text of the cart is entered into a buffer
                # 
                # The actual item being purchased is formatted
                # inside a 25 character width field

$text_of_cart .= &format_text_field(
$sc_cart_display_fields[$display_counter]) .
"= nothing entered\n";
$cart_fields[$display_index] = "&nbsp;";
}       

		# Display price cell.

if ($display_index == $sc_cart_index_of_price)
{
$price = &display_price($cart_fields[$display_index]); 
print qq!<TD ALIGN = "right">$cart_font_style$price</FONT></TD>\n!;
$text_of_cart .= &format_text_field(
$sc_cart_display_fields[$display_counter]) .
"= $price\n";
}

elsif ($display_index == $sc_cart_index_of_price_after_options)
{
$lineTotal = &format_price(($cart_fields[0]*$cart_fields[$display_index])+($cart_fields[0]*$cart_fields[6]));
$lineTotal = &display_price($lineTotal);
print qq!<TD ALIGN = "right">$cart_font_style$lineTotal</FONT></TD>\n!;
$text_of_cart .= &format_text_field(
$sc_cart_display_fields[$display_counter]) .
"= $lineTotal\n";
}

elsif ($display_index == $sc_cart_index_of_measured_value)
{
$shipping_price = &display_price($cart_fields[$display_index]); 
print qq!
<TD ALIGN = "right">$cart_font_style$shipping_price</FONT></TD>\n
!;
$text_of_cart .= &format_text_field($sc_cart_display_fields[$display_counter]) .
"= $price\n
";
}


		# Display all other cells (blank cells have already been
		# reformatted)

else
{
print qq!<TD ALIGN = "center">$cart_font_style$cart_fields[$display_index]</FONT></TD>\n!;

	if ($display_index != 5)
	{
	$text_of_cart .= &format_text_field(
	$sc_cart_display_fields[$display_counter]) .
	"= $cart_fields[$display_index]\n";
	}

}

		# If the current display index happens to be a cell which
		# must be measured, we will add the value to
		# $total_measured_quantity for later calculation and
		# display.

if ($display_index == $sc_cart_index_of_measured_value) 
{
$total_measured_quantity += ($cart_fields[0]*$cart_fields[6]);  
$shipping_total = $total_measured_quantity;
}

$display_counter++;

# End of foreach $display_index (@sc_cart_index_for_display)
}

                # Then we will need to use the quantity value we shifted
                # earlier to fill the next table cell, and then, after
                # using another database specific setup variable,
                # calculate the subtotal for that database row and fill
                # the final cell and close out the table row and the cart
                # file (once we have gone all the way through it.)

  
$unformatted_subtotal = ($cart_fields[$sc_cart_index_of_price_after_options]);
$subtotal = &format_price($cart_fields[0]*$unformatted_subtotal);
$unformatted_grand_total = $grand_total + $subtotal;
$grand_total = &format_price($unformatted_grand_total);
                
$price = &display_price($subtotal);

$text_of_cart .= &format_text_field("Quantity") .
"= $quantity\n";

$text_of_cart .= &format_text_field("Subtotal For Item") .
"= $price\n";

# End of while (<CART>)
}

close (CART);
                
                # Finally, print out the footer with the cart_footer
                # subroutine in web_store.html.
 
$price = &display_price($grand_total);
$shipping_total = &display_price($shipping_total);

if ($reason_to_display_cart =~ /verify/i) 
{
print <<ENDOFTEXT;
<INPUT TYPE=HIDDEN NAME=TOTAL VALUE=$grand_total>

ENDOFTEXT
}

&cart_table_footer($price);

if ($reason_to_display_cart =~ /verify/i)
{
&display_calculations($grand_total,"at",
$total_measured_quantity,$text_of_cart);
}
else
{
&display_calculations($grand_total,"change/delete",
$total_measured_quantity,$text_of_cart);
}

		# The Subtotal info is also added to $text_of_cart 

$text_of_cart .= "\n\n" . &format_text_field("Subtotal:") .
"= $price\n\n";

		# We need to return the subtotal for those routines such
		# as ordering calculations
		#
		# We also need to return the text of the cart in case we
		# are logging orders to email or to a file

return($grand_total, $total_quantity, $total_measured_quantity, $text_of_cart);

#End of display_cart_table
}

#######################################################################
#                    cart_table_footer Subroutine                     #
#######################################################################

		# cart_table_footer is used to display the footer for cart
		# table displays.  It takes one argumnet, the pre shipping
		# grand total and is called with the following syntax:
		#
		#  &cart_table_footer(PRICE);

sub cart_table_footer
{
local($price, $shipping_total) = @_;
print qq!
</tr>
<tr><td bgcolor=$colorcode colspan=10 align=right>
<TABLE border=0 cellpadding=4 bgcolor=$colorcode class="boxborder">

<TR bgcolor=$colorcode align=right>
<TD align=right>
$cart_font_style Subtotal: $price</FONT>
</TD>
</TR>
!;

}

#######################################################################
#                    make_hidden_fields Subroutine                    #
#######################################################################

		# make_hidden_fields is used to generate the hidden fields
		# necessary for maintaining state.  It takes no arguments
		# and is called with the following syntax:
		#
		# &make_hidden_fields;

sub make_hidden_fields
{
local($hidden);
local($db_query_row);
local($db_form_field);

		# $hidden is defined initially as containing the cart_id
		# and page hidden tags which are necessry state variables
		# on EVERY page in the cart.
		#
		# The script then goes through  checking to see which
		# optional state variables it has received as incoming
		# form data.  For each of those, it adds a hidden input
		# tag.

$hidden = qq!
<INPUT TYPE = "hidden" NAME = "cart_id" VALUE = "$cart_id">
<INPUT TYPE = "hidden" NAME = "page" VALUE = "$form_data{'page'}">!;

if ($form_data{'keywords'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "keywords" VALUE = "$form_data{'keywords'}">!;
}

if ($form_data{'exact_match'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "exact_match" VALUE = "$form_data{'exact_match'}">!;
}

if ($form_data{'case_sensitive'} ne "") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "case_sensitive" VALUE = "$form_data{'case_sensitive'}">!;
}

foreach $db_query_row (@sc_db_query_criteria) 
{
$db_form_field = (split(/\|/, $db_query_row))[0];
if ($form_data{$db_form_field} ne "" && $db_form_field ne "keywords") 
{
$hidden .= qq!
<INPUT TYPE = "hidden" NAME = "$db_form_field" VALUE = "$form_data{$db_form_field}">!;
}

}

return ($hidden);

# End of make_hidden_fields
}


#######################################################################
#                   PrintNoHitsBodyHTML Subroutine                    #
#######################################################################

		# PrintNoHitsBodyHTML is utilized by the HTML-based store
		# search routines to produce an error message in case no
		# hits were found based on the client-defined keyords
		# It is called with no argumnets and the following syntax:
		#
		# &PrintNoHitsBodyHTML;

sub PrintNoHitsBodyHTML
{
print qq!

<CENTER>  
<TABLE>

<TR>
<TD>
&nbsp;
</TD>
</TR>

<TR>
<TD>
<FONT FACE=ARIAL>
I'm sorry, no matches were found. Please try your search again.
</TD>
</TR>

<TR>
<TD>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
</TD>
</TR>

</TABLE>
</CENTER>
!;

&StoreFooter;

print qq!



!;

}

1;
