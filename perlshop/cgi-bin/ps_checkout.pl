
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 customer check-out related subroutines
#
# Copyright (c) 2004 by David M. Godwin, All rights reserved
# 
# This code may not be copied, borrowed, stolen, sold, resold, reused, 
# recycled, plagiarized, modified, or in any way used for anything at
# all without the express written permission of the author.
#
#
# File version history
#
# Version 1.1
#	- Added support for rejectable country codes.
#	- Added support for $mail_order_cc_list setting.
#	- Cleaned up the text of various error messages.
#	- Increased phone number field max text length to 30.
#
# Version 1.2
#	- Tightened up the invoice header time conversion algorithm.
#
# Version 1.3
#	- Added PW (Palau) to the US valid state list.
#
# Version 1.4
#	- Added support for $paypal_web_accept setting.
#	- Altered code to accept any payby value that starts 
#	  with the string 'credit' in place of the old logic
#	  that required the single word 'credit'.
#	- Improved the text of various error message.
#	- $order_item_total variable now in use.
#	- Rebate total is recomputed prior to final storage.
#
# Version 1.5 
#	- Removed extra white space from invoice format.
#	- Added invoice plugin events.
#	- Added support for the $form_submission_method setting.
#	- Hyphens are removed from credit card numbers prior to processing.
#	- Shipping options are no longer displayed for shipping type "included".
#
# Version 1.6
#	- Credit card Month and Year selection options are now generated 
#	  algorithmically.
#	- Added support for the orderFormFields data structure.
#	- Added support for the orderFormTitles list.
#	- The 'header_above_banner' content plugin event is supported by the order form error page.
#	- The 'header_above_banner' content plugin event is supported by the thank you page.
#
# Version 1.7
#	- Added the 'add_to_company_email' plugin event.
#
# Version 1.8
#	- Added 0000000000000001 as a valid credit card test number.
#	- Added support for data encryption
#
# Version 1.9
# 	- Moved the logic from sub CardDataOnOrderForm() into the real-time transaction library
#
# Version 1.10
#	- Added support for the item_note plugin event.
#


sub SendConfirmation
{
	my $padlen = 0;
	my $email_subject;
	my $i;
	my $rebate_text;
	my $rebate_amount;
	my $confirm = '';
	my $html_end;
	my $html_confirm;
	my $company_data = '';
	my $content_insertion = '';
	my $item_total_currency;
	my $invoice_term = ucfirst $email_invoice_term;
	my @company_addr;

	check_if_orders_exist();
	
	PageHeader('Order Confirmation', 'ps_utilities.js');
	
	print qq(<body id="$thankyouPageStyle">\n) . 
		ExecutePlugins('header_above_banner', $unique_id);

	# Execute invoice header plugins
	ExecutePlugins('invoice_page_header', $unique_id);

	print qq(
<b>
Thank you very much for your order.<br>
);

	$confirm .= '<pre class="invoiceAddress">';
	
	@company_addr = split(/<br>/, $email_invoice_address);
	foreach $company_line (@company_addr) 
	{
		$confirm .= center($company_line) . '<br>';
	}
	$confirm .= "</pre>\n";
	

	# Open the temporary customer data file
	open(customer_file, $customer_file_name)
		or error_trap("Cannot open $customer_file_name for reading : $!\n");
	
	# Read in the data
	$customer_data = <customer_file>;
	chomp($customer_data);

	# Close the file
	close customer_file;
	
	# Break the data up into separate fields
	($unused,
	 $id, $ip, $date, $time, $title, $first, $last, $company, 
	 $street1, $street2, $city, $state, $zip, $country, $email, 
	 $dphone, $dexten, $nphone, $nexten, $fax, $Shiptype, $Payby, 
	 $Cardtype, $Cardno, $Expyr, $Expmo, $Source, $Suggest, $FVPin,
	
	 $ship_same, $ship_title, $ship_first, $ship_last, $ship_company, 
	 $ship_street1, $ship_street2, $ship_city, $ship_state, 
	 $ship_zip, $ship_country,
	
	 $unused) = split(/^"|"$delim"|"$/, $customer_data);
	
	# Check for IP value consistancy, if needed
	if ($confirm_customer_ip && ($ip ne $ENV{'REMOTE_ADDR'}))
	{
		Transmission_error(6, qq(
<p>
Inconsistancy detected during order confirmation.<br>
<p>
Original customer IP was $ip.<br>
Current customer IP is $ENV{'REMOTE_ADDR'}.<br>
));
	}
	
	
	$confirm .= '<pre class="invoiceTitle">' . center($email_title_line) . '<br></pre>';
	
	my ($hh, $mm, $ss) = split(/:/, $time);
	my $ampm = (($hh >= 12) ? 'pm' : 'am');

	# Force a leading zero onto the minute field as needed
	$mm = sprintf('%02d', $mm);
	
	# Convert hour from 24 hour time
	$hh %= 12;
	$hh = 12
		if ($hh == 0);

	# Generate time string
	$time = "$hh:$mm $ampm";

	$title .= ' '
		if $title ne '';

	$confirm .= qq(
<pre class="invoiceData">$invoice_term #: $id                $invoice_term Date: $date   Time: $time $local_time<br></pre>
<pre class="invoiceData">Sold To:  $title$first $last<br>);
	
	$confirm .= "          $company<br>" 
		if ($company ne '');

	$confirm .= "          $street1<br>";
	$confirm .= "          $street2<br>" 
		if ($street2 ne '');
	
	$confirm .= "          $city, $state   $zip";
	$confirm .= "   $country"
		if (uc $country ne uc $catalog_country);
	$confirm .= "<br>";
	
	if ($dphone ne '')
	{
		$confirm .= "          Daytime Phone:  $dphone";
		$confirm .= "  Ext: $dexten" 
			if ($dexten ne '');
		$confirm .= '<br>';
	}
	
	if ($nphone ne '')
	{
		$confirm .= "          Evening Phone:  $nphone";
		$confirm .= "  Ext: $nexten" 
			if ($nexten ne '');
		$confirm .= '<br>';
	} 
	
	$confirm .= "          Fax:  $fax<br>"
		if ($fax ne '');
	
	$confirm .= "          Email:  $email<br>"
		if ($email ne '');
	
	
	$confirm .= qq(</pre>
<pre class="invoiceData">Paid By:  $Payby $payby_note);

	if ($Payby =~ /^credit/i) 
	{
		$confirm .= " $Cardtype "; 
	
		$confirm .= '(Subject to Verification) '
			if (lc $online_credit_verify eq 'no');
	}
	
	elsif ($Payby =~ /purchase order/i) 
	{
		$confirm .= " $Cardno";
	}
	
	$confirm .= "<br></pre>\n";
	
	if ($shipping_type ne 'none')
	{
		$confirm .= '<pre class="invoiceData">';
	
		if ($ship_same eq 'true')
		{
			$confirm .= 'The Shipping Address is the same as the Billing Address.<br>';
		}
		
		else
		{
			$confirm .= 'Ship To:  ';
			$confirm .= "$ship_title "
				if $ship_title ne '';
			$confirm .= "$ship_first $ship_last<br>";
			
			$confirm .= "          $ship_company<br>" 
				if ($ship_company ne '');
			
			$confirm .= "          $ship_street1<br>";
			$confirm .= "          $ship_street2<br>" 
				if ($ship_street2 ne '');
			
			$confirm .= "          $ship_city, $ship_state   $ship_zip";
			$confirm .= "   $ship_country"
				if (uc $ship_country ne uc $catalog_country);
			$confirm .= '<br>';
		}
		
		$confirm .= "</pre>\n";

		$confirm .= qq(
<pre class="invoiceData">Ship By:  $Shiptype<br></pre>)
			if ($Shiptype ne '');
	}
	
	$confirm .= '<br>';
	
	
	print qq(
You may print this screen out as a record of your order.<br>
A copy of your order has also been sent to you by email.<br>
)
		if (lc $email_to_customer eq 'yes');

	AddBookmark();
	
	# Is payment by check of some sort?
	if ( ($Payby eq 'MAIL') ||
		 ($Payby eq 'CHECK') )
	{
		print qq(
<p>
Send a copy of this form to the address below along with your payment.<br>
Make checks payable to: $Pay_checks_to<br>
<p>
);
	}
	
	# Is payment by credit card of some sort?
	elsif ( ($Payby =~ /^credit/i) || 
			(uc($Payby) =~ 'REPEAT') ||
			(uc($Payby) =~ 'TELEPHONE') ||
			(uc($Payby) =~ 'FAX') )
	{
		if ($online_credit_verify eq 'no') 
		{
#		print qq(
#You will receive an email confirmation of your order<br>
#once your payment information has been verified.<br>
#);
		}
	
		else
		{
			print qq(
Your Credit Card has been charged the Grand Total shown below.<br>
);
		}
	}

	# Is payment by COD?
	elsif ($Payby eq 'COD') 
	{
		print qq(
Your order will be shipped COD for the Grand Total shown below. <br>
If you refuse delivery, you will still be charged for the COD charge <br>
shown below.<br>
);
	}
	
	# Is payment via PayPal standard account ?
	elsif ((uc($Payby) eq 'PAYPAL') && (lc $paypal_web_accept ne 'yes'))
	{
		print qq(
<p>
Our PayPal email address is $paypal_email_address.<br>
Please use your PayPal account to complete your purchase: 
<a href="$paypal_url" target="paypal">
<img src="$image_location/credit/paypal2.gif"
	width="88" height="32" border="0" 
	alt="Make payments with PayPal - it's fast, free and secure."></a>

<script language="JavaScript">
URLWindow('$paypal_url', 'Paypal');
</script>

<p>
);
	}

	# Is payment via BillPoint ?
	elsif (uc($Payby) eq 'BILLPOINT')
	{
		print qq(
<p>
Our BillPoint email address is $billpoint_email_address.<br>
Please use your 
<a href="$billpoint_url" target="billpoint">BillPoint account</a>
to complete your purchase.

<script language="JavaScript">
URLWindow('$billpoint_url', 'Billpoint');
</script>

<p>
);
	}

	
	print qq(
If you have any questions about your order, please reference your $email_invoice_term number when calling.<br>
We appreciate your business and hope you will return soon.</b><br>
-----------------------------------------------------------------------------------------------<br><br>
);

	$order_total = 0;
	$total_discount = 0;
	
	$confirm .= qq(
<pre class="invoiceContents">
------------------------------------------------------------------------
Product ID    Product Name           Unit Price     Qty     Item Total  
------------------------------------------------------------------------
);

	# Load order data from order file into internal array
	LoadOrders();
	
	# First display taxable items, then other taxtype (e.g. non-taxable) items
	foreach $taxtype (@taxtypes) 
	{
		if ($#orders > 0) 
		{
			if ($taxtype eq '' && $#taxtypes > 0) 
			{
				$padlen = 10;
				$confirm .= '-------------------- ** Taxable Items ** -------------------------------' . ('-' x $padlen) . '<br>';
			}
	
			elsif ($taxtype eq 'none')
			{
				$padlen = 10;
				$confirm .= '------------------- ** NON Taxable Items **-----------------------------' . ('-' x $padlen) . '<br>';
			}
	
			elsif ($taxtype ne '')
			{
				$padlen = 10;
				$confirm .= "------------------- ** $taxtype Tax Items ** ---------------------------" . ('-' x $padlen) . '<br>';
			}
		}
	
		$sub_total = 0;
	
		$numOrders = $#orders;
	
		# Examine each item ordered
		foreach $i (0..$numOrders)
		{
			($order_id, $item_id, $item_name, $price, $quantity, $weight, 
			 $item_taxtype, $option1, $option2, $option3,
			 $qty_min, $qty_max, $item_shiptype) = @{$orders[$i]};	
		
			# Skip this item if it isn't of the right tax type
			next unless (lc $item_taxtype eq $taxtype);
		
			# Remove all leading and trailing spaces from the item name
			$item_name =~ s/^\s+(.*)$\s+/$1/;

			$item_id = left($item_id, 25);
		
			$item_name_part = (' ' x 7);
	
			$item_total = $price * $quantity;
			$quantity = right($quantity, 4);
			$sub_total += $item_total;
			$item_total_currency = right(Currency($item_total), 13);
			$price = right(Currency($price), 11);
	
			$confirm .= "$item_id  $item_name_part  $price    $quantity  $item_total_currency\n";
	
			while ($item_name ne '') 	
			{	
				$item_name_part = left($item_name, 60);
				$confirm .= "              $item_name_part\n";
				$item_name = substr($item_name, 60);
			}
	
			$confirm .= "              $option1_caption: $option1\n"
				if ($option1_caption ne '') and ($option1 ne '');

			$confirm .= "              $option2_caption: $option2\n"
				if ($option2_caption ne '') and ($option2 ne '');

			$confirm .= "              $option3_caption: $option3\n"
				if ($option3_caption ne '') and ($option3 ne '');

			$confirm .= "              $weight_caption ($local_weight): $weight\n"
				if ($weight_caption ne '') and ($weight > 0);

			$confirm .= "              $free_shipping_message\n"
				if (lc $item_shiptype eq 'free');

			# Add product note if needed
			$item_note = ExecutePlugins('item_note', $unique_id, $item_id);
			$confirm .= "              $item_note\n"
				unless $item_note eq '';

		} # For each item ordered
		

		# Display the item subtotal
		$sub_tot = right(Currency($sub_total), 15);
		$confirm .= "------------------------------------------------------------------------\n" .
			    "                                          Item Total:  $sub_tot\n";
		
		# Display any applicable discount information
		if (calculate_discount() != 0) 
		{
			$discount_currency = right($discount_currency, 15);
			$confirm .= '<span class="invoiceDiscount">' .
					'                                  Discount of ' .  
					right($disc_rate, 5) . 
					"%:  $discount_currency</span>\n";
			$sub_tot = right(Currency($discount_total), 15);	

			$confirm .= "                             -------------------------------------------\n";
			$confirm .= "                                           Sub Total:  $sub_tot\n";
		}
		
		# Alter the subtotal based on the discount
		$order_item_total += $discount_total;


		# Display any applicable tax information
		if (calculate_tax() > 0) 
		{
			$tax_currency = right($tax_currency, 15);
			$confirm .= "                                    $state Tax at " . 
				right($Tax_Rate, 5) . "%:  $tax_currency\n";
		}
	
		if ($taxtype ne 'none')
		{
			$tax_tot = right(Currency($tax_total), 15);	
			$confirm .= '                             -------------------------------------------' . 
				('-' x $padlen) . "\n" .
				'                                           Tax Total:  ' . 
				(' ' x $padlen) . "$tax_tot\n";
		}
	} # For each $taxtype


	if (calculate_shipping('after_compute_invoice') > 0) 
	{
		$shipping_currency = &right($shipping_currency, 15);
		$confirm .= '                                            Shipping:  ' . 
				(' ' x $padlen) . "$shipping_currency\n";
			
		if ($country_uc eq 'OTHER')
		{
			$confirm .= qq(
<br>
Shipping rates for locations outside the United States vary widely.<br>
We will contact you with your final total, including shipping fee.<br>
Your order will not be considered confirmed until you have agreed to 
the final amount.<br>
);
		}
	}
	
	# Add handling charges
	if ($Handling > 0) 
	{
		$Handling_currency = right($Handling_currency, 15);
		$confirm .= '                                            Handling:  ' . 
				(' ' x $padlen) . "$Handling_currency\n";
	}

	# Add additional taxes
	if ($additional_taxes > 0) 
	{
		$Additional_currency = right($Additional_currency, 15);
		$confirm .= '                  Additional Shipping/Handling Taxes:  ' . 
				(' ' x $padlen) . "$Additional_currency\n";
	}

	# Add COD charges
	if ($Payby eq 'COD') 
	{
		$cod_currency = right($cod_currency, 15);
		$confirm .= '                                          COD Charge:  ' . 
				(' ' x $padlen) . "$cod_currency\n";
	}
	
	# Add rebate information
	foreach my $rebate (sort keys %rebate_table)
	{
		$confirm .= "------------------------------------------------------------------------\n";

		$rebate_amount = right(Currency($rebate_table{$rebate}->{'amount'}), 15);

		$rebate_text = $rebate_table{$rebate}->{'description'};

		$rebate_text =~ s/\n/ /g;
		$rebate_text =~ s/<br>/\n/;

		if (length($rebate_text) > 52)
		{
			$rebate_text .= "\n" . (' ' x 52)
		}

		else
		{
			$rebate_text = right($rebate_text, 52);
		}

		$confirm .= qq(<span class="invoiceRebate">$rebate_text:  ) .
					(' ' x $padlen) . "$rebate_amount</span>\n";
	}
	
	# Add grand total
	$grand_total_currency = &right($grand_total_currency, 15);
	$confirm .= '                             -------------------------------------------' . 
				('-' x $padlen) . "\n" .
				qq(<span class="invoiceTotal">) . 
				'                                         Grand Total:  ' . 
				(' ' x $padlen) . "$grand_total_currency</span></pre>\n";
	
	# Add shipping policy
	if ($shipping_policy ne '')
	{
		$confirm .= '<p><pre class="invoiceTitle">' . 
					center('SHIPPING POLICY') . "</pre>\n" .
					$shipping_policy;
	}
	
	# Add return policy
	if ($return_policy ne '')
	{
		$confirm .= '<p><pre class="invoiceTitle">' . 
					center('RETURN POLICY') . "</pre>\n" .
					$return_policy;
	}
	
	# Display the invoice
	print qq(
$confirm

<div align="center">
<table border=0 cellpadding=3 cellspacing=3 align="center">
<tr>
<td>
);

	ExecutePlugins('invoice_page_above_print', $unique_id);

	# Display the Print button
	DisplayPrintButton();

	print qq(
</td>
<td>
);
	
	ExecutePlugins('invoice_page_above_continue', $unique_id);

	# Display the Continue button
	DisplayContinueButton();

	print qq(
</td>
</tr>
</table>
</div>
);
	
	# Execute invoice footer plugins
	ExecutePlugins('invoice_page_footer', $unique_id);

	add_company_footer();

	# Finish the html page
	print qq(
</body>
</html>
);

	$confirm =~ s/<\/pre><br>/<\/pre>/g;

	# Create an html copy of the invoice
	$html_confirm = PageHeader("$company_name Invoice", '', '', 1) . 
                      "\n<body>\n" .
                      ExecutePlugins('invoice_email_header_html', $unique_id) .
                      "\n$confirm\n" .
                      ExecutePlugins('invoice_email_footer_html', $unique_id);

	# Remove html tags for plain text email
	$confirm =~ s/<\/?span.*?>|<pre.*?>|<em>|<\/em>|<i>|<\/i>|<\/?div.*?>//go;
	$confirm =~ s/<\/pre>|<br>|<p>/\n/go;

	# Condense white space lines
	$confirm =~ s/^\s+$//g;
	$confirm =~ s/\n\n/\n/g;
	
	# Wrap plain text email in any plugin generated header and footer
	$confirm = ExecutePlugins('invoice_email_header_plain', $unique_id) .
                 $confirm .
                 ExecutePlugins('invoice_email_footer_plain', $unique_id);

	$email_subject = (($email_storename_in_subject eq 'yes')
						? "$company_name Order"
						: 'Order');

	# Add invoice number to store copy of email, if requested
	$email_subject .= " - $id"
		if $email_id_in_subject;

	# Load the email handling library
	LoadLibrary('ps_email.pl');


	# Send invoice email to customer
	if (lc $email_to_customer eq 'yes')
	{
		SendEmail($email, $company_email, $email_subject, 
      	          $confirm, "$html_confirm\n</body>\n</html>\n",
            	    '', '');
	}


	# Append more information for the store copy of the email
	
	# Add credit card information, if requested
	$company_data .= qq(

Credit Card:
Type: $Cardtype, Number: $Cardno, Expiration: $Expyr/$Expmo
)
		if ((lc $cardno_on_email eq 'yes') && ($Payby =~ /^credit/i));
	
	# Add Payment Network Reference ID number, if used
	$company_data .= qq(

Credit Card Transaction Reference : $card_approval_note
)
		if ($card_approval_note ne '');
	
	# Add optional form data
	$company_data .= qq(

How did you find us?
$Source
)
		if ($Source ne '');

	# Add optional form data
	$company_data .= qq(

Suggestions?
$Suggest
)
		if ($Suggest ne '');


	$company_data .= ExecutePlugins('add_to_company_email', $unique_id);


	# Add customer last name to store copy of email, if requested
	$email_subject .= " - $last"
		if $email_lastname_in_subject;

	# Send invoice to store office
	if (lc $email_to_store eq 'yes')
	{
		SendEmail($mail_order_to, $email, $email_subject, 
			    $confirm . $company_data, 
			    $html_confirm . qq(
<pre>
$company_data
</pre>
</body>
</html>
),
	                $mail_order_cc_list, '');
	}

}


sub PlaceOrder
{
	my $line;
	my $out_buffer = '';

	# Send confirming email to both customer and store
	SendConfirmation();

	# Recompute total rebate amount
	$total_rebate = 0;
	foreach my $rebate (keys %rebate_table)
	{
		$total_rebate += $rebate_table{$rebate}->{'amount'};
	}

	# Open the temporary order file
	open(order_file, $order_file_name)
		or error_trap("Cannot open $order_file_name for reading : $!\n");

	# Create the permanent order file
	open(out_file, ">$orders_directory/$unique_id")
		or error_trap("Cannot create file $orders_directory/$unique_id : $!\n");

	# Copy all information from the temporary order file
	# into the permanent order file
	while ($line = <order_file>) 
	{
		# Convert the temporary data delimitter into a comma, if needed
		$line =~ s/$delim/,/g 
			if ($convert_delim_to_commas eq 'yes');

		# Write the data into the permanent file
		$out_buffer .= $line;
	}	
	
	# Do we encrypt the order data ?
	if ($encryption_index ne '')
	{
		# Load the data encryption library
		LoadLibrary('ps_encryption.pl');

		$out_buffer = encrypt_data($out_buffer);
	}

	# Write the order data to file
	print out_file $out_buffer;

	# Close both files
	close out_file;
	close order_file;
		

	# Open the temporary customer file
	open(customer_file, $customer_file_name)
		or error_trap("Cannot open $customer_file_name for reading : $!\n");

	# Create the permanent customer file
	open(out_file, ">$customers_directory/$unique_id")
		or error_trap("Cannot create file $customers_directory/$unique_id : $!\n");

	$out_buffer = '';

	# Read all data from the temporary customer file, process it, 
	# add in all final totals, and store it all in the permanent customer file
	while ($line = <customer_file>) 
	{	
		# Remove end-of-line character
		chomp($line);

		# Convert temporary delimitters to commas, if needed
		$line =~ s/$delim/,/g
			if ($convert_delim_to_commas eq 'yes');

		# Prepare all final totals
		$sub_total 	= sprintf("%.2f", $sub_total);
		$tax 		= sprintf("%.2f", $tax);
		$shipping 	= sprintf("%.2f", $shipping);
		$grand_total	= sprintf("%.2f", $grand_total);
		$total_discount	= sprintf("%.2f", $total_discount);
		$total_rebate	= sprintf("%.2f", $total_rebate);

		$cod_charge = (($Payby eq 'COD') ? sprintf("%.2f", $cod_charge) : '0.00');

		$Handling = sprintf("%.2f", $Handling);

		# Create the data for the permanent customer file
		$out_buffer .= qq($line,"$sub_total","$tax","$shipping","$grand_total","$total_discount","$cod_charge","$Handling","$total_rebate"\n);
	}	

	# Do we encrypt the customer data ?
	if ($encryption_index ne '')
	{
		# Load the data encryption library
		LoadLibrary('ps_encryption.pl');

		$out_buffer = encrypt_data($out_buffer);
	}

	# Write the customer data to the file
	print out_file $out_buffer;

	# Close both files
	close out_file;	
	close customer_file;

	# Unless testing switch is enabled, delete tokens file, 
	# temporary order file, and temporary customer file.
	unless ($testing eq 'yes') 
	{
		unlink $token_file_name;
		unlink $order_file_name;
		unlink $customer_file_name;	
	}
}


sub AddressFields
{
	my ($fieldNamePrefix, $cc_msg1, $cc_msg2) = @_;

	my @fieldList = ('title', 'fname', 'lname', 'company', 'street1', 'street2', 'city', 'state', 'zip', 'country');
	my %fieldNames;
	my %fieldText;
	my $scriptURL = (($use_secure_server eq 'yes')
						? $secure_server_address . $secure_script_directory
						: "http://$server_address" . $script_directory);

	# Create all of the field names needed for address entry
	foreach my $field (@fieldList)
	{
		$fieldNames{$field} = $fieldNamePrefix . $field;

		# Create a default hidden field for each required input
		$fieldText{$field} = qq(
<input type=hidden name="$fieldNames{$field}" value="$orderFormFields{$field}->{'default'}">
);
	}

	# Display the credit card related message
	if ($cc_msg1 ne '')
	{
		print qq(
<tr>
<td>&nbsp;</td>
<td><b>$cc_msg1 $cc_msg2</b></td>
</tr>
);
	}

	# Do we display the title input field?
	if ($orderFormFields{'title'}->{'visible'})
	{
		$fieldText{'title'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'title'}->{'text'}</b>
</td>

<td colspan=4>
<select name="$fieldNames{'title'}">
<option selected>
);

		foreach my $item (@orderFormTitles)
		{
			$fieldText{'title'} .= "<option>$item\n";
		}

		$fieldText{'title'} .= qq(
</select>
</td>
</tr>
);
	}

	# Do we display the first name field?
	if ($orderFormFields{'fname'}->{'visible'})
	{
		$fieldText{'fname'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'fname'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'fname'}" maxlength="40" size="40" 
	value="$orderFormFields{'fname'}->{'default'}"
	vcard_name=vCard.FirstName
	onChange="ValidateNotEmpty('$orderFormFields{'fname'}->{'text'}', this);">
</td>
</tr>
);
	}

	# Do we display the last name field?
	if ($orderFormFields{'lname'}->{'visible'})
	{
		$fieldText{'lname'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'lname'}->{'text'}</b>
</td>
<td colspan=4>
<input type=text name="$fieldNames{'lname'}" maxlength="40" size="40" 
	value="$orderFormFields{'lname'}->{'default'}"
	vcard_name=vCard.LastName
	onChange="ValidateNotEmpty('$orderFormFields{'lname'}->{'text'}', this);">
</td>
</tr>
);
	}

	# Do we display the company name field?
	if ($orderFormFields{'company'}->{'visible'})
	{
		$fieldText{'company'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'company'}->{'text'}</b>
</td>
<td colspan=4>
<input type=text name="$fieldNames{'company'}" maxlength="40" size="40" 
	value="$orderFormFields{'company'}->{'default'}"
	vcard_name=vCard.Company>
</td>
</tr>
);
	}

	# Do we display the street1 field?
	if ($orderFormFields{'street1'}->{'visible'})
	{
		$fieldText{'street1'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'street1'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'street1'}" maxlength="40" size="40" 
	value="$orderFormFields{'street1'}->{'default'}"
	vcard_name=vCard.Home.StreetAddress
	onChange="ValidateNotEmpty('Address', this);">
</td>
</tr>
);
	}

	# Do we display the street2 field?
	if ($orderFormFields{'street2'}->{'visible'})
	{
		$fieldText{'street2'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'street2'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'street2'}" maxlength="40" size="40"
	value="$orderFormFields{'street2'}->{'default'}">
</td>
</tr>
);
	}

	# Do we display the city field?
	if ($orderFormFields{'city'}->{'visible'})
	{
		$fieldText{'city'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'city'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'city'}" maxlength="40" size="40" 
	value="$orderFormFields{'city'}->{'default'}"
	vcard_name=vCard.Home.City
	onChange="ValidateNotEmpty('City', this);">
</td>
</tr>
);
	}

	# Do we display the state field?
	if ($orderFormFields{'state'}->{'visible'})
	{
		$fieldText{'state'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'state'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'state'}" maxlength="20" size="20" 
	value="$orderFormFields{'state'}->{'default'}"
	vcard_name=vCard.Home.State>
Please use the state/provincial abbreviations provided by your postal system.
</td>
</tr>
);
	}

	# Do we display the zip field?
	if ($orderFormFields{'zip'}->{'visible'})
	{
		$fieldText{'zip'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'zip'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'zip'}" maxlength="15" size="15" 
	value="$orderFormFields{'zip'}->{'default'}"
	vcard_name=vCard.Home.Zipcode>
</td>
</tr>
);
	}

	# Do we display the country field?
	if ($orderFormFields{'country'}->{'visible'})
	{
		$fieldText{'country'} = qq(
<tr>
<td class="orderformField" align="right">
<b>$orderFormFields{'country'}->{'text'}</b>
</td>

<td colspan=4>
<input type=text name="$fieldNames{'country'}" value="$catalog_country" 
	value="$orderFormFields{'country'}->{'default'}"
	maxlength="2" size="2">

<a href="javascript:CountryWindow('$scriptURL', '$fieldNames{'country'}');"
    title="Select International Country Code">
[Country Code List]</a>

</td>
</tr>
);
	}

	# Display the html for the order form address fields
	print qq(
$fieldText{'title'}
$fieldText{'fname'}
$fieldText{'lname'}
$fieldText{'company'}
$fieldText{'street1'}
$fieldText{'street2'}
$fieldText{'city'}
$fieldText{'state'}
$fieldText{'zip'}
$fieldText{'country'}
);
}


sub BillingFields
{
	my @fieldList = ('email', 'dphone', 'nphone', 'fax');
	my %fieldNames;
	my %fieldText;

	# Create all of the field names needed for address entry
	foreach my $field (@fieldList)
	{
		$fieldNames{$field} = $field;

		# Create a default hidden field for each required input
		$fieldText{$field} = qq(
<input type=hidden name="$fieldNames{$field}" value="$orderFormFields{$field}->{'default'}">
);
	}

	# Do we display the email address field?
	if ($orderFormFields{'email'}->{'visible'})
	{
		$fieldText{'email'} = qq(
<tr>
<td class="orderformField" align="right"><b>$orderFormFields{'email'}->{'text'}</b></td>
<td colspan=4>
<input type=text name="email" maxlength="60" size="40" 
	value="$orderFormFields{'email'}->{'default'}"
	vcard_name=vCard.Email
	onChange="ValidateNotEmpty('Email Address', this);">
</td>
</tr>
);
	}

	# Do we display the daytime phone number field?
	if ($orderFormFields{'dphone'}->{'visible'})
	{
		$fieldText{'dphone'} = qq(
<tr>
<td class="orderformField" align="right"><b>$orderFormFields{'dphone'}->{'text'}</b></td>
<td>
<input type=text name="Dphone" maxlength="30" size="15" 
	value="$orderFormFields{'dphone'}->{'default'}"
	vcard_name=vCard.Business.Phone>
</td>

<td class="orderformField" align="right"><b>Extension:</b></td>
<td><input type=text name="Dexten" maxlength="6" size="6"></td>
</tr>
);
	}

	# Do we display the nighttime phone number field?
	if ($orderFormFields{'nphone'}->{'visible'})
	{
		$fieldText{'nphone'} = qq(
<tr>
<td class="orderformField" align="right"><b>$orderFormFields{'nphone'}->{'text'}</b></td>
<td>
<input type=text name="Nphone" maxlength="30" size="15" 
	value="$orderFormFields{'nphone'}->{'default'}"
	vcard_name=vCard.Home.Phone>
</td>

<td class="orderformField" align="right"><b>Extension:</b></td>
<td><input type=text name="Nexten" maxlength="6" size="6"></td>
</tr>
);
	}

	# Do we display the fax number field?
	if ($orderFormFields{'fax'}->{'visible'})
	{
		$fieldText{'fax'} = qq(
<tr>
<td class="orderformField" align="right"><b>$orderFormFields{'fax'}->{'text'}</b></td>
<td colspan=4>
<input type=text name="fax" maxlength="40" size="40" 
	value="$orderFormFields{'fax'}->{'default'}"
	vcard_name=vCard.Home.Fax>
</td>
</tr>

</table>
<br>
);
	}

	# Display the html for the order form billing fields
	print qq(
$fieldText{'email'}
$fieldText{'dphone'}
$fieldText{'nphone'}
$fieldText{'fax'}
);

}


sub GenerateOrderForm 
{
	my $checked;
	my $accept_by;
	my $accept_by_uc;
	my ($Ship_Country, $Shipper, $Ship_Desc, 
	    $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt);
	my $ship_option;
	my $index;
	my $submit_button_text;
	my $param;
	my $image_html = '';
	my $upper_table = '';
	my $upper_table_text = '';
	my $faq_url = "http://$cgi_prog_location?ACTION=thispage&thispage=$order_faq_page&ORDER_ID=$unique_id&nextpage=$input{'THISPAGE'}";
	my $shipping_url = "http://$cgi_prog_location?ACTION=SHIPPING+RATES&thispage=$input{'THISPAGE'}&ORDER_ID=$unique_id";
	my ($mon, $year) = (localtime)[4, 5];
	
	$year = Year2000($year);

	# Append redirection data to all page links
	if ($input{'REDIRECT_URL'} ne '')
	{
		$shipping_url .= "&redirect_url=$redirect_encoded";
	}

	# Generate the HTML page header
	PageHeader('Order Form', 'ps_utilities.js', 'profile.js');
	
	if (($shipping_type ne 'included') && ($shipping_type ne 'none'))
	{
		add_menu_bar('CONTINUE SHOPPING', 'VIEW ORDERS', 'SHIPPING RATES');
	}
	
	else
	{
		add_menu_bar('CONTINUE SHOPPING', 'VIEW ORDERS');
	}
	
	add_company_header(0, 0, $orderPageStyle);
	
	# If we're using a secure server, say so
	$upper_table_text .= qq(
To protect your privacy, we operate on a secure web server.<br>
)
		if ($use_secure_server eq 'yes');

	# If we have an order FAQ, create a link to it
	$upper_table_text .= qq(
Questions about ordering?  Please see our 
<a href="$faq_url">Ordering FAQ</a>.
)
		unless ($order_faq_page eq '');
	
	# Add ordering instructions page link, if specified
	$upper_table .= qq(
<tr>
<td align="center">
<small><b><span style="color:darkgreen">
$upper_table_text
</span></b></small>
</td></tr>
) unless ($upper_table_text eq '');

	# Display credit card logos
	if ($#valid_credit_cards > -1)
	{
		foreach $credit_card (@valid_credit_cards)
		{
			if ($credit_images{$credit_card}->{'image'} ne '')
			{
				$image_html .= qq(
<img src="$image_location/$credit_images{$credit_card}->{'image'}"
	alt="$credit_card" border=0 
	width=$credit_images{$credit_card}->{'width'}
	height=$credit_images{$credit_card}->{'height'}
>
);
			}
		}
	}

	# Display PayPal logo
	foreach $index (@accept_payment_by)
	{
		if ($index eq 'PayPal')
		{
			$image_html .= qq(
<img src="$image_location/$credit_images{'PayPal'}->{'image'}"
	alt="PayPal" border=0
	width=$credit_images{'PayPal'}->{'width'}
	height=$credit_images{'PayPal'}->{'height'}
>
);

			last;
		}
	}

	# Generate the row of credit card images, if needed
	$upper_table .= qq(
<tr><td align="center">
$image_html
</td></tr>
) if ($image_html ne '');
	
	# Start the table that contains the order form
	print qq(
<table border=0 cellpadding=3 cellspacing=3 width="100%">
<tr>
);

	# Add in a left-side spacer logo image, if needed
	print qq(
<td valign="top">
<img src="$image_location/$small_logo" border=0>
</td>
) unless ($small_logo eq '');

	print qq(
<td>

<table border=0 align="center">
$upper_table
</table>

<form method=$form_submission_method name="checkoutForm"
	onSubmit="return CheckoutSubmitCheck();"
	action="$checkout_url">

<input type=hidden name="ORDER_ID" value="$unique_id">
);

	# If we accept credit cards, we need to add this message to the billing form
	if ($#valid_credit_cards > -1)
	{
		$cc_msg1 = 'If paying by credit,'; 
		$cc_msg2 = 'must match name on card.';
	}
	
	# Execute all plugins that need to display at the top of the order form 
	ExecutePlugins('before_display_order_form', $unique_id);
	
	print qq(

<script type="text/javascript" language="JavaScript1.2">
AutoFormInstructions("checkoutForm");
</script>

<a name="topoftable"></a>
);

	# Execute all plugins that need to display before the billing address 
	ExecutePlugins('order_form_before_billing_address', $unique_id);

	print qq(
<h2 class="orderformHeader">Billing Address:</h2>
<table border=0 cellspacing=3 cellpadding=3>
);

	AddressFields('', $cc_msg1, $cc_msg2);

	BillingFields();

	print qq(
</table>
);

	# Execute all plugins that need to display after the billing address 
	ExecutePlugins('order_form_after_billing_address', $unique_id);

	# Do we have some type of shipping to do ?
	if ($shipping_type eq 'none') 
	{
		print qq(
<input name="ship_same" type=hidden value=true>
);
	}
	
	else
	{
		print qq(
<p>
<hr>
);

		# Execute all plugins that need to display before the shipping address
		ExecutePlugins('order_form_before_shipping_address', $unique_id);
	
		print qq(
<h2 class="orderformHeader">Shipping Address:</h2>

<table border=0 cellspacing=3 cellpadding=3>
<tr>
<td>&nbsp;</td>
<td colspan=4>
<b>The Shipping Address is the same as the Billing Address : </b>
<input name="ship_same" type=checkbox value=true
	onClick="SetShippingFields(this.checked);">
</td>
);

		AddressFields('ship_', '', '');

		print qq(
</table>
);

		# Execute all plugins that need to display after the shipping address 
		ExecutePlugins('order_form_after_shipping_address', $unique_id);
	}


	print qq(
<p>
<hr>
);

	# Execute all plugins that need to display before the payment data
	ExecutePlugins('order_form_before_payment_data', $unique_id);

	print qq(
<h2 class="orderformHeader">Payment Information:</h2>
);


	if ($#accept_payment_by > -1) 
	{
		print qq(
<table border=0 cellpadding=3 cellspacing=3>
<tr>
<td class="orderformField" align="right" valign="top">
<b>Payment Method:</b>
</td>

<td colspan=4>
);

		$checked = 'checked';
		foreach $accept_by (@accept_payment_by) 
		{
			$accept_by_uc = uc($accept_by);
			print qq(
<input type=radio name="Payby" value="$accept_by_uc" $checked
	onClick="SetCreditFields('$accept_by_uc');">$accept_by
);

			print '(Your credit card information will be taken after this form has been submitted)'
				if ($accept_by =~ /^credit/i) && !CardDataOnOrderForm();

			print "<br>\n";

			$checked = '';
		}
	}
	
	print qq(
</td>
</tr>
);


	# If we don't accept credit cards, or if our real-time credit card processor
	# will be taking the card number for us, fill all credit card related form 
	# values in as empty.
	if (($#valid_credit_cards == -1) || !CardDataOnOrderForm())
	{
		print qq(
<tr><td>
<input type=hidden name="Cardtype" value=" ">
<input type=hidden name="Cardno" value=" ">
<input type=hidden name="Expmonth" value=" ">
<input type=hidden name="Expyear" value=" ">
);
	}
	
	# We accept credit cards
	else
	{
		print qq(
<tr><td class="orderformField" align="right"><b>Card Type:</b></td>
<td colspan=4>
<select name="Cardtype">
);

		# Construct the list of accepted cards
		$checked = 'selected';
		foreach $credit_card (@valid_credit_cards) 
		{
			print qq(
<option $checked value="$credit_card">$credit_card
);
			$checked = '';	
		}
		
		# Construct the card number field
		print qq(
</select><br>

<tr>
<td class="orderformField" align="right">
<b>Credit Card #:</b>
</td>

<td colspan=2>
<input type=text name="Cardno" maxlength="40" size="40" autocomplete=off
	onChange="ValidateCardNumber(this);">
</td>
);

		# Is the card code field turned off?
		if (lc $card_security_code eq 'no')
		{
			print qq(
<td colspan=2>&nbsp;</td>
);
		}

		# Construct the card security code field
		else
		{
			print qq(
<td class="orderformField" align="right">
<b>Security Code #:</b>
</td>

<td>
<input type=text name="Cardcode" maxlength="4" size="6" autocomplete=off>
</td>
);
		}

		# Construct the card expiration information fields
		print qq(
</tr>

<tr>
<td class="orderformField" align="right"><b>Expiration Date:</b></td>
<td class="orderformField" align="right"><b>Month:</b></td>
<td>
<select name="Expmonth">
<option value="01">01 (January)
<option value="02">02 (February)
<option value="03">03 (March)
<option value="04">04 (April)
<option value="05">05 (May)
<option value="06">06 (June)
<option value="07">07 (July)
<option value="08">08 (August)
<option value="09">09 (September)
<option value="10">10 (October)
<option value="11">11 (November)
<option value="12">12 (December)
</select>
</td>

<td class="orderformField" align="right"><b>Year:</b></td>
<td>
<select name="Expyear">
);

		# Generate fields for the next 10 years
		map(print("<option>$_\n"), $year..($year + 10));

		print qq(
</select>
</td>
);
	}
	
	# Do we accept payment via Virtual Check?
	if ((lc $online_check_verify ne 'no') && CardDataOnOrderForm())
	{
		print qq(
<tr>
<td colspan=5 align="center">
<hr width="75%" color="blue" noshade>
</td>
</tr>

<tr>
<th class="orderformField" align="right">
<b>Virtual Check:</b>
</td>

<td colspan=2>
ABA Number: <input type=text name="ABA" value="" size=20>
</td>

<td colspan=2>
Account Number: <input type=text name="Account" value="" size=20>
</td>
</tr>
);
	}


	# Do we accept payment via Purchase Order?
	if (AcceptPaymentBy('PURCHASE ORDER') || AcceptPaymentBy('PO')) 
	{
		print qq(
<tr>
<td colspan=5 align="center">
<hr width="75%" color="blue" noshade>
</td>
</tr>

<tr>
<td class="orderformField" align="right">
<b>Purchase Order Number:</b>
</td>

<td colspan=4>
<input type=text name="PO" value="" size=20>
</td>
</tr>
);
	}


	print qq(
</tr>
</table>
);

	# Execute all plugins that need to display after the payment data
	ExecutePlugins('order_form_after_payment_data', $unique_id);
	
	# Do we have some type of shipping to do ?
	if (($shipping_type ne 'included') && ($shipping_type ne 'none'))
	{
		print qq(
<hr>
<p>
);

		# Execute all plugins that need to display before the shipping data
		ExecutePlugins('order_form_before_shipping_data', $unique_id);

		print qq(
<h2 class="orderformHeader">Shipping Information:</h2>
<table border=0 cellpadding=3 cellspacing=3>
<tr>
<td class="orderformField" align=left>
<b>Ship via:</b>

<select name="Shiptype">
<option selected>
);

		($Ship_Country, $Shipper, $Ship_Desc, 
		 $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = @{$Shipping_Rates[0]};
	
		print "$Shipper\n";
	
		$ship_option = $Shipper;
		foreach $index (0..$#Shipping_Rates)
		{
			($Ship_Country, $Shipper, $Ship_Desc, 
			 $Ship_Min, $Ship_Max, $Ship_Mul, $Ship_Amt) = 
				@{$Shipping_Rates[$index]};
	
			if ($ship_option ne $Shipper)
			{
				$ship_option = $Shipper;
				print "<option>$Shipper\n";
			}
		}
	
		print qq(
</select>

</td>
</tr>

<tr>
<td>
Questions about shipping?  Please see our 
);

		print qq(
<a href="$faq_url">
Ordering FAQ</a> and our
) unless ($order_faq_page eq '');

		print qq(
<a href="$shipping_url" target="shippingrates">
Shipping Rates</a> page.

</td>
</tr>
</table>
);
	}
	
	# Execute all plugins that need to display after the shipping data
	ExecutePlugins('order_form_after_shipping_data', $unique_id);
	
	# Generate text for submit button
	$submit_button_text = (($use_secure_server eq 'yes') 
								? 'SECURE SUBMIT' 
								: 'SUBMIT');
	
	# Generate html for submit button
	print "<hr>\n";

	# Execute all plugins that need to display before the comment fields
	ExecutePlugins('order_form_before_comments', $unique_id);
	
	print qq(
<h2 class="orderformHeader">Optional:</h2>
<p>
<span class="orderformField">
<b>Please tell us where you heard about our site:</b>
</span>
<input TYPE="text" name="source">
</p>

<p>
<span class="orderformField">
<b>Suggestions and Comments:</b>
</span>
</p>

<p><textarea name="Suggest" ROWS="5" COLS="65"></textarea></p>
);

	# Execute all plugins that need to display after the comment fields
	ExecutePlugins('order_form_after_comments', $unique_id);
	
	print qq(
<p><b>
<font color="blue">Press</font>
<nobr><font color="navy">$submit_button_text</font></nobr>
<font color="blue">to preview your final order.</font>
</b></p>

<p>
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
);


	AddButton($submit_button_text);
	AddButton('CLEAR');

	print "</p>\n";
	
	# Execute all plugins that need to display at the bottom of the order form 
	ExecutePlugins('after_display_order_form', $unique_id);
	
	
	if ($input{'REDIRECT_URL'} ne '')
	{
		print qq(
<input type=hidden name="redirect_url" value="$redirect_decoded">
);
	}

	print qq(
</form>

<hr>

</td>
</tr>
</table>

);

	if (($shipping_type ne 'included') && ($shipping_type ne 'none'))
	{
		add_button_bar('CONTINUE SHOPPING', 'VIEW ORDERS', 'SHIPPING RATES');
	}

	else
	{
		add_button_bar('CONTINUE SHOPPING', 'VIEW ORDERS');
	}
	
	add_company_footer();
}


sub RequireField
{
	my ($field_name, $field_val) = @_;

	if ($field_val eq '')
	{
		$error_msg .= qq(<li>The $field_name field has not been filled in.<br>\n);
		return 0;
	}

	return 1;
}


sub check_email
{
	my ($mail_addr) = @_;

	if ($mail_addr eq '')
	{
		return 0;
	}
	 
	elsif ($mail_addr =~ /^[\s]*[\w-.]+\@[\w-]+([\.]{1}[\w-]+)+[\s]*$/)
	{
    		return 1;
	}

	else
	{
		$error_msg .= qq(<li>Email address is not in the form 'name\@isp.com'.<br>\n);
		return 0; 
	} 		
}


sub check_zip 
{         
	my ($zip_code, $zip_type) = @_;

	# Check zipcode for US locations only
	if (uc $zip_type eq 'US') 
	{  
		# Remove all white space
		$zip_code =~ s/\s//g;

		# Zipcode must be 5 characters, or 10 characters (5 dash 4)
		if ((length($zip_code) != 5) && (length($zip_code) != 10))
		{
			$error_msg .= "<li>Zip code must have 5 or 9 digits.<br>\n";	
			return 0;
		}
	}
}


sub ValidateStateName 
{         
	my ($state_code, $country_code) = @_;
	my @valid_state_names;

	# Don't do validation for state/province values outside the US and Canada
	return $state_code 
		unless (uc $country_code eq 'US') ||
			   (uc $country_code eq 'CA');

	# Remove all white space from state code value
	$state_code = uc($state_code);
	$state_code =~ s/[\s.]//g;

	# Valid US state postal service state codes, including territories
	if (uc $country_code eq 'US')
	{
		@valid_state_names = (
		'AL', 'AK', 'AR', 'AS', 'AZ', 'CA', 'CO', 'CT', 'DE', 'DC',
		'FL', 'FM', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 
		'KY', 'LA', 'MA', 'MD', 'ME', 'MH', 'MI', 'MN', 'MO', 'MP', 
		'MS', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 
		'OH', 'OK', 'OR', 'PA', 'PR', 'PW', 'RI', 'SC', 'SD', 'TN',  
		'TX', 'UT', 'VT', 'VA', 'VI', 'WA', 'WV', 'WI', 'WY',
		
		'AA',		# Armed Forces, America
		'AE',		# Armed Forces, Europe
		'AP'		# Armed Forces, Pacific
		);
	}

	# Valid Canadian postal service codes, including territories
	else
	{
		@valid_state_names = (
		'AB', 'BC', 'MB', 'NB', 'NF', 'NS', 'NT', 'ON', 'PE', 'QC', 'SK', 'YT'
		);
	}

	# Perform validity check for postal service state/province codes
	foreach $state_abbr (@valid_state_names)
	{
		return $state_code if ($state_abbr eq $state_code);
	}

	$error_msg .= qq(
<li>Invalid state code : $state_code<br>
State must be a valid postal code abbreviation.<br>
);

	return 0;
}


sub ValidateCountryName 
{         
	my ($country_code, $description) = @_;

	# Remove all white space from country code
	$country_code =~ s/\s//g;

	# Perform length sanity check
	if (length($country_code) == 0)  
	{
		$error_msg .= qq(
<li>No country code was specified for the $description address.<br>
);
		return 0;
	}
	
	# Perform length sanity check
	elsif (length($country_code) != 2)  
	{
		$error_msg .= qq(
<li>$country_code is not a valid 2 letter Country Code
for the $description address.<br>
);
		return 0;
	}
	
	$country_code = lc $country_code;
	
	foreach my $country_abbr (@reject_country_codes)
	{
		if (lc $country_abbr eq $country_code)
		{
			$error_msg = qq(
<li>We're sorry, but we are unable to process orders for the following country :
$country_abbr.<br>
$reject_country_message<br>
);

			last;
		}
	}

	# Valid ISO standard postal service country codes
	my @valid_country_codes = (
	'ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'aq',
	'ar', 'as', 'at', 'au', 'aw', 'az', 'ba', 'bb', 'bd', 'be',
	'bf', 'bg', 'bh', 'bi', 'bj', 'bm', 'bn', 'bo', 'br', 'bs',
	'bt', 'bv', 'bw', 'by', 'bz', 'ca', 'cc', 'cf', 'cg', 'ch',
	'ci', 'ck', 'cl', 'cm', 'cn', 'co', 'cr', 'cs', 'cu', 'cv',
	'cx', 'cy', 'cz', 'de', 'dj', 'dk', 'dm', 'do', 'dz', 'ec',
	'ee', 'eg', 'eh', 'er', 'es', 'et', 'fi', 'fj', 'fk', 'fm',
	'fo', 'fr', 'ga', 'gb', 'gd', 'ge', 'gf', 'gh', 'gi', 'gl',
	'gm', 'gn', 'gp', 'gq', 'gr', 'gs', 'gt', 'gu', 'gw', 'gy',
	'hk', 'hm', 'hn', 'hr', 'ht', 'hu', 'id', 'ie', 'il', 'in',
	'io', 'is', 'it', 'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki',
	'km', 'kn', 'kp', 'kr', 'kw', 'ky', 'kz', 'la', 'lb', 'lc',
	'li', 'lk', 'lr', 'ls', 'lt', 'lu', 'lv', 'ly', 'ma', 'mc',
	'md', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn', 'mo', 'mp', 'mq',
	'mr', 'ms', 'mt', 'mu', 'mv', 'mw', 'mx', 'my', 'mz', 'na',
	'nc', 'ne', 'nf', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nu',
	'nz', 'om', 'pa', 'pe', 'pf', 'pg', 'ph', 'pk', 'pl', 'pm',
	'pn', 'pr', 'pt', 'pw', 'py', 'qa', 're', 'ro', 'ru', 'rw',
	'sa', 'sb', 'sc', 'sd', 'se', 'sg', 'sh', 'si', 'sj', 'sk',
	'sl', 'sm', 'sn', 'so', 'sr', 'st', 'su', 'sv', 'sy', 'sz',
	'tc', 'td', 'tf', 'tg', 'th', 'tj', 'tk', 'tm', 'tn', 'to',
	'tp', 'tr', 'tt', 'tv', 'tw', 'tz', 'ua', 'ug', 'uk', 'um',
	'us', 'uy', 'uz', 'va', 'vc', 've', 'vg', 'vi', 'vn', 'vu',
	'wf', 'ws', 'ye', 'yt', 'yu', 'za', 'zm', 'zr', 'zw', 'ps'
	);
	
	foreach my $country_abbr (@valid_country_codes)
	{
		return $country_abbr if ($country_abbr eq $country_code);
	}

	$error_msg .= "<li>$country_code is not a valid 2 letter Country Code.<br>\n"; 

	return 0;
}


sub check_phone 
{        
	my ($phone_no, $phone_type) = @_;
    
	# No phone number?  No problem.
	return '' if $phone_no eq '';

	# Remove non-digits
	$phone_no =~ s/\D//g;

	# Check for US and Canada
	if ((uc $phone_type eq 'US') || (uc $phone_type eq 'CA'))  
	{
		# Check for 10 digits with optional leading '1'
		if ($phone_no =~ /^1?(\d{3})(\d{3})(\d{4})$/)
		{
			# Format nicely
			$phone_no = "1($1)$2-$3";
		}

		# Something is wrong
		else	
		{
			$error_msg .= qq(
<li>The telephone number '$phone_no' is not valid.
10 or 11 digits are required for phone numbers from the US or Canada.<br>
);

			$phone_no = 0;
		} 
	}

	# International phone number must have between 6 and 18 digits
	elsif ($phone_no !~ /^\d{6,18}$/)  
	{			    	
		$error_msg .= qq(
<li>The telephone number '$phone_no' is not valid for the country '$phone_type'.<br>
);

		$phone_no = 0;
	}

	return $phone_no;
}		


# Check credit card length, prefix and checkdigit.
# See ANSI/ISO/IEC 7812-1-1993 Identification of Issuers - Part 1: Numbering System.
sub check_card_num		
{				
	my ($card_num, $card_type) = @_;

	# Don't check blank entries
	return 0
		if ($card_num eq '');

	# Return OK for simple test cases
	return 1
		if $card_num =~ /^000000000000000/;

	if ($card_num =~ /\D{1,}?/)		 #Check for any other non-digits
	{
		$error_msg .= "<li>Credit Card Number cannot contain a \"$1\" Character.<br>";
		return 0;		
	}

	$card_len = length($card_num);

	unless (($card_type eq 'MasterCard'         &&  $card_len == 16)  
		||  ($card_type eq 'Visa'               && ($card_len == 13 || $card_len == 16)) 		
		||  ($card_type eq 'American Express'   &&  $card_len == 15) 
		||  ($card_type eq 'Optima'             &&  $card_len == 15)
		||  ($card_type eq 'Carte Blanche'      &&  $card_len == 15)
		||  ($card_type eq 'Diners Club'        &&  $card_len == 15)   		
		||  ($card_type eq 'Discover'           &&  $card_len == 16)  		
		||  ($card_type eq 'JCB'                && ($card_len == 15 || $card_len == 16)) 
        ||  ($card_type eq 'Switch'             && ($card_len == 18 || $card_len == 19)) 
        ||  ($card_type eq 'Solo'               && ($card_len == 18 || $card_len == 19))
		)
	{
		$error_msg .= qq(
<li>A $card_type Credit Card # cannot have $card_len digits.<br>
<!-- $card_type, $card_len, '$card_num' -->
); 

		return 0;
	}

	$prefix_type{'35'} 	= 'JCB';	
	$prefix_type{'21'} 	= 'JCB';
	$prefix_type{'18'} 	= 'JCB';
	$prefix_type{'51'} 	= 'MasterCard';
	$prefix_type{'52'} 	= 'MasterCard';
	$prefix_type{'53'} 	= 'MasterCard';
	$prefix_type{'54'}	= 'MasterCard';
	$prefix_type{'55'}	= 'MasterCard';
	$prefix_type{'4'} 	= 'Visa';
	$prefix_type{'34'} 	= 'American Express';
	$prefix_type{'37'} 	= 'American Express';
	$prefix_type{'3707'} 	= 'Optima';
	$prefix_type{'3717'} 	= 'Optima';
	$prefix_type{'3727'} 	= 'Optima';
	$prefix_type{'3737'} 	= 'Optima';
	$prefix_type{'3747'} 	= 'Optima';
	$prefix_type{'3757'} 	= 'Optima';
	$prefix_type{'3767'} 	= 'Optima';
	$prefix_type{'3777'} 	= 'Optima';
	$prefix_type{'3787'} 	= 'Optima';
	$prefix_type{'3797'} 	= 'Optima';
	$prefix_type{'94'} 	= 'Carte Blanche';
	$prefix_type{'95'} 	= 'Carte Blanche';
	$prefix_type{'38'} 	= 'Carte Blanche';
	$prefix_type{'30'} 	= 'Diners Club';
	$prefix_type{'31'} 	= 'Diners Club';
	$prefix_type{'35'} 	= 'Diners Club';
	$prefix_type{'36'} 	= 'Diners Club';
	$prefix_type{'38'} 	= 'Diners Club';	
	$prefix_type{'6011'} 	= 'Discover';
	$prefix_type{'67'}	= 'Switch';
	$prefix_type{'67'}      = 'Solo';


	if		($card_type eq 'MasterCard')		{$card_prefix = substr($card_num, 0, 2);}      
	elsif	($card_type eq 'Visa')             	{$card_prefix = substr($card_num, 0, 1);}      	
	elsif	($card_type eq 'American Express') 	{$card_prefix = substr($card_num, 0, 2);}      
	elsif	($card_type eq 'Optima')           	{$card_prefix = substr($card_num, 0, 4);}      
	elsif	($card_type eq 'Carte Blanche')    	{$card_prefix = substr($card_num, 0, 2);}      
	elsif	($card_type eq 'Diners Club')     	{$card_prefix = substr($card_num, 0, 2);}      
	elsif	($card_type eq 'Discover')      	{$card_prefix = substr($card_num, 0, 4);}      
	elsif	($card_type eq 'JCB') 	 	     	{$card_prefix = substr($card_num, 0, 2);}    
	elsif	($card_type eq 'Switch')            {$card_prefix = substr($card_num, 0, 2);}      
	elsif	($card_type eq 'Solo') 	 	     	{$card_prefix = substr($card_num, 0, 2);}
  	

	if ($prefix_type{$card_prefix} ne $card_type) 
	{
		$error_msg .= qq(<li>Invalid credit card # for a $card_type card<br>\n);
		return 0;
	}

	# Now do a LUHN MOD 10 check digit check on the card number.
	$weight = 2;
	$sum = 0;

	for ($i = $card_len - 2; $i >= 0; $i--) 
	{
		$curr_digit = substr($card_num, $i, 1);  
	
		$product = $weight * $curr_digit;
		
		$ones = chop($product); 

		$sum += $ones + $product;			

		$weight = $weight % 2 + 1;   ### 2->1,  1->2

	}

	# Is the card number mathematically valid ?
	if (substr($card_num, $card_len - 1, 1) != (10 - ($sum % 10)) % 10)
	{
		$error_msg .= "<li>The credit card number is invalid<br>\n";
		return 0;
	}

	return 1;
}


sub check_expire_date
{
	my ($expire_month, $expire_year) = @_;

	# Get local time
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = 
		localtime(time);
	$mon++;
	
	# Do the Y2K thing
	Year2000($expire_year);
	Year2000($year);

	# Did the card expire in a previous year?
	if ($expire_year < $year)
	{
		$error_msg .= '<li>Credit card expiration year has passed<br>';
		return 0;
	}

	# Did the card expire earlier this year?
	elsif (($expire_year == $year) && ($expire_month < $mon))
	{
		$error_msg .= '<li>Credit card expiration month has passed<br>';
		return 0;
	}

	# Card date is OK
	return 1;
}


sub SubmitCustomerInformation
{
	# Validate & Save Order (Shipping & Payment) info, and make sure	
	# it's linked to an Order Number (i.e. that an order file exists). 

	check_if_orders_exist();

	SelfTest();

	$error_msg = '';

	RequireField('First Name', $input{'FNAME'});
	RequireField('Last Name', $input{'LNAME'});
	RequireField('Street1', $input{'STREET1'});
	RequireField('City', $input{'CITY'});
	RequireField('Billing address State/Province', $input{'STATE'})
		if CountryRequiresState($input{'COUNTRY'});
	RequireField('Zip Code', $input{'ZIP'});
	RequireField('Country', $input{'COUNTRY'});
	RequireField('Email Address', $input{'EMAIL'});

	check_email($input{'EMAIL'});

	ValidateCountryName($input{'COUNTRY'}, 'Billing');

	check_zip($input{'ZIP'}, $input{'COUNTRY'});

	$input{'STATE'} = ValidateStateName($input{'STATE'}, $input{'COUNTRY'});

#	if (($input{'PAYBY'} =~ /^credit/i)
#	&& ((lc $online_credit_verify eq 'secureorder') || (lc $online_check_verify eq 'secureorder'))
#	&& (($input{'DPHONE'} eq '') && ($input{'NPHONE'} eq '')))
#		{RequireField("Daytime or Nighttime Phone", $input{'DPHONE'});}
		
	$input{'DPHONE'} = check_phone($input{'DPHONE'}, $input{'COUNTRY'});
	$input{'NPHONE'} = check_phone($input{'NPHONE'}, $input{'COUNTRY'});
	$input{'FAX'} = check_phone($input{'FAX'}, $input{'COUNTRY'});
	
	# Assign the default payment type unless one has already been chosen.
	$input{'PAYBY'} = uc @accept_payment_by[0]
		unless exists $input{'PAYBY'};

	# Remove all white space from payment data fields
	$input{'ABA'} =~ s/\s+//g;
	$input{'ACCOUNT'} =~ s/\s+//g;
	$input{'CARDNO'} =~ s/\s+//g;
	$input{'CARDCODE'} =~ s/\s+//g;
	$input{'PO'} =~ s/\s+//g;

	# Remove hyphens from credit card numbers
	$input{'CARDNO'} =~ s/\-//g;
	$input{'CARDCODE'} =~ s/\-//g;

	# Are we paying by Virtual Check?
	if (uc($input{'PAYBY'}) eq 'VIRTUAL CHECK')
	{
		RequireField('ABA Number', $input{'ABA'});	
		RequireField('Account Number', $input{'ACCOUNT'});	

		# Reuse card type and number fields to store the ABA and Account
		# numbers.  This keeps us from needing new fields in the customer
		# file.
		$input{'CARDTYPE'} = $input{'ABA'};
		$input{'CARDNO'} = $input{'ACCOUNT'};
	}

	# Are we paying by Purchase Order?
	elsif ((uc($input{'PAYBY'}) eq 'PURCHASE ORDER') ||
		   (uc($input{'PAYBY'}) eq 'PO'))
	{
		RequireField('Purchase Order Number', $input{'PO'});	

		# Reuse card number field to store the PO number.  
		# This keeps us from needing new fields in the customer file.
		$input{'CARDNO'} = $input{'PO'};
	}

	# Are we paying by anything other than a credit card?
	elsif ($input{'PAYBY'} !~ /^credit/i)
	{
		# Make sure they did not enter a credit card number
		if (($input{'CARDNO'} ne '') && CardDataOnOrderForm())
		{
			$error_msg .= '<li>Credit Card number entered, but Pay By [Credit] not selected.';
		}
	}

	# Payment is by credit card and we are responsible for 
	# taking the card information
	elsif (CardDataOnOrderForm())
	{
		RequireField('Card Type', $input{'CARDTYPE'});	
		RequireField('Credit Card #', $input{'CARDNO'});
		RequireField('Expiration Month', $input{'EXPMONTH'});
		RequireField('Expiration Year', $input{'EXPYEAR'});

		RequireField('Credit Card Security Code', $input{'CARDCODE'})
			if lc $card_security_code eq 'required';

		check_card_num($input{'CARDNO'}, $input{'CARDTYPE'});
		check_expire_date($input{'EXPMONTH'}, $input{'EXPYEAR'});
	}

	# Do we have a shipping type defined?
	if ($shipping_type ne 'none') 
	{	
		# Examine the shipping address street value
		$shipstreet_uc = ($input{'SHIP_SAME'} eq 'true')
						? uc($input{'STREET1'})
						: uc($input{'SHIP_STREET1'});

		if (($shipstreet_uc =~ /\bbox\b/i) &&
		    (($input{'SHIPTYPE'} =~ /^ups/i) ||
		     ($input{'SHIPTYPE'} =~ /^dhl/i) ||
		     ($input{'SHIPTYPE'} =~ /^fedex/i)))
		{
			$error_msg .= "<li>$input{'SHIPTYPE'} cannot ship to a P.O. Box.  Please enter a valid street address.";
		}
	
		# Figure out what state we're shipping to
		$state_uc = ($input{'SHIP_SAME'} eq 'true')
						? uc($input{'STATE'})
						: uc($input{'SHIP_STATE'});

		# Figure out what country we're shipping to
		$country_uc = ($input{'SHIP_SAME'} eq 'true')
						? uc($input{'COUNTRY'})
						: uc($input{'SHIP_COUNTRY'});

		# Validate the ship-to state and country values
		if (CountryRequiresState($country_uc) && ($input{'SHIP_SAME'} ne 'true'))
		{
			RequireField('Shipping address State/Province', $state_uc);
			ValidateStateName($state_uc, $country_uc);
		}

		RequireField('Country', $country_uc);
		ValidateCountryName($country_uc, 'Shipping');

		# Initialize tracking variables
		$country_found = 0;
		$shipper_found = (($shipping_type eq 'included') ? 1 : 0);

		# Loop through the entire Shipping_Rates table
		foreach $index(0..$#Shipping_Rates) 
		{
			# Break up this table entry
			($Ship_Country, $Shipper, $Ship_Desc, $Ship_Min, $Ship_Max, 
			 $Ship_Mul, $Ship_Amt) = @{$Shipping_Rates[$index]};

			# Does this table entry shipper work for the specified country?
			if ((($Ship_Country =~ /$country_uc/i) || ($Ship_Country eq 'ALL')) && 
			    ($input{'SHIPTYPE'} eq $Shipper))
			{
				$shipper_found = 1;
			}

			# Did we actually find the country specified?
			if ($Ship_Country =~ /$country_uc/i)
			{
				$country_found = 1;
			}
		}
		
		# Were we unable to find a shipper?
		if ($shipper_found == 0) 
		{
			# If we can't ship to any country, they're out of luck
			if (($accept_any_country eq 'no') && (!$country_found))
			{
				$error_msg .= "<li>Orders for delivery to $country_uc cannot be accepted at this time.<br>";
			}

			# Country not in table.  
			# Make sure Shipper entered is valid for 'OTHER'.
			else	
			{
				foreach $index (0..$#Shipping_Rates)
				{
					($Ship_Country, $Shipper, $Ship_Desc, 
					 $Ship_Min, $Ship_Max, $Ship_Mul, 
					 $Ship_Amt) = @{$Shipping_Rates[$index]};		

					last if ($Ship_Country eq 'OTHER') && 
							($input{'SHIPTYPE'} eq $Shipper);
				}

				# No valid shipper found?
				if (($input{'SHIPTYPE'} ne $Shipper) || ($country_found == 1))
				{
					# Initialize tracking variables
					$valid_shippers = '';
					$prev_Shipper = '';

					# Build a list of valid shippers for the given country
					foreach $index (0..$#Shipping_Rates) 
					{
						# Break the entry up
						($Ship_Country, $Shipper, $Ship_Desc, 
						 $Ship_Min, $Ship_Max, 
						 $Ship_Mul, $Ship_Amt) = @{$Shipping_Rates[$index]};

						if (((uc $Ship_Country eq 'ALL') || 
						     (!$country_found && ($Ship_Country eq 'OTHER')) ||
						     ($Ship_Country =~ /$country_uc/i)) && 
						    ($valid_shippers !~ $Shipper))	
						{
							$valid_shippers .= ', or '
								if ($valid_shippers ne '');

							$valid_shippers .= $Shipper;
						}

						$prev_Shipper = $Shipper;
					} # For each shipper
	
					$error_msg .= qq(
<li>$input{'SHIPTYPE'} is not a valid shipper for the following country :
$country_uc.<br>
Please use $valid_shippers.<br>
);
				}#if	
			}#else		
		}#if	
	}#shipping ne none

	# Are there any order form errors ?
	if ($error_msg ne '') 
	{
		PageHeader('Errors on Order Form', 'ps_utilities.js');

		print qq(<body id="$errorPageStyle">\n) . 
			ExecutePlugins('header_above_banner', $unique_id) .
			qq(
<h2>The Following Order Form Errors Were Encountered:</h2>
<hr>
<ul><h3>$error_msg</h3></ul>
<hr>
<i>Press your browser's BACK button to return to the order form and fix them. 
Thank you.</i>
</body>
</html>
);

		# Exit the program now (unless we're in test mode)
		exit if ($testing ne 'yes');
	}

	# Start customer data with invoice ID and customer IP address
	$customerData = Quote($unique_id, $delim) .
					Quote($ENV{'REMOTE_ADDR'}, $delim);

	# Get the local time
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = StoreTime(time());
	$mon++;

	# Ensure correct format for 4 digit years
	if ($date_format =~ 'yyyy')
	{
		Year2000($year);
	}

	# Ensure correct format for 2 digit years
	else
	{
		$year %= 100;
	}

	# Put date string into customer file
	if ($date_format =~ 'mmddyy')
	{
		$customerData .= 
			Quote("$mon$date_separator$mday$date_separator$year", $delim);
	}

	elsif ($date_format =~ 'ddmmyy')
	{
		$customerData .= 
			Quote("$mday$date_separator$mon$date_separator$year", $delim);
	}

	# Convert suggestion data into useable form
	$input{'SUGGEST'} =~ tr/\"\n\r/\` /d;

	# Append card code to card number
	$input{'CARDNO'} .= ' ' . $input{'CARDCODE'}
		unless $input{'CARDCODE'} eq '';

	# Put customer information into file
	$customerData .= Quote("$hour:$min:$sec", $delim) .
					 Quote($input{'TITLE'}, $delim) .
					 Quote($input{'FNAME'}, $delim) .
					 Quote($input{'LNAME'}, $delim) .
					 Quote($input{'COMPANY'}, $delim) .
					 Quote($input{'STREET1'}, $delim) .
					 Quote($input{'STREET2'}, $delim) .
					 Quote($input{'CITY'}, $delim) .
					 Quote($input{'STATE'}, $delim) .
					 Quote($input{'ZIP'}, $delim) .
					 Quote($input{'COUNTRY'}, $delim) .
					 Quote($input{'EMAIL'}, $delim) .
					 Quote($input{'DPHONE'}, $delim) .
					 Quote($input{'DEXTEN'}, $delim) .
					 Quote($input{'NPHONE'}, $delim) .
					 Quote($input{'NEXTEN'}, $delim) .
					 Quote($input{'FAX'}, $delim) .
					 Quote($input{'SHIPTYPE'}, $delim) .
					 Quote($input{'PAYBY'}, $delim) .
					 Quote($input{'CARDTYPE'}, $delim) .
					 Quote($input{'CARDNO'}, $delim) .
					 Quote($input{'EXPMONTH'}, $delim) .
					 Quote($input{'EXPYEAR'}, $delim) .
					 Quote($input{'SOURCE'}, $delim) .
					 Quote($input{'SUGGEST'}, $delim) .
					 Quote($input{'FVPIN'}, $delim) .

					 Quote($input{'SHIP_SAME'}, $delim) .
					 Quote($input{'SHIP_TITLE'}, $delim) .
					 Quote($input{'SHIP_FNAME'}, $delim) .
					 Quote($input{'SHIP_LNAME'}, $delim) .
					 Quote($input{'SHIP_COMPANY'}, $delim) .
					 Quote($input{'SHIP_STREET1'}, $delim) .
					 Quote($input{'SHIP_STREET2'}, $delim) .
					 Quote($input{'SHIP_CITY'}, $delim) .
					 Quote($input{'SHIP_STATE'}, $delim) .
					 Quote($input{'SHIP_ZIP'}, $delim) .
					 Quote($input{'SHIP_COUNTRY'}, "\n");


	# Create the temporary customer data file
	open(customer_file, ">$customer_file_name") or
		error_trap("Cannot open customer $customer_file_name for writing\n");

	# Write the entire customer record
	print customer_file $customerData;

	# Close the file
	close customer_file;	

	ViewCart();
}


sub AcceptPaymentBy
{
	my ($payment_mode) = @_;

	foreach my $mode (@accept_payment_by)
	{
		return 1
			if uc($mode) eq uc($payment_mode);
	}

	return 0;
}


sub CountryRequiresState
{
	my ($order_country) = @_;

	foreach my $country (@countries_requiring_state)
	{
		return 1
			if $country eq uc $order_country;
	}

	return 0;
}


sub CardDataOnOrderForm()
{
	# Use the Perlshop order form if we're not doing real-time transactions
	return 1 if (lc $online_credit_verify eq 'no') and (lc $online_check_verify eq 'no');

	# Include the Perlshop real-time transaction library
	LoadLibrary('ps_transact.pl');

	# We'll use the Perlshop form unless the library tells us not to
	return RequestCardDataOnOrderForm();
}


##############################
# Library file return code
1;


