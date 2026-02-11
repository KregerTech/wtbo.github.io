#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;

	$podcastId=intval($_REQUEST['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
	
?>

	<table align="center" width="100%">
		<tr align="center" valign="bottom">
			<font color="red"><em>Need help understanding rss and itpc podcast links? Please check out the help section.</em></font>
		</tr>
		<tr>
			<br><br>itpc link:<br><br>
			example: <a href="<?echo htmlentities($podcastObj->getFeedItpc());?>">Click here to add this podcast to iTunes.</a><br><br>
			<i>Copy the following text into your web page source code, and replace "link text" with what should be displayed as
			the link.</i><br><br>
			<?echo htmlentities('<a href="'.$podcastObj->getFeedItpc().'">your text</a>');?><br>
			<hr>
		<tr>
		<tr>
			<br><br>itpc link with image:<br><br>
				example:<br>
				<a href="<?echo $podcastObj->getFeedItpc();?>">
					<img src="http://<?echo DOMAINNAME;?>/iWebStreamer/iWebStreamer-UserWeb/podcastLogo.jpg" border="0">
				</a>
			</span>
			<br><br>
			<i>Copy the following text into your web page source code</i><br><br>
			<?echo htmlentities('<a href="'.$podcastObj->getFeedItpc().'">');?><br>
			<?echo htmlentities('<img src="http://www.'.DOMAINNAME.'/iWebStreamer/iWebStreamer-UserWeb/podcastLogo.jpg" border="0">');?><br>
			<?echo htmlentities('</a>');?><br><br>
			<hr>
		</tr>
		<tr>
			<br><br>rss link:<br><br>
			
			example: <a href="<?echo $podcastObj->getFeedUrl();?>">RSS</a><br><br>
			
			<i>Copy the following text into your web page source code, replace "your text" with what you want the link to say.</i><br><br>
			<?echo htmlentities('<a href="'.$podcastObj->getFeedUrl().'">your text</a>');?><br>
			<hr>
		<tr>
		<tr>
			<br><br>rss link with image:<br><br><br>
				<a href="<?echo $podcastObj->getFeedUrl();?>">
					<img src="http://<?echo DOMAINNAME;?>/iWebStreamer/iWebStreamer-UserWeb/rss.jpg" border="0">
				</a>
			</span>
			<br><br>
			<i>Copy the following text into your web page source code</i><br><br>
			<?echo htmlentities('<a href="'.$podcastObj->getFeedUrl().'">');?><br>
			<?echo htmlentities('<img src="http://www.'.DOMAINNAME.'/iWebStreamer/iWebStreamer-UserWeb/rss.jpg" border="0">');?><br>
			<?echo htmlentities('</a>');?><br><br>
			<hr>
		</tr>
	</table>
<?
