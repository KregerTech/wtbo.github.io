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
			Step 3:<br><br>
			<i>Play automatically?</i><br><br>
		</p>
		<p>
			Would you like for the stream to begin playing when the web page is loaded?<br><br>
			<br><font color="red">Warning:</font><br>This may result in very high transfer usage,  
			even on lower traffic sites, and it is generally not considered courteous to play audio 
			automatically on web pages within the web development community.
		</p>
		<hr>
	<?
	
	$type=$_REQUEST['type'];
	$color=$_REQUEST['color'];
	
	echo "<a href='stream_managerCodeGen_stage4.php?webStreamId=$webStreamId&type=$type&color=$color&autoplay=false' target='main'>No</a>, I do not 
	want the player to begin playing automatically<br><br>\n";
	
	echo "<a href='stream_managerCodeGen_stage4.php?webStreamId=$webStreamId&type=$type&color=$color&autoplay=true' target='main'>Yes</a>, I would like the player to begin playing automatically\n";
	
	
?>