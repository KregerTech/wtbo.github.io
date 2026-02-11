#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	
	$webStreamId=trim($_REQUEST['webStreamId']);
	if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
		$iWebStreamerErrorObj->registerCritical('Invalid WebStream Id.');
	}
	
	if(isset($_REQUEST['action'])){
		$action=$_REQUEST['action'];
		if($action=="delete_track"){
			$webStreamFileId=intval($_REQUEST['webStreamFileId']);
			if(!$webStreamFileObj=$webStreamObj->getWebStreamFileObj($webStreamFileId)){
				$iWebStreamerErrorObj->registerCritical('Invalid WebStream File Id.');
			}
			
			$webStreamObj->removeWebStreamFile($webStreamFileId);
			$saveConf=true;
			unset($webStreamObj);
		}
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
	
	if(isset($_REQUEST['resort'])){
		$webStreamFileId=intval($_REQUEST['webStreamFileId']);
		if(!$webStreamFileObj1=$webStreamObj->getWebStreamFileObj($webStreamFileId)){
			$iWebStreamerErrorObj->registerCritical('Invalid WebStream File Id.');
		}
		
		$matched=false;
		switch($_REQUEST['direction']){
			case "up":{
				foreach($webStreamObj->getReverseSortedWebStreamFileArr() as $tmpWebStreamFileId => $tmpWebStreamFileObj){
					if($matched){
						$targetId=$tmpWebStreamFileId;
						$matched=false;
						break;
					}
					
					if($webStreamFileId==$tmpWebStreamFileId){
						$matched=true;
					}	
				}
			break;
			}
			
			case "down":{
				foreach($webStreamObj->getSortedWebStreamFileArr() as $tmpWebStreamFileId => $tmpWebStreamFileObj){
					if($matched){
						$targetId=$tmpWebStreamFileId;
						$matched=false;
						break;
					}
					
					if($webStreamFileId==$tmpWebStreamFileId){
						$matched=true;
					}	
				}
			break;
			}
			
			default:{
				$iWebStreamerErrorObj->registerCritical('Error, bad url.');
			}
		}
		
		$webStreamFileObj2=$webStreamObj->getWebStreamFileObj($targetId);
		$webStreamFileObj1->setWebStreamFileId($targetId);
		$webStreamFileObj2->setWebStreamFileId($webStreamFileId);
		$webStreamObj->webStreamFileArr[$targetId]=$webStreamFileObj1;
		$webStreamObj->webStreamFileArr[$webStreamFileId]=$webStreamFileObj2;
		
		//quick check to make sure the logic didn't get screwy
		foreach($webStreamObj->getWebStreamFileArr() as $webStreamFileId => $webStreamFileObj){
			if($webStreamFileId != $webStreamFileObj->getWebStreamFileId()){
				$iWebStreamerErrorObj->registerCritical('Error, changing playlist order.');
			}
		}
		$saveConf=true;
	}
	
	
	
	
	if(count($webStreamObj->getWebStreamFileArr())){
		?>
			<form action="stream_managerManageStream.php?webStreamId=<?echo $webStreamId;?>" method="POST" target="main" onSubmit="javascript:return confirm('Are you sure you want to remove this track?\n\nNote: this does not delete the file.\nFile deletion is done under Available Audio.');">
			<input type="hidden" name="action" value="delete_track">
			<?
				if(count($webStreamObj->getWebStreamFileArr())>1){
					?>
						<p align="center">
							The playlist will display in the order shown below.
							If you would like to alter the order,
							you can use the up and down controls listed next to each track.
						</p>
					<?
				}
				
			?>
			<table align="center" cellspacing="3">
			<tr>
				<td><input type="submit" name="submit" id="submit" value="Remove" disabled="true" class="button"></td>
				<td colspan="2"></td>
				<td><font color="#E94D02">Title</font></td>
				<td><font color="#E94D02">Author</font></td>
				<td><font color="#E94D02">File Size</font></td>	
				<td></td>
			</tr>
		<?
		$loopCount=0;
		$colorSwitch=true;
		foreach($webStreamObj->getSortedWebStreamFileArr() as $webStreamFileId => $webStreamFileObj){
		
			if($webStreamFileObj->getIsRFAudio()){
				$fileObj=$rfaudio_infoObj->getRfAudioFileObjById($webStreamFileObj->getFileId());
			}else{
				$fileObj=$fileInfoObj->getFileObj($webStreamFileObj->getFileId());
			}
			
			//try to safely crap out if the file object is bad but just not printing the row
			if($fileObj){
			
				echo "<tr valign='center' ";
			
				if($colorSwitch){
					echo "bgcolor='#F1F2F8'";
						$colorSwitch=false;
				}else{
					$colorSwitch=true;
				}
				echo ">\n";
				
				echo "<td><input type='radio' name='webStreamFileId' value='$webStreamFileId' onClick='document.getElementById(\"submit\").disabled=false;'></td>\n";
				if(count($webStreamObj->getWebStreamFileArr())>1){
					
					if($loopCount!=0){
						echo "<td><a href='".$_SERVER['PHP_SELF']."?webStreamId=$webStreamId&resort=true&webStreamFileId=$webStreamFileId&direction=up'>UP</a></td>\n";
					}else{
						echo "<td></td>\n";
					}
					
					if(($loopCount+1)!=count($webStreamObj->getWebStreamFileArr())){
						echo "<td><a href='".$_SERVER['PHP_SELF']."?webStreamId=$webStreamId&resort=true&webStreamFileId=$webStreamFileId&direction=down'>DOWN</a></td>\n";
					}else{
						echo "<td></td>\n";
					}
				}else{
					echo "<td bgcolor='white'></td><td bgcolor='white'></td>\n";
				}
				
				echo "<td>".$fileObj->getTitle()."</td>";	
				echo "<td>".$fileObj->getAuthor()."</td>";
				echo "<td>".$fileObj->getFileSize()."MB</td>";
				echo "<td><a href='".$fileObj->getPreviewUrl()."' target='preview'>Listen</a></td\n>";
			}
			$loopCount++;
		}
		?>
			</table>
			</form>
		<?
	}else{
		?><br><br><br><center>No Tracks Have Been Added</center><?
	}
?>