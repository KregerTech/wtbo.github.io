#!/usr/local/dev/bin/php
<?php
	$sid = md5(uniqid(rand()));
?>
<html>
<head>
	<title>Mp3 Uploader</title>
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<script language="javascript" type="text/javascript" src="prototype.js"></script>
	<script language="javascript" type="text/javascript" src="upload.js">></script>
	<script language="javascript" type="text/javascript">
	
	function clear_form(){
		form_upload_button = document.getElementById("upload_button");
		form_upload_button.disabled=false;
		document.upload_helper_form.mp3_file.disabled=false;
		document.upload_helper_form.mp3_file.value="";
	}
	
	</script>
	<link rel="stylesheet" href="upload.css" type="text/css" media="screen" title="Upload" charset="utf-8" />
</head>
<body onLoad="clear_form();">
	<p>
	<br><br>
	<form name="postform" action="receive.php" method="post">
		<input id="mp3_file" type="hidden" name="mp3_file" value="" />
	</form>
	
	<form enctype="multipart/form-data" 
		action="http://audiotesting.christianwebhost.com/cp/iWebStreamer/testing/upload/cgi-bin/upload.cgi?sid=<?php echo $sid; ?>" method="post" 
		target="hidden_iframe" name="upload_helper_form" />
		
		<input class="input" type="file" name="mp3_file"/>
		
		<div class="progresscontainer" style="display: none;">
			<div class="progressbar" id="mp3_file_progress"></div>
		</div>
	</form>
	<iframe name="hidden_iframe" style="border: 0;width: 0px;height: 0px;"></iframe>
	
	<input type="button" onclick="this.disabled=true;beginUpload(document.upload_helper_form.mp3_file, '<?php echo $sid; ?>');
	document.upload_helper_form.mp3_file.disabled=true;" value="Submit" name="upload_button" id="upload_button">
	</p>
</body>
</html>