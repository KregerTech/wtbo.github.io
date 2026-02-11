#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	
	$webStreamId=trim($_REQUEST['webStreamId']);
	if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
		$iWebStreamerErrorObj->registerCritical('Invalid WebStream Id.');
	}
	
	$fileId=intval($_REQUEST['rfAudioFile_id']);
	$isRFAudio=true;
	
	if(!$fileObj=$rfaudio_infoObj->getRfAudioFileObjById($fileId)){
		$iWebStreamerErrorObj->registerCritical('File id does not exist');
	}
	
	//Begin adding this file to the WebStream
	
	if($webStreamObj->addWebStreamFile($fileId, $isRFAudio)){
		$webStreamFileId=$webStreamObj->idCount-1;
		$saveConf=true;
		//enter nav bar here
		require_once(dirname(__FILE__).'/navbar.php');
		?>
		<br><br><br>
			<table align="center" cellpadding="5" cellspacing="5">
				<tr align="center">
					<td>
						Track added successfully.
					</td>
				</tr>
			</table>
		<?
	}else{
		$iWebStreamerErrorObj->registerCritical('Error adding file to the WebStream.');
	}
?>