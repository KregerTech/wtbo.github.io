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
		<center>
		<p>
			Step 2:<br><br>
			<i>Choose the player color</i><br><br>
		</p>
		<table border="1" cellpadding="3">
	<?
	
	$type=$_REQUEST['type'];
	
	foreach($webStreamObj->getAvailableColors($type) as $index => $color){
		echo "<tr>\n";
			echo "<td>".$webStreamObj->getFlashPlayerCode($type, $color, false, $color)."</td>\n";
			echo "<td><a href='stream_managerCodeGen_stage3.php?webStreamId=$webStreamId&type=$type&color=$color' target='main'>".strtoupper($color)."</a></td>\n";
		echo "</tr>\n";
	}
	
	?>
		</table>
		</center>
	<?
	
?>