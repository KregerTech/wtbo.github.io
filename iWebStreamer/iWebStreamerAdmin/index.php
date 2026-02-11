#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	$sid = md5(uniqid(rand()));

?>
	
	
	<p>
	<br><br>
	<form name="postform" action="receive.php" method="post">
		<input id="mp3_file" type="hidden" name="mp3_file" value="" />
	</form>
	
	
	<form 
	enctype="multipart/form-data" 
	action="http://<?echo DOMAINNAME;?>/cp/iWebStreamer/upload.cgi?sid=<?php echo $sid; ?>" 
	method="post" 
	target="hidden_iframe" name="upload_helper_form" 
	/>
		<center>
			<table>
				<tr align="left">
					<font color="#F08946"><b>Your MP3 file</b></font>
					<input class="input" type="file" name="mp3_file"/>
				</tr>
				<div class="progresscontainer" style="display: none;">
					<div class="progressbar" id="mp3_file_progress"></div>
				</div>
	</form>
	
				<iframe name="hidden_iframe" style="border: 0;width: 0px;height: 0px;"></iframe>
				<br><br>
				</tr>
				<tr align="left">
				<input type="button"
				onclick="this.disabled=true;beginUpload(document.upload_helper_form.mp3_file
				, '<?php echo $sid; ?>');
				document.upload_helper_form.mp3_file.disabled=true;" 
				value="Submit" name="upload_button" id="upload_button">
	</p>
	</tr>
	</table>
	
</body>
<script language="javascript" type="text/javascript">
clear_form();
</script>
</html>