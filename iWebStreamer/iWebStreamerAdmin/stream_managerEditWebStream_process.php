#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	
	$name=trim($_REQUEST['name']);
	$webStreamId=trim($_REQUEST['webStreamId']);
	if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
		$iWebStreamerErrorObj->registerCritical('Invalid WebStream Id.');
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
	
if($webStreamObj->setName($name)){
	$saveConf=true;
?>

<center><br><br><br>WebStream Edited Successfully.</center>

<?
	}else{
		$iWebStreamerErrorObj->registerCritical('Failed to edit WebStream.');
	}
?>