#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	
	$webStreamId=trim($_REQUEST['webStreamId']);
	if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
		$iWebStreamerErrorObj->registerCritical('Invalid WebStream Id.');
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
?>


<script language="javascript" type="text/javascript">

	function validateForm(){
		var formForm = document.getElementById("EditWebStream");
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
	<form name="EditWebStream" id="EditWebStream" action="stream_managerEditWebStream_process.php?webStreamId=<?echo $webStreamId?>" method="POST">
	
		<?
			$name=$webStreamObj->getName();
		?>
	
		<tr valign="center" bgcolor="#F1F2F8">
			<td align="right">
				WebStream Name
			</td>
			<td align="left" nowrap>
			 	<input type="text" name="name" id="name" size="40" value="<?echo htmlentities($name);?>">
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
				<input class="button" type="button" id="submitButton" value="Update WebStream" onClick="validateForm()">
			</td>
		
			<td align="left">
			</td>
		</tr>
	</form>
</tabele>