############################################################
#  
# subroutine: display_order_form
#   Usage:
#     &display_order_form
#
#   Parameters:
#     None. It outputs the HTML in $sc_html_order_form_path
#     specified in the setup file.
#
#   Output:
#     This routine merely outputs an HTML form with
#     cart specific information.
#
############################################################

sub display_order_form {
  
  local($line);
  local($subtotal);
  local($total_quantity);
  local($total_measured_quantity);
  local($text_of_cart);
  local($hidden_fields_for_cart);

                # Open the order form HTML file
                # 
                # If there is an error, report it to
                # the system and exit.

#&StoreHeader;

open (ORDERFORM, "$sc_html_order_form_path") ||
&file_open_error("$sc_html_order_form_path", "Display Order Form File Error",__FILE__,__LINE__);

                # The order form is read into
                # $line line by line.
                # 
                # This line is then parsed to see if
                # it should be display as-is or
                # if some piece of cart information
                # needs to display.
                # 
                # If the <FORM> tag is encountered,
                # then it is replaced with a form tag
                # generated based on values in the setup file
                # for the shopping cart script.
                # 
                # Hidden variables such as the page
                # we came from and the current cart_id are
                # passed to the process_order_form later on.

while (<ORDERFORM>) {

$line = $_;

# If we find the form tag, we 
# need to output the order form

if ($line =~ /<FORM/i) {

print qq!
</FORM>

<FORM METHOD = "post" ACTION = "$sc_order_script_url">
<INPUT TYPE = "hidden" NAME = "page" VALUE = "$form_data{'page'}">
<INPUT TYPE = "hidden" NAME = "cart_id" VALUE = "$form_data{'cart_id'}">\n!;

$line = "";

} # End of If Form tag found

		# If we found a tag stating
		# where the cart contents should
		# appear, then we process the 
		# cart and display it
		#
                # <H2> tags surrounding
                # a "cart contents" label
                # designates this state as being
                # true

if ($line =~ /<h2>cart.*contents.*h2>/i) {

                # So, we call the display_cart_table
                # routine and pass it "orderform" to
                # let it know to display order form
                # specific information

                # It returns subtotal
                # total quantity of items in the cart
                # total measured quantity of the measurement
                # field specified in the setup file, and
                # the ascii text of the cart (for logging
                # or emailing the order).

($subtotal, 
 $total_quantity,
 $total_measured_quantity,
 $text_of_cart) = &display_cart_table("orderform");      

$line = "";

}

                # Print the line (assuming it has
                # not change).

print $line;

} # End of Parsing Order Form

if ($sc_gateway_name = "Offline")
{
&StoreFooter;
}
else
{
&StoreFooter;
}
  
} # End of display_order_form

############################################################
#  
# subroutine: process_order_form
#   Usage:
#     &process_order_form()
#
#   Parameters:
#     None. This takes input from the form 
#     variables of the previously displayed
#     order form
#
#   Output:
#     The HTML for displaying the shipping, discount,
#     and sales tax calculations for the cart. The ascii 
#     text version of this is returned appended to
#     $text_of_cart.
#
#     The $text_of_cart along with the form fields that
#     the user submitted will be emailed and/or logged
#     to a file depending on variables in the setup file.
#
############################################################

sub process_order_form {
local($subtotal, $total_quantity,
      $total_measured_quantity,
      $text_of_cart,
      $required_fields_filled_in);

                # First, we output the header of
                # the processing of the order

#&StoreHeader;

                # We display the cart table.
                # This also has the effect of 
                # populating the text_of_cart
                # variable with the ASCII text version
                # of the cart for emailing/logging
                # the order that is being processed.

($subtotal, 
 $total_quantity,
 $total_measured_quantity,
 $text_of_cart) = 
 &display_cart_table("verify");      

                # Now that we have the text of the cart
                # all together. We check the required
                # form fields from the previous form
                # to see if they were filled in by the user
                # 
                # $required_fields_filled_in is set to "yes"
                # and remains this way until any ONE 
                # required field is missing -- at which
                # point it is set to no.

$required_fields_filled_in = "yes";

foreach $required_field (@sc_order_form_required_fields) {
if ($form_data{$required_field} eq "") {
    $required_fields_filled_in = "no";

$we_need_to_exit++;

print <<ENDOFTEXT;

<CENTER>
<HR>
<TABLE>
<TR>
<TD>
<FONT FACE=ARIAL COLOR=RED>
You forgot to fill in $sc_order_form_array{$required_field}.
</FONT>
</TD>
</TR>
</TABLE>
</CENTER>

ENDOFTEXT
  }

} 

# End of checking required fields

if ($we_need_to_exit > 0)
{
&StoreFooter;
exit;
}

                # Since the required fields were
                # filled in correctly, we process
                # the rest of the order

if ($required_fields_filled_in eq "yes") {

                # The $text_of_cart is appended with all
                # the values for the form that the user
                # has entered into the system.

  foreach $form_field (sort(keys(%sc_order_form_array))) {
    $text_of_cart .= 
      &format_text_field($sc_order_form_array{$form_field})
      . "= $form_data{$form_field}\n";
  }
  $text_of_cart .= "\n";

                # If PGP (Pretty Good Privacy) is in
                # use, then we translate the text of the
                # cart to a PGP encrypted form using
                # the pgp-lib.pl file that we provided
                # with the web_store.

if ($sc_use_pgp =~ /yes/i) {
    &require_supporting_libraries(__FILE__, __LINE__,
    "$sc_pgp_lib_path");

$text_of_cart = &make_pgp_file($text_of_cart,
               "$sc_pgp_temp_file_path/$$.pgp");
$text_of_cart = "\n" . $text_of_cart . "\n";

  }

&printSubmitPage;

} else {
                # The user is notified if the order
                # was not a success (not all required
                # fields were filled in).

print <<ENDOFTEXT;

<CENTER>
<HR>
<TABLE>
<TR>
<TD>
<FONT FACE=ARIAL>
I'm sorry, but there seems to be a problem with your order. Please check the order 
form, verify your information, and try submitting the order again.</FONT>
</TD>
</TR>
</TABLE>
<HR>
<CENTER>  

ENDOFTEXT

} 

&StoreFooter;

print qq!
</BODY>
</HTML>
!;

} # End of process_order_form

############################################################
#  
# subroutine: calculate_final_values
#   Usage:
#         ($final_shipping,
#          $final_discount,
#          $final_sales_tax,$grand_total) =
#    &calculate_final_values($subtotal,
#                       $total_quantity,
#                       $total_measured_quantity,
#                       $are_we_before_or_at_process_form);
#
#   Parameters:
#     $subtotal = the current cart subtotal
#     $totalquantity = the total quantity of items in
#        in the cart
#     $total_measured_quantity = the total quantity
#        of whatever field you want to measure in the
#        the cart (as specified in the setup file)
#     $are_we_before_or_at_process_form = values
#       ("before" or "at") -- This indicates which
#       calculations to support based on the setup
#       file
#
#   Output:
#     $final_shipping = final value of shipping
#     $final_discount = final value of discount
#     $final_sales_tax = final sales tax
#     $grand_total = new grand total now that the
#       above items have been calculated
#
############################################################

sub calculate_final_values {

local($upgradeShipPrice, $shipMethod) = split (/\|/,$form_data{upgradeShipping});

local($subtotal,
      $total_quantity,
      $total_measured_quantity,
      $are_we_before_or_at_process_form) = @_;
local($temp_total) = 0;
local($grand_total) = 0;
local($final_shipping, $shipping);
local($final_discount, $discount);
local($final_sales_tax, $sales_tax);
local($calc_loop) = 0;

                # $temp_total is initialized to
                # the subtotal. This temp total
                # will be updated after each calculation
                # cycle in order to form the final grand total

$temp_total = $subtotal;

                # We got through THREE cycles of
                # calculation. Why? Because we have
                # THREE things to calculate:
                # 
                #  shipping
                #  discount
                #  sales tax
                # 
                # The simplest thing is to calculate
                # all of these at once on the subtotal.
                # 
                # However, your logic may not work that way.
                # 
                # You may want one or more of these calculations
                # calculated and applied to the subtotal before
                # another calculation so that the next calculation
                # is based off of a larger subtotal amount.
                # 
                # Thus, in the setup file there are variables
                # that you can set for the above calculations to
                # let the system know which order you want to use
                # in calculating the values.

for (1..3) {

                # At the beginning of the loop, we
                # set the calculated values to 0.

$shipping = 0;
$discount = 0;
$sales_tax = 0;
$calc_loop = $_;

                # The calculation logic may also
                # be different depending on whether we
                # are at the actual form where the
                # order is being processed.
                # 
                # OR
                # 
                # Whether we are at the form that
                # the user needs to enter data into
                # (such as state or shipping type).
                # 
                # For example, you may not be able
                # to provide the user an estimate of sales
                # tax until you learn what state they are
                # in. So you should only calculate this
                # value at the process order form instead of
                # the initial display of the order form.

if ($are_we_before_or_at_process_form =~ /before/i)
{

                # Each of the items is calculated

if ($sc_calculate_discount_at_display_form ==
    $calc_loop) {
    $discount = 
    &calculate_discount($temp_total,
    $total_quantity,
    $total_measured_quantity);
    } # End of if discount gets calculated here

if ($sc_calculate_shipping_at_display_form ==
    $calc_loop) {
    $shipping = &define_shipping_logic($total_measured_quantity);
    } # End of shipping calculations

if ($sc_calculate_sales_tax_at_display_form ==
    $calc_loop) {
    $sales_tax = 
    &calculate_sales_tax($temp_total);
   } # End of sales tax calculations

                # The else handles the case of 
                # whether we are at the process order
                # form
   } else {

if ($sc_calculate_discount_at_process_form ==
    $calc_loop) {
    $discount = 
    &calculate_discount($temp_total,
    $total_quantity,
    $total_measured_quantity);
    } # End of if discount gets calculated here

if ($sc_calculate_shipping_at_process_form ==
    $calc_loop) {
    $shipping = &define_shipping_logic($total_measured_quantity);
   } # End of shipping calculations

if ($sc_calculate_sales_tax_at_process_form ==
    $calc_loop) {
    $sales_tax = 
    &calculate_sales_tax($temp_total);
   } # End of sales tax calculations
} # End of if we are before or at process order form

                # Finally, for THIS CYCLE ONLY, we 
                # calculate the new temp_total.
                # 
                # We also assign the final discount
                # shipping, and sales tax values because
                # they might not be calculated again
                # in the next cycle.

$final_discount = $discount if ($discount > 0);
$final_shipping = $shipping if ($shipping > 0);
#$final_shipping += ($final_shipping*($upgradeShipPrice/100));
$final_sales_tax = $sales_tax if ($sales_tax > 0);
$temp_total = $temp_total - $discount + $shipping + $sales_tax;
} # End of $calc_loop

                # The grand total becomes the final temp 
                # total after the routine has been processed

$grand_total = $temp_total;

                # We return the main values that we calculated

return ($final_shipping,
        $final_discount,
        $final_sales_tax,
        &format_price($grand_total));

} # calculate_totals

############################################################
#  
# subroutine: calculate_shipping
#   Usage:
#        $shipping = 
#          &calculate_shipping($sub_total,
#            $total_quantity,
#            $total_measured_quantity);
#
#   Parameters:
#     $sub_total = the subtotal to calculate shipping on
#     $total_quantity = quantity of items to calc shipping on
#     $total_measured_quantity = quanity of measured item to
#                                calc shipping on
#
#   Output:
#     The value of the shipping
#
############################################################

sub calculate_shipping {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity) = @_;

                # This routine calls the calculate
                # general logic subroutine
                # by passing it a reference to the
                # shipping logic and order form
                # shipping related fields variable

  return(&calculate_general_logic(
           $subtotal,
           $total_quantity,
           $total_measured_quantity,
           *sc_shipping_logic,
           *sc_order_form_shipping_related_fields));

} # End of calculate_shipping

############################################################
#  
# subroutine: calculate_discount
#   Usage:
#        $discount = 
#          &calculate_shipping($sub_total,
#            $total_quantity,
#            $total_measured_quantity);
#
#   Parameters:
#     $sub_total = the subtotal to calculate discount on
#     $total_quantity = quantity of items to calc discount on
#     $total_measured_quantity = quanity of measured item to
#                                calc discount on
#
#   Output:
#     The value of the discount
#
############################################################

sub calculate_discount {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity) = @_;

                # This routine calls the calculate
                # general logic subroutine
                # by passing it a reference to the
                # discount logic and order form
                # discount related fields variable

  return(&calculate_general_logic(
           $subtotal,
           $total_quantity,
           $total_measured_quantity,
           *sc_discount_logic,
           *sc_order_form_discount_related_fields));

} # End of calculate_discount

############################################################
#  
# subroutine: calculate_general_logic
#   Usage:
#  $general_value = &calculate_general_logic(
#           $subtotal,
#           $total_quantity,
#           $total_measured_quantity,
#           *general_logic,
#           *general_related_form_fields);
#
#   Parameters:
#     $sub_total = the subtotal to calculateon
#     $total_quantity = quantity of items to calc on
#     $total_measured_quantity = quanity of measured item to
#                                calc on
#     *general_logic = a reference to an array in the 
#       setup file which defines the logic to calculate
#       the discount or shipping with.
#     *general_related_form_fields = a reference to
#       an array in the setup file which defines what form
#       fields from the order form possibly affect the
#       calculation.
#
#   Output:
#     The final value of the calculation
#
############################################################

sub calculate_general_logic {
  local($subtotal,
        $total_quantity,
        $total_measured_quantity,
        *general_logic,
        *general_related_form_fields) = @_;

  local($general_value);

  local($x, $count);
  local($logic);
  local($criteria_satisfied);
  local(@fields);

                # The @related_form_values
                # array contains the values of the
                # form fields specified in the
                # @general_related_form_fields
                # array.

  local(@related_form_values) = ();
  
                # The form values are assigned
$count = 0;

foreach $x (@general_related_form_fields) {

$related_form_values [$count] = $form_data{$x};
$count++;

}


                # Sample Shipping Logic Appears Below
                # 
                #  @sc_shipping_logic =
                #    ("ups|20814-20855||100.00-200.00||10%",
                #     "ups|20814-20855||200.01-500.00||20%");
                #   foreach $logic (@general_logic) {
                #  

foreach $logic (@general_logic) {

                # First, we start off assuming the criteria
                # is satisfied until it is not.
                # 

$criteria_satisfied = "yes";

                # 
                # The definition of the logic being checked
                # is split out of the $logic variable --
                # the logic is pipe delimited
                # 

@fields = split(/\|/, $logic);  

                #
		    # First, we go through the form
		    # variables to see if the criteria matches
		    #
                # Recall that in the setup file discussion
                # we stated that the first part of the criteria
                # the is examined are the related form values
                # 

    for (1..@related_form_values) {
      if (!(&compare_logic_values(
            $related_form_values[$_ - 1],
            $fields[$_ - 1]))) {
            $criteria_satisfied = "no";
      }
    } # End of loop through form values

		# We shift off the @fields
		# that we have already checked
		#

    for (1..@related_form_values) {
      shift(@fields);
    }

		# Now, we are ready to deal with
		# comparing the general logic with
		# the totals (subtotal, quantity
		# total, measured total)
		#
		# The next field is the subtotal 
		# range to compare against
		#

    if (!(&compare_logic_values(
          $subtotal,
          $fields[0]))) {
          $criteria_satisfied = "no";
    }
                # Shift off the subtotal

    shift (@fields);

		# The next field is the quantity
		# range to compare against

    if (!(&compare_logic_values(
          $total_quantity,
          $fields[0]))) {
          $criteria_satisfied = "no";
    }
                # Shift off the quantity

    shift (@fields);

		# The next field is the subtotal 
		# range to compare against

    if (!(&compare_logic_values(
          $total_measured_quantity,
          $fields[0]))) {
       $criteria_satisfied = "no";
    }

           # Shift off the fields

    shift (@fields);

		# Finally, the last field of $logic is the
		# general value to apply, if
		# all the criteria was
		# satisified.

    if ($criteria_satisfied eq "yes") {

		# If the last field is a percentage
		# then we make the general value a percentage
		# of the subtotal
		# 
		# otherwise, we just make the general value
		# equal to that field.

    if ($fields[0] =~ /%/) {
        $fields[0] =~ s/%//;
        $general_value = $subtotal * $fields[0] / 100;
      } else {
        $general_value = $fields[0];
      }
    }

    
  } # End of foreach loop through shipping logic

                # We simply return the formatted value
                # of the calculated general value

  return(&format_price($general_value));

} # End of calculate_general_logic

############################################################
#  
# subroutine: calculate_sales_tax
#   Usage:
#        $sales_tax = 
#          &calculate_sales_tax($sub_total);
#
#   Parameters:
#     $sub_total = the subtotal to calculate sales tax on
#
#   Output:
#     The value of the sales tax
############################################################

sub calculate_sales_tax {
  local($subtotal) = @_;
  local($sales_tax) = 0;

                # If the sales tax is dependant on
                # a form variable, then
                # we check the value of that form
                # variable against the possible values
                # that have been designated in the
                # @sc_sales_tax_form_variable array.
                # 
                # A match results in the sales tax
                # being calculated.

  if ($sc_sales_tax_form_variable ne "") {
    foreach $value (@sc_sales_tax_form_values) {
      if (($value =~ 
          /^$form_data{$sc_sales_tax_form_variable}$/i) &&
         ($form_data{$sc_sales_tax_form_variable} ne ""))  {
        $sales_tax = $subtotal * $sc_sales_tax;
      }
    }
                # If it is not form variable
                # dependant, then the sales tax is
                # always calculated

  } else {
    $sales_tax = $subtotal * $sc_sales_tax;
  }
                # We return the sales tax already
                # in a preformatted form.

  return (&format_price($sales_tax));

} # End of calculate sales tax

############################################################
#  
# subroutine: compare_logic_values
#   Usage:
#        $boolean_value = 
#          &calculate_logic_values($input_value,
#                                  $value_to_compare);
#
#   Parameters:
#     $input_value = the value we are performing the
#        logic on.
#     $value_to_compare = the logical value. This can also
#        be a RANGE (indicated with a hyphen). The range
#        can also be open-ended (eg 1-,-5, etc...)
#
#   Output:
#     $boolean_value = 1 if true, 0 if false compare
############################################################

sub compare_logic_values {
  local($input_value, $value_to_compare) = @_;
  local($lowrange, $highrange);

                # Case 1, The value is a RANGE of values separated
                # by hypens. So do a range compare

if ($value_to_compare =~ /-/) {

                # We split the low and high range by the
                # hyphen

    ($lowrange, $highrange) = split(/-/, $value_to_compare);

                # If the lowrange does not have a value,
                # it means that the range is open ended, so
                # we assume the high range was entered and only
                # compare that. (eg -10).

    if ($lowrange eq "") {
      if ($input_value <= $highrange) {
        return(1);
      } else {
        return(0);
      }

                # If the highrange does not have a value,
                # it means that the range is open ended, so
                # we assume the low range was entered and
                # only compare that. (eg 5-).

    } elsif ($highrange eq "") {
      if ($input_value >= $lowrange) {
        return(1);
      } else {
        return(0);
      }

                # Otherwise, we fall through here
                # and compare both the low and high range.

    } else {
      if (($input_value >= $lowrange) &&
         ($input_value <= $highrange)) {
        return(1);
      } else {
        return(0);
      }
    }

                # Case 2, the value is straight. So do a 
                # normal pattern match, case insensitive
                # direct comparison

  } else {
    if (($input_value =~ /$value_to_compare/i) ||
        ($value_to_compare eq "")) {
      return(1);
    } else {
      return(0);
    }
  }
} # End of compare_logic_values

1;