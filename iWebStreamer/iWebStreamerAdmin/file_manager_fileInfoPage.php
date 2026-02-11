#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	require_once(dirname(__FILE__).'/finalize.php');
	global $_GET;
?>

<script>
	function switchFileDisplay(currentDisplay, newDisplay, divID, mode){
		if(mode=="more"){
			newMode="less";
		}else{
			newMode="more";
		}
		
		document.getElementById(divID).innerHTML=newDisplay + "<br><a href='javascript:;' onClick='switchFileDisplay(\"" + newDisplay + "\",\"" + currentDisplay + "\",\"" + divID + "\",\"" + newMode + "\");'>" + newMode + "</a>";
	}
</script>

<?
	if(count($fileInfoObj->getFilesArr())){
?>

<table cellspacing="0" cellpadding="0" class="toolBar" align="left" width="100%">
		
		<tr align="left" bgcolor="#F1F2F8">
			<td colspan="2">
			</td>
			<td><font color="#E94D02" size="-2"><b>Artist/Author</b></font></td>
			<td><font color="#E94D02" size="-2"><b>Title</b></font></td>
			<td><font color="#E94D02" size="-2"><b>Size</b></font></td>
			<td><font color="#E94D02" size="-2"><b>File Name</b></font></td>
			<td align="center"><font color="#E94D02" size="-2"><b>Listen</b></font></td>
			
			
			
			
		</tr>
			
				
				<?
					$colorSwitch=false;
					
					
					
					foreach(array_reverse($fileInfoObj->getFilesArr(), true) as $file_id => $fileObj){
					
					echo "<tr valign=\"center\" ";
					
					if($colorSwitch){
						echo "bgcolor='#F1F2F8'";
						$colorSwitch=false;
					}else{
						$colorSwitch=true;
					}
					echo ">\n";
						 
						echo "<td align=\"left\">\n";
						echo "<a href='delete_file.php?fileId=$file_id' target='available_audio_main'>
						<img src='images/delete.gif' border='0'>
						</a>";
						echo "</td>\n";
		
						echo "<td align=\"left\">\n";
						echo "<a href=\"modify_fileObj.php?file_id=$file_id\" target=\"main\"><img src='images/modify.gif' border='0'><font size='-3'></font></a>";
						echo "</td>\n";
						
						echo "<td align=\"left\">\n";
						echo $fileObj->getAuthor();
						echo "</td>\n";
						
						echo "<td align=\"left\">\n";
						echo $fileObj->getTitle();
						echo "</td>\n";
						
						echo "<td align=\"left\">\n";
						echo $fileObj->getFileSize()."MB";
						echo "</td>\n";
						
						echo "<td align=\"left\" nowrap>\n";
						$fileId=$fileObj->getFileId();
						$fullFileName = $fileObj->getFileName();
						$shortFileName = substr($fullFileName, 0, 10);
						echo "<font size='-3'><div id='fileNameDisDiv$fileId'>$shortFileName<br><a href='javascript:;' onClick='switchFileDisplay(\"$shortFileName\",\"$fullFileName\",\"fileNameDisDiv$fileId\", \"more\");'>more</a></div></font>";
						echo "</td>\n";
						
						echo "<td align='center' valign='center'><a href='".$fileObj->getPreviewUrl()."' target='preview'><img src='images/listen.gif' border='0'></a></td\n>";
						
						echo "</tr>\n";
					}
				?>
	</table>
<?
	}else{
?>
<center><br><br><br>
You have not uploaded any audio files yet.<br><br>
<a href="upload_front.php">Would you like to upload one now?</a><br>
</center>
<?
}
