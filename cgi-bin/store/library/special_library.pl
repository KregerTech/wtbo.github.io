sub displayProductPage
{
local($keywords, $imageURL);
$keywords = $form_data{'keywords'};

$keywords =~ s/ /+/g;

open (PAGE, "html/html-templates/productPage.$sc_layout.inc") ||
&file_open_error("$sc_cart_path", "display_cart_contents", __FILE__, __LINE__);

while (<PAGE>)
{
$imageURL = $display_fields[0];
$imageURL =~ s/%%URLofImages%%/$URL_of_images_directory/g;

s/%%URLofImages%%/$URL_of_images_directory/g;

s/%%scriptURL%%/$sc_main_script_url/g;
s/%%cart_id%%/$cart_id/g;
s/%%product%%/$form_data{'product'}/g;
s/%%keywords%%/$keywords/g;

s/%%image%%/$imageURL/g;
s/%%name%%/$display_fields[1]/g;
s/%%description%%/$display_fields[2]/g;
s/%%optionFile%%/$display_fields[3]/g;
s/%%price%%/$display_fields[4]/g;
s/%%shippingPrice%%/$display_fields[5]/g;
s/%%userFieldOne%%/$display_fields[6]/g;
s/%%userFieldTwo%%/$display_fields[7]/g;
s/%%userFieldThree%%/$display_fields[8]/g;
s/%%userFieldFour%%/$display_fields[9]/g;
s/%%userFieldFive%%/$display_fields[10]/g;

s/%%itemID%%/item-$itemID/g;

print $_;
}

close PAGE;

}

###################################################################################

if ($form_data{'viewOrder'} eq "yes")
{
$sc_should_i_display_cart_after_purchase = "yes";
}
else
{
$sc_should_i_display_cart_after_purchase = "no";
}

1;