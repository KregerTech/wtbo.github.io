<?

global $podcastId, $podcastFileId, $fileId, $webStreamId, $webStreamFileId, $_SERVER;

$page=$_SERVER['REQUEST_URI'];

$pageType='';
if(preg_match('/pod_manager/', $page)){
	$pageType='podcast';
}

if(preg_match('/stream_manager/', $page)){
	$pageType='webstream';
}

if($pageType){

	?>
		<table align="center" cellpadding="5" cellspacing="4">
			<tr align="center" valign="top">
	<?	

	switch($pageType){
		case 'podcast':{
		
			?>
				<td align="left" bgcolor="#FFE6FF" nowrap>
					<font color="black">Your time zone:</font> 
						<font color="purple"><em>
						<?
							echo $podcastInfoObj->getCurrTimeZone();
						?>
						</em></font>
					<br>
			
					<font color="black">Your language:</font> 
					<font color="purple"><em>
					<?
					$langArr=$podcastInfoObj->getIsoCodes();
					$langDesc=$langArr[$podcastInfoObj->getCurrIsoCode()];
					echo $langDesc;
					?>
					</em></font>
				<br><br>
			
				<a href="pod_managerPrefs.php" target="main">
				Timezone/<br>Language Settings
				</a>
				</td>
				<td>
					<a href="pod_managerAddNewPodcast.php" target="main">
					<img border="0" width="40" height="40" src="images/plus.jpg"><br>
					Create a New Podcast
					</a>
				</td>
				<td>
					<a href="pod_manager.php" target="main">
					<img border="0" width="40" height="40" src="images/ipod.gif"><br>
					View all Podcasts
					</a>
				</td>
				
			<?
			
			if(isset($podcastId)&&!isset($podcastFileId)){
				?>
					<td>
						<a href="pod_managerAddNewEpisodeFromUploaded.php?podcastId=<?echo $podcastId;?>" target="main">
						<img src="images/plus.jpg" border="0" height="40" width="40">
						<br>Add Episode to this Podcast</a>
					</td>
					
					<td>
						<a href="pod_managerManagePodcast.php?podcastId=<?echo $podcastId;?>" target="main">
						<img src="images/edit.jpg" border="0" height="40" width="40">
						<br>Edit this Podcast
						</a>
					</td>
					<td>
						<a href="pod_managerCodeGen.php?podcastId=<?echo $podcastId;?>" target="main">
						<img src="images/generate.jpg" border="0" height="40" width="40">
						<br>Generate HTML code for this Podcast
						</a>
					</td>
					
				<?
			}
			
			if(isset($podcastFileId)){
			
				if(!is_object($podcastObj)){
					if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
						$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
					}
				}
				
				if(!is_object($podcastFileObj)){
					if(!$podcastFileObj=$podcastObj->getPodcastFileObj($podcastFileId)){
						$iWebStreamerErrorObj->registerCritical('Episode Id does not exist.');
					}
				}
				
				if($podcastFileObj->getIsRFAudio()){
					$url='?rfAudioFile_id='.$podcastFileObj->getFileId();
				}else{
					$url='?fileId='.$podcastFileObj->getFileId();
				}
			
				?>
					<td>
						<a href="pod_managerEditEpisode.php?podcastId=<?echo $podcastId?>&podcastFileId=<?echo $podcastFileId;?>" target="main">
						<img src="images/edit.jpg" border="0" height="40" width="40">
						<br>Edit this Episode
						</a>
					</td>
					<td>
						<a href="/iWebStreamer/iWebStreamer-UserWeb/flash/previewPlayer/preview.php<?echo $url;?>" target="preview">
						<img src="images/listen.jpg" border="0" height="40" width="40">
						<br>Listen to this Episode
						</a>
					</td>
				<?
			}
			
			if(isset($podcastId)){
				?>
					<td>
						<a href="pod_managerManageEpisodes.php?podcastId=<?echo $podcastId;?>" target="main">
						<img src="images/viewall.jpg" border="0" height="40" width="40"><br>
						View all Episodes for this Podcast
						</a>
					</td>
				<?
			}
			
		break;
		}
		
		case "webstream":{
		
			?>
				<td>
					<a href="stream_manager.php" target="main">
					<img border="0" width="40" height="40" src="images/webstreams.jpg"><br>
					View All<br>
					WebStreams
					</a>
				</td>
				<td>
					<a href="stream_managerAddNewWebStream.php" target="main">
					<img border="0" width="40" height="40" src="images/plus.jpg"><br>
					Create a<br>
					New WebStream
					</a>
				</td>
			<?
			
				if(isset($webStreamId)){
					?>
					<td>
						<a href="stream_managerEditWebStream.php?webStreamId=<?echo $webStreamId;?>" target="main">
						<img border="0" width="40" height="40" src="images/edit.jpg"><br>
						Edit this WebStream
						</a>
					</td>
					<td>
					<a href="stream_managerAddWebStreamFromUploaded.php?webStreamId=<?echo $webStreamId;?>" target="main">
						<img border="0" width="40" height="40" src="images/plus.jpg"><br>
						Add a Track to this WebStream
						</a>
					</td>
					<td>
					<a href="stream_managerManageStream.php?webStreamId=<?echo $webStreamId;?>" target="main">
						<img border="0" width="40" height="40" src="images/viewall.jpg"><br>
						View All Tracks for this WebStream
						</a>
					</td>
					
					<?
						global $webstreamInfoObj;
						$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId);
						$confirm=' onclick="javascript:return confirm(\'Are you sure you want to generate html already?\nYou have not added any tracks yet.\')" ';
						$tracksAdded=false;
						$trackNum=count($webStreamObj->getWebStreamFileArr());
						if($trackNum>0){
							$tracksAdded=true;
						}
					?>
					
					<td>
						<a href="stream_managerCodeGen.php?webStreamId=<?echo $webStreamId?>" target="main"<?if(!$tracksAdded){echo $confirm;}?>>
						<img border="0" width="40" height="40" src="images/generate.jpg"><br>
						Generate HTML Code for this WebStream
						</a>
					</td>
					<?
				}
				
				if(isset($webStreamFileId)){
				
					if(!is_object($webStreamObj)){
						if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
							$iWebStreamerErrorObj->registerCritical('Invalid WebStream Id.');
						}
					}
				
					if(!is_object($webStreamFileObj)){
						if(!$webStreamFileObj=$webStreamObj->getWebStreamFileObj($webStreamFileId)){
							$iWebStreamerErrorObj->registerCritical('WebStream Id does not exist.');
						}
					}
				
					if($webStreamFileObj->getIsRFAudio()){
						$url='?rfAudioFile_id='.$webStreamFileObj->getFileId();
					}else{
						$url='?fileId='.$webStreamFileObj->getFileId();
					}
					
					?>
					<td>
						<a href="/iWebStreamer/iWebStreamer-UserWeb/flash/previewPlayer/preview.php<?echo $url;?>" target="preview">
						<img src="images/listen.jpg" border="0" height="40" width="40">
						<br>Listen to this Track
						</a>
					</td>
					<?
				}
			
		break;
		}
	}
	
	?>
	</tr>
		</table>
		
		<?
			if($pageType=='podcast'){
				?><font color="#E94D02"><i>Podcast Manager</i></font><?
			}elseif($pageType=='webstream'){
				?><font color="#E94D02"><i>WebStream Manager</i></font><?
			}
			
		?>
		<hr>
	<?
}
