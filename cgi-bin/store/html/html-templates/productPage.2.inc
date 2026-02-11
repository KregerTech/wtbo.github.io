
<FORM METHOD = "post" ACTION = "%%scriptURL%%">
 <TR> 
  
  <TD COLSPAN = "3"> 
      <HR align="center" noshade size="1">
    </TD>
  </TR>
  <TR> 
      <TD ALIGN="CENTER" VALIGN="MIDDLE"><font face="ARIAL" size="2"><b><font face="Arial, Helvetica, sans-serif" size="-1">%%name%%</font></b> 
        <font face="Arial, Helvetica, sans-serif" size="-1"><br>
        %%description%% <br>
        <font color="#FF0000">%%price%%</font></font> </font> </TD>
      <TD ALIGN="CENTER" valign="middle"><font face="Arial, Helvetica, sans-serif" size="-1">%%image%%</font></TD>
      <TD align="center" valign="middle"> <FONT FACE="ARIAL" SIZE="2"> 
        <input type = "hidden" name = "cart_id" value = "%%cart_id%%">
        <input type = "hidden" name = "product" value = "%%product%%">
        <input type = "hidden" name = "keywords" value = "%%keywords%%">
        <br>
        %%optionFile%% <br>
        </FONT>
        <p> <!--BEGIN SELECT QUANTITY BUTTON--> 
        <table>
          <tr align="CENTER"> 
            <td valign="MIDDLE"> 
              <input type="TEXT" name="%%itemID%%" size="3" maxlength="3" value="1">
            </td>
            <td valign="MIDDLE"> 
              <input type="IMAGE" name="add_to_cart_button" value="Add To Cart" src="%%URLofImages%%/add_to_cart.gif" border="0">
            </td>
          </tr>
        </table>
        <!--END SELECT QUANTITY BUTTON--> <FONT FACE="ARIAL" SIZE="2"><br>
        </FONT> </TD>
  </TR></FORM>