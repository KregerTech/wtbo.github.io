#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	
	global $_REQUEST;
	
	if(isset($_REQUEST['action'])){
		$action=$_REQUEST['action'];
		if($action=="delete_stream"){
			$webStreamId=intval($_REQUEST['webStreamId']);
				if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
					$iWebStreamerErrorObj->registerCritical('Invalid Web Stream Id.');
			}
			$webstreamInfoObj->removeWebStream($webStreamId);
			$saveConf=true;
			unset($webStreamId);
		}
	}
	
	
	require_once(dirname(__FILE__).'/navbar.php');
?>

<?
	if(count($webstreamInfoObj->getWebStreamsArr())){
		
		?>
			<table align="center" cellpadding="3" cellspacing="2">
				<tr valign="center" bgcolor="#F1F2F8">
					<td>
					</td>
					<td>
					<font color="#E94D02">Tracks</font>
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
		foreach($webstreamInfoObj->getWebStreamsArr() as $webStreamId => $webStreamObj){
			
			$confirm=' onclick="javascript:return confirm(\'Are you sure you want to generate html already?\nYou have not added any tracks yet.\')" ';
			$tracksAdded=false;
			$trackNum=count($webStreamObj->getWebStreamFileArr());
			if($trackNum>0){
				$tracksAdded=true;
			}
			
			echo "<tr valign='center' ";
			
			if($colorSwitch){
				echo "bgcolor='#F1F2F8'";
				$colorSwitch=false;
			}else{
				$colorSwitch=true;
			}
			
			
			
			
			 echo ">";
			 
			 echo "<td><a href='stream_managerManageStream.php?webStreamId=$webStreamId'>".$webStreamObj->getName()."</a></td>\n";
			 echo "<td align='right'>".count($webStreamObj->getWebStreamFileArr())."</td>\n";
			 echo "<td><a href='stream_managerCodeGen.php?webStreamId=$webStreamId'";
			 	if(!$tracksAdded){echo $confirm;}
			 echo ">Generate HTML Code</a></td>\n";
			 echo "<td><a href='stream_managerEditWebStream.php?webStreamId=$webStreamId'><img src='images/modify.gif' border='0'></a></td>\n";
			 echo "<td><a href='stream_manager.php?webStreamId=$webStreamId&action=delete_stream' onclick=\"javascript:return confirm('Are you sure you want to delete this Web Stream? Do not forget to update your web site source code if you click ok.');\" target='main'><img src='images/delete.gif' border='0'></a></td>\n";
			 echo "</tr>\n";
		}
		
		?>
			</table>
		<?
		
	}else{
		?><br><br><br><center>No Web Streams have been created yet.</center><?
	}
?>