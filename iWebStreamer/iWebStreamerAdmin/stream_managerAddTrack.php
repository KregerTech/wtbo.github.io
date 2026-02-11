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

<center><br><br>
	Would you like to 
	<a href="stream_managerAddWebStreamFromUploaded.php?webStreamId=<?echo $webStreamId?>">
	add a track from an mp3 you have uploaded</a> 
	<br><br>
	or 
	<br><br>
	<a href="stream_managerAddWebStreamFromRFAudio.php?webStreamId=<?echo $webStreamId?>">
	add a track from the royalty free audio included in this program
	</a>?
	<br><br><br><br>
	Haven't uploaded audio yet?
	<br>Click <a href="upload_front.php">here</a> to upload your mp3.
</center>
