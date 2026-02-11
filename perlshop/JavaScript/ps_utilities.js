
// Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin, All rights reserved
// 
// This code may not be copied, borrowed, stolen, sold, resold, reused, 
// recycled, plagiarized, modified, or in any way used for anything at
// all without the express written permission of the author.


// Mark the form objects as unsubmitted
var itemFormSubmitted = false;
var placeFormSubmitted = false;


// Attempt to print the screen
function PrintPage()
{
	// Does the browser have a print method?
	if (window.print)
	{
		// Call the print method
		window.print();
	}

	else
	{
		alert("Your browser software does not support this feature.");
	}

	// Always return false to keep the main browser window from updating
	return false;
}


// Call up a new window containing the ISO country code table
function CountryWindow(url, fieldName)
{
	// Open a window for the specified URL
	var cWin = window.open(url + "/country.html?field=" + fieldName,
				"infoWindow", 
				"height=500,width=400,screenX=300,left=300,screenY=100,top=100,scrollbars"); 
						   
	// Make sure the window has focus
	cWin.focus();
}


// Call up a note window containing the specified local file
function NoteWindow(fileName)
{
	// Open a window for the specified URL
	var nWin = window.open("http://" + window.location.hostname + "/" + fileName, 
				"infoWindow", 
				"height=450,width=400,screenX=400,left=400,screenY=100,top=100,scrollbars"); 
						   
	// Make sure the window has focus
	nWin.focus();
}


// Call up a new window containing the specified URL
function URLWindow(windowURL, windowName)
{
	// Open a window for the specified URL
	var uWin = window.open(windowURL, windowName,
				"height=500,width=500,screenX=400,left=400,screenY=100,top=100,scrollbars"); 
						   
	// Make sure the window has focus
	uWin.focus();
}


// Called by checkout form to make sure a form field has some value in it
function ValidateNotEmpty(description, field)
{
	// Internal consistancy check
	if (!field)
	{
		return false;
	}

	// Check the length of the value typed in
	if (field.value.length == 0)
	{
		alert("The " + description + " field must be filled in.");

		// Force the cursor back to this field
		field.focus();

		return false;
	}

	return true;
}


// Called by checkout form to make sure state value has been filled in
function ValidateState(description, state, country)
{
	// Only check state value for US and Canada
	if (((country.value == 'US') || (country.value == 'CA')) &&
		(state.value.length == 0))
	{
		alert("The " + description + " field must be filled in.");

		// Force the cursor back to this field
		state.focus();

		return false;
	}

	return true;
}


// Called by checkout form to ensure a credit card number was given if needed
function ValidateCardNumber(field)
{
	var payby = document.checkoutForm.Payby;
	var cardno = document.checkoutForm.Cardno;
	var i;

	// Scan the payby setting
	for (i = 0; i < payby.length; i++)
	{
		// Was credit selected but the card number left blank?
		if (payby[i].checked && 
			(payby[i].value.indexOf('CREDIT') == 0) &&
			(cardno.value.length == 0))
		{
			alert("The Credit Card Number field must be filled in.");

			// Force the mouse back to this field
			field.focus();

			return false;
		}
	}

	return true;
}


// Turn access on or off for all forms fields used for credit card data entry
function SetCreditFields(active)
{
	// Do we need to disabel the credit card fields?
	disable = (active.indexOf('CREDIT') == 0) ? false : true;

	// Set all card field disabled properties
	document.checkoutForm.Cardtype.disabled = disable;
	document.checkoutForm.Cardno.disabled = disable;
	document.checkoutForm.Expmonth.disabled = disable;
	document.checkoutForm.Expyear.disabled = disable;
}


// Decide whether or not the shipping information is the same as
// the billing information
function SetShippingFields(useBilling)
{
	var df = document.checkoutForm;
	var fieldList = new Array('title', 'fname', 'lname', 'company',
							  'street1', 'street2', 'city', 'state',
							  'zip', 'country');
	var field;
	var billingField;
	var shippingField;
	
	// Handle all form fields associated with shipping information
	for (field = 0; field < fieldList.length; field++)
	{
		// Create access variables for the shipping and billing fields
		billingField = eval('df.' + fieldList[field]);
		shippingField = eval('df.ship_' + fieldList[field]);

		// Is the shipping information the same as the billing information?
		if (useBilling)
		{
			// Is this field a select list?
			if (shippingField.type == 'select-one')
			{
				// Copy the billing information
				shippingField.selectedIndex = billingField.selectedIndex;
			}

			// Assume this field has a value property
			else
			{
				// Copy the billing information
				shippingField.value = billingField.value;
			}

			// Make this field uneditable
			shippingField.disabled = true;
		}

		// The shipping and billing information are different
		else
		{
			// Is this field a select list?
			if (shippingField.type == 'select-one')
			{
				// Reset the list selector
				shippingField.selectedIndex = 0;
			}

			// Assume this field has a value property
			else
			{
				// Clear the field value
				shippingField.value = '';
			}

			// Allow this field to be edited
			shippingField.disabled = false;
		}
	}
}


// Called in response to the customer order form being submitted
function CheckoutSubmitCheck()
{
	var df = document.checkoutForm;
	var billing;
	var shipping = true;
	var validate_shipping = false;

	// Validate all billing information
	billing = ValidateNotEmpty('First Name', df.fname) &&
			ValidateNotEmpty('Last Name', df.lname) &&
			ValidateNotEmpty('Street Address', df.street1) &&
			ValidateNotEmpty('City', df.city) &&
			ValidateState('State', df.state, df.country) &&
			ValidateNotEmpty('Zipcode', df.zip) &&
			ValidateNotEmpty('Email', df.email) &&
			ValidateCardNumber(df.Cardno);

	// Do we have a ship-same setting to evaluate?
	if (df.ship_same)
	{
		// Is the ship-same setting a checkbox?
		if (df.ship_same.type == "checkbox")
		{
			// We will validate shipping if the checkbox is not checked.
			validate_shipping = !df.ship_same.checked;
		}

		// The ship-same setting isn't a check box
		else
		{
			// Assume the ship-same field has a value property.
			validate_shipping = (df.ship_same.value == "false");
		}
	}

	// If billing data is OK, validate shipping data
	if (billing && validate_shipping)
	{
		shipping = ValidateNotEmpty('Shipping First Name', df.ship_fname) &&
				   ValidateNotEmpty('Shipping Last Name', df.ship_lname) &&
				   ValidateNotEmpty('Shipping Street Address', df.ship_street1) &&
				   ValidateNotEmpty('Shipping City', df.ship_city) &&
				   ValidateState('Shipping State', df.ship_state, df.ship_country) &&
				   ValidateNotEmpty('Shipping Zipcode', df.ship_zip);
	}

	// Allow form submission if both billing and shipping data are OK
	return billing && shipping;
}


// Called in response to the place order form being submitted
function PlaceSubmitCheck()
{
	// Has the form already been submitted?
	if (placeFormSubmitted)
	{
		// Tell the customer to be patient
		alert('The web server is taking an unusually long time to respond.  Please be patient.');
		
		// Prevent the form from being submitted a second time
		return false;
	}

	placeFormSubmitted = true;

	return true;
}


// Called in response to the item form submission event.
function OnAddItems(formName)
{
	var quantityField;
	var quantityMin;
	var quantityMax;
	var quantity;
	var total = 0;
	var limit;
	var name;
	var message;
	var i;

	// Has the form already been submitted?
	if (itemFormSubmitted)
	{
		// Tell the customer to be patient
		alert('The web server is taking an unusually long time to respond.  Please be patient.');
		
		// Prevent the form from being submitted a second time
		return false;
	}

	// Web TV can't deal, so bail
	else if (is.webtv)
	{
		// Allow submission.  Server will catch errors.
		return true;
	}

	// Use default form name if no name was specified
	if (typeof(formName) == 'undefined')
	{
		formName = 'itemForm';
	}

	// The first quantity field has no number
	quantityField = eval('document.' + formName + '.QTY');
	quantityMin   = eval('document.' + formName + '.QTY_MIN');
	quantityMax   = eval('document.' + formName + '.QTY_MAX');
	name          = eval('document.' + formName + '.ITEM_NAME');

	// Check every field on the form
	for (i = 1; i <= document.itemForm.length; i++)
	{
		// Does this quantity field exist?
		if (quantityField)
		{
			// Get the number of this item ordered
			quantity = parseInt(quantityField.value);

			// Is there a minimum quantity field?
			if (quantityMin)
			{
				// Get the lower limit value
				limit = parseInt(quantityMin.value);

				// Is the quantity value below the limit ?
				if ((quantity > 0) && (quantity < limit))
				{
					// Construct and display a pop-up message
					message = 'The minimum quantity allowed';
					if (name)
					{
						message += ' for ' + name.value;
					}
					alert(message + ' is ' + limit + '.');

					// Alter the form value and put the cursor there
					quantityField.value = limit;
					quantityField.focus();

					// Abort the form submission
					return false;
				}
			}

			// Is there a maximum quantity field?
			if (quantityMax)
			{
				// Get the upper limit value
				limit = parseInt(quantityMax.value);

				// Is the quantity value above the limit ?
				if (quantity > limit)
				{
					// Construct and display a pop-up message
					message = 'The maximum quantity allowed';
					if (name)
					{
						message += ' for ' + name.value;
					}
					alert(message + ' is ' + limit + '.');

					// Alter the form value and put the cursor there
					quantityField.value = limit;
					quantityField.focus();

					// Abort the form submission
					return false;
				}
			}

			// Total up the number of items ordered
			total += quantity;
		}

		// Generate the names of the next set of item fields
		quantityField = eval('document.' + formName + '.QTY' + i);
		quantityMin   = eval('document.' + formName + '.QTY_MIN' + i);
		quantityMax   = eval('document.' + formName + '.QTY_MAX' + i);
		name          = eval('document.' + formName + '.ITEM_NAME' + i);
	}
	
	// If nothing was ordered, deny the form submission
	if (total == 0)
	{
		alert('You must select at least one item to place in your shopping cart.');

		return false;
	}

	// Mark the item form as submitted
	itemFormSubmitted = true;

	// Allow the form submission
	return true;
}


// Called when the quantity up/down buttons are pressed on the product page.
function OnChangeQuantity(delta)
{
	// Create a reference to the quantity field
	var quantity = document.itemForm.qty;

	// Give a new value to the quantity field
	quantity.value = Math.max(Math.round(quantity.value) + delta, 1);
}


