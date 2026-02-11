#!/usr/local/dev/bin/php
<?
/*
	This cron automatically updates the available royalty free audio.
	If sync problems appear, running it command line should give you and
	idea about the problem.
*/
require_once(dirname(__FILE__).'../../custom_classes/ConfigFile.class');
require_once(dirname(__FILE__).'/includes/RfAudioFile.class');
require_once(dirname(__FILE__).'/includes/rfaudio_info.class');
//Load the conf file
$iWebStreamerConf = parse_ini_file(dirname(__FILE__).'/includes/iWebStreamerMainConf.inc', true);


//shorten stuff up
$host=$iWebStreamerConf['RF Audio']['host'];
$ftpuser=$iWebStreamerConf['RF Audio']['ftpuser'];
$ftppass=$iWebStreamerConf['RF Audio']['ftppass'];
$rfConfName=$iWebStreamerConf['RF Audio']['rfConfName'];
$sourceConfPath=$iWebStreamerConf['RF Audio']['sourceConfPath'];
$destinationConfPath=$iWebStreamerConf['RF Audio']['destinationConfPath'];
$sourceMp3DirPath=$iWebStreamerConf['RF Audio']['sourceMp3DirPath'];
$destinationMp3DirPath=$iWebStreamerConf['RF Audio']['destinationMp3DirPath'];

$saveRFObj=false;

$desConfObj=new ConfigFile($rfConfName);
$desConfObj->setConfPath($destinationConfPath);

//check to make sure our local directory and object exist
if(!$desConfObj->confExists()){
	mkdir($destinationConfPath, 0755, true);
	$desConfObj->touchConf();
	$desRfaudio_infoObj=new rfaudio_info ();
	$desRfaudio_infoObj->setRf_audio_fileDir($destinationMp3DirPath);
	if(!$desConfObj->saveEncObj($desRfaudio_infoObj)){
		die("Unable to save destination conf object");
	}
}

$desRfaudio_infoObj = $desConfObj->restoreEncObj();

//open our ftp connection
$conn_id = ftp_ssl_connect($host) or die("Couldn't connect to $host"); 

// login to source host or die
if (@ftp_login($conn_id, $ftpuser, $ftppass)) {
   echo "Connected as $ftpuser@$host\n";
   if(ftp_pasv($conn_id, true)){
   	echo "entering passive mode\n";
   }else{
   	die("failed to enter passive mode\n");
   }
} else {
   die("Couldn't connect as $ftpuser\n");
}

$tmpSrcConfFile=tempnam("/tmp", "tmpSrcConfFile");

//make sure to always remove this file
function removeSrcConfFile(){
	global $tmpSrcConfFile;
	if(unlink ($tmpSrcConfFile)){
		echo "temp conf file $tmpSrcConfFile removed\n";
	}else{
		echo "faile to remove $tmpSrcConfFile\n";
	}
}
register_shutdown_function("removeSrcConfFile");

//copy over the object to our tmp soure object
if (ftp_get($conn_id, $tmpSrcConfFile, $sourceConfPath.'/'.$rfConfName, FTP_BINARY)) {
   echo "Successfully written to $tmpSrcConfFile\n";
} else {
   echo "There was a problem\n";
}

//Restore the object state of the conf file
$srcConfObj=new ConfigFile($tmpSrcConfFile);
$srcConfObj->setConfPath("/tmp");
$srcRfaudio_infoObj=$srcConfObj->restoreEncObj();

//Is it a valid rfaudio_info object?
if(is_a($srcRfaudio_infoObj, 'rfaudio_info')){
	echo "Source conf file validates as a RF Audio Info Object.\n";
}else{
	die("Source conf file is not a valid RF Audio Info Object.\n");
}

//begin comparing
$saveConf=false;

//get what we don't have
foreach($srcRfaudio_infoObj->getRfAudioFileArr() as $srcRfAudioFile_id => $srcRfAudioFileObj){
	
	$desRfAudioFileObj=$desRfaudio_infoObj->getRfAudioFileObjById($srcRfAudioFile_id);

	//we have the object, do a comparison
	if(is_a($desRfAudioFileObj, 'RfAudioFile')){
		if(strcmp($desRfAudioFileObj->getAuthor(), $srcRfAudioFileObj->getAuthor())){
			$desRfAudioFileObj->setAuthor($srcRfAudioFileObj->getAuthor());
			$saveConf=true;
		}
		
		if(strcmp($desRfAudioFileObj->getTitle(), $srcRfAudioFileObj->getTitle())){
			$desRfAudioFileObj->setTitle($srcRfAudioFileObj->getTitle());
			$saveConf=true;
		}
		
		//do the files themselves match
		$srcFileSize=ftp_size($conn_id, $sourceMp3DirPath.'/'.$srcRfAudioFileObj->getFileName());
		$desFileSize=filesize($destinationMp3DirPath.'/'.$desRfAudioFileObj->getFileName());
		if(  (strcmp($desRfAudioFileObj->getFileName(), $srcRfAudioFileObj->getFileName())) || 
		     ($srcFileSize != $desFileSize)  ){
			
		     	echo "file names or sizes don't match, correcting\n";
		     	echo "names ".$desRfAudioFileObj->getFileName()." ".$srcRfAudioFileObj->getFileName()."\n";
			echo "sizes $desFileSize $srcFileSize\n";
		     	//remove the old file
			unlink($destinationMp3DirPath.'/'.$desRfAudioFileObj->getFileName());
			
			//update the name
			$desRfAudioFileObj->setFileName($srcRfAudioFileObj->getFileName());
			
			//upload the file
			ftp_get($conn_id, $destinationMp3DirPath.'/'.$desRfAudioFileObj->getFileName(), $sourceMp3DirPath.'/'.$srcRfAudioFileObj->getFileName(), FTP_BINARY);
			
			$saveConf=true;
		}
	}
	
	//object doesn't exist or is invalid
	else{
	
		echo "Found an invalid or missing audio file.  Overwrite and upload the file\n";	
	
		//be sure to save the conf now since we'll be adding this
		$saveConf=true;
		
		//add the object description
		$desRfaudio_infoObj->RF_AudioFileArr[$srcRfAudioFile_id]=$srcRfAudioFileObj;
	
		//now upload it
		if(ftp_get($conn_id,$destinationMp3DirPath.'/'.$srcRfAudioFileObj->getFileName(),
		$sourceMp3DirPath.'/'.$srcRfAudioFileObj->getFileName(),FTP_BINARY)){
			echo "file upload complete\n";
		}else{
			echo "file upload failed to complete\n";
		}
	}
}

//remove what we don't need
$desRFaudioObjArr=$desRfaudio_infoObj->getRfAudioFileArr();
foreach($desRFaudioObjArr as $desRfAudioFile_id => $desRfAudioFileObj){
	
	//does the source object have this
	if(!$srcRfaudio_infoObj->getRfAudioFileObjById($desRfAudioFile_id)){
		echo $desRfAudioFileObj->getFileName()." no longer needed, removing\n";
		$desRfaudio_infoObj->removeRfAudioFile($desRfAudioFile_id);
		$saveConf=true;
	}
}

if ($handle = opendir($destinationMp3DirPath)) {
   echo "Destination directory open\n";
   echo "Files:\n";

  	while (false !== ($file = readdir($handle))) {
       	if ($file != "." && $file != "..") {
			$inUse=false;
           		foreach($desRfaudio_infoObj->getRfAudioFileArr() as $desRfAudioFile_id => $desRfAudioFileObj){
				if(!strcmp($desRfAudioFileObj->getFileName(), $file)){
					$inUse=true;
				}
			}
			
			if(!$inUse){
				echo "found $destinationMp3DirPath/$file not in use, removing\n";
				unlink($destinationMp3DirPath.'/'.$file);
			}
       		}
   	}
   closedir($handle);

}

if($saveConf){
	echo "Need to save the conf file, saving...\n";
	if($desConfObj->saveEncObj($desRfaudio_infoObj)){
		echo "Conf file saved successfully.\n";
	}else{
		echo "Failed to save the conf file.\n";
	}
}

/*

$srcConfObj=new ConfigFile($rfConfName);
$srcConfObj->setConfPath("ftps://$ftpuser:$ftppass@$host$sourceConfPath");
$srcRfaudio_infoObj=$srcConfObj->restoreEncObj();


//cheap way to check our connection
//die if bad
if(!is_object($srcRfaudio_infoObj)){
	die("ftp connection failed");
}else{
	echo "ftp connection good\n";
}

//compare what we have to the source
foreach($desRfaudio_infoObj->getRfAudioFileArr() as $desRfAudioFile_id => $desRfAudioFileObj){
	if(!array_key_exists($desRfAudioFile_id, array_keys($srcRfaudio_infoObj->getRfAudioFileArr()))) {
		echo $desRfAudioFileObj->getFileName()." does not exist, removing\n";
		$desRfaudio_infoObj->removeRfAudioFile($desRfAudioFile_id);
		$saveRFObj=true;
	}else{
		echo $desRfAudioFileObj->getFileName()." exists in both places upon initial check, skipping..\n";
	}
}

//let's compare the source to what we have
foreach($srcRfaudio_infoObj->getRfAudioFileArr() as $srcRfAudioFile_id => $srcRfAudioFileObj){	
	echo "compariing files..\n";
	if(array_key_exists($srcRfAudioFile_id, array_keys($desRfaudio_infoObj->getRfAudioFileArr()))) {
		//so we have the key, but doublecheck the rfAudioFileObj
		//to make sure it matches too.
		$desRfAudioFileObj=$desRfaudio_infoObj->getRfAudioFileObjById($srcRfAudioFile_id);
		
		//Do the titles match?
		if($srcRfAudioFileObj->getTitle()!=$desRfAudioFileObj->getTitle()){
			$desRfAudioFileObj->setTitle($srcRfAudioFileObj->getTitle());
			$saveRFObj=true;
		}
		
		//Do the authors match
		if($srcRfAudioFileObj->getAuthor()!=$desRfAudioFileObj->getAuthor()){
			$desRfAudioFileObj->setAuthor($srcRfAudioFileObj->getAuthor());
			$saveRFObj=true;
		}
		
		//Do the files names match
		if($srcRfAudioFileObj->getFileName()!=$desRfAudioFileObj->getFileName()){
			$desRfAudioFileObj->setFileName($srcRfAudioFileObj->getFileName());
			$saveRFObj=true;
		}
		//do the files themselves appear to match
		$srcFile="ftps://$ftpuser:$ftppass@$host$sourceMp3DirPath/".$srcRfAudioFileObj->getFileName();
		$desFile=$desRfaudio_infoObj->getRf_audio_fileDir().'/'.$desRfAudioFileObj->getFileName();
		if(md5_file($srcFile)!=md5_file($desFile)){
			//probably a failed copy, do over
			echo "partial copy of a previous file, trying again\n";
			if(copyLock('lockme')){
				echo "begin copying $srcFile to $desFile\n";
				ob_flush();
				if(!copy($srcFile, $desFile)){
					$saveRFObj=false;
					die("failed to copy $srcFile to $desFile. This could indicate other problems\n");
				}else{
					//wait a little bit between copies
					copyLock('unlockme');
					echo "successfully copied";
					echo "now sleeping for 20 seconds to satisfy ftp limits\n";
					ob_flush();
					sleep(20);
				}
			}
		}
	}else{
		//what to do if we don't have this file
		$desRfaudio_infoObj->RF_AudioFileArr[$srcRfAudioFile_id]=
		new RfAudioFile($srcRfAudioFile_id, $srcRfAudioFileObj->getFileName(), $srcRfAudioFileObj->getTitle(), 
		$srcRfAudioFileObj->getAuthor());
		
		$desRfAudioFileObj=$desRfaudio_infoObj->getRfAudioFileObjById($srcRfAudioFile_id);
		
		$srcFile="ftps://$ftpuser:$ftppass@$host$sourceMp3DirPath/".$srcRfAudioFileObj->getFileName();
		$desFile=$desRfaudio_infoObj->getRf_audio_fileDir().'/'.$desRfAudioFileObj->getFileName();
		
		echo "begin copying $srcFile to $desFile\n";
		ob_flush();
		if(copyLock('lockme')){
			if(!copy($srcFile,$desFile)){
				$saveRFObj=false;
				die("failed to copy $srcFile to $desFile. This could indicate other problems");
			}else{
				copyLock('unlockme');
				echo "successfully copied..\n";
				echo "now sleeping for 20 seconds to satisfy ftp limits\n";
				ob_flush();
				sleep(20);
				$saveRFObj=true;
			}
		}
	}
	ob_flush();
}

//do some cleaning up if necessary
if ($handle = opendir($destinationMp3DirPath)) {
   while (false !== ($file = readdir($handle))) {
   	$safe=false;
       if ($file != "." && $file != ".." && $file != ".htaccess") {
           foreach($desRfaudio_infoObj->getRfAudioFileArr() as $desRfAudioFile_id => $desRfAudioFileObj){
	   	if($file==$desRfAudioFileObj->getFileName()){
			$safe=true;
		}
	   }
       }else{
       	$safe=true;
       }
       if(!$safe){
       	unlink($destinationMp3DirPath."/".$file);
       }
   }
   closedir($handle);
}else{
	die("Can't open the destination mp3 directory.");
}

if($saveRFObj){
	$desConfObj->saveEncObj($desRfaudio_infoObj);
}

//prevent more than one copy operation at a time
//will wait until the lock is open before returning true
function copyLock($switch){
	
	static $lock='unlocked';
	
	if($switch=='lockme'){
		if($lock=='locked'){
			//lock is already open, wait
			echo "stream is busy, now sleeping..\n";
			ob_flush();
			sleep(10);
			return copyLock($switch);
		}elseif($lock=='unlocked'){
			$lock='locked';
			return true;
		}
	}elseif($switch=='unlockme'){
		$lock='unlocked';
		echo "stream lock opened..\n";
		ob_flush();
		return true;
	}
}

*/
?>