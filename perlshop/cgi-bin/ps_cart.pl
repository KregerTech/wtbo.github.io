
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 shopping cart display subroutines
#
# Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin
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


sub GenerateOrderForm
{
	# Are we paying by credit card and are using real-time credit card processing?
	# Are we using PayPal Web Accept?
	# Are we paying by electronic check?
	if (((lc $online_credit_verify ne 'no') and ($Payby =~ /^credit/i)) or
	    ((lc $Payby eq 'paypal') and (lc $paypal_web_accept eq 'yes')) or
	    ((lc $online_check_verify ne 'no') and (lc $Payby eq 'virtual check')))
	{
		# Include Perlshop real-time result processing library
		LoadLibrary('ps_transact.pl');

		GenerateOnlineOrderForm();	
	}

	# Generate the standard Perlshop order form
	else
	{
		print qq(
<form name="placeorderForm" method=$form_submission_method target="_top"
	onSubmit="return PlaceSubmitCheck()"
	action="$checkout_url">
<input type=hidden name="ORDER_ID" value="$unique_id">
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);
	}

	# Add in redirection data, if needed
	print qq(
<input type=hidden name="redirect_url" value="$redirect_decoded">
) if ($input{'REDIRECT_URL'} ne '');

	AddButton('PLACE ORDER', $suppressAction);

	# Close the order form
	print qq(
</form>
</td>
);
}


sub DisplayCartContents
{
	my $updateImage = '';
	my $colspan;
	my $col_width;
	my $i;
	my $qtylen;
	my $oid;
	my $exp_mon_txt;
	my $exp_yr_2000;
	my $phone;
	my $area_code;
	my $prefix;
	my $suffix;
	my $rebate_cur;
	my $item_total_currency;
	my $adjustable = 0;
	my $image_file;
	my $item_note;
	my $discount_text;

	check_if_orders_exist();
	
	# Do we already have a customer file?
	if (-e $customer_file_name)
	{   	
		# Call any cart view related plugins
		ExecutePlugins('before_view_checkout_cart', $unique_id);

		# Open customer data file
		open(customer_file, "$customer_file_name") || 
			error_trap("Cannot open $customer_file_name for reading : $!\n");

		# Read in data from customer file
		$customer_data = <customer_file>;
		chop($customer_data);

		# Break data up into component parts
		($unused,
		 $id, $ip, $date, $time, $title, $first, $last, $company, 
		 $street1, $street2, $city, $state, $zip, $country, 
		 $email, $dphone, $dexten, $nphone, $nexten, $fax, $Shiptype, $Payby, 
		 $card_type, $card_no, $exp_mon, $exp_yr, $source, $suggest, $FVpin,

		 $ship_same, $ship_title, $ship_first, $ship_last, $ship_company, 
		 $ship_street1, $ship_street2, $ship_city, $ship_state, 
		 $ship_zip, $ship_country,

		 $unused) = split(/^"|"$delim"|"$/, $customer_data);

		# Check for error
		if (($ip ne $ENV{'REMOTE_ADDR'}) && ($resuming_order != 1) &&
			$confirm_customer_ip)
		{
			Transmission_error(5, qq(
<p>
Inconsistancy detected during cart display.<br>
<p>
Original customer IP was $ip.<br>
Current customer IP is $ENV{'REMOTE_ADDR'}.<br>
));
		}
	}

	else
	{
		# Call any cart view related plugins
		ExecutePlugins('before_view_simple_cart', $unique_id);
	}

	$order_total = 0; 	
	$item_num = 1;	

	if ($add_cart != 1) 
	{
		PageHeader($page_title{$action}, 'ps_utilities.js');
		add_menu_bar('CONTINUE SHOPPING');
		add_company_header();
	}

	# Load order data from order file into internal array
	LoadOrders();

	print qq(
<br clear=all>
<div align="center">
<hr width="75%"><br>

<table bgcolor="white" border=0>
<tr><td align="center">
<b>
<font color="red">Please examine the following CAREFULLY.</font><br>
Your order has <font color="red">NOT</font> been confirmed.
<p>
When you are satisfied with your order, please follow the <br>
instructions at the bottom of this page to complete your purchase.
</p>
</b>
</td></tr>
</table>

);

	if (-e $customer_file_name)
	{
		ExecutePlugins('before_checkout_cart_contents', $unique_id);
	}

	else
	{
		ExecutePlugins('before_simple_cart_contents', $unique_id);
	}

	# Begin display of the shopping cart contents
	print qq(
<p>
<span style="background-color:white"><b>$cart_view_message</b></span><br>

<form name="updateForm" method=$form_submission_method 
	action="http://$cgi_prog_location">
<table border=1 bgcolor="white" cellspacing=3 cellpadding=3 width="75%">
);

	# Display the table caption if we have one
	print qq(<caption>$cart_content_caption</caption>\n)
		unless $cart_content_caption eq '';

	$colspan = 3; 

	# Start the row of column labels
	print qq(<tr class="cartHeaderRow">\n);

	# Display the label for custom column 1, if defined
	if (lc $thumbnail_image_in_cart eq 'yes')
	{
		print qq(<th>Item</th>\n);
		$colspan++;
	}

	# Display the Product ID column label if requested
	if (lc $product_id_in_cart eq 'yes')
	{
		print qq(<th>Product ID</th>\n);
		$colspan++;
	}

	# Display the Product Name column label
	print qq(<th>Product Name</th>\n);

	if ($option1_caption ne '')
	{
		print qq(<th>$option1_caption</th>);
		$colspan++;
	}

	if ($option2_caption ne '')
	{
		print qq(<th>$option2_caption</th>);
		$colspan++;
	}

	if ($option3_caption ne '')
	{
		print qq(<th>$option3_caption</th>);
		$colspan++;
	}

	if ($weight_caption ne '')
	{
		print qq(<th>$weight_caption ($local_weight)</th>);
		$colspan++;
	}

	print qq(
<th>Unit Price</th>
<th>Qty</th>
<th>Item Total</th>
</tr>
);

	$col_width = $colspan;


# First display taxable items, then other taxtype (e.g. non-taxable) items
foreach $taxtype (@taxtypes) 
{
	if ($#orders > 0) 
	{
		if ($taxtype eq '' && $#taxtypes > 0) 
		{
			$col_width = $colspan + 1;
			print qq(
<tr class="cartTaxRow">
<td colspan=$col_width align=center>** Taxable Items **</td>
</tr>
);
		}

		elsif ($taxtype eq 'none')
		{
			$col_width = $colspan + 1;
			print qq(
<tr class="cartTaxRow">
<td colspan=$col_width align=center>** NON Taxable Items **</td>
</tr>
);
		}

		elsif ($taxtype ne '')
		{
			$col_width = $colspan + 1;
			print "<tr><td colspan=$col_width align=center>** $taxtype Tax Items **</td></tr>\n";
		}
	}

	$sub_total = 0;

	LOOP: foreach $i (0 .. $#orders) 
	{
		($order_id, $item_id, $item_name, $price, $quantity, $weight, 
		 $item_taxtype, $option1, $option2, $option3,
		 $qty_min, $qty_max, $item_shiptype) = @{$orders[$i]};
	
		next LOOP if (lc $item_taxtype ne $taxtype);

		print qq(
<input type=hidden name=ITEM_ID$item_num value="$item_id">
<input type=hidden name=ITEM_NAME$item_num value="$item_name">
<input type=hidden name=ITEM_OPTION1$item_num value="$option1">	
<input type=hidden name=ITEM_OPTION2$item_num value="$option2">	
<input type=hidden name=ITEM_OPTION3$item_num value="$option3">	
<input type=hidden name=QTY_MIN$item_num value="$qty_min">	
<input type=hidden name=QTY_MAX$item_num value="$qty_max">	

<tr class="cartItemRow" align="right">
);
	
		$item_total = $price * $quantity;
		$sub_total = $sub_total + $item_total;
		$item_total_currency = Currency($item_total);
		$price = Currency($price);


		# Item image column
		if (lc $thumbnail_image_in_cart eq 'yes')
		{
			# Open the column
			print qq(<td valign="top" align="left">\n);

			foreach my $suffix ('jpg', 'gif', 'png')
			{
				# Create the image file name from the Product ID
				$image_file = "$item_id.$suffix";
				$image_file =~ s/\s//g;

				#print "Testing: $thumbnail_directory/$image_file<br>\n";
				
				# Does the thumbnail image exist?
				if (-e "$thumbnail_directory/$image_file")
				{
					# Create the HTML image tag for the thumbnail
					print qq(<img src="$image_location$thumbnail_subdirectory/$image_file">);
					last;
				}
			}

			# Close the column
			print qq(<br></td>\n);
		}


		# Item ID column
		print qq(<td valign="top" align="left">$item_id</td>\n)
			if (lc $product_id_in_cart eq 'yes');


		# Item Name column
		print qq(<td valign="top" align="left">$item_name);

		# Add free shipping text if needed
		print "<br>\n<em><small>$free_shipping_message</small></em>"
			if lc $item_shiptype eq 'free';

		# Add product note if needed
		$item_note = ExecutePlugins('item_note', $unique_id, $item_id);
		print "<br>\n$item_note"
			unless $item_note eq '';

		print "</td>\n";


		# Option 1, if used
		if ($option1_caption ne '')
		{
			if ($option1 eq '')
				{print "<td>&nbsp</td>\n";}	
			else			
				{print qq(<td valign="top" align="left">$option1</td>\n);}
		}

		# Option 2, if used
		if ($option2_caption ne '')
		{
			if ($option2 eq '')
				{print "<td>&nbsp</td>\n";}	
			else			
				{print qq(<td valign="top" align="left">$option2</td>\n);}
		}

		# Option 3, if used
		if ($option3_caption ne '')
		{
			if ($option3 eq '')
				{print "<td>&nbsp</td>\n";}	
			else			
				{print qq(<td valign="top" align="left">$option3</td>\n);}
		}

		# Weight column, if used
		print qq(<td valign="top" align=right>$weight</td>\n)
			unless ($weight_caption eq '');

		# Price column
		print qq(<td valign="top">$price</td>\n);

		$qtylen = ((lc $allow_fractional_qty eq 'yes') ? 6 : 3);

		# Special case used to disable quantity box
		if ($qty_max == $qty_min)
		{
			print qq(
<td valign="top">
<input type=hidden name=QTY$item_num value=$quantity>$quantity </td>
<td valign="top">$item_total_currency</td>

</tr>
);
		}

		else
		{
			print qq(
<td valign="top">
<input type=text name=QTY$item_num size=$qtylen MaxLength=$qtylen 
	value=$quantity></td>
<td valign="top">$item_total_currency</td>

</tr>
);
			$adjustable++;
		}

		$item_num++;
	} # For each order detail
	
	$sub_tot = Currency($sub_total);

	print qq(
<tr class="cartSubtotalRow" align="right">
<td colspan=$colspan valign="top">Item Total: </td>
<td>$sub_tot<br>
<p>
);

	# Add the redirection data, if needed
	if ($input{'REDIRECT_URL'} ne '')
	{
		print qq(
<input type=hidden name="redirect_url" value="$redirect_decoded">
);
	}

	AddButton('UPDATE')
		if $adjustable > 0;

	print qq(
</td>
</tr>
);
		
	if (calculate_discount() != 0) 
	{
		$discount_text = ($discount_type eq 'plugin')
							? 'Discount Total: '
							: "Discount of $disc_rate%: ";

		print qq(
<tr align=right>
<td colspan=$colspan class="discountRow">$discount_text</td>
<td>$discount_currency</td>
</tr>
);
		$sub_tot = Currency($discount_total);
		print qq(
<tr class="cartSubtotalRow" align=right>
<td colspan=$colspan>Sub Total: </td>
<td>$sub_tot</td>
</tr>
);
	}

	##customer file exists and has been opened.  				
	if (-e $customer_file_name)
	{
		if (calculate_tax() > 0) 
		{
			print qq(
<tr align="right">
<td colspan=$colspan>$state Tax at $Tax_Rate%: </td>
<td>$tax_currency</td>
</tr>
);
		}

		if (($#taxtypes > 0) && ($tax_total > 0))
		{
			$tax_tot = Currency($tax_total);
			print qq(
<tr align="right">
<td class="cartSubtotalRow" colspan=$colspan>Sub Total: </td>
<td>$tax_tot</td>
</tr>
);
		}
	}
	
} # For each $taxtype

	# Do we already have a customer data file ?
	# If so, the customer has already filled in their order form.
	if (-e $customer_file_name) 
	{			
		$shipping_message = '';
		if ($country_uc eq 'OTHER')
		{
			$shipping_message .= qq(
<br>
Shipping rates for locations outside the United States vary widely.<br>
We will contact you with your final total, including shipping fee.<br>
);
		}

		if (calculate_shipping('after_compute_cart') > 0)
		{
			print qq(
<tr align="right">
<td colspan="$colspan">Shipping: $shipping_message</td>
<td>$shipping_currency</td>
</tr>
);
		}

		if ($Payby eq 'COD') 			
		{
			print qq(
<tr align="right">
<td colspan="$colspan">COD Charge: </td>
<td>$cod_currency</td>
</tr>
);
		}

		if ($Handling > 0)
		{
			print qq(
<tr align="right">
<td colspan="$colspan">Handling: </td>
<td>$Handling_currency</td>
</tr>
);
		}

		if ($additional_taxes > 0)
		{
			print qq(
<tr align="right">
<td colspan="$colspan">Additional $state Shipping/Handling Taxes: </td>
<td>$Additional_currency</td>
</tr>
);
		}

		ViewRebates($colspan, 1);

		print qq(
<tr align="right">
<td colspan=$colspan>Grand Total: </td>
<td>$grand_total_currency</td>
</tr>	

</table>
</div>
<br>
);
	}

	# The customer has not yet filled in their order form
	else 	
	{						 				
		ViewRebates($colspan, 0);

		print "</table><br>";

		if ($shipping_type eq 'included')
		{
			print qq(
<i>Tax will be added when you check out.</i><br>
<i>Delivery fees are already included in the prices.</i><br>
<br>
);
		}

		elsif ($shipping_type eq 'none')
		{
			print '<i>Tax will be added when you check out</i><br><br>';
		}			

		else
		{
			print '<b><i>Tax and Shipping will be added when you check out</i></b><br><br>';
		}
			
		# Add instruction for normal checkout button
		$final_preview_cart_instructions = $view_cart_instructions;
	}		
	
	print qq(
</div>	

<table align="center" width="75%">
<tr><td>
<b><small>
<ul>
);

	print qq(
<li>To change your order, enter a new quantity, and press the
<nobr><font color="navy">UPDATE</font></nobr> button.<br>

<p>
<li>To remove an item, change the quantity to 0 (zero), and press the
<nobr><font color="navy">UPDATE</font></nobr> button.<br>
) if (($button_data{'UPDATE'}->{'visible'} == 1) &&
	($adjustable > 0));

#	if ($add_cart != 1)
#	{
#		print qq(
#<p>
#<li>If you wish to order more merchandise, press the
#<nobr><font color="navy">CONTINUE SHOPPING</font></nobr> button.
#);
#	}

	print qq(
<br>

<p>
$final_preview_cart_instructions

</ul>
</small></b>
</table>

<input type=hidden name=ORDER_ID value=$unique_id>
<input type=hidden name=NUM_ITEMS value=$item_num>

<p>
<div align="center">
<table border=0>
<tr><td>
);

	print qq(
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
</form>
</td>

<td>
);

	# If the customer file already exists, we must be performing the
	# final order confirmation.  Create the place order button and
	# hidden form.
	if (-e $customer_file_name) 
	{
		GenerateOrderForm();
	}		

	# No customer file present, so create a simple check out button
	else 
	{
		print qq(
<form name="checkoutForm" method=GET 
	action="$checkout_url">
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

		AddButton('CHECK OUT');

		print qq(
</form>
</td>
);
		
	}

	if ($add_cart != 1)
	{
		# Start the form object
		print qq(
<td>
<form name="continueForm" method=GET
	action="http://$cgi_prog_location">

<input type=hidden name="ORDER_ID" value=$unique_id>
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);

		# Add in redirection data, if needed
		if ($input{'REDIRECT_URL'} ne '')
		{
			print qq(
<input type=hidden name="redirect_url" value="$redirect_decoded">
);
		}

		# Add the button itself
		AddButton('CONTINUE SHOPPING');

		# Finish the form
		print qq(
</form>
</td>
);
	}

	if (($shipping_type ne 'included') && ($shipping_type ne 'none')) 
	{
		print qq(
<td>
<form name="shippingForm" method="POST" target="shippingrates"
	action="http://$cgi_prog_location">
<input type=hidden name="ORDER_ID" value=$unique_id>
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);

		# Add in redirection data, if needed
		if ($input{'REDIRECT_URL'} ne '')
		{
			print qq(
<input type=hidden name="redirect_url" value="$redirect_decoded">
);
		}

		AddButton('SHIPPING RATES');

		print qq(
</form>
</td>
);
	}

	# Add optional home button
	if (($add_cart != 1) && ($home_page ne ''))
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
		
	print '</tr></table></div>';

	if ($add_cart != 1)
	{
		add_company_footer();

		exit;
	}
}


sub UpdateShoppingCart
{
	my @shopping_cart;
	my $cart_data = '';
	my $cart_items = 0;

	# Validate the update form field data before proceeding
	foreach $index (1..$input{'NUM_ITEMS'} - 1) 
	{
		Check_Valid_Quantity($input{'QTY'.$index}, $input{'ITEM_NAME'.$index});
	}


	# Open the shopping cart file for reading
	open(order_file, $order_file_name)
		or error_trap("Cannot open $order_file_name for reading : $!\n");
	
	# Read in all shopping cart data
	@shopping_cart = <order_file>;

	close order_file;


	# Look at each item in the shopping cart
	foreach my $item_data (sort @shopping_cart)
	{  		
		chomp($item_data);

		# Split the item data into fields
		($order_id, $item_id, $item_name, $price, $quantity, $weight, 
		 $item_taxtype, $option1, $option2, $option3,
		 $qty_min, $qty_max, $item_shiptype) = split(/$delim/, $item_data);

		# Remove the boundary quotes from the fields we need
		UnQuote($item_id); 
		UnQuote($option1); 
		UnQuote($option2); 
		UnQuote($option3);
		UnQuote($qty_min);
		UnQuote($qty_max);

		# Compare this item data to each item in the update form
		foreach $index (1..$input{'NUM_ITEMS'} - 1) 
		{
			# Compare item ID and all option values
			if (($item_id eq $input{'ITEM_ID'.$index}) &&
			    ($option1 eq $input{'ITEM_OPTION1'.$index}) &&
			    ($option2 eq $input{'ITEM_OPTION2'.$index}) &&
			    ($option3 eq $input{'ITEM_OPTION3'.$index}))
			{ 	
				$quantity = $input{'QTY'.$index};

				# Skip this item if the quantity is 0
				last unless $quantity > 0;

				# Correct for lower range boundary
				if ($quantity < $qty_min)
				{
					$quantity = $qty_min;

					$cart_view_message .= qq(
<span id="$errorPageStyle">
The minimum quantity allowed for item $item_name is $qty_min.<br>
</span>
);
				}

				# Correct for upper range boundary
				elsif (($quantity > $qty_max) && ($qty_max != -1))
				{
					$quantity = $qty_max;

					$cart_view_message .= qq(
<span id="$errorPageStyle">
The maximum quantity allowed for item $item_name is $qty_max.<br>
</span>
);
				}

				# Add this item to the shopping cart buffer
				$cart_data .=
						"\"$unique_id\"$delim" .
						"\"$item_id\"$delim" .
						"$item_name$delim" .
						"$price$delim" .
						"\"$quantity\"$delim" .
						"$weight$delim" .
						"$item_taxtype$delim" .
						"\"$option1\"$delim" .
						"\"$option2\"$delim" .
						"\"$option3\"$delim" .
						"\"$qty_min\"$delim" .
						"\"$qty_max\"$delim" .
						"$item_shiptype\n";

				$cart_items++;

				# We're done with the comparison loop
				last;
			}
		}
	}

	# Do we have stuff in the shopping cart ?
	if ($cart_items > 0)
	{
		# Create a new shopping cart file
		open(out_file, ">$order_file_name")
			or error_trap("Cannot open $order_file_name for writing : $!\n");

		print out_file $cart_data;

		close out_file;
	}

	# Shopping cart is now empty
	else
	{
		# Remove cart file
		unlink $order_file_name;
	}

	# Check for cases where we need to add the shopping cart data
	# to the bottom of a catalog page
	if ((($stay_on_page eq 'yes') || (uc $input{'STAYONPAGE'} eq 'YES')) && 
		(! -e $customer_file_name))
	{
		$add_cart = 1;
	}

	# Generate a standard shopping cart display
	else
	{
		ViewCart();

		exit;
	}
}


sub AddItemsToCart
{
	my $option_string = '';
	my $order_data = '';

	# Expand data from ITEM_DATA tags into standard input tags
	ExpandItemData();

#print "<!--\n";
#foreach my $key (sort keys %input)
#{
#	print "$key : $input{$key}\n";
#}
#print "-->\n";

	# Check for duplicate entries
	if (-e $order_file_name) 
	{
		open(order_file, $order_file_name) or
			error_trap( "Cannot open $order_file_name for reading : $!\n");

		while (<order_file>) 
		{
			chomp;

			($order_id, $item_id, $item_name, $item_price, $item_qty, 
			 $item_weight, $item_taxtype, 
			 $item_option1, $item_option2, $item_option3,
			 $qty_min, $qty_max, $item_shiptype) = split(/$delim/,$_);

			UnQuote($item_id); 
			UnQuote($item_option1); 
			UnQuote($item_option2); 
			UnQuote($item_option3);
			UnQuote($qty_min);
			UnQuote($qty_max);
			UnQuote($item_shiptype);
			
			$index = '';
			do 
			{
				if (! defined $input{'ITEM_OPTION1'.$index})
					{$input{'ITEM_OPTION1'.$index} = '';}
				if (! defined $input{'ITEM_OPTION2'.$index})
					{$input{'ITEM_OPTION2'.$index} = '';}
				if (! defined $input{'ITEM_OPTION3'.$index})
					{$input{'ITEM_OPTION3'.$index} = '';}

				if ( ($input{'QTY'.$index} > 0)			
				&&   ($item_id eq $input{'ITEM_ID'.$index}) 				
				&&   (lc $item_option1 eq lc $input{'ITEM_OPTION1'.$index}) 
				&&   (lc $item_option2 eq lc $input{'ITEM_OPTION2'.$index}) 
				&&   (lc $item_option3 eq lc $input{'ITEM_OPTION3'.$index})  )
				 {
					PageHeader('Duplicate Item');

					$option_string .=  ", $item_option1"
						if ($item_option1 ne '');
					$option_string .=  ", $item_option2"
						if ($item_option2 ne '');
					$option_string .=  ", $item_option3"
						if ($item_option3 ne '');

					print qq(
<body id="$errorPageStyle">
<div align="center">
<h2>The following item has already been ordered:</h2>
<h3>$input{'ITEM_NAME'.$index}$option_string</h3>
<p>
You may change the quantity ordered by pressing the VIEW ORDERS button below.<br>
</div>
);

					# Force the page footer to appear
					$add_page_footer = 1;

					add_button_bar('CONTINUE SHOPPING', 'VIEW ORDERS');

					print "</body>\n";
					print "</html>\n";
					exit;
				 }
			if ($index eq '')
				{$index = 1;}
			else
				{$index++;}
			} until (! defined $input{'ITEM_ID'.$index});
			
		}#while order_file
		close order_file;
	}#if file exists

	# Check if the Item # and Price have been tampered with
	if (-e $token_file_name) 
	{
		open(token_file, $token_file_name) or
			error_trap("Cannot open token file $token_file_name for reading : $!");

		$token = <token_file>;
		chop($token);

		$index = '';  
		$item_code = ''; 
		$items_ordered = 0;

		do 
		{
			# Exit with err msg if not valid quantity	
			Check_Valid_Quantity($input{'QTY'.$index}, 
						   $input{'ITEM_NAME'.$index});

			if ($input{'QTY'.$index} > 0)
				{$items_ordered++;}
			if (! defined $input{'ITEM_WEIGHT'.$index})
				{$input{'ITEM_WEIGHT'.$index} = 0;}
			if (! defined $input{'ITEM_TAXTYPE'.$index})
				{$input{'ITEM_TAXTYPE'.$index} = '';}
			if (! defined $input{'ITEM_SHIPTYPE'.$index})
				{$input{'ITEM_SHIPTYPE'.$index} = '';}
			$input{'ITEM_PRICE'.$index} = &UnCurrency($input{'ITEM_PRICE'.$index});
			$item_code .= $input{'ITEM_ID'.$index} . 
						  $input{'ITEM_PRICE'.$index} . 
						  $input{'ITEM_WEIGHT'.$index} . 
						  $input{'ITEM_TAXTYPE'.$index};
			if ($index eq '')
				{$index = 1;}
			else
				{$index++;}
		} until (! defined $input{'ITEM_ID'.$index});
				
		# Generate the ITEMCODE value.
		# This is done by SHA encoding a string which is
		# composed of the customer IP address, the
		# computed item code string for this catalog
		# page, and the session token value
		if ($confirm_customer_ip)
		{
			$item_code = SHA($ENV{'REMOTE_ADDR'} . $item_code . $token);
		}

		else
		{
			$item_code = SHA($item_code . $token);
		}

		$item_code =~ s/\s+/ /g;

		# Don't check the item code if QuickBuy was used to get here;
		# don't check the item code if confirmation is disabled.
		if (($action ne 'QUICKBUY') &&
			$confirm_item_code && ($item_code ne $input{'ITEM_CODE'}))
		{
			print qq(
Item code is <pre>$item_code</pre><br>
Input is <pre>$input{'ITEM_CODE'}</pre><br>
);

			Transmission_error(4, qq(
Item code is <pre>$item_code</pre><br>
Input is <pre>$input{'ITEM_CODE'}</pre><br>
));
		}
	}
		
	if ($items_ordered == 0) 
	{  
		PageHeader('No Items Ordered');

		print qq(
<body id="$errorPageStyle">
<h3 align="center">All quantities were zero (0).  Please go back and enter a valid quantity for at least one item.</h3>
);

		add_button_bar('CONTINUE SHOPPING', 'VIEW ORDERS');

		print qq(
</body>
</html>
);

		exit;
	}

	# Set up the page item index
	$index = ''; 

	# Open the order file for appending
	open(order_file, ">>$order_file_name") || 
		error_trap("Cannot open order $order_file_name for writing : $!\n");

	# Examine all items on this store page
	do 
	{
		# Perform lower limit boundary check
		if (defined($input{'QTY_MIN' . $index}) &&
			($input{'QTY' . $index} < $input{'QTY_MIN' . $index}))
		{
			$input{'QTY' . $index} = $input{'QTY_MIN' . $index};

			$cart_view_message .= qq(
<span id="$errorPageStyle">
The minimum quantity allowed for item $input{'ITEM_NAME' . $index}
is $input{'QTY_MIN' . $index}.<br>
</span>
);
		}

		# Perform upper limit boundary check
		elsif (defined($input{'QTY_MAX' . $index}) &&
			  ($input{'QTY_MAX' . $index} != -1) &&
			  ($input{'QTY' . $index} > $input{'QTY_MAX' . $index}))
		{
			$input{'QTY' . $index} = $input{'QTY_MAX' . $index};

			$cart_view_message .= qq(
<span id="$errorPageStyle">
The maximum quantity allowed for item $input{'ITEM_NAME' . $index}
is $input{'QTY_MAX' . $index}.<br>
</span>
);
		}

		# Did the customer set a non-zero quantity for this item?
		if ($input{'QTY'.$index} > 0)
		{
			# Assign default values to all optional fields not referenced
			if (! defined $input{'ITEM_WEIGHT'.$index})
				{$input{'ITEM_WEIGHT'.$index} = 0;}
			if (! defined $input{'ITEM_TAXTYPE'.$index})
				{$input{'ITEM_TAXTYPE'.$index} = '';}
			if (! defined $input{'ITEM_SHIPTYPE'.$index})
				{$input{'ITEM_SHIPTYPE'.$index} = '';}
			if (! defined $input{'ITEM_OPTION1'.$index})
				{$input{'ITEM_OPTION1'.$index} = '';}
			if (! defined $input{'ITEM_OPTION2'.$index})
				{$input{'ITEM_OPTION2'.$index} = '';}
			if (! defined $input{'ITEM_OPTION3'.$index})
				{$input{'ITEM_OPTION3'.$index} = '';}
			if (! defined $input{'QTY_MIN'.$index})
				{$input{'QTY_MIN'.$index} = 0;}
			if (! defined $input{'QTY_MAX'.$index})
				{$input{'QTY_MAX'.$index} = 999999999;}

			# Add the order unique_id to the file
			$order_data = qq("$unique_id");

			# Add all fields to the file
			foreach $element ('ITEM_ID', 'ITEM_NAME', 'ITEM_PRICE', 'QTY', 
							  'ITEM_WEIGHT', 'ITEM_TAXTYPE', 'ITEM_OPTION1', 
							  'ITEM_OPTION2', 'ITEM_OPTION3',
							  'QTY_MIN', 'QTY_MAX', 'ITEM_SHIPTYPE')
			{	
				$order_data .= qq($delim"$input{$element.$index}");
			}

			# Add the line marker for this entry
			print order_file "$order_data\n";
		}

		# Move to the next page item index
		$index = ($index eq '') ? 1 : ($index + 1);

	# Keep going until we get to an index that is not defined
	} until (! defined $input{'ITEM_ID'.$index});
	
	# Close the order file
	close order_file;	
	
	# Output the order details page
	if (($stay_on_page eq 'yes') || (uc $input{'STAYONPAGE'} eq 'YES'))
	{	
		$add_cart = 1;
	}

	elsif (($stay_on_page eq 'skip') || (uc $input{'STAYONPAGE'} eq 'SKIP'))
	{	
		$add_cart = 0;
	}

	# Don't display cart for QuickBuy
	elsif ($action ne 'QUICKBUY')
	{
		ViewCart();

		exit;
	}
}


##############################
# Library file return code
1;


