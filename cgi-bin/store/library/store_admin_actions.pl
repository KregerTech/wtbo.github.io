#######################################################################################
# This file contains the action logic for the store admin program
#
#######################################################################################
# commerce_user_lib.pl
#######################################################################################
sub action_process_login
{

if($in{'username'} eq "$username" && $in{'password'} eq "$password")
{
open(FILE, ">$ip_file") || die "Can't Open $ip_file";
print(FILE "\$ok_ip=\"$ENV{'REMOTE_ADDR'}\";\n");
close(FILE);
}

else
{
&display_login;
exit;
}

}
#######################################################################################

sub action_add_product
{
local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, $userDefinedThree, $userDefinedFour, $userDefinedFive, $options);

open (CHECKSKU, "$datafile") || die "Can't Open $datafile";

while(<CHECKSKU>)

	{

($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, 
 $userDefinedThree, $userDefinedFour, $userDefinedFive, 
 $options) = split(/\|/,$_);

chop($options);

foreach ($sku) {

if ($sku eq $in{'sku'})
{
#print "sku already exists!";
$add_product_status="no";
&add_product_screen($add_product_status);
exit;
}
			
# End of foreach
}



# End of while CHECKSKU

	}

close (CHECKSKU);

$formatted_description = $in{'description'};
$formatted_description =~ s/\r/ /g;
$formatted_description =~ s/\t/ /g;
$formatted_description =~ s/\n/ /g;

##
if ($in{'image'} ne "")
{
$formatted_image = "\<IMG SRC\=\"%%URLofImages%%\/$in{'image'}\" BORDER\=0\>";
}
else
{
$formatted_image = "\<IMG SRC\=\"%%URLofImages%%\/notavailable.gif\" BORDER\=0\>";
}

##
if ($in{'option_file'} ne "")

{
	if (-e "../html/options/$in{'option_file'}")
	{
	$formatted_option_file = "\%\%OPTION\%\%$in{'option_file'}";
	}
	else
	{
	$formatted_option_file = "\%\%OPTION\%\%blank.html";
	}
}

else

{
$formatted_option_file = "\%\%OPTION\%\%blank.html";
}
##

open (NEW, "+>> $datafile") || die "Can't Open $datafile";

print (NEW  "$in{'sku'}|$in{'category'}|$in{'price'}|$in{'name'}|$formatted_image|$formatted_description|$in{shipping_price}|$in{'userDefinedOne'}|$in{'userDefinedTwo'}|$in{'userDefinedThree'}|$in{'userDefinedFour'}|$in{'userDefinedFive'}|$formatted_option_file\n");

close(NEW);

$add_product_status="yes";
&add_product_screen($add_product_status);

}
#######################################################################################

sub display_catalog_screen

{
&PageHeader;

open (DATABASE, "$datafile") || die "Can't Open $datafile";

while(<DATABASE>)

	{

($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, 
 $userDefinedThree, $userDefinedFour, $userDefinedFive, 
 $options) = split(/\|/,$_);

chop($options);

foreach ($sku) {

	#if ($sku eq $in{'sku'})
	#{
	&DisplayRequestedProduct;
	#}

# End of foreach
}



# End of while DATABASE

	}

close(DATABASE);

&PageFooter;
}

#######################################################################################
sub action_edit_product
{
	
local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, 
      $userDefinedThree, $userDefinedFour, $userDefinedFive, 
      $options);

open (CHECKSKU, "$datafile") || die "Can't Open $datafile";

while(<CHECKSKU>)

	{

($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, $userDefinedThree, $userDefinedFour, $userDefinedFive, $options) = split(/\|/,$_);

chop($options);

foreach ($sku) {

if ($sku eq $in{'EditWhichProduct'})
{

$options =~ s/%%OPTION%%//g;
$image =~ s/.*%%URLofImages%%\///g;
$image =~ s/.gif.*/.gif/g;
$image =~ s/.jpg.*/.jpg/g;

&display_perform_edit_screen;
}

# End of foreach
}
# End of while
}

}
#######################################################################################
sub action_submit_edit_product
{
### Begin
local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, $userDefinedThree, $userDefinedFour, $userDefinedFive, $options);

$formatted_description = $in{'description'};
$formatted_description =~ s/\r/ /g;
$formatted_description =~ s/\t/ /g;
$formatted_description =~ s/\n/ /g;

##
if ($in{'image'} ne "")
{
$formatted_image = "\<IMG SRC\=\"%%URLofImages%%/$in{'image'}\" BORDER\=0\>";
}
else
{
$formatted_image = "\<IMG SRC\=\"%%URLofImages%%/notavailable.gif\" BORDER\=0\>";
}

##
if ($in{'option_file'} ne "")

{
	if (-e "../html/options/$in{'option_file'}")
	{
	$formatted_option_file = "\%\%OPTION\%\%$in{'option_file'}";
	}
	else
	{
	$formatted_option_file = "\%\%OPTION\%\%blank.html";
	}
}

else

{
$formatted_option_file = "\%\%OPTION\%\%blank.html";
}
##

open(OLDFILE, "$datafile") || die "Can't Open $datafile";
@lines = <OLDFILE>;
#print @lines;

open(NEWFILE,">$datafile") || die "Can't Open $datafile";

foreach $line (@lines)
	{
($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, $userDefinedThree, $userDefinedFour, $userDefinedFive, $options) = split(/\|/,$line);

if ($sku == $in{'ProductEditSku'})
{
print (NEWFILE  "$in{'ProductEditSku'}|$in{'category'}|$in{'price'}|$in{'name'}|$formatted_image|$formatted_description|$in{'shipping_price'}|$in{'userDefinedOne'}|$in{'userDefinedTwo'}|$in{'userDefinedThree'}|$in{'userDefinedFour'}|$in{'userDefinedFive'}|$formatted_option_file\n");
}

else 
{
print NEWFILE $line;
}

	}

close (NEWFILE);



&edit_product_screen;

### End
}

#######################################################################################
#######################################################################################
sub action_submit_edit_category
{
### Begin
local($sku2, $linkname, $displayname);

$formatted_categoryname = $in{'categoryname'};
$formatted_categoryname =~ s/\r/ /g;
$formatted_categoryname =~ s/\t/ /g;
$formatted_categoryname =~ s/\n/ /g;


##

open(OLDFILE, "$categoriesfile") || die "Can't Open $categoriesfile";
@lines = <OLDFILE>;
#print @lines;

open(NEWFILE,">$categoriesfile") || die "Can't Open $categoriesfile";

foreach $line (@lines)
	{
($sku2, $linkname, $displayname) = split(/\|/,$line);

if ($sku2 == $in{'CategoryEditSku'})
{
print (NEWFILE  "$in{'CategoryEditSku'}|$linkname|$formatted_categoryname\n");
}

else 
{
print NEWFILE $line;
}

	}

close (NEWFILE);



&edit_categories_screen;

### End
}

#######################################################################################
#######################################################################################
sub action_submit_edit_page
{
### Begin
local($sku3, $pagename, $pagecontent);

$formatted_newpagecontent = $in{'newpagecontent'};
$formatted_newpagecontent =~ s/\r/ /g;
$formatted_newpagecontent =~ s/\t/ /g;
$formatted_newpagecontent =~ s/\n/ /g;


##

open(OLDFILE, "$pagesfile") || die "Can't Open $pagesfile";
@lines = <OLDFILE>;
#print @lines;

open(NEWFILE,">$pagesfile") || die "Can't Open $pagesfile";

foreach $line (@lines)
	{
($sku3, $pagename, $pagecontent) = split(/\|/,$line);

if ($sku3 == $in{'PageEditSku'})
{
print (NEWFILE  "$in{'PageEditSku'}|$pagename|$formatted_newpagecontent\n");
}

else 
{
print NEWFILE $line;
}

	}

close (NEWFILE);



&edit_page_screen;

### End
}

#######################################################################################

sub action_delete_product
{
### Begin
local($sku, $category, $price, $short_description, $image, 
      $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, $userDefinedThree, $userDefinedFour, $userDefinedFive, $options);

open(OLDFILE, "$datafile") || die "Can't Open $datafile";
@lines = <OLDFILE>;

open(NEWFILE,">$datafile") || die "Can't Open $datafile";

foreach $line (@lines)
	{
($sku, $category, $price, $short_description, $image, 
 $long_description, $shipping_price, $userDefinedOne, $userDefinedTwo, $userDefinedThree, $userDefinedFour, $userDefinedFive, $options) = split(/\|/,$line);

if ($sku == $in{'DeleteWhichProduct'})
{
$line = "";
}

else 
{
print NEWFILE $line;
}

	}

close (NEWFILE);



&delete_product_screen;

### End
}
#######################################################################################
sub action_change_password_settings

{
$user_settings = "../admin_files/commerce_user_lib.pl";

local($admin_email, $order_email, $cookieDomain, $cookiePath);
&ReadParse;

$cookieDomain = $in{'store_url'};
$cookiePath = $in{'store_url'};

$cookieDomain =~ s/http.*:\/\///g;
$cookieDomain =~ s/\/.*//g;
$cookieDomain =~ s/\/merchant.cgi//g;

$cookiePath =~ s/http.*:\/\/$cookieDomain//g;
$cookiePath =~ s/merchant.cgi//g;
chop $cookiePath;

$order_email = $in{'order_email'}; 
$order_email =~ s/\@/\\@/;

$admin_email = $in{'admin_email'};
$admin_email =~ s/\@/\\@/;

open (SETTINGS, "> $user_settings") || die "Can't Open $user_settings";

print (SETTINGS  "## This file contains the user specific variables\n");
print (SETTINGS  "## necessary for merchant.cgi\n");
print (SETTINGS  "\n");
print (SETTINGS  "\$sc_gateway_name = \"$in{'gateway_name'}\";\n");
print (SETTINGS  "\$sc_sales_tax = \"$in{'sales_tax'}\";\n");
print (SETTINGS  "\$sc_sales_tax_state = \"$in{'sales_tax_state'}\";\n");
print (SETTINGS  "\$sc_send_order_to_email = \"$in{'email_orders_yes_no'}\";\n");
print (SETTINGS  "\$sc_order_log_name = \"$in{'name_of_the_log_file'}\";\n");
print (SETTINGS  "\$sc_send_order_to_log = \"$in{'log_orders_yes_no'}\";\n");
print (SETTINGS  "\$sc_order_email = \"$order_email\";\n");
print (SETTINGS  "\$sc_store_url = \"$in{'store_url'}\";\n");
print (SETTINGS  "\$sc_admin_email = \"$admin_email\";\n");
print (SETTINGS  "\$sc_domain_name_for_cookie = \"$cookieDomain\";\n");
print (SETTINGS  "\$sc_path_for_cookie = \"$cookiePath\";\n");
print (SETTINGS  "\$URL_of_images_directory = \"$in{'URL_of_images_directory'}\";\n");
print (SETTINGS  "\$colorcode = \"$in{'colorcode'}\";\n");
print (SETTINGS  "\$sc_db_max_rows_returned = \"$in{'db_max_rows_returned'}\";\n");
print (SETTINGS  "\$sc_user = \"$in{'user'}\";\n");
print (SETTINGS  "\$sc_pass = \"$in{'pass'}\";\n");
print (SETTINGS  "\$sc_layout = \"$in{'layout'}\";\n");
print (SETTINGS  "1\;\n");
close(SETTINGS);

&change_password_screen;

}

#######################################################################################

#######################################################################################
sub action_change_settings

{
$user_settings = "../admin_files/commerce_user_lib.pl";

local($admin_email, $order_email, $cookieDomain, $cookiePath);
&ReadParse;

$cookieDomain = $in{'sc_store_url'};
$cookiePath = $in{'sc_store_url'};

$cookieDomain =~ s/http.*:\/\///g;
$cookieDomain =~ s/\/.*//g;
$cookieDomain =~ s/\/merchant.cgi//g;

$cookiePath =~ s/http.*:\/\/$cookieDomain//g;
$cookiePath =~ s/merchant.cgi//g;
chop $cookiePath;

$order_email = $in{'email_address_for_orders'}; 
$order_email =~ s/\@/\\@/;

$admin_email = $in{'admin_email'};
$admin_email =~ s/\@/\\@/;

open (SETTINGS, "> $user_settings") || die "Can't Open $user_settings";

print (SETTINGS  "## This file contains the user specific variables\n");
print (SETTINGS  "## necessary for merchant.cgi\n");
print (SETTINGS  "\n");
print (SETTINGS  "\$sc_gateway_name = \"$in{'gateway_name'}\";\n");
print (SETTINGS  "\$sc_sales_tax = \"$in{'sales_tax'}\";\n");
print (SETTINGS  "\$sc_sales_tax_state = \"$in{'sales_tax_state'}\";\n");
print (SETTINGS  "\$sc_send_order_to_email = \"$in{'email_orders_yes_no'}\";\n");
print (SETTINGS  "\$sc_order_log_name = \"$in{'name_of_the_log_file'}\";\n");
print (SETTINGS  "\$sc_send_order_to_log = \"$in{'log_orders_yes_no'}\";\n");
print (SETTINGS  "\$sc_order_email = \"$order_email\";\n");
print (SETTINGS  "\$sc_store_url = \"$in{'sc_store_url'}\";\n");
print (SETTINGS  "\$sc_admin_email = \"$admin_email\";\n");
print (SETTINGS  "\$sc_domain_name_for_cookie = \"$cookieDomain\";\n");
print (SETTINGS  "\$sc_path_for_cookie = \"$cookiePath\";\n");
print (SETTINGS  "\$URL_of_images_directory = \"$in{'URL_of_images_directory'}\";\n");
print (SETTINGS  "\$colorcode = \"$in{'colorcode'}\";\n");
print (SETTINGS  "\$sc_db_max_rows_returned = \"$in{'sc_db_max_rows_returned'}\";\n");
print (SETTINGS  "\$sc_user = \"$in{'user'}\";\n");
print (SETTINGS  "\$sc_pass = \"$in{'pass'}\";\n");
print (SETTINGS  "\$sc_layout = \"$in{'layout'}\";\n");
print (SETTINGS  "1\;\n");
close(SETTINGS);

&change_settings_screen;

}

#######################################################################################
sub action_gateway_settings

{
$gateway_settings = "../admin_files/gateway-user_lib.pl";
local($admin_email, $order_email);
&ReadParse;

$order_email = $in{'email_address_for_orders'}; 
$order_email =~ s/\@/\\@/;

$admin_email = $in{'admin_email'};
$admin_email =~ s/\@/\\@/;

if ($sc_gateway_name eq "Offline")
{
open (GATEWAY, "> $gateway_settings") || die "Can't Open $gateway_settings";
print (GATEWAY  "\$sc_order_script_url = \"$in{'order_url'}\";\n");
print (GATEWAY  "1\;\n");
close(GATEWAY);
}

elsif ($sc_gateway_name eq "gateway")
{
open (GATEWAY, "> $gateway_settings") || die "Can't Open $gateway_settings";
print (GATEWAY  "\$sc_gateway_username = \"$in{'sc_gateway_username'}\";\n");
print (GATEWAY  "\$sc_order_script_url = \"$in{'order_url'}\";\n");
print (GATEWAY  "\$mername = \"$in{'mername'}\";\n");
print (GATEWAY  "\$acceptcards = \"$in{'acceptcards'}\";\n");
print (GATEWAY  "\$acceptchecks = \"$in{'acceptchecks'}\";\n");
print (GATEWAY  "\$accepteft = \"$in{'accepteft'}\";\n");
print (GATEWAY  "\$altaddr = \"$in{'altaddr'}\";\n");
print (GATEWAY  "\$email_text = \"$in{'email_text'}\";\n");
print (GATEWAY  "1\;\n");
close(GATEWAY);
}

&gateway_settings_screen;

}



#######################################################################################
sub action_edit_category
{
	
local($sku2, $linkname, $displayname);

open (CHECKSKU, "$categoriesfile") || die "Can't Open $categoriesfile";

while(<CHECKSKU>)

	{

($sku2, $linkname, $displayname) = split(/\|/,$_);

chop($displayname);

foreach ($sku2) {

if ($sku2 eq $in{'EditWhichCategory'})
{
&display_perform_edit_category_screen;
}

# End of foreach
}
# End of while
}

}

#######################################################################################
#######################################################################################
sub action_edit_page
{
	
local($sku3, $pagename, $pagecontent);

open (CHECKSKU, "$pagesfile") || die "Can't Open $pagessfile";

while(<CHECKSKU>)

	{

($sku3, $pagename, $pagecontent) = split(/\|/,$_);

chop($pagecontent);

foreach ($sku3) {

if ($sku3 eq $in{'EditWhichPage'})
{
&display_perform_edit_page_screen;
}

# End of foreach
}
# End of while
}

}

#######################################################################################

1;