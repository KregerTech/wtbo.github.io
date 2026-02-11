#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	$fileId=intval($_REQUEST['fileId']);
	
	if(!$fileObj=$fileInfoObj->getFileObj($fileId)){
		$iWebStreamerErrorObj->registerCritical('File id does not exist.');
	}
	?>
		<br><br><br>
		Removing file from podcasts and WebStreams
	<?
	
	if($fileObj->deleteFileFromPodcastsAndWebStreams()){
		?>
			<br>complete!<br><br>
			Removing the file from server
			
		<?
		
	
		if($fileInfoObj->removeFile($fileId)){
			$saveConf=true;
		
			?>
				<script language="javascript" type="text/javascript">
				function load(url) {
  					self.parent.location.href = url;
				}
				setTimeout("load('file_manager.php')",2000);
				</script>
				
				File removed successfully!
			<?
		}else{
			?>
				File removal failed!
			<?
		}
	}
		
?>