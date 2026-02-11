#!/usr/local/dev/bin/php
<?
	require_once(dirname(__FILE__).'/initialize.php');
	require_once(dirname(__FILE__).'/navbar.php');
?>


<script language="javascript" type="text/javascript">

	function validateForm(){
		var formForm = document.getElementById("addNewWebStream");
		var thisFormName =  document.getElementById("name");
		if(thisFormName.value==''){
			alert("You must enter a name for this WebStream.");
			thisFormName.focus();
			return false;
		}else{
			formForm.submit();
		}
	}
	
</script>

<table width="100%" align="center">
	<form name="addNewWebStream" id="addNewWebStream" action="stream_managerAddNewWebStream_process.php" method="POST">
		<tr valign="center" bgcolor="#F1F2F8">
			<td align="right">
				WebStream Name
			</td>
			<td align="left" nowrap>
			 	<input type="text" name="name" id="name" size="40">
			</td>
			<td align="left">
				WebStream Names will appear in certain variations of the flash player.
			</td>
		</tr>
		
		<tr align="center">
			<td align="right">
			</td>
		
			<td>
				<br>
				<input class="button" type="button" id="submitButton" value="Create WebStream" onClick="validateForm()">
			</td>
		
			<td align="left">
			</td>
		</tr>
	</form>
</tabele>