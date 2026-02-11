
// Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin, All rights reserved
// 
// This code may not be copied, borrowed, stolen, sold, resold, reused, 
// recycled, plagiarized, modified, or in any way used for anything at
// all without the express written permission of the author.


// Function AFCPair
// Create a new object composed of a form field name and a vcard field name
function AFCPair(fieldName, cardName)
{
	var pair = new Object();

	pair.name = fieldName;
	pair.card = cardName;

	return pair;
}


// Function AutoFormComplete
// Use autocompletion to fill out as much of the form as we can.
//
//		Parameters:
//			formObject			: The form object to be filled out
//			requestorName		: The name of the site making the request
//			suppressWarnings	: Do we skip warnings for unavailable data?
//
function AutoFormComplete(formObject, requestorName, suppressWarnings)
{
	var vcardData = new Array();
	var warnings = "";
	var result;
	var i;

	// If we don't have a userProfile object, we can't do anything
	if (!navigator.userProfile)
		return;

	// Create a mapping between the form elements and their vcard equivelents
	for (i = 0; i < formObject.elements.length; i++)
	{
		with (formObject.elements[i])
		{
			// Does this form element have a vcard association?
			if (formObject.elements[i].vcard_name)
			{
				// Create a name pair for this form field
				vcardData = vcardData.concat(new AFCPair(name, vcard_name));
			}
		}
	}

	// Did we see any form fields with vcard associations?
	if (vcardData.length > 0)
	{
		// Start with an empty request queue
		navigator.userProfile.clearRequest();

		// Add one request for each vcard element used
		for (i = 0; i < vcardData.length; i++)
		{
			navigator.userProfile.addRequest(vcardData[i].card);
		}

		// Perform the vcard data request
		navigator.userProfile.doReadRequest(2, requestorName);

		// Fill out the various form fields using the resulting vcard data
		for (i = 0; i < vcardData.length; i++)
		{
			// Get the resulting vcard value for this field
			result = navigator.userProfile.getAttribute(vcardData[i].card);

			// If we got no data, add this to the warning list
			if (result.length == 0)
				warnings += vcardData[i].card.substr(6) + "\n";

			// Fill out the form field
			else
				formObject[vcardData[i].name].value = result;
		}
	}

	// If we need to, display the warning list
	if ((warnings.length > 0) && !suppressWarnings)
	{
		alert("Information for the following fields could not be located:\n\n" +
			  warnings);
	}
}



// Function AutoFormInstructions
// Write basic instructions and a "Do It" button to the current page.
// Designed to be called by an in-line script during page loading time.
//
//		Parameters	:
//			formName	:	The name of the form object to autocomplete
//
function AutoFormInstructions(formName)
{
	// No userProfile object, no can do
	if (navigator.userProfile)
	{
		document.writeln(
'<hr>\n' +
'<div align="center"><b>\n' +
'If you have filled in your Internet Explorer Profile Assistant information,<br>\n' +
'your browser will be able to fill most of this form in for you.<p>\n' +
'<input type=button value="Automatic Form Completion"\n' +
'    class="buttonNormal"\n' +
'    onMouseOver="this.className = ' + "'" + 'buttonOver' + "'" + ';"\n' +
'    onMouseDown="this.className = ' + "'" + 'buttonDown' + "'" + ';"\n' +
'    onMouseOut="this.className = ' + "'" + 'buttonOut' + "'" + ';"\n' +
'    onClick="AutoFormComplete(document.' + formName + ');">\n' +
'</b></div><br>\n' +
'<hr>\n');
	}
}


