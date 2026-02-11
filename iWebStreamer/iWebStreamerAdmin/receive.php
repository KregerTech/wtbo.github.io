#!/usr/local/dev/bin/php
<?php
$tmp_dir="/tmp";
$title = $_POST['hidden_title'];
$author = $_POST['hidden_author'];
$full_file_name = $_POST['hidden_full_file_name'];
$sid = $_POST["mp3_file"];

if(!empty($sid)) {
	require_once("initialize.php");
	require_once("receive_helper.php");
	$result = receive($sid);
	cleanup($sid);

?>
	<center>
	<table>
	<tr><td height="100">
	<tr><td>
	<font color="#0000D2" size="-2"><b><?echo $result;?></b></font><br><br>
	</td>
	<tr><td><a href="http://<?echo DOMAINNAME?>/cp/iWebStreamer/upload_front.php">Upload another MP3?</a>
	</font></b>
	</td></tr>
	</table>
	</p>
</body>
</html>
<?
}else{
	?>
	<center>
	<table>
	<tr><td height="100">
	<tr><td>
	<font color="#0000D2" size="-2"><b>sid not empty</b></font><br><br>
	</td></tr>
	</table>
	</p>
</body>
</html>
<?
}

/**
* Clean up temporary files
*/
function cleanup($sid) {
	global $tmp_dir, $_FILES;
	$files = array("_flength","_iWebStream_postdata","_err","_signal","_qstring");
	foreach($files as $file) {
		if(file_exists("$tmp_dir/$sid$file")) {
			unlink("$tmp_dir/$sid$file");
		}
	}
}