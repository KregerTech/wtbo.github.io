#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET, $_POST;

	$podcastId=intval($_GET['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist.');
	}
	
	$podcastFileId=intval($_GET['podcastFileId']);
	if(!$podcastFileObj=$podcastObj->getPodcastFileObj($podcastFileId)){
		$iWebStreamerErrorObj->registerCritical('Episode Id does not exist.');
	}
	
	$isRFAudio=$podcastFileObj->getIsRFAudio();
	
	$fileId=$podcastFileObj->getFileId();
	
	//since the only thing need from either an rf or file object are methods
	//by the same name, just using fileObj for either one.
	if($isRFAudio){
		if(!$fileObj=$rfaudio_infoObj->getRfAudioFileObjById($fileId)){
			$iWebStreamerErrorObj->registerCritical('File id does not exist');
		}
	}else{
		if(!$fileObj=$fileInfoObj->getFileObj($fileId)){
			$iWebStreamerErrorObj->registerCritical('File id does not exist');
		}
	}
	
	$pubDateDay=trim($_POST['pubDateDay']);
	$pubDateHour=intval($_POST['pubDateHour']);
	$pubDateMinute=intval($_POST['pubDateMinute']);
	$pubDateMeridiem=intval($_POST['pubDateMeridiem']);
	
	
	$pubDateDayArr=preg_split('/\//', $pubDateDay);
	$pubDateMonth=$pubDateDayArr[0];
	$pubDateDay=$pubDateDayArr[1];
	$pubDateYear=$pubDateDayArr[2];
	
	$pubDate=intval(mktime($pubDateHour, $pubDateMinute, 0, $pubDateMonth, $pubDateDay, $pubDateYear));
	$block=$_POST['block'];
	
	if($isRFAudio){
		$duration=$podcastFileObj->getDuration();
	}else{
		$duration=intval($_POST['duration']);
	}
	$explicit=trim($_POST['explicit']);
	$keywords=trim($_POST['keywords']);
	$subtitle=trim($_POST['subtitle']);
	$summary=trim($_POST['summary']);
	
	if($podcastFileObj->setPubDate($pubDate)&&
	$podcastFileObj->setBlock($block)&&
	$podcastFileObj->setExplicit($explicit)&&
	$podcastFileObj->setKeywords($keywords)&&
	$podcastFileObj->setSubtitle($subtitle)&&
	$podcastFileObj->setSummary($summary)&&
	$podcastFileObj->setDuration($duration)){
		$saveConf=true;
		require_once(dirname(__FILE__).'/navbar.php');
		?>
			<br><br><br>
			<table align="center" cellpadding="5" cellspacing="5">
				<tr>
					<td>
						Episode Edited Successfully.
					</td>
				</tr>
			</table>
		<?
	}
?>