#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	require_once(dirname(__FILE__).'/finalize.php');
	global $_REQUEST;
	$fileId=intval($_REQUEST['fileId']);
	
	if(!$fileObj=$fileInfoObj->getFileObj($fileId)){
		$iWebStreamerErrorObj->registerCritical('File id does not exist.');
	}
	
	if($fileObj->isFileInUse()){
		?>
			
				<?
					if($fileObj->getPodCastIdsUsingFile()){
						?>
							<br>
							Podcasts using "<?echo $fileObj->getTitle();?>":<br><br>
							<table>
						<?
						foreach($fileObj->getPodCastIdsUsingFile() as $index => $podcastId){
							$podcastObj=$podcastInfoObj->getPodcastObj($podcastId);
							$title=$podcastObj->getTitle();
							echo "<tr><td><a href='pod_managerManageEpisodes.php?podcastId=$podcastId'>$title</a></td></tr>\n";
						}
						?>
							</table>
							<p>
							<font color="red">Note:</font>
							<br><i>It is normal to remove an old episode from a podcast.  Users 
							that have subscribed to your podcast will retain the episode for as long as they have 
							configured within the iTunes software.</i>
							</p>
						<?
					}
					
					if($fileObj->getWebStreamIdsUsingFile()){
						?>	<br>
							WebStreams using "<?echo $fileObj->getTitle();?>":<br>
							<table>
						<?
						foreach($fileObj->getWebStreamIdsUsingFile() as $index => $webStreamId){
							$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId);
							$title=$webStreamObj->getName();
							echo "<tr><td><a href='stream_managerManageStream.php?podcastId=$webStreamId'>$title</a></td></tr>\n";
						}
						?>
							</table>
						<?
					}
				?>
				
				<br>Any podcasts or WebStreams using this file will be updated automatically to reflect this removal.<br>
				
				
		<?
	}else{
		?>
				"<?echo $fileObj->getTitle();?>" is not in use by any podcasts or webstreams.
		<?
	}
	
		?>
				<form action="delete_file_process.php" method="POST" onSubmit="document.getElementById('submit').disabled=true">
				<input type="hidden" name="fileId" value="<?echo $fileId;?>">
					<br><br>Confirm file deletion?<br>
					<input name="submit" id="submit" type="submit" value="Yes" class="button" ><br><br>
					<button onclick="document.location.href='file_manager.php'" class="button">No Thanks</button>
				</form>
				
		<?
