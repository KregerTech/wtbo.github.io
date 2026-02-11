#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET;

	$podcastId=intval($_GET['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
	
?>
<br><br>
<center>
	Would you like to 
	<a href="pod_managerAddNewEpisodeFromUploaded.php?podcastId=<?echo $podcastId;?>">
	add an episode from an mp3 you have uploaded</a> 
	<br><br>
	or 
	<br><br>
	<a href="pod_managerAddNewEpisodeFromRFAudio.php?podcastId=<?echo $podcastId;?>">
	add an episode from the royalty free audio included in this program
	</a>?
	<br><br><br><br>
	Haven't uploaded audio yet?
	<br>Click <a href="upload_front.php">here</a> to upload your mp3.
</center>
