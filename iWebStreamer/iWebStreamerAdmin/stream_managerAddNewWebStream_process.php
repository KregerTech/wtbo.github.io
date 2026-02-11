#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	
	$name=trim($_REQUEST['name']);
	
	
	if($webstreamInfoObj->addNewWebStream($name)){
		$saveConf=true;
		$webStreamId=$webstreamInfoObj->idCount-1;
		require_once(dirname(__FILE__).'/navbar.php');
?>

<center><br><br><br>WebStream Added Successfully.</center>

<?
	}else{
		$iWebStreamerErrorObj->registerCritical('Failed to add new WebStream.');
	}
?>