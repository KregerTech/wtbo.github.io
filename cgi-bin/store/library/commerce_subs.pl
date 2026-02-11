###########################################################################################
sub SetCookies
{

$cookie{'cart_id'} = "$cart_id";

# Set the domain to be correct for your domain

$domain = $sc_domain_name_for_cookie;
$secureDomain = $sc_secure_domain_name_for_cookie;

# The path to your 'store' directory

$path = $sc_path_for_cookie;
$securePath = $sc_secure_path_for_cookie;

# Leave this as is.

$secure = "";

# Cookie will expire in 24 hours

$now = time;

# Second in twenty four hours

$twenty_four_hours = "86400";

$expiration = $now+$twenty_four_hours;#number of days until cookie expires


if(!$form_data{'secure'})
{
&set_cookie($expiration,$domain,$path,$secure);
}
else
{
&set_cookie($expiration,$secureDomain,$securePath,$secure);
}

} 

############################################################################################

sub StoreHeader
{

local($reason_to_display_cart) = @_;
local(@cart_fields);
local($cart_id_number);
local($quantity);
local($unformatted_subtotal);
local($subtotal);
local($unformatted_grand_total);
local($grand_total);
local($price);
local($price2);
local($text_of_cart);
local($total_quantity) = 0;
local($total_measured_quantity) = 0;
local($display_index);
local($counter);
local($hidden_field_name);
local($hidden_field_value);
local($display_counter);
local($product_id, @db_row);
open (CART, "$sc_cart_path");

while (<CART>)
{
chop;    
@cart_fields = split (/\|/, $_);
$cart_row_number = pop(@cart_fields);
push (@cart_fields, $cart_row_number);
$quantity = $cart_fields[0];
$product_id = $cart_fields[1];
$total_quantity += $quantity;
$display_counter = 0;
$unformatted_subtotal = ($cart_fields[$sc_cart_index_of_price_after_options]);
$subtotal = &format_price($cart_fields[0]*$unformatted_subtotal);
$unformatted_grand_total = $grand_total + $subtotal;
$grand_total = &format_price($unformatted_grand_total);

}
# End of while (<CART>)

close (CART);
if($grand_total ne "")
{
$price2 = &display_price($grand_total);
}
else
{
$price2 = "\$ 0.00";
}

$categoriesfile2 = "admin_files/categories_lib.data";
open (CHECKSKU, "$categoriesfile2") || die "Can't Open $categoriesfile2";

while(<CHECKSKU>)

{
chop;
$catrow=$_;
@cats = split(/\|/,$catrow);

if ($cats[2] ne "") {

$insertcategories  .= "&nbsp;<a href=merchant.cgi?product=$cats[1]&cart_id=$cart_id>$cats[2]</a>\n<br> \n";

}

}
$insertcategories2 = "$insertcategories";

open (HEADER, "$sc_store_header_file");

while (<HEADER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;
s/%%colorcode%%/$colorcode/g;
s/%%cart_id%%/$cart_id/g;
s/%%mername%%/$mername/g;
s/%%price%%/$price2/g;
s/%%insertcategories%%/$insertcategories2/g;
s/%%webURL%%/$webURL/g;
print $_;
}
close (HEADER);

}

############################################################################################

sub StoreFooter
{

&specials;

open (FOOTER, "$sc_store_footer_file");

while (<FOOTER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;
s/%%cart_id%%/$cart_id/g;
s/%%colorcode%%/$colorcode/g;
s/%%mername%%/$mername/g;
s/%%specials%%/$speciallinks/g;
print $_;
}

close (FOOTER);
}

############################################################################################

sub SecureStoreHeader
{
open (SECUREHEADER, "$sc_secure_store_header_file");

while (<SECUREHEADER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;
s/%%cart_id%%/$cart_id/g;
print $_;
}
close (SECUREHEADER);

}

############################################################################################

sub SecureStoreFooter
{
open (SECUREFOOTER, "$sc_secure_store_footer_file");

while (<SECUREFOOTER>)
{
s/%%URLofImages%%/$URL_of_images_directory/g;
s/%%cart_id%%/$cart_id/g;
print $_;
}

close (SECUREFOOTER);
}

############################################################################################

sub define_shipping_logic

{

local ($shipping_price) = @_;
local($upgradeShipLevel, $shipMethod) = split (/\|/,$form_data{upgradeShipping});

# The values defined in this array each represent a percentage
# of the base shipping price. On your orderform, you'll notice code
# like this:
# <SELECT NAME="upgradeShipping">
# <OPTION VALUE="">Please Make Your Selection</OPTION>
# <OPTION VALUE="1|Ground Shipping">Regular Ground</OPTION>
# <OPTION VALUE="2|U.P.S. Two Day - Upgrade">Two Day - Upgrade</OPTION>
# <OPTION VALUE="3|U.P.S. Overnight - Upgrade">U.P.S. Overnight - Upgrade</OPTION>
# </SELECT>
# Each of the values defined on the left of the | symbol 
# correspond to a value below. 

@upgradeShipPrice = (0, 5, 10, 15, 20);

$shipping_price += ($shipping_price*($upgradeShipPrice[$upgradeShipLevel]/100));
return $shipping_price;

}
1;