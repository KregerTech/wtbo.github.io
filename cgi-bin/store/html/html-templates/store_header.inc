<html>
<head>
<title>%%mername%% Online Store</title>
</head>
<body marginwidth="0" marginheight="0" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" bgcolor="#FFFFFF">

<!--Start Header Here-->

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr bgcolor="%%colorcode%%">
    <td align="left" valign="middle"><img src="%%URLofImages%%/trans.gif" width="6" height="1" border="0" alt=""><img src="%%URLofImages%%/demo-logo.gif" width="350" height="50" border="0" alt="merchant.cgi"></td>
    <td align="right">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr bgcolor="#000000" height="25">
    <td align="left"><img src="%%URLofImages%%/pixel_trans.gif" width="6" height="1" border="0" align="absmiddle" alt=""><font face="Verdana, Arial" size="1" color="#FFFFFF">

     <script language="JavaScript">

		  		  var months=new Array(13);

		  		  months[1]="January";

		  		  months[2]="February";

		  		  months[3]="March";

		  		  months[4]="April";

		  		  months[5]="May";

		  		  months[6]="June";

		  		  months[7]="July";

		  		  months[8]="August";

		  		  months[9]="September";

		  		  months[10]="October";

		  		  months[11]="November";

		  		  months[12]="December";

		  		  var time=new Date();

		  		  var lmonth=months[time.getMonth() + 1];

		  		  var date=time.getDate();

		  		  var year=time.getYear();

		  		  if (year < 2000)

		  		  year = year + 1900;

		  		  document.write(lmonth + " ");

		  		  document.write(date + ", " + year);

		  		  </script>

     </font></td>
    <td align="right"><font face="Verdana, Arial" color="#FFFFFF" size="2">Current Subtotal: %%price%%</font> <a href="merchant.cgi?add_to_cart_button.x=yes&cart_id=%%cart_id%%&keywords=&viewOrder=yes"><img src="%%URLofImages%%/cart-checkout.gif" width="181" height="25" border="0" align="absmiddle" alt=""></a></td>
  </tr>
</table>

<!--End Header Here-->

<!--Start Body Here-->

<table border="0" width="100%" cellspacing="5" cellpadding="5">
  <tr>

<!-- Start Left Navigation Here -->

    <td width="125" valign="top"><table border="0" width="125" cellspacing="0" cellpadding="0">
      <tr>
        <td width="125">
            <table border="0" width="100%" cellspacing="0" cellpadding="2">
              <tr>
                <td bgcolor="%%colorcode%%" class="boxborder"><font face="Verdana, Arial" size="2">&nbsp;Navigation&nbsp;</font></td>
              </tr>
              <tr>
                <td><font face="Verdana, Arial" size="1">&nbsp;<a href="merchant.cgi?cart_id=%%cart_id%%">Catalog Home</a>&nbsp;<br>
                  &nbsp;<a href="merchant.cgi?page=aboutus.html&cart_id=%%cart_id%%">About Us</a>&nbsp;<br>
                  &nbsp;<a href="merchant.cgi?page=customerservice.html&cart_id=%%cart_id%%">Customer Service<br>
                  </a>&nbsp;<a href="merchant.cgi?page=refundpolicy.html&cart_id=%%cart_id%%">Refund Policy</a>
                  <br>
                  &nbsp;<a href="merchant.cgi?page=contactus.html&cart_id=%%cart_id%%">Contact Us</a>&nbsp; <br><br>
                  </font></td>
              </tr>
            <tr>
                <td bgcolor="%%colorcode%%" class="boxborder"><font face="Verdana, Arial" size="2">Quick
                  Find </font></td>
              </tr>
              <tr>
                <td>
                  <form method=POST action=merchant.cgi>
                    <input type="text" name="keywords" size="16" maxlength="60" value="">
                    <input type="hidden" name="cart_id" value="">
                    <input type="submit" name="search_request_button" value="Search">
                  </form>
                </td>
              </tr>
              
              <tr>
                <td bgcolor="%%colorcode%%" class="boxborder"><font face="Verdana, Arial" size="2">&nbsp;Categories</font></td>
              </tr>
              <tr>
              <td>
              <font face="Verdana, Arial" size="1">
              
              <!--start insert categories here-->
              
              
              %%insertcategories%%
              
              
              <!--end insert categories here-->
              
              <br>
              </font> </td>
              </tr>
            </table>
          </td>
      </tr>
    </table></td>

<!-- End Left Navigation Here -->
<td class="boxborder" valign=top>