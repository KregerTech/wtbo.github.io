#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET, $_POST;

	$podcastId=intval($_GET['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
	}
	
	$rfAudioFile_id=intval($_POST['rfAudioFile_id']);
	$isRFAudio=true;
	
	if(!$rfAudioFileObj=$rfaudio_infoObj->getRfAudioFileObjById($rfAudioFile_id)){
		$iWebStreamerErrorObj->registerCritical('Royalty Free Audio file id does not exist');
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
	$duration=intval($_POST['duration']);
	$explicit=trim($_POST['explicit']);
	$keywords=trim($_POST['keywords']);
	$subtitle=trim($_POST['subtitle']);
	$summary=trim($_POST['summary']);
	$isRFAudio=true;
	
	if($podcastObj->addPodcastFile($rfAudioFile_id, $pubDate, $block, $rfAudioFileObj->getDuration(), $explicit, $keywords, $subtitle, $summary, $isRFAudio)){
		$saveConf=true;
		$podcastFileId=$podcastObj->idCount-1;
		require_once(dirname(__FILE__).'/navbar.php');
		?>
			<br><br><br>
			<table align="center" cellpadding="5" cellspacing="5">
				<tr align="center">
					<td>
						Episode added successfully.
					</td>
				</tr>
				<tr align="center">
					<td><a href="pod_managerAddNewEpisode.php?podcastId=
					<?echo $podcastObj->idCount-1;?> target='main'">
					Add another episode to this podcast</a><br>
					<i>NOTE: Please be careful not to add too many episodes before your 
					subscribers have a chance to listen to them.  By default, the iTunes software 
					will automatically unsubscribe any Podcasts which have gone five episodes 
					without being played, and also by default the iTunes software will only check 
					for new updates once per day as well.</i></td>
				</tr>
				
			</table>
		<?
		
	}else{
		$saveConf=false;
		?>Error Adding Podcast Episode<?
	}
	
?>