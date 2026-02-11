#######################################################################
#                    Order Form Definition Variables                  #
#######################################################################

%sc_order_form_array =('Ecom_BillTo_Postal_Name_First', 'First Name',
                       'Ecom_BillTo_Postal_Name_Last', 'Last Name',
                       'Ecom_BillTo_Postal_Street_Line1', 'Billing Address Street',
                       'Ecom_BillTo_Postal_City', 'Billing Address City',
                       'Ecom_BillTo_Postal_StateProv', 'Billing Address State',
                       'Ecom_BillTo_PostalCode', 'Billing Address Zip',
                       'Ecom_BillTo_Postal_CountryCode', 'Billing Address Country',
                       'Ecom_ShipTo_Postal_Street_Line1', 'Shipping Address Street',
                       'Ecom_ShipTo_Postal_City', 'Shipping Address City',
                       'Ecom_ShipTo_Postal_StateProv', 'Shipping Address State',
                       'Ecom_ShipTo_Postal_PostalCode', 'Shipping Address Zip',
                       'Ecom_ShipTo_Postal_CountryCode', 'Shipping Address Country',
                       'Ecom_BillTo_Telecom_Phone_Number', 'Phone Number',
                       'Ecom_BillTo_Online_Email', 'Email',
                       'Ecom_Payment_Card_Type', 'Type of Card',
                       'Ecom_Payment_Card_Number', 'Card Number',
                       'Ecom_Payment_Card_ExpDate_Month', 'Card Expiration Month',
                       'Ecom_Payment_Card_ExpDate_Day', 'Card Expiration Day',
                       'Ecom_Payment_Card_ExpDate_Year', 'Card Expiration Year');
                        

@sc_order_form_required_fields = ("Ecom_ShipTo_Postal_StateProv");

###############################################################################

sub printSubmitPage

{
local($invoice_number, $customer_number, $displayTotal);

$displayTotal = &display_price($authPrice);

$invoice_number = time;
$customer_number = $cart_id;
$customer_number =~ s/_/./g;

print <<ENDOFTEXT;



<INPUT TYPE=\"HIDDEN\" NAME=\"vendor_id\" VALUE=\"$sc_gateway_username\">
<INPUT TYPE=\"HIDDEN\" NAME=\"home_page\" VALUE=\"$sc_store_url\">
<input type='hidden' name='ret_mode' value='post'>
<INPUT TYPE=\"HIDDEN\" NAME=\"ret_addr\" VALUE=\"$sc_store_url\">
<INPUT TYPE=\"HIDDEN\" NAME=\"email_text\" VALUE=\"$email_text\">

<INPUT TYPE=\"HIDDEN\" NAME=\"1-desc\" VALUE=\"Online Order\">
<INPUT TYPE=\"HIDDEN\" NAME=\"1-qty\" VALUE=\"1\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p5\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p5\" VALUE=\"$customer_number\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p6\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p6\" VALUE=\"$invoice_number\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p7\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p7\" VALUE=\"$authPrice\">

<INPUT TYPE=HIDDEN NAME=\"showaddr\" VALUE=\"1\">
<INPUT TYPE=HIDDEN NAME=\"nonum\" VALUE=\"0\">

<INPUT TYPE=HIDDEN NAME=\"mername\" VALUE=\"$mername\">
<INPUT TYPE=HIDDEN NAME=\"acceptcards\" VALUE=\"$acceptcards\">
<INPUT TYPE=HIDDEN NAME=\"acceptchecks\" VALUE=\"$acceptchecks\">
<INPUT TYPE=HIDDEN NAME=\"accepteft\" VALUE=\"$accepteft\">
<INPUT TYPE=HIDDEN NAME=\"altaddr\" VALUE=\"$altaddr\">

<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"first_name\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"last_name\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"address\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"city\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"state\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"zip\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"country\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"phone\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"email\">

<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"sfname\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"slname\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"saddr\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"scity\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"sstate\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"szip\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"sctry\">

<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"total\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"authcode\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"test_mode\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"when\">
<INPUT TYPE=HIDDEN NAME=\"lookup\" VALUE=\"xid\">

<TABLE BGCOLOR="$colorcode" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD>

<TABLE BGCOLOR="$colorcode" CELLPADDING="0" CELLSPACING="0">
<TR BGCOLOR="$colorcode">
<TD BGCOLOR="$colorcode"><FONT FACE="ARIAL" SIZE="2" COLOR="#000000">
Please verify the above order information. When you are confident 
that it is correct, click the 'Secure Orderform' button to enter 
your payment information through our securely encrypted server.</FONT></TD>
<TD  BGCOLOR="$colorcode">
</TR>
<TR BGCOLOR="$colorcode">
<TD>
<CENTER>
<INPUT TYPE=SUBMIT VALUE="Secure Orderform">
</CENTER>
</TD>
</TR>
</TABLE>

</TD>
</TR>
</TABLE>
</CENTER>

</FONT>

ENDOFTEXT

}
############################################################################################

sub processOrder {

local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart,
      $required_fields_filled_in, $product, $quantity, $options);

$orderDate = &get_date;

print qq!
<html><head><title>Thank you for your order.</title></head><body bgcolor=white>
<center><br><br>
<font face=arial,helvetica size=-1><b><center>Thank you for your order. Please print this page as your receipt.<br><a href="$sc_store_url">When done click here to return to our Online Store</a></b></font><br><br>
<br><br>

<TABLE BORDER = "0" width=600 CELLPADDING="4" class="boxborder">
<tr width=600>
<td colspan=10>
<table bgcolor=$colorcode width=600>
<tr $colorcode>
<td colspan=2><font face=arial,helvetica size=+1><b>$mername Order Confirmation</b></font>
</td>
</tr>
<tr $colorcode>
<td width=50% align=left>
<font face=arial,helvetica size=-1><b>CUST ID: $form_data{'p5'}</b></font>
</td>
<td width=50% align=right>
<font face=arial,helvetica size=-1><b>INVOICE #: $form_data{'p6'}</b></font>
</td>
</tr>
</table>
</td>
</tr>
<TR bgcolor=$colorcode width=600>
<FONT FACE=ARIAL SIZE=2>


<TH width=20%><FONT FACE=ARIAL SIZE=2>&nbsp;Quantity&nbsp;</FONT></TH>

<TH width=20%><FONT FACE=ARIAL SIZE=2>&nbsp;Item Number&nbsp;</FONT></TH>

<TH width=20%><FONT FACE=ARIAL SIZE=2>&nbsp;Product&nbsp;</FONT></TH>

<TH width=20%><FONT FACE=ARIAL SIZE=2>&nbsp;Price (ea)&nbsp;</FONT></TH>

<TH width=20%><FONT FACE=ARIAL SIZE=2>&nbsp;Options&nbsp;</FONT></TH>

!;

$text_of_cart .= "New Order: $orderDate\n\n";

$text_of_cart .= "  --PRODUCT INFORMATION--\n\n";
$bgcolor1 = "#E4E4E4";
$bgcolor2 = "#F5F5F5";
open (CART, "$sc_cart_path") ||
&file_open_error("$sc_cart_path", "display_cart_contents", __FILE__, __LINE__);

while (<CART>)
{
if ($bgcount > 1)
	{$bgcolor=$bgcolor2;$bgcount=1;}
	else
	{$bgcolor=$bgcolor1;$bgcount=2;}
	
$cartData++;
@cart_fields = split (/\|/, $_);
$quantity = $cart_fields[0];
$itemnumber = $cart_fields[1];
$product_price = $cart_fields[3];
$product = $cart_fields[4];
$options = $cart_fields[7];
$options =~ s/<br>/ /g;
$text_of_cart .= "Quantity:      $quantity\n";
$text_of_cart .= "Item Number:   $itemnumber\n";
$text_of_cart .= "Product:       $product\n";
$text_of_cart .= "Price Each:    $sc_money_symbol $product_price\n";
$text_of_cart .= "Options:       $options\n\n";
print qq!

<TR bgcolor=$bgcolor width=600><TD ALIGN = "center"><FONT FACE=ARIAL SIZE=2>$quantity</FONT></TD>
<TD ALIGN = "center"><FONT FACE=ARIAL SIZE=2>$itemnumber</FONT></TD>
<TD ALIGN = "right"><FONT FACE=ARIAL SIZE=2>$product</FONT></TD>

<TD ALIGN = "right"><FONT FACE=ARIAL SIZE=2>$sc_money_symbol $product_price</FONT></TD>

<TD ALIGN = "center"><FONT FACE=ARIAL SIZE=2>$options</FONT></TD>

!;
}
close(CART);


$text_of_confirm_email .= "Thank you for your order. We appreciate your business and will do everything we can to meet your expectations. Please visit us again soon!\n\n";

$text_of_confirm_email .= $text_of_cart;
$text_of_confirm_email .= "\n";
$text_of_cart .= "  --ORDER INFORMATION--\n\n";

$text_of_cart .= "CUST ID:       $form_data{'p5'}\n";
$text_of_confirm_email .= "CUST ID:       $form_data{'p5'}\n";

$text_of_cart .= "INVOICE:       $form_data{'p6'}\n\n";
$text_of_confirm_email .= "INVOICE:       $form_data{'p6'}\n\n";

$text_of_cart .= "AUTH CODE      $form_data{'authcode'}\n";
$text_of_cart .= "TIME:          $form_data{'when'}\n";
$text_of_cart .= "TRANS ID:      $form_data{'xid'}\n\n";

$text_of_cart .= "SUBTOTAL:      $form_data{'p1'}\n";
$text_of_confirm_email .= "SUBTOTAL:      $form_data{'p1'}\n";

if ($form_data{'p2'})
{
$text_of_cart .= "SHIPPING:      $form_data{'p2'}  $form_data{'p4'}\n";
$text_of_confirm_email .= "SHIPPING:      $form_data{'p2'}  $form_data{'p4'}\n";
}

if ($form_data{'p3'})
{
$text_of_cart .= "SALES TAX:     $form_data{'p3'}\n";
$text_of_confirm_email .= "SALES TAX:     $form_data{'p3'}\n";
}

$text_of_cart .= "TOTAL:         $form_data{'p7'}\n\n";
$text_of_confirm_email .= "TOTAL:         $form_data{'p7'}\n\n";

$text_of_cart .= "BILLING INFORMATION --------------\n\n";
$text_of_cart .= "NAME:          $form_data{'first_name'} $form_data{'last_name'}\n";
$text_of_cart .= "ADDRESS:       $form_data{'address'}\n";
$text_of_cart .= "CITY:          $form_data{'city'}\n";
$text_of_cart .= "STATE:         $form_data{'state'}\n";
$text_of_cart .= "ZIP:           $form_data{'zip'}\n";
$text_of_cart .= "COUNTRY:       $form_data{'country'}\n";
$text_of_cart .= "PHONE:         $form_data{'phone'}\n";
$text_of_cart .= "EMAIL:         $form_data{'email'}\n\n";
$text_of_cart .= "SHIPPING INFORMATION --------------\n\n";
$text_of_cart .= "NAME:          $form_data{'sfname'} $form_data{'slname'}\n";
$text_of_cart .= "ADDRESS:       $form_data{'saddr'}\n";
$text_of_cart .= "CITY:          $form_data{'scity'}\n";
$text_of_cart .= "STATE:         $form_data{'sstate'}\n";
$text_of_cart .= "ZIP:           $form_data{'szip'}\n";
$text_of_cart .= "COUNTRY:       $form_data{'sctry'}\n\n";

#$text_of_cart .= "PGPSIGNATURE:  $form_data{'signature'}\n\n";

if ($sc_use_pgp =~ /yes/i)
{
&require_supporting_libraries(__FILE__, __LINE__, "$sc_pgp_lib_path");
$text_of_cart = &make_pgp_file($text_of_cart, "$sc_pgp_temp_file_path/$$.pgp");
$text_of_cart = "\n" . $text_of_cart . "\n";
}

if ($sc_send_order_to_email =~ /yes/i)
{
&send_mail($sc_order_email, $sc_order_email, "Online Store Order",$text_of_cart);
}

if ($sc_send_order_to_log =~ /yes/i) {
open (ORDERLOG, "+>>./log_files/$sc_order_log_name");
print ORDERLOG "-" x 60 . "\n";
print ORDERLOG $text_of_cart;
print ORDERLOG "-" x 60 . "\n";
close (ORDERLOG);
}

if ($cartData)
{
&send_mail($sc_admin_email, $form_data{'email'}, "Thank you for your order!", "$text_of_confirm_email");
}
  
print <<ENDOFTEXT;
<tr><td bgcolor=$colorcode colspan=10 align=right>
<TABLE border=0 cellpadding=4 width=600 bgcolor=$colorcode class="boxborder">

<TR bgcolor=$colorcode align=right>
<TD align=right>
<FONT FACE=ARIAL SIZE=2> Subtotal: $form_data{'p1'}</FONT>
</TD>
</TR>
<TR bgcolor=$colorcode align=right>
<TD align=right>
<FONT FACE=ARIAL SIZE=2> Shipping: $form_data{'p4'}</FONT>
</TD>
</TR>
<TR bgcolor=$colorcode align=right>
<TD align=right>
<FONT FACE=ARIAL SIZE=2> Sales Tax: $form_data{'p3'}</FONT>
</TD>
</TR>
<TR bgcolor=$colorcode align=right>
<TD align=right>
<b><FONT FACE=ARIAL SIZE=2> Grand Total: $form_data{'p7'}</FONT></b>
</TD>
</TR>
</TABLE>
</TD>
</TR>
</TABLE>
</center>
<center>
<table border=0 width=600>
<tr bgcolor=$bgcolor2>
<td colspan=2>
<FONT FACE=ARIAL SIZE=2><b>BILLING INFORMATION --------------</b></font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>NAME: </td><td width=50%>         $form_data{'first_name'} $form_data{'last_name'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>ADDRESS:  </td><td width=50%>      $form_data{'address'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>CITY:   </td><td width=50%>        $form_data{'city'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>STATE:   </td><td width=50%>       $form_data{'state'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>ZIP:   </td><td width=50%>         $form_data{'zip'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>COUNTRY:  </td><td width=50%>      $form_data{'country'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>PHONE:  </td><td width=50%>        $form_data{'phone'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>EMAIL:   </td><td width=50%>       $form_data{'email'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td colspan=2>
<FONT FACE=ARIAL SIZE=2><b>SHIPPING INFORMATION --------------</b></font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>NAME:   </td><td width=50%>        $form_data{'sfname'} $form_data{'slname'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>ADDRESS:  </td><td width=50%>      $form_data{'saddr'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>CITY:    </td><td width=50%>       $form_data{'scity'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>STATE:  </td><td width=50%>        $form_data{'sstate'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor2>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>ZIP:   </td><td width=50%>         $form_data{'szip'}</font>
</td>
</tr>
<tr bgcolor=$bgcolor1>
<td width=50%>
<FONT FACE=ARIAL SIZE=2>COUNTRY:  </td><td width=50%>      $form_data{'sctry'}</font>
</td>
</tr>
</table>
<br><br>

ENDOFTEXT

# This empties the cart after the order is successful

open (CART, ">$sc_cart_path");
close (CART);

# and the footer is printed


print qq!
</body></html>
!;

} # End of process_order_form

#################################################################

sub display_calculations {

local($upgradeShipPrice, $shipMethod) = split (/\|/,$form_data{upgradeShipping});

local($subtotal,
      $are_we_before_or_at_process_form,
      $total_measured_quantity,
      $text_of_cart) = @_;

local($final_shipping,
	$final_discount,
	$final_sales_tax,$grand_total) =
	&calculate_final_values($subtotal,
	$total_quantity,
	$total_measured_quantity,
	$are_we_before_or_at_process_form);
 
if ($final_shipping > 0)
{
print "<TR bgcolor=$colorcode align=right>\n";
print "<TD align=right>\n";

$final_shipping = &format_price($final_shipping);

$pass_final_shipping = $final_shipping;

$final_shipping = &display_price($final_shipping);

if($upgradeShipPrice && $shipMethod)
{
print "$cart_font_style $shipMethod: $final_shipping</FONT>\n";
}
else
{
print "$cart_font_style Shipping: $final_shipping</FONT>\n";
}
print "</TD>\n";
print "</TR>\n";

if($upgradeShipPrice && $shipMethod)
{
$final_shipping += ($final_shipping*($shipPrice/100));

$final_shipping = &format_price($final_shipping);

$final_shipping = &display_price($final_shipping);

$text_of_cart .= &format_text_field("$shipMethod:") . 
"= $final_shipping\n\n";
}
else
{
$final_shipping = &format_price($final_shipping);

$final_shipping = &display_price($final_shipping);

$text_of_cart .= &format_text_field("Shipping:") . 
"= $final_shipping\n\n";
}

};

if ($final_discount > 0)
{
$final_discount = &format_price($final_discount);

$pass_final_discount = &format_price($final_discount);

$final_discount = &display_price($final_discount);

print "<TR bgcolor=$colorcode align=right>\n";
print "<TD align=right>\n";
print "$cart_font_style Discount: $final_discount</FONT>\n";
print "</TD>\n";
print "</TR>\n";

$text_of_cart .= &format_text_field("Discount:") . 
"= $final_discount\n\n";
}

if ($final_sales_tax > 0)
{
$final_sales_tax = &format_price($final_sales_tax);

$pass_final_sales_tax = &format_price($final_sales_tax);

$final_sales_tax = &display_price($final_sales_tax);

print "<TR bgcolor=$colorcode align=right>\n";
print "<TD align=right>\n";
print "$cart_font_style Sales Tax: $final_sales_tax</FONT>\n";
print "</TD>\n";
print "</TR>\n";

$text_of_cart .= &format_text_field("Sales Tax:") . 
"= $final_sales_tax\n\n";
}

$authPrice = $grand_total;
$grand_total = &display_price($grand_total);

print "<TR bgcolor=$colorcode align=right>\n";
print "<TD align=right>\n";
print "<b>$cart_font_style Grand Total: $grand_total</FONT></b>\n";
print "</TD>\n";
print "</TR>\n";
print "</TABLE>\n";
print "</TD>\n";
print "</TR>\n";
print "</TABLE>\n";

if ($are_we_before_or_at_process_form =~ /at/i) 
{
print <<ENDOFTEXT;

</FORM>

<FORM METHOD=POST ACTION=\"$sc_order_script_url\">

<INPUT TYPE=HIDDEN NAME=\"1-cost\" VALUE=\"$authPrice\">

<INPUT TYPE=\"HIDDEN\" name=\"passback\" value=\"p1\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p1\" VALUE=\"$subtotal\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p2\">
<INPUT TYPE=\"HIDDEN\" NAME=\"p2\" VALUE=\"$pass_final_shipping\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p3\">
<INPUT TYPE=HIDDEN NAME=\"p3\" VALUE=\"$pass_final_sales_tax\">

<INPUT type=\"HIDDEN\" name=\"passback\" value=\"p4\">
<INPUT TYPE=HIDDEN NAME=\"p4\" VALUE=\"$shipMethod\">

ENDOFTEXT
}

$text_of_cart .= &format_text_field("Grand Total:") . 
"= $grand_total\n\n";

return ($text_of_cart);

}
