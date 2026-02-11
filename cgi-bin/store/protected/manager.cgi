#!/usr/bin/perl -T

############################################################
# Patch applied 11/24/98 - Fixes a bug where the           #
# script didn't exit properly                              #
############################################################
# Choose a user name and password here...please change the # 
# defaults!!!!!!!                                          #
############################################################

$username="admin";
$password="admin";

##################################################################
# Pick a unique name for this value with at least 8 characters   #
##################################################################

$a_unique_name="thisisunique";

##################################################################
# Do not edit below this line                                    #
##################################################################

require "./../library/cgi-lib.pl";
require "./../library/commerce.setup.db";
require "./../library/store_admin_html.pl";
require "./../library/store_admin_actions.pl";
require "./../admin_files/commerce_user_lib.pl";
$pagesfile = "../admin_files/pages_lib.data";
$categoriesfile = "../admin_files/categories_lib.data";
$datafile = "../data_files/data.file";
$ip_file = "./files/$a_unique_name.pl";
$username="$sc_user";
$password="$sc_pass";

# Read in form data

&ReadParse($in, $in_name, $in_type, $in_server_name);

# Send header to keep browser happy

print "Content-type: text/html\n\n";

if ($in{'login'} ne "") 
{
&action_process_login;
}

# Check to see if login file is too old

if (-M "$ip_file" > ".15")
{
&display_login;
exit;
}

# End login file check

# If the login file exists, require it and check to see that 
# ip of the client is the same as the ip set in the file,
# otherwise, return an error

if (-e "$ip_file")
{
	require "$ip_file";
	if ($ok_ip ne $ENV{'REMOTE_ADDR'})
	{
	&display_login;
	exit;
	}
} 

# If the login file doesn't exist, you better log in

else
{
&display_login;
exit;
}

# Display Screen Logic

if ($in{'welcome_screen'} ne "")
{
&show_welcome_screen;
exit;
}

if ($in{'display_screen'} ne "") 
{
&display_catalog_screen;
exit;
}

if ($in{'add_screen'} ne "") 
{
&add_product_screen;
exit;
}

if ($in{'edit_screen'} ne "") 
{
&edit_product_screen;
exit;
}

if ($in{'edit_page_screen'} ne "") 
{
&edit_page_screen;
exit;
}

if ($in{'edit_categories_screen'} ne "") 
{
&edit_categories_screen;
exit;
}

if ($in{'hide_screen'} ne "") 
{
&hide_product_screen;
exit;
}

if ($in{'delete_screen'} ne "") 
{
&delete_product_screen;
exit;
}

if ($in{'change_settings_screen'} ne "") 
{
&change_settings_screen;
exit;
}

if ($in{'gateway_screen'} ne "") 
{
&gateway_settings_screen;
exit;
}

if ($in{'change_password_screen'} ne "") 
{
&change_password_screen;
exit;
}


## End Of Display Screen Logic

## Admin Action Logic

if ($in{'AddProduct'} ne "")
{
&action_add_product;
exit;
}

if ($in{'EditProduct'} ne "")
{
&action_edit_product;
exit;
}

if ($in{'SubmitEditProduct'} ne "")
{
&action_submit_edit_product;
exit;
}

if ($in{'EditPage'} ne "")
{
&action_edit_page;
exit;
}

if ($in{'SubmitEditPage'} ne "")
{
&action_submit_edit_page;
exit;
}

if ($in{'EditCategory'} ne "")
{
&action_edit_category;
exit;
}

if ($in{'SubmitEditCategory'} ne "")
{
&action_submit_edit_category;
exit;
}

if ($in{'DeleteProduct'} ne "")
{
&action_delete_product;
exit;
}

if ($in{'ChangeSettings'} ne "")
{
&action_change_settings;
exit;
}

if ($in{'ChangePasswordSettings'} ne "")
{
&action_change_password_settings;
exit;
}

if ($in{'GatewaySettings'} ne "")
{
&action_gateway_settings;
exit;
}



## End Admin Action Logic

