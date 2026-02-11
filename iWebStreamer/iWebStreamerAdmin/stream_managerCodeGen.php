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
			Step 1:<br><br>
			<i>Choose the type of player you would like.</i><br><br>
		</p>
		<table border="1" cellpadding="3">
	<?
	
	foreach($webStreamObj->getAvailableTypes() as $index => $type){
		echo "<tr>\n";
			echo "<td>".$webStreamObj->getDefaultPlayerCode($type)."</td>\n";
			echo "<td><a href='stream_managerCodeGen_stage2.php?webStreamId=$webStreamId&type=$type' target='main'>".strtoupper($type)."</a></td>\n";
		echo "</tr>\n";
	}
	
	?>
		</table>
		</center>
	<?
	
?>


