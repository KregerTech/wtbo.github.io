#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	require_once(dirname(__FILE__).'/finalize.php');
	global $_GET;
?>
<table cellspacing="0" cellpadding="0" width="100%" height="100%">
<tr>
<td></td>
<td align="right">
	<table width="100%"><tr><td></td>
	<td align="right" width="370">
	<!--
			<font color="black" size="-2">
				<b>iWebStreamer Quota:
			</font>
			<font color="purple" size="-2">
				<?echo AUDIOQUOTAMEGS;?>MB<br>
			</font>
			
			<font color="black" size="-2">
				Used:
			</font>
			<font color="purple" size="-2">
				<? 
				
					if($fileInfoObj->getAudioDiskUsageMegs()>AUDIOQUOTAMEGS){
						$usage=AUDIOQUOTAMEGS;
					}else{
						$usage=$fileInfoObj->getAudioDiskUsageMegs();
					}
					
					echo $usage;	
				?>MB<br>
			</font>
			<font color="red" size="-2">
			<b><?
				$freePerc=intval(100-(($fileInfoObj->getAudioDiskUsageMegs()/AUDIOQUOTAMEGS)*100));
				
				if($freePerc<0){
					$freePerc=0;
				}
				echo $freePerc;
				
			?>% Free</b>
			</font>
	</font><br>
	<font color="#0000D2" size="-2"><b><i>Upgrade your package today and get more iWebStreamer quota!</i></b></font>
	-->
	</td></tr></table>
</td>
</tr>
<tr>
<?
	//Left Toolbar
?>
<td valign="top" align="center" width="60">
<a href="upload_front.php" target="available_audio_main"><img src="images/up-arrow.jpg" width="50" height="50" border="0"><br>
Upload an Mp3</a><br><br>
<a href="file_manager_fileInfoPage.php" target="available_audio_main"><img src="images/folder.jpg" width="50" height="50" border="0"><br>
Your Uploaded Audio</a><br><br>
<!--
<a href="displayRFAudio.php" target="available_audio_main"><img src="images/speaker-notes.jpg" width="50" height="50" border="0"><br>
Royalty Free Audio</a>
-->
<br>
</td>

<?
	//End left toolbar
?>

<td valign="top" align="center">

	<iframe src="file_manager_fileInfoPage.php" name="available_audio_main" scrolling="auto" frameborder="no" id="available_audio_main" width="100%" height="100%" ALIGN=middle>
	</iframe>

</td>
</tr>

</table>
