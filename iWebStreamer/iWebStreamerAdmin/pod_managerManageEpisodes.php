#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET, $_REQUEST;

	$podcastId=intval($_GET['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
	}
	
	if(isset($_REQUEST['action'])){
		$action=$_REQUEST['action'];
		if($action=="delete_episode"){
			$podcastFileId=intval($_REQUEST['podcastFileId']);
				if(!$podcastFileObj=$podcastObj->getPodcastFileObj($podcastFileId)){
				$iWebStreamerErrorObj->registerCritical('Episode Id does not exist.');
			}
			
			$podcastObj->removePodcastFile($podcastFileId);
			$saveConf=true;
			unset($podcastFileId);
		}
	}

require_once(dirname(__FILE__).'/navbar.php');

if(count($podcastObj->getPodcastFilesArr())>0){
		?>
		
			<form name="removePodcastEpisode" id="removePodcastEpisode" action="pod_managerManageEpisodes.php" target="main" onSubmit="javascript:return confirm('Are you sure you want to remove this episode?\n\nNote: this does not delete the file.\nFile deletion is done under Available Audio.'); method='POST'">
			<input type="hidden" name="action" value="delete_episode">
			<input type="hidden" name="podcastId" value="<?echo $podcastId;?>">
			<table align="center" cellpadding="3" cellspacing="2">
				<tr valign="center" bgcolor="#F1F2F8">
					<td colspan="2">
					<input type="submit" id="submit_button" name="submit_button" value="Delete" disabled="true" class="button">
					</td>
					<td>
					<font color="#E94D02">Title</font>
					</td>
					<td>
					<font color="#E94D02">Author/Artist</font>
					</td>
					
					<td>
					<font color="#E94D02">Publish Date</font>
					</td>
					
					<td>
					<font color="#E94D02">Source</font>
					</td>
					
					<td>
					<font color="#E94D02">Size</font>
					</td>
					
					<td>
					<font color="#E94D02">Length</font>
					</td>
					
					<td>
					</td>
				</tr>
		<?
		$colorSwitch=false;
		
		foreach(array_reverse($podcastObj->getPodcastFilesArr(), true) as $podcastFileId => $podcastFileObj){
			
			echo "<tr valign='center' ";
			
			if($colorSwitch){
				echo "bgcolor='#F1F2F8'";
				$colorSwitch=false;
			}else{
				$colorSwitch=true;
			}
			
			 echo ">";
			 
			echo "<td align=\"left\">\n";
			echo "<input type=\"radio\" name=\"podcastFileId\" value=\"$podcastFileId\" 
			onClick=\"document.getElementById('submit_button').disabled=false\">";
			echo "</td>";
			
			echo "<td><a href='pod_managerEditEpisode.php?podcastId=".$podcastId."&podcastFileId=".$podcastFileId."'>Edit</a></td>\n"; 
			 
			echo "<td>".$podcastFileObj->getTitle()."</td>\n";
			
			echo "<td>".$podcastFileObj->getAuthor()."</td>\n";
			
			echo "<td>".date('F j, Y, g:i a', $podcastFileObj->getPubDate())."</td>\n";
			
			echo "<td>";
				if($podcastFileObj->getIsRFAudio()){
					echo "royalty free audio";
				}else{
					echo "uploaded file";
				}
			echo "</td>\n";
			
			echo "<td>".$podcastFileObj->getFileSize()."MB</td>\n";
			
			echo "<td>".$podcastFileObj->getDurationFormattedStr()."</td>\n";
			
			
			if($podcastFileObj->getIsRFAudio()){
				$fileObj=$rfaudio_infoObj->getRfAudioFileObjById($podcastFileObj->getFileId());
			}else{
				$fileObj=$fileInfoObj->getFileObj($podcastFileObj->getFileId());
			}
			
			echo "<td><a href='".$fileObj->getPreviewUrl()."' target='preview'>Listen</a></td\n>";
			
			echo "</tr>";
		}
		
		?>
			</table>
			</form>
		<?
		
	}else{
		?>
		<br><br><br><br><center>
		No episodes have been added yet.
		<?
	}
		