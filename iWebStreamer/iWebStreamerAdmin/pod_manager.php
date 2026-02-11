#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	require_once(dirname(__FILE__).'/navbar.php');
	
	global $_REQUEST;
	if(isset($_REQUEST['podcastId'])){
		$podcastId=intval($_REQUEST['podcastId']);
		if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
			$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
		}
	}
	
	$action=$_REQUEST['action'];
	if($action=="delete_podcast"){
		$podcastInfoObj->removePodcast($podcastId);
		$saveConf=true;
		unset($podcastId);
	}
	
	if(count($podcastInfoObj->getPodcastsArr())>0){
	
		?>
			<table align="center" cellpadding="3" cellspacing="2">
				<tr valign="center" bgcolor="#F1F2F8">
					<td>
					</td>
					<td>
					<font color="#E94D02">Episodes</font>
					</td>
					
					<td>
					</td>
					
					<td>
					</td>
					
					
					<td>
					</td>
				</tr>
		<?
		$colorSwitch=false;
		foreach($podcastInfoObj->getPodcastsArr() as $podcastId => $podcastObj){
			
			echo "<tr valign='center' ";
			
			if($colorSwitch){
				echo "bgcolor='#F1F2F8'";
				$colorSwitch=false;
			}else{
				$colorSwitch=true;
			}
			
			 echo ">";
			
			echo "<td><a href='pod_managerManageEpisodes.php?podcastId=".$podcastId."' target='main'>".$podcastObj->getTitle()."</a></td>\n";
			
			echo "<td align='right'>".count($podcastObj->getPodcastFilesArr())."</td>\n";
			
			echo "<td>";
			echo "<a href='pod_managerCodeGen.php?podcastId=".$podcastId."' target='main'>
			Generate HTML Code
			</a>
			</td>\n";
			
			echo "<td>";
			echo "<a href='pod_managerManagePodcast.php?podcastId=".$podcastId."' target='main'>
			<img src='images/modify.gif' border='0'>
			</a>
			</td>\n";
			
			echo "<td>";
			echo "<a href='pod_manager.php?podcastId=".$podcastId."&action=delete_podcast' target='main' 
			onclick=\"javascript:return confirm('Are you sure you want to delete this podcast? Do not forget to update your web site source code if you click ok.');\">
			<img src='images/delete.gif' border='0'>
			</a>
			</td>\n";
			
			echo "</tr>";
		}
		?>
			</table>
		<?
		
	}else{
		?><br><br><br><br><center>
		No Podcadcasts have been added. <br><br> 
		Click <a href="pod_managerAddNewPodcast.php" target="main">here</a> to add a new podcast</center><?
	}
		
?>