# This file contains the HTML for the store admin screens
#
######################################################################################

sub PageHeader

{
print <<ENDOFTEXT;

<html>
<head>
<title>Catalog Management System 3.01</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language='JavaScript'>

<!--Cloak Engaged
function login()
{clickpop=window.open('http://www.merchantcgi.com/demo/login.html','clickpop','toolbar=0,location=0,status=0,menubar=0,scrollbars=0,resizable=0,left,top,width=450,height=250')}

//-- Cloak Disengaged-->

</script>

</head>

<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
ENDOFTEXT

&printCommonHeader;

}

######################################################################################

sub DisplayRequestedProduct

{

print <<ENDOFTEXT;


<TR WIDTH=500>
<TD WIDTH=125>
$sku
</TD>
<TD WIDTH=125>
$category
</TD>
<TD WIDTH=125>
$short_description
</TD>
<TD WIDTH=125>
$price
</TD>
</TR>

ENDOFTEXT

}

#######################################################################################

sub PageFooter
{

print <<ENDOFTEXT;

</TABLE>
</CENTER>
</BODY>
</HTML>

ENDOFTEXT

}

#######################################################################################

sub display_login
{

&PageHeader;


print <<ENDOFTEXT;
  <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Login</b></font></td>
  </tr>
</table>

<FORM METHOD=POST ACTION=manager.cgi>

<CENTER>
<TABLE WIDTH=500 BORDER=0 CELLPADDING=2>

<TR>
<TD COLSPAN=2>
<HR WIDTH=550>
</TD>
</TR>

ENDOFTEXT

print <<ENDOFTEXT;

<TR>
<TD COLSPAN=2><P>&nbsp;</P></TD>
</TR>

<TR>
<TD COLSPAN=2>Username:&nbsp;<INPUT TYPE=text NAME=username></TD>
</TR>
<TR>
<TD COLSPAN=2>Password:&nbsp;<INPUT TYPE=password NAME=password></TD>
</TR>

<TR>
<TD>&nbsp;</TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE=HIDDEN NAME="login" VALUE="yes">
<INPUT TYPE=HIDDEN NAME="welcome_screen" VALUE="yes">
<INPUT TYPE=submit VALUE=submit>&nbsp;<INPUT TYPE=reset VALUE=reset>
</CENTER>
</TD>
</TR>

</TABLE>
</CENTER>

</FORM>


<P>&nbsp;</P>

</BODY>
</HTML>

ENDOFTEXT

}

#######################################################################################
sub add_product_screen

{
local($add_product_success) = @_;

##

local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, 
      $userDefinedTwo, $userDefinedThree, $userDefinedFour, 
      $userDefinedFive, $options);

open (NEWSKU, "$datafile") || die "Can't Open $datafile";

while(<NEWSKU>)

	{

($sku, $category, $price, $short_description, $image, 
 $long_description, $options) = split(/\|/,$_);

chop($options);

push(@sku_num,$sku);

	}

close(NEWSKU);

$highest_value = $sku_num[$#sku_num];
$highest_value++;
$new_sku = $highest_value;

##

&PageHeader;

print <<ENDOFTEXT;
  <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Add Products Screen</b></font></td>
  </tr>
</table>


<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
This is the Add Product screen. Just follow the directions and add products to your store right through your web browser.</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

ENDOFTEXT

if($add_product_success eq "yes")

{

print <<ENDOFTEXT;

<CENTER>
<TABLE border=0>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Product number $in{'sku'} has been added to the catalog.</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

}

elsif($add_product_success eq "no")
{
print <<ENDOFTEXT;

<CENTER>
<TABLE border=0>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Reference # already exists in datafile! Unable to add product, please choose a new Reference # number.</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

}

$categoriesfile2 = "../admin_files/categories_lib.data";
open (CHECKSKU, "$categoriesfile2") || die "Can't Open $categoriesfile2";

while(<CHECKSKU>)

{
chop;
$catrow=$_;
@cats = split(/\|/,$catrow);
if ($cats[2] ne ""){

$insertcategories  .= "<option value=$cats[1]>$cats[2]</option>\n";

}

}
$insertcategories2 = "$insertcategories";

print <<ENDOFTEXT;

<FORM METHOD=POST ACTION=manager.cgi>
<CENTER>
<TABLE BORDER=0 CELLPADDING=5 CELLSPACING=1 WIDTH="550">
<TR bgcolor=#999966>
<TD WIDTH=100><FONT FACE=ARIAL, helvetica color=white SIZE=-1><b>$new_sku</b></FONT></TD>
<TD WIDTH=450><FONT FACE=ARIAL, helvetica color=white SIZE=-1><b>Reference #</b></FONT></TD>
</TR>


<TR bgcolor=#E4E4E4>
<TD WIDTH=100><select name="category">$insertcategories2</select></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Category</b> - Please Select</font></TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="price" TYPE="TEXT" SIZE=35 MAXLENGTH=35></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Price</b></font> - No \$ sign needed</TD>
</TR>
<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="name" TYPE="TEXT" SIZE=35 MAXLENGTH=35></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Product Name</b> - 3 or 4 words</font></TD>
</TR>
<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="image" TYPE="TEXT" SIZE=35 MAXLENGTH=35></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Image File</b> - filename.gif</font></TD>
</TR>
<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="option_file" TYPE="TEXT" SIZE=35 MAXLENGTH=35></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Option File</b> - filename.html</font></TD>
</TR>
<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="shipping_price" TYPE="TEXT" SIZE=35 MAXLENGTH=35 VALUE="0.00"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Shipping Price</b></font></TD>
</TR>

<!--BEGIN USER DEFINED-->

<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="userDefinedOne" TYPE="TEXT" SIZE=35 MAXLENGTH=128></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">Enter the word "Special" to make this product show up in the "Special Buys" column.</font></TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="userDefinedTwo" TYPE="TEXT" SIZE=35 MAXLENGTH=128></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Two</font></TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="userDefinedThree" TYPE="TEXT" SIZE=35 MAXLENGTH=128></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Three</font></TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="userDefinedFour" TYPE="TEXT" SIZE=35 MAXLENGTH=128></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Four</font></TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="userDefinedFive" TYPE="TEXT" SIZE=35 MAXLENGTH=128></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Five</font></TD>
</TR>

<!--END USER DEFINED-->

<TR bgcolor=#F7EEE6>
<TD WIDTH=100><TEXTAREA NAME="description" ROWS=6 COLS=35 wrap=soft></TEXTAREA></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Description</b> - Enter the HTML (including price) for your product description here. </font></TD>
</TR>
</TABLE>
<TABLE WIDTH=550 border=0>
<TR WIDTH=550 bgcolor=#E4E4E4>
<TD WIDTH=550>
<INPUT TYPE=HIDDEN NAME=sku VALUE=$new_sku>
<CENTER>
<INPUT TYPE=SUBMIT NAME=AddProduct VALUE="Add Product">&nbsp;
<INPUT TYPE=RESET VALUE="Clear Form">
</CENTER>
</TD>
<TR>
</TABLE>
</CENTER>
</FORM>
</BODY>
</HTML>

ENDOFTEXT
}

#############################################################################################
#######################################################################################
sub show_welcome_screen

{

&PageHeader;

print <<ENDOFTEXT;
  <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Main Screen</b></font></td>
  </tr>
</table>


<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
This is the Catalog Management System Main Screen. Please choose a link below to build your online catalog.</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE BORDER=0 CELLPADDING=5 CELLSPACING=1 WIDTH="600">
<TR bgcolor=#999966>
<TD colspan=3><FONT FACE=ARIAL, helvetica color=white SIZE=-1><b>Catalog Management Areas</b></FONT></TD>
</TR>


<TR>
<TD width=33% valign=top>
<font face=arial,helvetica size=-1><b>
 <A HREF=manager.cgi?edit_page_screen=yes>Edit Pages</A><p>
 <A HREF=manager.cgi?edit_categories_screen=yes>Edit Categories</A><p>
 <A HREF=manager.cgi?add_screen=yes>Add Products</A><p>
</b></font>
</td>
<td width=33% valign=top>
<font face=arial,helvetica size=-1><b>
 <A HREF=manager.cgi?edit_screen=yes>Edit Products</A><p>
 <A HREF=manager.cgi?delete_screen=yes>Delete Products</A><p>
 <A HREF=manager.cgi?change_settings_screen=yes>Store Settings</A><p>
</b></font>
</TD>
<td width=34% valign=top>
<font face=arial,helvetica size=-1><b>
 <A HREF=manager.cgi?gateway_screen=yes>Gateway Settings</A><p>
 <A HREF=javascript:login()>Gateway Login</A><p>
 <A HREF=manager.cgi?change_password_screen=yes>Edit Username & Password</A><p>
</b></font>
</TD>
</TR>
</table>
</center>
<br><br><br>
</BODY>
</HTML>

ENDOFTEXT
}

#############################################################################################
sub edit_product_screen
{


&PageHeader;

print <<ENDOFTEXT;
<form method=post value=manager.cgi>
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Edit Products Screen</b></font></td>
  </tr>
</table>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
This is the Edit Product screen. Click <b>'Edit'</b> to make 
changes to products in your catalog.</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

ENDOFTEXT

if ($in{'ProductEditSku'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>Reference \# $in{'ProductEditSku'} successfully edited</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<CENTER>

<TABLE WIDTH=550 BORDER=0 cellpadding=2 cellspacing=2>
	<TR WIDTH=550 bgcolor=#999966>
	<TD>
	<b><font face=arial,helvetica size=-1 color=white>Edit</font></b>
	</TD>
	<TD>
	<B><font face=arial,helvetica size=-1 color=white>Ref. #</font></B>
	</TD>

	<TD>
	<B><font face=arial,helvetica size=-1 color=white>Category</font></B>
	</TD>
	
	<TD>
	<B><font face=arial,helvetica size=-1 color=white>Product</font></B>
	</TD>

	<TD>
	<B><font face=arial,helvetica size=-1 color=white>Price</font></B>
	</TD>
	
	<TD>
	<B><font face=arial,helvetica size=-1 color=white>Specials</font></B>
	</TD>	

	</TR>

ENDOFTEXT

$categoriesfile2 = "../admin_files/categories_lib.data";
$bgcolor1 = "#E4E4E4";
$bgcolor2 = "#F7EEE6";
open (CHECKSKU, "$categoriesfile2") || die "Can't Open $categoriesfile2";

while(<CHECKSKU>)

{
chop;
($sku2, $categorylink, $categoryname) = split(/\|/,$_);

if ($categorylink eq "cat01"){$cat01  = "$categoryname";}
if ($categorylink eq "cat02"){$cat02  = "$categoryname";}
if ($categorylink eq "cat03"){$cat03  = "$categoryname";}
if ($categorylink eq "cat04"){$cat04  = "$categoryname";}
if ($categorylink eq "cat05"){$cat05  = "$categoryname";}
if ($categorylink eq "cat06"){$cat06  = "$categoryname";}
if ($categorylink eq "cat07"){$cat07  = "$categoryname";}
if ($categorylink eq "cat08"){$cat08  = "$categoryname";}
if ($categorylink eq "cat09"){$cat09  = "$categoryname";}
if ($categorylink eq "cat10"){$cat10  = "$categoryname";}
if ($categorylink eq "cat11"){$cat11  = "$categoryname";}
if ($categorylink eq "cat12"){$cat12  = "$categoryname";}
if ($categorylink eq "cat13"){$cat13  = "$categoryname";}
if ($categorylink eq "cat14"){$cat14  = "$categoryname";}
if ($categorylink eq "cat15"){$cat15  = "$categoryname";}
if ($categorylink eq "cat16"){$cat16  = "$categoryname";}
if ($categorylink eq "cat17"){$cat17  = "$categoryname";}
if ($categorylink eq "cat18"){$cat18  = "$categoryname";}
if ($categorylink eq "cat19"){$cat19  = "$categoryname";}
if ($categorylink eq "cat20"){$cat20  = "$categoryname";}
if ($categorylink eq "cat21"){$cat21  = "$categoryname";}
if ($categorylink eq "cat22"){$cat22  = "$categoryname";}
if ($categorylink eq "cat23"){$cat23  = "$categoryname";}
if ($categorylink eq "cat24"){$cat24  = "$categoryname";}
if ($categorylink eq "cat25"){$cat25  = "$categoryname";}
if ($categorylink eq "cat26"){$cat26  = "$categoryname";}
if ($categorylink eq "cat27"){$cat27  = "$categoryname";}
if ($categorylink eq "cat28"){$cat28  = "$categoryname";}
if ($categorylink eq "cat29"){$cat29  = "$categoryname";}
if ($categorylink eq "cat30"){$cat30  = "$categoryname";}


}

open (DATABASE, "$datafile") || die "Can't Open $datafile";
while(<DATABASE>)

	{

($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping, $user1, $options) = split(/\|/,$_);

chop($options);

foreach ($sku) {

	if ($bgcount > 1)
	{$bgcolor=$bgcolor2;$bgcount=1;}
	else
	{$bgcolor=$bgcolor1;$bgcount=2;}

if ($category eq "cat01"){$cat = "$cat01";}
if ($category eq "cat02"){$cat = "$cat02";}
if ($category eq "cat03"){$cat = "$cat03";}
if ($category eq "cat04"){$cat = "$cat04";}
if ($category eq "cat05"){$cat = "$cat05";}
if ($category eq "cat06"){$cat = "$cat06";}
if ($category eq "cat07"){$cat = "$cat07";}
if ($category eq "cat08"){$cat = "$cat08";}
if ($category eq "cat09"){$cat = "$cat09";}
if ($category eq "cat10"){$cat = "$cat10";}
if ($category eq "cat11"){$cat = "$cat11";}
if ($category eq "cat12"){$cat = "$cat12";}
if ($category eq "cat13"){$cat = "$cat13";}
if ($category eq "cat14"){$cat = "$cat14";}
if ($category eq "cat15"){$cat = "$cat15";}
if ($category eq "cat16"){$cat = "$cat16";}
if ($category eq "cat17"){$cat = "$cat17";}
if ($category eq "cat18"){$cat = "$cat18";}
if ($category eq "cat19"){$cat = "$cat19";}
if ($category eq "cat20"){$cat = "$cat20";}
if ($category eq "cat21"){$cat = "$cat21";}
if ($category eq "cat22"){$cat = "$cat22";}
if ($category eq "cat23"){$cat = "$cat23";}
if ($category eq "cat24"){$cat = "$cat24";}
if ($category eq "cat25"){$cat = "$cat25";}
if ($category eq "cat26"){$cat = "$cat26";}
if ($category eq "cat27"){$cat = "$cat27";}
if ($category eq "cat28"){$cat = "$cat28";}
if ($category eq "cat29"){$cat = "$cat29";}
if ($category eq "cat30"){$cat = "$cat30";}

###
print <<ENDOFTEXT;
	
	<TR WIDTH=600 bgcolor=$bgcolor>
	<TD>
	<CENTER>
	<a href=manager.cgi?EditProduct=yes&EditWhichProduct=$sku>EDIT</a>
	</CENTER>
	</TD>
	<TD>
	$sku
	</TD>
	
	<TD>
	$cat
	</TD>
	
	<TD>
	$short_description
	</TD>

	<TD>
	$price
	</TD>
	
	<TD>
	<font color=red>$user1</font>
	</TD>	

	</TR>

ENDOFTEXT

# End of foreach
}

	} # End of while database

print <<ENDOFTEXT;

	</TABLE>

	</CENTER>
	<br><br><br>
	</BODY>
	</HTML>

ENDOFTEXT
}
#############################################################################################

sub change_settings_screen
{
require "../admin_files/commerce_user_lib.pl";

&PageHeader;

print <<ENDOFTEXT;

<FORM METHOD="POST" ACTION="manager.cgi">
<input type=hidden name=user value=$sc_user>
<input type=hidden name=pass value=$sc_pass>

 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Main Store Configuration</b></font></td>
  </tr>
</table>
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<TABLE WIDTH=580 border=0>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Here you will set the data variables specific to your specific store. 
Each value is defined and described, so you should have no problem getting through this part.
</TD>
</TR>
</TABLE>
</CENTER>
<CENTER>
<HR WIDTH=580>
</CENTER>

ENDOFTEXT

if($in{'system_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE border=0>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED><b>System settings have been successfully updated.</b></FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=10 CELLSPACING=0 WIDTH=580 BORDER=0>



<input type=hidden NAME=gateway_name value=gateway>

<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
Please enter the color code # for the look and feel of your site.<br>
<a href=http://www.merchantcgi.com/demo/colorcodes.html target=blank>Click here to view color codes.</a>
</TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
<INPUT NAME="colorcode" TYPE="TEXT" SIZE=15 VALUE="$colorcode"><br>
</TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD COLSPAN=2>
Please enter the layout number for your products display.<br>
<a href=http://www.merchantcgi.com/demo/layouts.html target=blank>Click here to view layouts.</a>
</TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD COLSPAN=2>
<INPUT NAME="layout" TYPE="TEXT" SIZE=15 VALUE="$sc_layout"><br>
</TD>
</TR>



<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
Please enter the full URL of your /images directory. For example:<br>
<b>http://www.merchantcgi.com/demo</b><br>
DO NOT include the trailing slash!!!
</TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
<INPUT NAME="URL_of_images_directory" TYPE="TEXT" SIZE=70 VALUE="$URL_of_images_directory"><br>
</TD>
</TR>



<TR bgcolor=#E4E4E4>
<TD COLSPAN=2>
Please enter the full URL of your store here<BR>
(ex: <b>http://www.merchantcgi.com/cgi-bin/store/merchant.cgi</b>)
</TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD COLSPAN=2>
<INPUT NAME="sc_store_url" TYPE="TEXT" SIZE=70 MAXLENGTH="128" VALUE="$sc_store_url"><br>
</TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD COLSPAN="2">Customers from the state selected here will be charged sales tax</td>
</tr>
<tr bgcolor=#F7EEE6>
<td COLSPAN="2">
<SELECT NAME=sales_tax_state>
<OPTION>$sc_sales_tax_state</OPTION>
<OPTION>None</OPTION> 
<OPTION>AL</OPTION> 
<OPTION>AK</OPTION> 
<OPTION>AZ</OPTION> 
<OPTION>AR</OPTION> 
<OPTION>CA</OPTION> 
<OPTION>CO</OPTION> 
<OPTION>CT</OPTION> 
<OPTION>DC</OPTION>
<OPTION>DE</OPTION> 
<OPTION>FL</OPTION> 
<OPTION>GA</OPTION> 
<OPTION>GU</OPTION> 
<OPTION>HI</OPTION> 
<OPTION>ID</OPTION> 
<OPTION>IL</OPTION> 
<OPTION>IN</OPTION> 
<OPTION>IA</OPTION> 
<OPTION>KS</OPTION> 
<OPTION>KY</OPTION> 
<OPTION>LA</OPTION> 
<OPTION>ME</OPTION> 
<OPTION>MD</OPTION> 
<OPTION>MA</OPTION> 
<OPTION>MI</OPTION> 
<OPTION>MN</OPTION> 
<OPTION>MS</OPTION> 
<OPTION>MO</OPTION> 
<OPTION>MT</OPTION> 
<OPTION>NE</OPTION> 
<OPTION>NV</OPTION> 
<OPTION>NH</OPTION> 
<OPTION>NJ</OPTION> 
<OPTION>NM</OPTION> 
<OPTION>NY</OPTION> 
<OPTION>NC</OPTION> 
<OPTION>ND</OPTION> 
<OPTION>OH</OPTION> 
<OPTION>OK</OPTION> 
<OPTION>OR</OPTION> 
<OPTION>PA</OPTION> 
<OPTION>PR</OPTION> 
<OPTION>RI</OPTION> 
<OPTION>SC</OPTION> 
<OPTION>SD</OPTION> 
<OPTION>TN</OPTION> 
<OPTION>TX</OPTION> 
<OPTION>UT</OPTION> 
<OPTION>VI</OPTION> 
<OPTION>VT</OPTION> 
<OPTION>VA</OPTION> 
<OPTION>WA</OPTION> 
<OPTION>WV</OPTION> 
<OPTION>WI</OPTION> 
<OPTION>WY</OPTION> 
</SELECT><br>
</TD>
</TR>



<TR bgcolor=#E4E4E4>
<td COLSPAN="2">Enter sales tax percentage here. Enter as a decimal number. <br>
Ex: "<b>.05</b>" for "5%", "<b>.06</b>" for "6%", etc.
</td></tr>
<tr bgcolor=#E4E4E4>
<TD COLSPAN="2"><INPUT NAME="sales_tax" TYPE="TEXT" VALUE="$sc_sales_tax" SIZE="5"><br></TD>
</TR>



<TR bgcolor=#F7EEE6>
<TD COLSPAN="2">
Do you wish to have orders e-mailed to you?
</td>
</tr><tr bgcolor=#F7EEE6><td colspan=2>
<SELECT NAME="email_orders_yes_no">
<OPTION>$sc_send_order_to_email</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT><br>
</TD>
</TR>


<TR bgcolor=#E4E4E4>
<TD COLSPAN="2">
Enter the e-mail address where you'd like the orders sent
</TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD COLSPAN="2">
<INPUT NAME="email_address_for_orders" TYPE="TEXT" VALUE="$sc_order_email" SIZE="55">
</TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD COLSPAN="2">Do you wish to have the orders written to a log file?</td></tr>

<tr bgcolor=#F7EEE6>
<td COLSPAN="2">
<SELECT NAME="log_orders_yes_no">
<OPTION>$sc_send_order_to_log</OPTION>
<OPTION>yes</OPTION>
<OPTION>no</OPTION>
</SELECT><br>
</TD>
</TR>


<TR bgcolor=#E4E4E4>
<TD COLSPAN="2">
Choose a unique name for your log file.<br> (ex: "mylog3218.txt")
</td></tr>
<tr bgcolor=#E4E4E4><td COLSPAN="2">
<INPUT NAME="name_of_the_log_file" TYPE="TEXT" VALUE="$sc_order_log_name"><br>
</TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD COLSPAN="2">
Enter the e-mail address of your webmaster or administrator here
</TD></tr>

<TR bgcolor=#F7EEE6>
<TD COLSPAN="2">
<INPUT NAME="admin_email" TYPE="TEXT" VALUE="$sc_admin_email" SIZE="55">
</TD>

</TR>


<TR bgcolor=#E4E4E4>
<TD colspan=2>How many products do you wish to display on each product page?</td>
<tr bgcolor=#E4E4E4><td colspan=2>
<SELECT NAME="sc_db_max_rows_returned">
<OPTION>$sc_db_max_rows_returned</OPTION>
<OPTION>5</OPTION>
<OPTION>10</OPTION>
<OPTION>15</OPTION>
<OPTION>20</OPTION>
<OPTION>25</OPTION>
<OPTION>30</OPTION>
<OPTION>35</OPTION>
<OPTION>40</OPTION>
<OPTION>45</OPTION>
<OPTION>50</OPTION>
</SELECT>
</TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="ChangeSettings" TYPE="SUBMIT" VALUE="Submit">
&nbsp;&nbsp;
<INPUT TYPE="RESET" VALUE="Reset">
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

</TABLE>

</CENTER>
</FORM>

</BODY>
</HTML>

ENDOFTEXT
}
#############################################################################################
#############################################################################################

sub change_password_screen
{
require "../admin_files/commerce_user_lib.pl";

&PageHeader;

print <<ENDOFTEXT;

<FORM METHOD="POST" ACTION="manager.cgi">
<input type=hidden name=gateway_name value=$sc_gateway_name>
<input type=hidden name=sales_tax value=$sc_sales_tax>
<input type=hidden name=sales_tax_state value=$sc_sales_tax_state>
<input type=hidden name=email_orders_yes_no value=$sc_send_order_to_email>
<input type=hidden name=name_of_the_log_file value=$sc_order_log_name>
<input type=hidden name=log_orders_yes_no value=$sc_send_order_to_log>
<input type=hidden name=order_email value=$sc_order_email>
<input type=hidden name=store_url value=$sc_store_url>
<input type=hidden name=admin_email value=$sc_admin_email>
<input type=hidden name=cookieDomain value=$sc_domain_name_for_cookie>
<input type=hidden name=cookiePath = value=$sc_path_for_cookie>
<input type=hidden name=URL_of_images_directory value=$URL_of_images_directory>
<input type=hidden name=colorcode value=$colorcode>
<input type=hidden name=db_max_rows_returned value=$sc_db_max_rows_returned>
<input type=hidden name=layout value=$sc_layout>
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Password Configuration</b></font></td>
  </tr>
</table>
<CENTER>
<HR WIDTH=580>
</CENTER>

<CENTER>
<TABLE WIDTH=580 border=0>
<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>Here you can change the <b>Username</b> and <b>Password</b> that you use to access this Management System.
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

if($in{'password_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE border=0>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED><b>Username & Passord have been successfully updated.</b></FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=10 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the <b>Username</b> you would like to use to access this Management System.
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="user" TYPE="TEXT" SIZE=25 VALUE="$sc_user"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the <b>Password</b> you would like to use to access this Management System.
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="pass" TYPE="TEXT" SIZE=25 VALUE="$sc_pass"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="password_edit_success" VALUE="yes">
<INPUT NAME="ChangePasswordSettings" TYPE="SUBMIT" VALUE="Submit">
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

</TABLE>

</CENTER>
</FORM>

</BODY>
</HTML>

ENDOFTEXT
}
#############################################################################################
sub gateway_settings_screen
{
require "../admin_files/commerce_user_lib.pl";
require "../admin_files/gateway-user_lib.pl";

##
## OFFLINE PROCESSING
##

if ($sc_gateway_name eq "Offline")
{

&PageHeader;

print <<ENDOFTEXT;

<FORM METHOD="POST" ACTION="manager.cgi">

<CENTER>
</CENTER>

<CENTER>
<TABLE WIDTH=580 border=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD WIDTH=580>
<FONT FACE=ARIAL>
Offline Processing
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

if($in{'system_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE border=0>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=2 COLOR=RED>Gateway settings have been successfully updated</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=10 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
Please enter the Secure URL to your merchant.cgi store.
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<INPUT NAME="order_url" TYPE="TEXT" SIZE=70 VALUE="$sc_order_script_url"><br>
</TD>
</TR>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="GatewaySettings" TYPE="SUBMIT" VALUE="Submit">
&nbsp;&nbsp;
<INPUT TYPE="RESET" VALUE="Reset">
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

</TABLE>

</CENTER>
</FORM>

</BODY>
</HTML>

ENDOFTEXT
	
}# end if ($sc_gateway_name eq "Offline")

##
## Gateway
##

elsif ($sc_gateway_name eq "gateway")
{

&PageHeader;

print <<ENDOFTEXT;

<FORM METHOD="POST" ACTION="manager.cgi">
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Gateway Configuration</b></font></td>
  </tr>
</table>
<CENTER>
<TABLE WIDTH=580 border=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR>
<TD COLSPAN="2">
<FONT FACE=ARIAL>
If you have not setup your gateway or merchant account yet<br>please call Merchant Services (361) 654-1481.
</FONT>

</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT

if($in{'system_edit_success'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE border=0>
<TR>
<TD>
<FONT FACE=ARIAL SIZE=1 COLOR=RED>Gateway settings have been successfully updated</FONT>
</TD>
</TR>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<FONT FACE=ARIAL SIZE=2>
<CENTER>
<TABLE BORDER=0 CELLPADDING=10 CELLSPACING=0 WIDTH=580 BORDER=0>

<TR>
<TD COLSPAN=2><HR></TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD colspan=2>
Enter your Gateway Username here.
</TD>
</tr>
<tr bgcolor=#E4E4E4>
<td colspan=2>
<INPUT NAME="sc_gateway_username" TYPE="TEXT" SIZE=30 VALUE="$sc_gateway_username"><br>
</TD>
</TR>


<INPUT type=hidden NAME="order_url" TYPE="TEXT" SIZE=70 VALUE="$sc_order_script_url">

<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
Enter the name of your business here.
</TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
<INPUT NAME="mername" TYPE="TEXT" SIZE=70 VALUE="$mername"><br>
</TD>
</TR>

<input type=hidden NAME="acceptcards" VALUE="1">
<input type=hidden NAME="acceptchecks" VALUE="0">



<TR bgcolor=#E4E4E4>
<TD colspan=2>
Are you setup to accept EFT through the gateway?<br>
Select '0' for no, '1' for yes.
</td>
</tr>
<tr bgcolor=#E4E4E4>
<td colspan=2>
<SELECT NAME="accepteft">
<OPTION>$accepteft</OPTION>
<OPTION VALUE="0">0</OPTION>
<OPTION VALUE="1">1</OPTION>
</SELECT><br>
</TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD colspan=2>
Do you want to allow customers to 
enter an alternate shipping address?<br>
Select '0' for no, '1' for yes.
</td>
</tr>
<tr bgcolor=#F7EEE6>
<td colspan=2>
<SELECT NAME="altaddr">
<OPTION>$altaddr</OPTION>
<OPTION VALUE="0">0</OPTION>
<OPTION VALUE="1">1</OPTION>
</SELECT><br>

</TD>
</TR>



<TR bgcolor=#E4E4E4>
<TD COLSPAN="2">
Enter the text that you'd like to appear
in the body of the confirmation e-mail
sent to the customer.
</TD>
</TR>
<TR bgcolor=#E4E4E4>
<TD COLSPAN="2">
<TEXTAREA NAME="email_text" ROWS=6 COLS=65 wrap=soft>$email_text</TEXTAREA>
</TD>
</TR>


<TR bgcolor=#F7EEE6>
<TD COLSPAN=2>
<CENTER>
<INPUT TYPE="HIDDEN" NAME="system_edit_success" VALUE="yes">
<INPUT NAME="GatewaySettings" TYPE="SUBMIT" VALUE="Submit">
&nbsp;&nbsp;
<INPUT TYPE="RESET" VALUE="Reset">
</CENTER>
</TD>
</TR>

<TR>
<TD COLSPAN=2>
<HR>
</TD>
</TR>

</TABLE>

</CENTER>
</FORM>

</BODY>
</HTML>

ENDOFTEXT
	
}


}


#############################################################################################

sub delete_product_screen
{

&PageHeader;

print <<ENDOFTEXT;
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Delete Products Screen</b></font></td>
  </tr>
</table>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL COLOR=RED>
WARNING!</FONT>
<FONT FACE=ARIAL>Clicking the <b>'Delete'</b> button will IMMEDIATELY remove that product from your catalog.
You've been warned! :-)
</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

ENDOFTEXT

if ($in{'DeleteWhichProduct'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>Reference \# $in{'DeleteWhichProduct'} successfully deleted</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<CENTER>

<TABLE WIDTH=550 BORDER=0 cellspacing=2 cellpadding=2>
	<TR WIDTH=600 bgcolor=#999966>
	<TD><CENTER>
	<b><FONT COLOR=white face=arial,helvetica size=-1>Delete</FONT></b></CENTER>
	</TD>
	<TD>
	<B><FONT COLOR=white face=arial,helvetica size=-1>Ref. #</FONT></B>
	</TD>

	<TD>
	<B><FONT COLOR=white face=arial,helvetica size=-1>Category</FONT></B>
	</TD>

	<TD>
	<B><FONT COLOR=white face=arial,helvetica size=-1>Product</FONT></B>
	</TD>

	<TD>
	<B><FONT COLOR=white face=arial,helvetica size=-1>Price</FONT></B>
	</TD>

	<TD>
	<B><FONT COLOR=white face=arial,helvetica size=-1>Specials</FONT></B>
	</TD>
	
	</TR>

ENDOFTEXT

$categoriesfile2 = "../admin_files/categories_lib.data";
open (CHECKSKU, "$categoriesfile2") || die "Can't Open $categoriesfile2";

while(<CHECKSKU>)

{
chop;
($sku2, $categorylink, $categoryname) = split(/\|/,$_);

if ($categorylink eq "cat01"){$cat01  = "$categoryname";}
if ($categorylink eq "cat02"){$cat02  = "$categoryname";}
if ($categorylink eq "cat03"){$cat03  = "$categoryname";}
if ($categorylink eq "cat04"){$cat04  = "$categoryname";}
if ($categorylink eq "cat05"){$cat05  = "$categoryname";}
if ($categorylink eq "cat06"){$cat06  = "$categoryname";}
if ($categorylink eq "cat07"){$cat07  = "$categoryname";}
if ($categorylink eq "cat08"){$cat08  = "$categoryname";}
if ($categorylink eq "cat09"){$cat09  = "$categoryname";}
if ($categorylink eq "cat10"){$cat10  = "$categoryname";}
if ($categorylink eq "cat11"){$cat11  = "$categoryname";}
if ($categorylink eq "cat12"){$cat12  = "$categoryname";}
if ($categorylink eq "cat13"){$cat13  = "$categoryname";}
if ($categorylink eq "cat14"){$cat14  = "$categoryname";}
if ($categorylink eq "cat15"){$cat15  = "$categoryname";}
if ($categorylink eq "cat16"){$cat16  = "$categoryname";}
if ($categorylink eq "cat17"){$cat17  = "$categoryname";}
if ($categorylink eq "cat18"){$cat18  = "$categoryname";}
if ($categorylink eq "cat19"){$cat19  = "$categoryname";}
if ($categorylink eq "cat20"){$cat20  = "$categoryname";}
if ($categorylink eq "cat21"){$cat21  = "$categoryname";}
if ($categorylink eq "cat22"){$cat22  = "$categoryname";}
if ($categorylink eq "cat23"){$cat23  = "$categoryname";}
if ($categorylink eq "cat24"){$cat24  = "$categoryname";}
if ($categorylink eq "cat25"){$cat25  = "$categoryname";}
if ($categorylink eq "cat26"){$cat26  = "$categoryname";}
if ($categorylink eq "cat27"){$cat27  = "$categoryname";}
if ($categorylink eq "cat28"){$cat28  = "$categoryname";}
if ($categorylink eq "cat29"){$cat29  = "$categoryname";}
if ($categorylink eq "cat30"){$cat30  = "$categoryname";}


}

###***
$bgcolor1 = "#E4E4E4";
$bgcolor2 = "#F7EEE6";
open (DATABASE, "$datafile") || die "Can't Open $datafile";

while(<DATABASE>)

	{

($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping, $user1, $options) = split(/\|/,$_);

chop($options);

foreach ($sku) {
	if ($bgcount > 1)
	{$bgcolor=$bgcolor2;$bgcount=1;}
	else
	{$bgcolor=$bgcolor1;$bgcount=2;}

if ($category eq "cat01"){$cat = "$cat01";}
if ($category eq "cat02"){$cat = "$cat02";}
if ($category eq "cat03"){$cat = "$cat03";}
if ($category eq "cat04"){$cat = "$cat04";}
if ($category eq "cat05"){$cat = "$cat05";}
if ($category eq "cat06"){$cat = "$cat06";}
if ($category eq "cat07"){$cat = "$cat07";}
if ($category eq "cat08"){$cat = "$cat08";}
if ($category eq "cat09"){$cat = "$cat09";}
if ($category eq "cat10"){$cat = "$cat10";}
if ($category eq "cat11"){$cat = "$cat11";}
if ($category eq "cat12"){$cat = "$cat12";}
if ($category eq "cat13"){$cat = "$cat13";}
if ($category eq "cat14"){$cat = "$cat14";}
if ($category eq "cat15"){$cat = "$cat15";}
if ($category eq "cat16"){$cat = "$cat16";}
if ($category eq "cat17"){$cat = "$cat17";}
if ($category eq "cat18"){$cat = "$cat18";}
if ($category eq "cat19"){$cat = "$cat19";}
if ($category eq "cat20"){$cat = "$cat20";}
if ($category eq "cat21"){$cat = "$cat21";}
if ($category eq "cat22"){$cat = "$cat22";}
if ($category eq "cat23"){$cat = "$cat23";}
if ($category eq "cat24"){$cat = "$cat24";}
if ($category eq "cat25"){$cat = "$cat25";}
if ($category eq "cat26"){$cat = "$cat26";}
if ($category eq "cat27"){$cat = "$cat27";}
if ($category eq "cat28"){$cat = "$cat28";}
if ($category eq "cat29"){$cat = "$cat29";}
if ($category eq "cat30"){$cat = "$cat30";}

###
print <<ENDOFTEXT;

	<TR WIDTH=550 bgcolor=$bgcolor>
	<TD>
	<CENTER>
	<a href=manager.cgi?DeleteProduct=yes&DeleteWhichProduct=$sku>DELETE</a>
	</CENTER>
	</TD>
	<TD>
	$sku
	</TD>

	<TD>
	$cat
	</TD>

	<TD>
	$short_description
	</TD>

	<TD>
	$price
	</TD>

	<TD>
	<font color=red>$user1</font>
	</TD>
	</TR>

ENDOFTEXT

# End of foreach
}

	} # End of while database

print <<ENDOFTEXT;

	</TABLE>

	</CENTER>
	<br><br><br>
	</BODY>
	</HTML>

ENDOFTEXT
}
#############################################################################################
sub display_perform_edit_screen
{
$displaysku = "$sku";

$categoriesfile2 = "../admin_files/categories_lib.data";
open (CHECKSKU2, "$categoriesfile2") || die "Can't Open $categoriesfile2";

while(<CHECKSKU2>)

{
chop;
$catrow=$_;
@cats = split(/\|/,$catrow);
if ($cats[2] ne ""){

$insertcategories  .= "<option value=$cats[1]>$cats[2]</option>\n";

}


}
$insertcategories2 = "$insertcategories";

open (CHECKSKU3, "$categoriesfile2") || die "Can't Open $categoriesfile2";

while(<CHECKSKU3>)

{
chop;
($ref, $categorylink, $categoryname) = split(/\|/,$_);

if ($categorylink eq "cat01"){$cat01  = "$categoryname";}
if ($categorylink eq "cat02"){$cat02  = "$categoryname";}
if ($categorylink eq "cat03"){$cat03  = "$categoryname";}
if ($categorylink eq "cat04"){$cat04  = "$categoryname";}
if ($categorylink eq "cat05"){$cat05  = "$categoryname";}
if ($categorylink eq "cat06"){$cat06  = "$categoryname";}
if ($categorylink eq "cat07"){$cat07  = "$categoryname";}
if ($categorylink eq "cat08"){$cat08  = "$categoryname";}
if ($categorylink eq "cat09"){$cat09  = "$categoryname";}
if ($categorylink eq "cat10"){$cat10  = "$categoryname";}
if ($categorylink eq "cat11"){$cat11  = "$categoryname";}
if ($categorylink eq "cat12"){$cat12  = "$categoryname";}
if ($categorylink eq "cat13"){$cat13  = "$categoryname";}
if ($categorylink eq "cat14"){$cat14  = "$categoryname";}
if ($categorylink eq "cat15"){$cat15  = "$categoryname";}
if ($categorylink eq "cat16"){$cat16  = "$categoryname";}
if ($categorylink eq "cat17"){$cat17  = "$categoryname";}
if ($categorylink eq "cat18"){$cat18  = "$categoryname";}
if ($categorylink eq "cat19"){$cat19  = "$categoryname";}
if ($categorylink eq "cat20"){$cat20  = "$categoryname";}
if ($categorylink eq "cat21"){$cat21  = "$categoryname";}
if ($categorylink eq "cat22"){$cat22  = "$categoryname";}
if ($categorylink eq "cat23"){$cat23  = "$categoryname";}
if ($categorylink eq "cat24"){$cat24  = "$categoryname";}
if ($categorylink eq "cat25"){$cat25  = "$categoryname";}
if ($categorylink eq "cat26"){$cat26  = "$categoryname";}
if ($categorylink eq "cat27"){$cat27  = "$categoryname";}
if ($categorylink eq "cat28"){$cat28  = "$categoryname";}
if ($categorylink eq "cat29"){$cat29  = "$categoryname";}
if ($categorylink eq "cat30"){$cat30  = "$categoryname";}
}

if ($category eq "cat01"){$cat = "$cat01";}
if ($category eq "cat02"){$cat = "$cat02";}
if ($category eq "cat03"){$cat = "$cat03";}
if ($category eq "cat04"){$cat = "$cat04";}
if ($category eq "cat05"){$cat = "$cat05";}
if ($category eq "cat06"){$cat = "$cat06";}
if ($category eq "cat07"){$cat = "$cat07";}
if ($category eq "cat08"){$cat = "$cat08";}
if ($category eq "cat09"){$cat = "$cat09";}
if ($category eq "cat10"){$cat = "$cat10";}
if ($category eq "cat11"){$cat = "$cat11";}
if ($category eq "cat12"){$cat = "$cat12";}
if ($category eq "cat13"){$cat = "$cat13";}
if ($category eq "cat14"){$cat = "$cat14";}
if ($category eq "cat15"){$cat = "$cat15";}
if ($category eq "cat16"){$cat = "$cat16";}
if ($category eq "cat17"){$cat = "$cat17";}
if ($category eq "cat18"){$cat = "$cat18";}
if ($category eq "cat19"){$cat = "$cat19";}
if ($category eq "cat20"){$cat = "$cat20";}
if ($category eq "cat21"){$cat = "$cat21";}
if ($category eq "cat22"){$cat = "$cat22";}
if ($category eq "cat23"){$cat = "$cat23";}
if ($category eq "cat24"){$cat = "$cat24";}
if ($category eq "cat25"){$cat = "$cat25";}
if ($category eq "cat26"){$cat = "$cat26";}
if ($category eq "cat27"){$cat = "$cat27";}
if ($category eq "cat28"){$cat = "$cat28";}
if ($category eq "cat29"){$cat = "$cat29";}
if ($category eq "cat30"){$cat = "$cat30";}



&PageHeader;

print <<ENDOFTEXT;
<form method=post value=manager.cgi>
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Edit Products screen</b></font></td>
  </tr>
</table>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
Make changes to your product using this form. When you are satisfied with your changes, click <b>'Submit Edit'</b> below.
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE BORDER=0 CELLPADDING=5 CELLSPACING=1 WIDTH="550">
<TR bgcolor=#999966>
<TD WIDTH=100><FONT FACE=ARIAL,helvetica SIZE=-1 color=white><b>$displaysku</b></font></TD>
<TD WIDTH=450><FONT FACE=ARIAL,helvetica SIZE=-1 color=white><b>Reference #</b></FONT></TD>
</TR>
<TR bgcolor=#E4E4E4>
<TD WIDTH=100><select name="category"><option value=$category SELECTED>$cat</option>$insertcategories2</select></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Category</b> - Please Select</font></TD>
</TR>
<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="price" TYPE="TEXT" SIZE=35 MAXLENGTH=35 VALUE="$price"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Price</b></font> - No \$ sign needed</TD>
</TR>
<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="name" TYPE="TEXT" SIZE=35 MAXLENGTH=35 VALUE="$short_description"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Product Name</b> - 3 or 4 words</font></TD>
</TR>
<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="image" TYPE="TEXT" SIZE=35 MAXLENGTH=35 VALUE='$image'></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Image File</b> - filename.gif</font></TD>
</TR>
<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="option_file" TYPE="TEXT" SIZE=35 MAXLENGTH=35 VALUE="$options"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Option File</b> - filename.html</font></TD>
</TR>
<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="shipping_price" TYPE="TEXT" SIZE=35 MAXLENGTH=35 VALUE="$shipping_price"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Shipping Price</b></font></TD>
</TR>

<!--BEGIN USER DEFINED-->

<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="userDefinedOne" TYPE="TEXT" SIZE=35 MAXLENGTH=128 VALUE="$userDefinedOne"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">Enter the word "Special" to make this product show up in the "Special Buys" column.</font></TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="userDefinedTwo" TYPE="TEXT" SIZE=35 MAXLENGTH=128 VALUE="$userDefinedTwo"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Two</font></TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="userDefinedThree" TYPE="TEXT" SIZE=35 MAXLENGTH=128 VALUE="$userDefinedThree"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Three</font></TD>
</TR>

<TR bgcolor=#F7EEE6>
<TD WIDTH=100><INPUT NAME="userDefinedFour" TYPE="TEXT" SIZE=35 MAXLENGTH=128 VALUE="$userDefinedFour"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Four</font></TD>
</TR>

<TR bgcolor=#E4E4E4>
<TD WIDTH=100><INPUT NAME="userDefinedFive" TYPE="TEXT" SIZE=35 MAXLENGTH=128 VALUE="$userDefinedFive"></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2 COLOR="RED">User Defined Field Five</font></TD>
</TR>

<!--END USER DEFINED-->

<TR bgcolor=#F7EEE6>
<TD WIDTH=100><TEXTAREA NAME="description" ROWS=6 COLS=35 wrap=soft>$long_description</TEXTAREA></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=2><b>Description</b> - Enter the HTML (including price) for your product description here. </font></TD>
</TR>
</TABLE>
<TABLE WIDTH=550 border=0>
<TR WIDTH=550 bgcolor=#E4E4E4>
<TD WIDTH=550>
<CENTER><INPUT TYPE=HIDDEN NAME="ProductEditSku" VALUE="$displaysku"></CENTER>
<CENTER><INPUT TYPE=SUBMIT NAME="SubmitEditProduct" VALUE="Submit Edit">&nbsp;<INPUT TYPE=RESET VALUE="Clear Form"></CENTER>
</TD>
<TR>
</TABLE>
</CENTER>
</FORM>
</BODY>
</HTML>

ENDOFTEXT

}

#############################################################################################
sub display_perform_edit_category_screen
{

&PageHeader;

print <<ENDOFTEXT;
 <form method=post value=manager.cgi>
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Edit Categories Screen</b></font></td>
  </tr>
</table>
<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
Make changes to your Categories using this form. When you are satisfied with your changes, click <b>'Submit Edit'</b> below.
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE BORDER=0 CELLPADDING=5 CELLSPACING=1 WIDTH="550">
<TR bgcolor=#999966>
<TD><FONT FACE=ARIAL,helvetica SIZE=-1 color=white><b>Reference # $sku2</b></FONT></TD>
<TD><FONT FACE=ARIAL,helvetica SIZE=-1 color=white><b>Link # $linkname</b></FONT></TD>
</TR>
<TR>
<TD WIDTH=100><FONT FACE=ARIAL SIZE=2><b>Display Name</b></font></TD>
<TD WIDTH=450><INPUT NAME="categoryname" TYPE="TEXT" SIZE=35 MAXLENGTH=50 VALUE="$displayname"></TD>
</TR>
</TABLE>
<TABLE WIDTH=550 border=0>
<TR WIDTH=550>
<TD WIDTH=550>
<CENTER><INPUT TYPE=HIDDEN NAME="CategoryEditSku" VALUE="$sku2"></CENTER>
<CENTER><INPUT TYPE=SUBMIT NAME="SubmitEditCategory" VALUE="Submit Edit"></CENTER>
</TD>
<TR>
</TABLE>
</CENTER>
</FORM>
</BODY>
</HTML>

ENDOFTEXT

}
#############################################################################################
#############################################################################################
sub display_perform_edit_page_screen
{

&PageHeader;

print <<ENDOFTEXT;
<FORM METHOD=POST ACTION=manager.cgi>
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Edit Pages Screen</b></font></td>
  </tr>
</table>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
Make changes to your Pages using this form. When you are satisfied with your changes, click <b>'Submit Edit'</b> below.
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE BORDER=0 CELLPADDING=5 CELLSPACING=1 WIDTH="550">
<TR bgcolor=#999966>
<TD WIDTH=100><FONT FACE=ARIAL SIZE=-1 color=white><b>Page Name</b></FONT></TD>
<TD WIDTH=450><FONT FACE=ARIAL SIZE=-1 color=white><b>$pagename</b></FONT></TD>
</TR>
<TR>
<TD WIDTH=100 valign=top><FONT FACE=ARIAL SIZE=2><b>Page Content</b></FONT></TD>
<TD WIDTH=450><textarea name=newpagecontent cols=55 rows=20 wrap=soft>$pagecontent</textarea></TD>
</TR>
</TABLE>
<TABLE WIDTH=550 border=0>
<TR WIDTH=550>
<TD WIDTH=550>
<CENTER><INPUT TYPE=HIDDEN NAME="PageEditSku" VALUE="$sku3"></CENTER>
<CENTER><INPUT TYPE=SUBMIT NAME="SubmitEditPage" VALUE="Submit Edit"></CENTER>
</TD>
<TR>
</TABLE>
</CENTER>
</FORM>
</BODY>
</HTML>

ENDOFTEXT

}
#############################################################################################
sub printCommonHeader
{
print <<ENDOFTEXT;

<CENTER>
<!--BEGIN HEADER TABLE-->

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr height="37"> 
    <td width="3" height="37"></td>
    <td width="*%"><FONT FACE="arial, helvetica, verdana" SIZE="5" COLOR="#000000">Catalog Management System</FONT></td>
  </tr>
  <tr height="23"> 
    <td width="3" height="23"></td>
    <td width="*%">
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?edit_page_screen=yes>Edit Pages</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?edit_categories_screen=yes>Edit Categories</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?add_screen=yes>Add Products</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?edit_screen=yes>Edit Products</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?delete_screen=yes>Delete Products</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?change_settings_screen=yes>Store Settings</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=manager.cgi?gateway_screen=yes>Gateway Settings</A>  </FONT></b>
    <FONT FACE=ARIAL, HELVETICA SIZE=-1><b><A HREF=javascript:login()>Gateway Login</A></FONT></b>
    </td>
  </tr>

<!--END HEADER TABLE-->

ENDOFTEXT
}
#############################################################################################

#################################################################################

sub edit_categories_screen
{
&PageHeader;

print <<ENDOFTEXT;
<FORM METHOD=POST ACTION=manager.cgi>
 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Edit Categories Screen</b></font></td>
  </tr>
</table>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
This is the Edit Categories screen. Click the <b>'Edit'</b> to make 
changes to the titles of categories in your catalog.</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

ENDOFTEXT

if ($in{'CategoryEditSku'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>Category $in{'CategoryEditSku'} successfully edited.</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<CENTER>

<TABLE WIDTH=600 BORDER=0 cellspacing=2 cellpadding=2>
	<TR WIDTH=550 bgcolor=#999966>
	<TD>
	<b><font color=white size=-1 face=arial,helvetica>Edit</font></b>
	</TD>
	<TD>
	<B><font color=white size=-1 face=arial,helvetica>Reference #</font></B>
	</TD>

	<TD>
	<B><font color=white size=-1 face=arial,helvetica>Link #</font></B>
	</TD>

	<TD>
	<B><font color=white size=-1 face=arial,helvetica>Category Name</font></B>
	</TD>

	</TR>

ENDOFTEXT

###
$bgcolor1 = "#E4E4E4";
$bgcolor2 = "#F7EEE6";
open (CATEGORIES, "$categoriesfile") || die "Can't Open $categoriesfile";

while(<CATEGORIES>)

	{

($sku2, $linkname, $displayname) = split(/\|/,$_);

chop($displayname);

foreach ($sku2) {
	if ($bgcount > 1)
	{$bgcolor=$bgcolor2;$bgcount=1;}
	else
	{$bgcolor=$bgcolor1;$bgcount=2;}

###
print <<ENDOFTEXT;

	<TR WIDTH=550 bgcolor=$bgcolor>
	<TD>
	<CENTER>
	<a href=manager.cgi?EditCategory=yes&EditWhichCategory=$sku2>EDIT</a>
	</CENTER>
	</TD>
	<TD>
	$sku2
	</TD>

	<TD>
	$linkname
	</TD>

	<TD>
	$displayname
	</TD>
	</TR>

ENDOFTEXT

# End of foreach
}

	} # End of while database

print <<ENDOFTEXT;

	</TABLE>

	</CENTER>
	<br><br><br>
	</BODY>
	</HTML>

ENDOFTEXT

}
#################################################################################
#################################################################################

sub edit_page_screen
{

&PageHeader;

print <<ENDOFTEXT;

 <tr width="3"height="21"> 
    <td height="21"></td>
    <td width="*%"><font face=arial,helvetica size=-1 color=white><b>Catalog Management System Edit Pages Screen</b></font></td>
  </tr>
</table>

<CENTER>
<HR WIDTH=500>
</CENTER>

<CENTER>
<TABLE WIDTH=500 border=0>
<TR>
<TD WIDTH=500>
<FONT FACE=ARIAL>
This is the Edit Page screen. Click the <b>'Edit'</b> to make 
changes to the various pages in your catalog.</TR>
</TABLE>
</CENTER>

<CENTER>
<HR WIDTH=500>
</CENTER>

ENDOFTEXT

if ($in{'PageEditSku'} ne "")
{
print <<ENDOFTEXT;
<CENTER>
<TABLE WIDTH=550 BORDER=0>
<CENTER>
<TR WIDTH=550 BORDER=0>
<TD WIDTH=550 BORDER=0>
<CENTER><FONT FACE=ARIAL SIZE=2 COLOR=RED>Page successfully edited.</FONT></CENTER>
</TD>
</TR>
</CENTER>
</TABLE>
</CENTER>
ENDOFTEXT
}

print <<ENDOFTEXT;

<CENTER>

<TABLE WIDTH=600 BORDER=0 cellpadding=2 cellspacing=2>
	<TR WIDTH=600 bgcolor=#999966>
	<TD>
	<b><font color=white size=-1 face=arial,helvetica>Edit</font></b>
	</TD>
	<TD>
	<B><font color=white size=-1 face=arial,helvetica>Page Name</font></B>
	</TD>

	</TR>

ENDOFTEXT

###
$bgcolor1 = "#E4E4E4";
$bgcolor2 = "#F7EEE6";
open (PAGE, "$pagesfile") || die "Can't Open $pagesfile";

while(<PAGE>)

	{

($sku3, $pagename, $pagecontent) = split(/\|/,$_);

chop($pagecontent);
foreach ($sku3) {

	if ($bgcount > 1)
	{$bgcolor=$bgcolor2;$bgcount=1;}
	else
	{$bgcolor=$bgcolor1;$bgcount=2;}
###
print <<ENDOFTEXT;

	<TR WIDTH=600 bgcolor=$bgcolor>
	<TD>
	<CENTER>
	<a href=manager.cgi?EditPage=yes&EditWhichPage=$sku3>EDIT</a>
	</CENTER>
	</TD>
	<TD>
	$pagename
	</TD>
	</TR>

ENDOFTEXT

# End of foreach
}

	} # End of while database

print <<ENDOFTEXT;

	</TABLE>

	</CENTER>
	</BODY>
	</HTML>

ENDOFTEXT

}
#################################################################################
1;