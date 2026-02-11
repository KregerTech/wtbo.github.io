<?php
/**
* Receive uploaded file and clean up temp files
*/
function receive($sid) {
	global $tmp_dir, $title, $author, $full_file_name, $fileInfoObj, $saveConf, $iWebStreamerErrorObj;
	$sid = ereg_replace("[^a-zA-Z0-9]","",$sid);
	$file = $tmp_dir.'/'.$sid.'_qstring';
	
	$fileExists=false;
	for($i=0;$i<100;$i++){
		if(file_exists($file)) {
			$fileExists=true;
			break;
		}
		sleep(1);
	}
	if(!$fileExists){
		return "Unable to stat $file";
	}
	
	$qstr = join("",file($file));
	unlink("$tmp_dir/{$sid}_qstring");
	
	parse_str($qstr);

	/*
	 * uncomment and modify the following to suite your settings
	 * rename($file['tmp_name'][0], 'c:\temp\uploads\'. $file['name'][$i]);
	 *    for windows systems or */
	//rename($file['tmp_name'][0], '/tmp/uploads/'. $file['name'][0]);
	
	/*
		Instead of doing that above stuff with file, I'm going to
		parse at the file name from the directory info and rename
		any funky characters with an _
	*/
	$j=strlen($full_file_name)-1;
	$simple_file_name='';
	for($i=$j;$i>-1;$i--){
		
		if($full_file_name[$i]=='/'||$full_file_name[$i]=='\\'){
			break;
		}elseif(!preg_match('/(\w|\.)/', $full_file_name[$i])){
			$simple_file_name='_'.$simple_file_name;
			//Quick hack.  If we had to be here, it's likely the upload
			//component escaped this strange character, but doesn't
			//necessaryily mean it was an end of a directory.
			if($full_file_name[$i-1]=='\\'){
				$i--;
			}
		}else{
			$simple_file_name=$full_file_name[$i].$simple_file_name;
		}
		
	}
	$ext=strtolower(substr($simple_file_name, strlen($simple_file_name)-4, strlen($simple_file_name)-1));
	if($ext!=".mp3"){
		return "Error, you must upload only files with a .mp3 extension. $ext";
	}
	
	if(file_exists(AUDIOFILESDIR.'/'.$simple_file_name)){
		return "Error uploading $simple_file_name<br>File already exists.<br>
		If you would like to upload a file by the same name, please remove the 
		existing one first.";
	}
	$previous_file_size=filesize($file['tmp_name'][0]);
	
	$availableMegs=AUDIOQUOTAMEGS-$fileInfoObj->getAudioDiskUsageMegs();
	$previous_file_sizeMegs=intval($previous_file_size/1048576);
	//check to make sure we have enough space
	if($previous_file_sizeMegs>$availableMegs){
		return "Error, the file you have uploaded exceeds your available iWebStreamer<br>
		You will have to delete some files or upgrade your domain's package to a be able<br>
		to add this file.";
	}
	
	if(!rename($file['tmp_name'][0],  AUDIOFILESDIR.'/'.$simple_file_name)){
		return "Unable to copy uploaded file $simple_file_name.";
	}
	
	$new_file_size=filesize(AUDIOFILESDIR.'/'.$simple_file_name);
	
	
	if($new_file_size!=$previous_file_size){
		unlink(AUDIOFILESDIR.'/'.$simple_file_name);
		return "Error when copying file from /tmp. Please try again.<br>
		Please contact support if this problem persists.";
		
	}
	
	if(!chmod(AUDIOFILESDIR.'/'.$simple_file_name, 0644)){
		unlink(AUDIOFILESDIR.'/'.$simple_file_name);
		return "Error setting permissions on uploaded file.<br>
		If this problem persists, please contact support.";
	}
	
	if($title==""||$author==""){
		return "Error, title and author must be entered.";
	}
	
	$fileInfoObj->addFile($simple_file_name, $title, $author);
	global $confFileObj, $iWebStreamerConf;
	if(!$confFileObj->saveEncObj($iWebStreamerConf)){
		unlink(AUDIOFILESDIR.'/'.$simple_file_name);
		$iWebStreamerErrorObj->registerCritical("Failed to save the conf file.");
	}
	//success if we made it here
	return "$simple_file_name uploaded successfully.";
	
	
	//Instead of returning $file to receive.php, we'll send the results.
	//either an error message to return or success and send it to the browser.
	//return $file['name'][0];
	
	
}


?>