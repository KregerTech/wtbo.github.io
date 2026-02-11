-------------------------------------------------------------------------------
All Perl and JavaScript source code files in this zip archive contain legal information regarding licensing of those files.
All portions of Perlshop 4 that are derived from the original Perlshop 3.1 package are distributed under the
GNU General Public Licence (http://www.gnu.org/licenses/gpl.html).  All other source code is proprietary.


-------------------------------------------------------------------------------
First Time Perlshop 4 Installation Instructions

1:	Unzip the Perlshop 4 zip archive.

2:	Create all of the web server directories required by Perlshop.  You may do this in any one of three ways:
	- You may use the CREATE script included in the zip archive.  This script required command shell access to the web server.  Please see the on-line documentation for details.
	- You may use the ps_create.cgi program.  Please see the on-line documentation for details.
	- You may use your favorite FTP program to create the directories by hand.  Please use the CREATE script as a reference to ensure that you have created all of the required directories.

3:	Copy all files from the Public HTML directory of the zip archive to your main html directory.  This will be the directory where your web site index.html file is.  Make sure these files are copied to your server in ASCII mode.

4:	Copy all files from the JavaScript directory of the zip archive to your main html directory.  This will be the directory where your index.html file is.  Make sure these files are copied to your server in ASCII mode.

5:	Copy all files from the Catalog HTML directory of the zip archive into your Perlshop catalog directory.  Make sure this file is copied to your server in ASCII mode.  Once it has been installed, you MUST alter the contents of your copy of this file to suit your business model.

6:	Create a new directory called "credit" under your server images directory.  Copy all of the credit card image files into this directory.  Make sure these files are copied to your server in binary mode.

7:	Copy all files from the cgi-bin directory of the zip archive into your CGI directory.  Make sure these files are transferred in ASCII mode.  

8:	Copy the contents of the archive plugins/files directory into the web server plugins/files directory.  Make sure these files are copied to your server in ASCII mode.

9:	Use a text editor to change the first line of the perlshop.cgi file to reflect the local conditions at your ISP.

10:	Copy the ps.cfg file from the zip archive to your CGI directory.  Make sure these files are copied to your server in ASCII mode.

11:	Alter the configuration settings in the ps.cfg file to suit the needs of your store.  All settings are documented inside the cfg file.  Many settings are also discussed in detail in the Perlshop 3 manual.



Upgrading from a Previous Version of Perlshop 4

0:	Make full backups of all of your current Perlshop 4 related web server files.

1:	Unzip the Perlshop 4 zip archive.

2:	Read the release notes below.  Make any necessary changes or additions to your EXISTING ps.cfg file.

3:	Copy all files from the Public HTML directory of the zip archive to your main html directory.  This will be the directory where your web site index.html file is.  Make sure these files are copied to your server in ASCII mode.

4:	Copy all files from the JavaScript directory of the zip archive to your main html directory.  This will be the directory where your index.html file is.  Make sure these files are copied to your server in ASCII mode.

5:	Copy all files from the cgi-bin directory of the zip archive into your CGI directory.  Make sure these files are transferred in ASCII mode.  

6:	Copy any new files from the archive plugins/files directory into the web server plugins/files directory.  If these directories do not exist, you will need to create them.  Make sure the files are copied to your server in ASCII mode.

7:	Use a text editor to change the first line of the perlshop.cgi file to reflect the local conditions at your ISP.


-------------------------------------------------------------------------------
Version History

Perlshop 4.5 Development Version 4 (4.5.00) 
1 May 2004

1.	CGI data is now processed by the standard Perl CGI module.

2.	The static catalog page processing algorithm has been improved for efficiency and speed.

3.	The PSDBI catalog page processing algorithm has been improved for efficiency and speed.
	An upgraded version of the PSDBI software package is needed to support this version of Perlshop.
	Existing PSDBI customers can contact Waverider Systems for a free upgrade.

4.	Discounts may now be computed by user-authored plugins.  The 'compute_discount' and 'item_note' plugin events have been
    added to support this feature.

5.	The existing "minimum order subtotal" feature has been enhanced.  The error message now uses the local currency
	settings in the ps.cfg file, and the error page generated by Perlshop now supports custom message content.
	Please see the $minimum_price and $minimum_price_note settings in the ps.cfg file for details.

6.	A "minimum order item count" feature has added.  Please see the $minimum_quantity and $minimum_quantity settings
	in the ps.cfg file for details.


-------------------------------------------------------------------------------
Version History

Perlshop 4.4 Release Version, Service Pack 3 (4.4.03) 
28 February 2004

1.	Added support for the YourPay real-time transaction interface.

2.	Corrected a minor HTML format bug that was preventing the default order form page 
from displaying correctly in Netscape 6. 

3.	Corrected a computation bug that manifested when computing the shipping fee.  
The bug would occur when the shipping mode was set to 'price' and one or more of
the items in the shopping cart were marked for free shipping.


-------------------------------------------------------------------------------
Version History

Perlshop 4.4 Release Version, Service Pack 2 (4.4.02) 
20 July 2003

1.	Cart contents will be sorted by item code on the final invoice.

2.	Added support for the 'orderid' plugin event.

3.	There is no longer a limit to the number of parameters that can be supplied to a plugin.


-------------------------------------------------------------------------------
Version History

Perlshop 4.4 Release Version, Service Pack 1 (4.4.01)
1 December 2002

1.	Added the $card_security_code option.  
	This optional feature allows you to ask for credit card security code numbers
	on your order form.  See the ps.cfg file for details.

2.	Added the ability to display item thumbnail images in the shopping cart screen.
	See the ps.cfg file for details.

3.	Added support for customer data file encryption.
	This is intended for use with Perlshop Office v2.4.
	See the ps.cfg file for details.

4.	Added function PlaceSubmitCheck to the JavaScript library.
	This function ensures that the final Place Order button does not get clicked
	more than once.  This prevents duplicate order submissions.
	This function is called automatically.  You do not have to do anything to
	use this feature.


-------------------------------------------------------------------------------
Version History

Perlshop 4.4 Release Version (4.4.00)
12 August 2002

1.	Real-time credit card transaction processing is no longer a part of the free Perlshop package.
	See the Waverider Systems website for details on the nearly-free Real-Time Credit Card Processing module.

2.	Shipping and Handling fees can now be taxed according to the local laws of your municipality.
	These items will be listed on the invoice as "additional taxes".

3.	Added the plugin module self-initialization interface.

4.	Added the plugin module self-test interface.

5.	Added plugin module self-test results to the Perlshop Self Test page.

6.	The default behavior for a Perlshop CGI call with no CGI arguments is now Self Test.

7.	Added the 'add_to_company_email' plugin event.  This event is for use by plugin modules that want to add their
	own data to the company copy of the invoice email.

8.	Added the ps_plugin and ps_selftest support libraries.


Changes:
1.	Removed support for First Virtual Bank - they went out of business several years ago.


-------------------------------------------------------------------------------
Version History

Perlshop 4.3 Release Version, Service Pack 5 (4.3.05)
4 July 2002

1.	Corrected a bug relating to the processing of the item_data tag.


-------------------------------------------------------------------------------
Version History

Perlshop 4.3 Release Version, Service Pack 4 (4.3.04)
28 May 2002

1.	The Handling Fee table can now contain equations, just like the Shipping Fee table does.

2.	PayPal is now formally supported as a credit card processor.  See the documentation in the ps.cfg file for details.

3.	Plugin related changes:
	- The <!--#plugin event --> tag now supports parameter values.
	  Example: <!--#plugin event_name param1 param2 -->

4.	All Perl and JavaScript source code files in this zip archive contain legal information regarding licensing of 
	those files.  


-------------------------------------------------------------------------------
Version History

Perlshop 4.3 Release Version, Service Pack 3 (4.3.03)
9 February 2002

1.	Plugin event changes:
	- The "before_add_item" data processing plugin event now works with QuickBuy mode.
	- Added a new event called "before_check_out".  Please see the on-line documentation for details.

2.	Added the following new settings to the ps.cfg file:
	- $cart_content_caption
	- $email_invoice_term
	- $email_title_line
	- $email_to_customer
	- $email_to_store
	- $final_preview_cart_instructions
	- $minimum_price
	- $view_cart_instructions
	- @orderFormTitles
	- %orderFormFields

3.	The JavaScript library function called OnAddItems() has been enhanced to prevent an "Add To Cart" form from being submitted more than once for a given catalog page.  This is done to make the shopping experience easier on the customer using a slow connection.

4.	A new JavaScript library function called URLWindow() has been added.  This is a general purpose function that allows you to pop open a new browser window with its own name and URL.

5.	This release contains a number of internal enhancements allowing easier integration between Perlshop 4 and complex database search plugins.

6.	This release contains the new ps_clean.cgi program.  This program is used to manually execute the CLEAN script on web servers that do not have Crontab support or access to the command line.

7.	This release contains the new ps_create.cgi program.  This program is used to manually execute the CREATE script on web servers that do not have access to the command line.

8.	Initial support for Billpoint as as payment option has been added to this release.

9.	The internal self-test routine has been enhanced and can now be called from the browser by using the new "selftest" action.  Example: http://www.yourstore.com/cgi-bin/perlshop.cgi?action=selftest

10.	All shopping cart support routines have been moved into a new support library called ps_cart.pl.

11.	The Shipping Table can now support multiple countries per table entry.

12.	Error checking and reporting for order form Country and State values has been improved in various ways.


-------------------------------------------------------------------------------
Version History

Perlshop 4.3 Release Version, Service Pack 2 (4.3.02)
3 August 2001

1.	Added support for ECML based credit card transaction processing.
	This includes support for the following organizations:
		- Bank of America

2.	Added support for the new VeriSign Partner program.

3.	Added a wide range of invoice related events.  See the on-line documentation for details.

4.	If the shipping type is set to "included", shipping options are no longer displayed on the check out form.

5.	Added the $form_submission_method and $cache_control settings to the security section of the ps.cfg file.


-------------------------------------------------------------------------------
Perlshop 4.3 Release Version, Service Pack 1 (4.3.01) 
27 April 2001

1.	Added support for PayPal Business Account Web Accept.

2.	Extended payment type processing to accept any value that starts with the string 'credit' in place of the old logic that required the single word 'credit'.

3.	Added support for "Purchase Order" as a payment mode.

4.	Added support for customized order form pages.
	See the ps.cfg file for the new $orderFormPage setting.

5.	Added support for a timezone offset between your web server and your physical business location.  
	See the ps.cfg file for the new $store_timezone_offset setting.

6.	Added the @countries_requiring_state setting.  This setting tells Perlshop which countries require a state code entry on the order form.  By default, this list of countries is Australia, Canada, and the US.  Other countries may be added to this list as needed for your business.
	See the ps.cfg file for details.

7.	This release allows browser caching of the final invoice screen.

8.	Plugins can now be called from anywhere in any catalog page by using the new <!--#plugin event --> tag.
	See the on-line plugin documentation for details.

9.	Old incomplete orders can now be completed even if the order token file has been cleaned away.
	This allows better integration with Perlshop Office.

10.	New shipping table display related plugin events have been added.  See the on-line plugin documentation for details.

11.	The !ORDERID! value is no longer required when you are using the "enter" or "quickbuy" commands.

12.	The optional STAY_ON_PAGE input parameter can now take the value "skip".  This will cause an "Add to Cart" command
	to move directly to the next catalog page without displaying the shopping cart contents. 

13.	Added some minor internal enhancements to allow better operation with Windows web servers.


The following minor bugs have been corrected:
1.	The item_data tag now supports product names that contain colons.
2.	Corrected a problem with the PLACE ORDER link.  This problem existed only on sites using real-time payment processing in non-QuickBuy mode.
3.	Corrected a parsing bug that prevented !MYURL! from working correctly when used inside a form.
4.	Corrected an ancient Perlshop 3 format bug in the invoice generator.
5.	Corrected a bug in the ITEM_DATA tag processor that kept a QTX_MAX value of -1 from working correctly in all cases.


-------------------------------------------------------------------------------
Perlshop 4.3 Release Version
17 December 2000

1.	Added support for VeriSign/Signio real-time credit card processing support.
	This includes the following VeriSign partners:
		- American Express Payflow
		- First Interstate Financial Services
		- National Bankcard Systems (eNBS)
		- pay|Net Merchant Services
		- Wells Fargo Bank

2.	A new product data tag called ITEM_SHIPTYPE has been defined.  See the on-line documentation at Waverider Systems for details.

3.	A new product data tag called ITEM_DATA has been defined.  See the on-line documentation at Waverider Systems for details.

4.	New product data tags called QTY_MIN and QTY_MAX have been defined.  The JavaScript OnAddItems function has been enhanced to work with these values.  See the on-line documentation at Waverider Systems for details.

5.	A new "enteraction" input parameter has been added.  This gives Perlshop web sites the ability to combine the Enter action with something other than a catalog page file load.

6.	Customer check-out related code was moved into an external library file called ps_checkout.pl.

7.	Many new style classes have been defined for use with the Order Form, Shopping Cart, and Shipping display screens.  See the on-line style sheet documentation for details.

8.	The CREATE script has been extended to create the 'plugins' and 'plugins/files' directories.

9.	Real-time transaction authorization reference data is now included in the company copy of the order email.

10.	Extra copies of the store order email can be sent to a programmable cc email list.
	See the ps.cfg file $mail_order_cc_list setting for details.

11.	Made the old regular expression matching option for the search interface a configurable option. 
	See the ps.cfg file $searchRegExp setting for details.

12.	Added the ability to use a custom web page in place of the standard search interface.
	See the ps.cfg file $searchCatalogPage setting for details.

13.	Added the ability to reject orders from specific countries.
	See the ps.cfg file @reject_country_codes setting for details.


New features contributed by other authors:
1.	Chris Milner contributed code that eliminates the need to re-complete the order form if the customer has selected the "Continue Shopping" link after having filled out the order form.

2.	Phil Plumbo contributed code that lets QuickBuy mode use a specific Order ID.  See the on-line QuickBuy Mode documentation for details.


The following bugs have been corrected:
1.	The Update Shopping Cart command now deletes the 'orders' file if all items have been removed from a shopping cart.
	(This was a four year old bug from Perlshop 3 that was found by a User's Group member - thanks Glenn)

2.	The search function now works correctly with non-standard catalog subdirectory locations.

3.	Added logic to allow images on the final checkout page to use the secure image URL.  
	Change contributed by Cheryl Lambert.


-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 7 (4.2.07)
20 October 2000

The following features have been added:
1.	Support for real-time transaction processor WorldPay has been added.
	A separately downloaded WorldPay Support Package is required for this feature.
	Paul Southcott was co-author for this addition.

2.	Support for 'rebate' items has been added.  A new section has been added to the ps.cfg file to support this.
	A new rebate field has been appended to the customer file layout.  
	The shopping cart table will display rebates using the 'rebateRow' style class, if defined. 

3.	The Perlshop Plugin API has been further improved.  New event types have been added, and we now have support
	for "internal", "file", and "text" plugins.  See the external documentation for details.

4.	Defined Transmission Error 11 to assist in handling problems with internal plugin calls.

5.	Perlshop can now send automatic email to your store webmaster in response to Transmission Errors and other
	internal checks that result in error.  See the new $webmaster_email setting in the ps.cfg file for details.

6.	Invoice email may now be sent as HTML.  This optional feature requires the Perl MIME::Lite library module.
	See the ps.cfg file for details.

7.	The Search Results screen is now somewhat configurable.  See the ps.cfg file Search Configuration section
	for details.  The search results table header row will be displayed using the 'searchResultHeader' class style,
	if defined.  Search results table data rows will be displayed using the 'searchResultData' class style,
	if defined.

8.	Your tax rate table may now be stored in an external configuration file.  This makes it easier for business
	owners in municipalities with complex tax laws (Florida) to maintain their tax tables, and allows Perlshop
	to delay the processing of the tax table data until the customer checks out.  See the tax configuration 
	section of the ps.cfg file for details.
	

The following bugs have been corrected:
1.	The Update Shopping Cart command now correctly supports shopping carts with mixed tax types.
	(This was a four year old bug from Perlshop 3 that was found by a User's Group member - thanks Chris)


-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 6 (4.2.06)
30 September 2000

The following features have been added:
1.	Support for real-time transaction processor Ecommerce Exchange (ECX) has been added.

2.	The Perlshop Plugin API has been enhanced to allow for a wider range of parameter and event types.

3.	The example Calendar Plugin has been enhanced to better demonstrate plugin parameter passing.
	Calendar plugin file has been renamed ps_plugin_gencal.pl.

4.	The state tax table may include optional zip code values.

5.	Added support for the xssi printenv command.

6.	Additional Perlshop library module support diagnostics have been added.

7.	Email transmission related code was moved into an external library file called ps_email.pl.

8.	Support was added for DevMailer for Windows 2000 (beta level).

9.	The order form page may now use a specific style rule.

10.	Added support for Switch and Solo type debit cards (beta level).

11.	Standard web server configuration setup now includes optional settings that allow the css and js files to be located 
in specific subdirectories.

12.	The ps.cfg file has new or improved documentation for many configuration settings.


The following minor bugs have been corrected:
1.	US and Canadian phone numbers may now contain '.' characters, as in "800.555.1212".


NOTE: Plugin users must pay specific attention to the plugin section of the new ps.cfg file.  The plugin configuration support structure of the ps.cfg file has changed.

NOTE: The use of the $catalog_home setting has changed for some sites.  Please read the documentation in the new ps.cfg file to understand the change that may need to be made to your existing Perlshop 4 installation.
	

-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 5 (4.2.05)
29 August 2000
This release pertains to the Perlshop Search module (ps_search.pl) only.  
This library module has been upgraded from version 1.0 to version 1.1.

The following features have been added:
1.	Search result pages are now displayed by page title, not page file name.  The page title is copied from the <title>
	tags of the page in question, if present.  If no title can be found, the page file name will be used.

2.	Search results are sorted alphanumerically by page title.
	

-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 4 (4.2.04)
14 July 2000

The following minor features have been added:
1.	Optional $top_logo setting now supported by ps.cfg file.

The following minor bugs have been repaired:
1.	Case insensitivity added to tax table state check.
	

-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 3 (4.2.03)
25 June 2000

The following minor features have been added:
1.	Real-time transaction related code was moved into an external library file called ps_transact.pl.
2.	QuickBuy mode has been formally released. 
	

-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 2 (4.2.02)
This version was released only to test sites.

The following minor features have been added:
1.	Back-end only mode was added to this release. (This may be removed in a future version)
2.	Additional support for the PSDBI package was added to this release.
3.	Search related code was moved into an external library file called ps_search.pl.
	

-------------------------------------------------------------------------------
Perlshop 4.2 Release Version, Service Pack 1 (4.2.01)
This version was released only to test sites.

The following minor bugs have been corrected:
1.	An http header generation problem was repaired.  This bug only occured if cookies were enabled and the order ID value had become corrupted.

The following minor features have been added:
1.	The QuickBuy mode prototype was added to this release.
	

-------------------------------------------------------------------------------
Perlshop 4.2 Release Version (4.2.00)
26 May 2000

This version of Perlshop brings on-line transaction processing back to life for Perlshop.

Supported on-line transaction approval mechanisms are:
	- MerchanTrust Global Commerce 2000, by Merchant Commerce 
	(www.merchanttrust.com) (formerly ATS Bank)
	Credit cards and virtual checks are both supported.
	
	- EFT Secure, by Network 1 Financial
	(used by Charge.com)
	Credit cards and virtual checks are both supported.

This version of Perlshop has full support for the Perlshop Database Interface package, including catalog page templates.

The following minor features have been added:
1.	A 'Continue Shopping' link is now present on the Shipping Rates page.
	

-------------------------------------------------------------------------------
Perlshop 4.1 Release Version, Service Pack 3 (4.1.04)
20 May 2000

This version contained preliminary test support for MerchanTrust credit card processing,
and was only released to test sites.


-------------------------------------------------------------------------------
Perlshop 4.1 Release Version, Service Pack 3 (4.1.03)
12 May 2000

The following bug has been corrected:
1.	Tax Type value of 'none' is now working correctly.


-------------------------------------------------------------------------------
Perlshop 4.1 Release Version, Service Pack 2 (4.1.02)
6 May 2000

Support for PayPal has been added to this release:
1.	PayPal is now listed as a possible payment method in the ps.cfg file.
2.	If PayPal is an accepted payment mode, a PayPal logo will be displayed along with the various credit card logos at the 
top of the order page.  This logo image is supplied as a part of this zip archive.
3.	If the chosen payment method is PayPal, instructions on making payment are displayed at the top of the final invoice page.


The following minor features have been added:
1.	Perlshop 4 now supports a called to an external user supplied order post-processing plugin program.
2.	If the customer credit card information is to be sent by email, only the store copy of the email includes this data.


Additional:
1.	The existing order completion software has been enhanced for efficiency.
2.	Improved file error checking has been added to the existing order completion software.


-------------------------------------------------------------------------------
Perlshop 4.1 Release Version, Service Pack 1 (4.1.01)
28 April 2000

The following minor features have been added:
1.	Period characters are now ignored during the state code validity check.
2.	The Perlshop logo image can be specified via the new $perlshop_logo setting in the ps.cfg file.
	Default behavior is to use the image file that was hard-coded in previous versions.
3.	Perlshop and Waverider Systems logo images are now included in the Perlshop 4 zip archive.
4.	A new section on internal security control, including two new settings and related documentation, 
	has been added to the ps.cfg file.  
5.	The log file locking mechanism has been improved to eliminate a potential time-out.
6.	The keyword 'OTHER' has been added as an optional value for the Tax_States table.


-------------------------------------------------------------------------------
Perlshop 4.1 Release Version
8 April 2000

The following bug has been corrected:
1.	The return shopper cookie now displays the year as a full 4 digit value.


Additional:
1.	The PSDBI interface to PS4 is now stable and complete.


-------------------------------------------------------------------------------
Perlshop 4 Beta 7

The following feature has been added:
1.	The number '0000 0000 0000 0000' is now considered valid for all types of credit card.  This is intended for diagnostic testing of new PS installations.


The security section of the ps.cfg file has seen the following additions:
1.	The new $secure_server_domain setting is needed to support Perlshop Office.


The following bugs have been corrected:
1.	The 'Shipping Rates' links and buttons do not display if the shipping type is set to 'none'.
2.	The 'credit card on email' feature was broken during Beta 5.  It has been fixed.


Additional:
1.	The Plugin API was altered to make it simpler to configure plugins.
2.	Beta 7 contains the support infrastructure needed for the PSDB project.  No functional changes related to this support infrastructure are present in this release.


-------------------------------------------------------------------------------
Version Changes

Perlshop 4 Beta 6

The following bugs have been corrected:
1.	Countries with no states or provinces are now handled correctly during checkout.
2.	The $catalog_home value is used with the "Return to Home Page" button on the final invoice screen.


The email section of the ps.cfg file has seen the following additions:

# Include invoice number in the subject of both customer and store copies of 
# the email?    ('yes' or 'no')
$email_id_in_subject        = 'yes';

# Include store name in the subject of both customer and store copies of 
# the email?    ('yes' or 'no')
$email_storename_in_subject = 'yes';

# Include customer last name in the subject of the store copy of the email?
# ('yes' or 'no')
$email_lastname_in_subject  = 'yes';	



-------------------------------------------------------------------------------
Version Changes

Perlshop 4 Beta 5


The ps.cfg file has seen the following modifications:
1.	The $secure_image_directory value has been moved up to be with the other secure server settings.
2.	A new setting named $secure_css_directory has been added.  This works just like the $secure_image_directory value, except that it is used by Perlshop to reference .css files on a secure server.
3.	A new setting named $secure_script_directory has been added.  This works just like the $secure_image_directory value, except that it is used by Perlshop to reference .js files on a secure server.
4.	The global style sheet value is now just a single file name, not a full file path.


Perlshop has had the following modifications made to it:
1.	When running on a secure server, all .css and .js files are now automatically referenced by secure server URL.
2.	The secure server process begins with the checkout page, and stays enabled all the way through the end of the ordering process.
3.	The format of the customer invoice has been improved for clarity.  No changes have been made to information content.
4.	The Perlshop check for valid state code values now includes Canadian provinces and territories.
5.	Diagnostic information content for Transmission Errors 5 and 6 has been improved


Perlshop has had the following cosmetic changes made to it:
1.	All credit card images have been replaced with superior graphics.  Also, there is now an image for the JCB card.  Please replace your existing credit card images with the new ones from this zip file.


The following bugs have been corrected:
1.	The orderfaq.html file now references the correct style sheet URL.
2.	The country.html file now references the correct style sheet URL.
3.	The order form now displays correctly for businesses that do not accept credit cards.



