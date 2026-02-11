#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	require_once(dirname(__FILE__).'/finalize.php');
?>
<br>
<table cellspacing="0" cellpadding="3" class="toolBar" align="center" border="1" bordercolor="#C7C7FF">
	
	<tr valign="top">
		</td>
		<td><font color="#0000D2" size="-2"><b>Artist/Author</b></font></td>
		<td><font color="#0000D2" size="-2"><b>Title</b></font></td>
	</tr>
			
				
	<?
		foreach(array_reverse($rfaudio_infoObj->getRfAudioFileArr(), true) 
		as $rfAudioFile_id => $RfAudioFileObj){
				
			echo "<tr>\n";		
				
			echo "<td>\n";
			echo $RfAudioFileObj->getAuthor();
			echo "</td>";
						
			echo "<td>\n";
			echo $RfAudioFileObj->getTitle();
			echo "</td>";
			
			echo "<td>\n";
			echo "<a href='".$RfAudioFileObj->getPreviewUrl()."' target='preview'>Listen</a>\n";
			echo "</td>\n";
						
			echo "</tr>\n";
		}
	?>
</table>