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
<script>
	function switchFileDisplay(currentDisplay, newDisplay, divID, mode){
		if(mode=="more"){
			newMode="less";
		}else{
			newMode="more";
		}
		
		document.getElementById(divID).innerHTML=newDisplay + "<br><a href='#' onClick='switchFileDisplay(\"" + newDisplay + "\",\"" + currentDisplay + "\",\"" + divID + "\",\"" + newMode + "\");'>" + newMode + "</a>";
	}
</script>
<center><br><br>NOTE: Rows with a yellow background indicate files<br>
that are currently available from this Podcast already.<br><br></center>
<table cellspacing="0" cellpadding="1" class="toolBar" align="center" border="1" bordercolor="#C7C7FF">
		<form action="pod_managerAddNewEpisodeFromRFAudio_process.php?podcastId=<?echo $podcastId;?>" method="post" enctype="multipart/form-data" 
				name="form1" 
				target="_self" 
				onSubmit="submit_button.disabled=true">
		<tr align="left">
			<td>
			<input type="submit" name="submit_button" id="submit_button" value="Add File" disabled="true" class="button">
			</td>
			<td><font color="#0000D2" size="-2"><b>Artist/Author</b></font></td>
			<td><font color="#0000D2" size="-2"><b>Title</b></font></td>
			<td><font color="#0000D2" size="-2"><b>File Name</b></font></td>
			
			
		</tr>
			
				
				<?
					foreach(array_reverse($rfaudio_infoObj->getRfAudioFileArr(), true) as $rfAudioFile_id => $RfAudioFileObj){
						
						//set a flag to find out if this file has been added already
						$alreadyAdded=false;
						foreach($podcastObj->getPodcastFilesArr() as $podcastFileId => $podcastFileObj){
						
							if($podcastFileObj->getIsRFAudio()){
								if($podcastFileObj->getFileId()==$rfAudioFile_id){
									$alreadyAdded=true;
								}
							}
						
						}
					
						echo "<tr valign=\"top\"";
						if($alreadyAdded){
						  echo " bgcolor=\"yellow\"";
						}
						echo ">\n";
						
						echo "<td align=\"left\">\n";
						echo "<input type=\"radio\" name=\"rfAudioFile_id\" value=\"$rfAudioFile_id\" 
						onClick=\"document.getElementById('submit_button').disabled=false\">";
						echo "</td>";
						
						echo "<td align=\"left\">\n";
						echo $RfAudioFileObj->getAuthor();
						echo "</td>";
						
						echo "<td align=\"left\">\n";
						echo $RfAudioFileObj->getTitle();
						echo "</td>";
						
						echo "<td align=\"left\" nowrap>\n";
						$fullFileName = $RfAudioFileObj->getFileName();
						$shortFileName = substr($fullFileName, 0, 18);
						echo "<div id='fileNameDisDiv$rfAudioFile_id'>$shortFileName<br><a href='#' onClick='switchFileDisplay(\"$shortFileName\",\"$fullFileName\",\"fileNameDisDiv$rfAudioFile_id\", \"more\");'>more</a></div>";
						echo "</td>";
						
						echo "</tr>\n";
					}
				?>
	</table>