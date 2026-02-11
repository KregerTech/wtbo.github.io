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
		<p>
			Step 4:<br><br>
			<i>Replay Automatically?</i><br><br>
		</p>
		<p>
			Once started, would you like for the WebStream to replay automatically?<br><br>
		</p>
		<hr>
	<?
	
	$type=$_REQUEST['type'];
	$color=$_REQUEST['color'];
	$autoplay=$_REQUEST['autoplay'];
	
	echo "<a href='stream_managerCodeGen_stage5.php?webStreamId=$webStreamId&type=$type&color=$color&autoplay=$autoplay&repeat_playlist=true' target='main'>Yes</a>, I 
	would like for the WebStream to replay automatically.<br><br>\n";
	
	echo "<a href='stream_managerCodeGen_stage5.php?webStreamId=$webStreamId&type=$type&color=$color&autoplay=$autoplay&repeat_playlist=false' target='main'>No</a>, I would not like the WebStream to replay automatically.\n";
	
	
?>