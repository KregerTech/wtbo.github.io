#!/usr/local/dev/bin/php
<?

	//pass fileId or rfAudioFile_id through the get or post array
	//m3player will be created and begin playing track.

	global $_REQUEST;
	
	require_once(dirname(__FILE__).'/../../../iWebStreamerAdmin/initialize.php');
	
	if(isset($_REQUEST['fileId'])){
		$fileId=intval($_REQUEST['fileId']);
		if(!$fileObj=$fileInfoObj->getFileObj($fileId)){
			$iWebStreamerErrorObj->registerCritical("Invalid file id.");
		}
		$song_url=$fileObj->getDirectUrl();
		$song_title=$fileObj->getTitle();
	}
	
	if(isset($_REQUEST['rfAudioFile_id'])){
		$rfAudioFileId=intval($_REQUEST['rfAudioFile_id']);
		if(!$rfAudioFileObj=$rfaudio_infoObj->getRfAudioFileObjById($rfAudioFileId)){
			$iWebStreamerErrorObj->registerCritical("Invalid royalty free audio file id.");
		}
		$song_url=$rfAudioFileObj->getDirectUrl();
		$song_title=$rfAudioFileObj->getTitle();
	}
	
	if((!isset($_REQUEST['rfAudioFile_id']))&&(!isset($_REQUEST['fileId']))){
		$iWebStreamerErrorObj->registerCritical("Bad url passed.  Url must pass a file id.");
	}
	
?>
<table bgcolor="#d8d8d8" valign="top" align="center" cellpadding="0" cellspacing="0" border="0" width="100%" height="100%">
<tr valign="top" align="center"><td valign="top" align="center">
<div id="flashcontent" align="center" valign="top"></div>
<script type="text/javascript" src="../flashobject.js"></script>
<script type="text/javascript">
		var fo = new FlashObject("previewPlayer.swf?playlist_size=1&autoplay=true&song_url=<?echo $song_url;?>&song_title=<?echo $song_title;?>&rand=<?echo rand();?>", "mymovie", "400", "15", "7", "");
		fo.addParam("allowScriptAcces", "sameDomain");
		fo.addParam("quality", "high");
		fo.addParam("xn_auth", "no");
   		fo.write("flashcontent");
</script>
</td></tr>
</table>
</body>
