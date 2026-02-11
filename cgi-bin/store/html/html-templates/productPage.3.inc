 <FORM METHOD = "post" ACTION = "%%scriptURL%%">
    <TR> 
      <TD COLSPAN = "2"> 
        <HR align="center" noshade size="1">
      </TD>
    </TR>
    <TR align="left"> 
      <TD VALIGN="MIDDLE" colspan="2"><font face="ARIAL" size="2"><b><font face="Arial, Helvetica, sans-serif" size="-1">%%name%%</font></b> 
        <font face="Arial, Helvetica, sans-serif" size="-1"><br>
        %%description%% <br>
        <font color="#FF0000">%%price%%</font></font> </font></TD>
    </TR>
    <TR> 
      <TD ALIGN="CENTER" VALIGN="MIDDLE"> 
        <INPUT TYPE = "hidden" NAME = "cart_id" VALUE = "%%cart_id%%">
        <INPUT TYPE = "hidden" NAME = "product" VALUE = "%%product%%">
        <INPUT TYPE = "hidden" NAME = "keywords" VALUE = "%%keywords%%">
        <BR>
        %%optionFile%% <BR>
        <P> <!--BEGIN SELECT QUANTITY BUTTON--> 
        <TABLE>
          <TR ALIGN="CENTER"> 
            <TD VALIGN="MIDDLE"> 
              <INPUT TYPE="TEXT" NAME="%%itemID%%" SIZE="3" MAXLENGTH="3" VALUE="1">
            </TD>
            <TD VALIGN="MIDDLE"> 
              <INPUT TYPE="IMAGE" NAME="add_to_cart_button" VALUE="Add To Cart" SRC="%%URLofImages%%/add_to_cart.gif" BORDER="0">
            </TD>
          </TR>
        </TABLE>
        <!--END SELECT QUANTITY BUTTON--> </TD>
      <TD ALIGN="CENTER"><font face="Arial, Helvetica, sans-serif" size="-1">%%image%%</font></TD>
    </TR>
  </FORM>