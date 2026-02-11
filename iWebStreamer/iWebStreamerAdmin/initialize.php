<?
	/*
		This file is included within the main iframe.
		It is the first file included in the pages called
		within the main iframe pages and is used to include
		all the necessary includes and initialize stuff.
	*/

	ob_start("ob_gzhandler");
        ini_set('display_errors', 1);
	
	require_once(dirname(__FILE__).'/../custom_classes/UserInfo.class');
	require_once(dirname(__FILE__).'/../custom_classes/ConfigFile.class');
	require_once(dirname(__FILE__).'/../../iWebStreamer/includes/iWebStreamerError.class');
	require_once(dirname(__FILE__).'/../../iWebStreamer/includes/iWebStreamerConfFile.class');
	require_once(dirname(__FILE__).'/../../iWebStreamer/includes/file_info.class');
	require_once(dirname(__FILE__).'/../../iWebStreamer/includes/rfaudio_info.class');
	require_once(dirname(__FILE__).'/finalize.php');
	
	//keep pages from getting cached
	header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT"); // Date in the past
	
	//create a single error object for the rest of the execution
	$iWebStreamerErrorObj=new iWebStreamerError();
	
	//Load the conf file
	$iWebStreamerConf = parse_ini_file(dirname(__FILE__).'/../../iWebStreamer/includes/iWebStreamerMainConf.inc', true);
	
	
	//Initialize a UserInfo object
	$userInfo = new UserInfo ();
	
	if(!$userInfo->isValid()){
		$iWebStreamerErrorObj->registerCritical("An error occured while determing global variables.");
	}
	
	//define some constants to make life easier
	define("USERNAME", $userInfo->getUser());
	define("IP", $userInfo->getIP());
	define("USERROOTDIR", $userInfo->getUserRootDir()); // /home/ussr
	define("AUDIOQUOTAMEGS", $iWebStreamerConf['Audio File Quota'][$userInfo->getPackage()]); //audio quota in megs
	define("AUDIOFILESDIR", $userInfo->getDocumentRoot().'/'.$iWebStreamerConf['UserConfSettings']['audio_dir']);
	define("DOMAINNAME", $userInfo->getDomainName());
	define("AUDIOBASEURL", '/'.$iWebStreamerConf['UserConfSettings']['audio_dir'].'/');
	define("LANGUAGEFILE", $iWebStreamerConf['languages']['languages_file']);
	define("ITUNESCATEGORIESFILE", $iWebStreamerConf['iTunes']['categories_file']);
	define("READMP3SECSCMD",$iWebStreamerConf['programs']['readMp3SecondsCmd']);
	define("PREVIEWPLAYERURL", $iWebStreamerConf['programs']['previewUrl']);
	define("FLASHPLAYERSROOT", $iWebStreamerConf['programs']['flashPlayersRoot']);
	define("FLASHPLAYERSROOTFULLPATH", $iWebStreamerConf['programs']['flashPlayersRootFullPath']);
	
	//initialize the main conf file object
	$confFileObj=new ConfigFile($iWebStreamerConf['UserConfSettings']['conf_name']); 
	
	//initialize the royalty free audio object
	$rfaudio_infoConfObj=new ConfigFile($iWebStreamerConf['RF Audio']['rfConfName']);
	$rfaudio_infoConfObj->setConfPath($iWebStreamerConf['RF Audio']['destinationConfPath']);
	$rfaudio_infoObj=$rfaudio_infoConfObj->restoreEncObj();
	define("AVAILRFAUDIOFILESDIR", $iWebStreamerConf['RF Audio']['destinationMp3DirPath']);
	define("RFAUDIOBASEURL", '/'.$iWebStreamerConf['RF Audio']['relativeUrl'].'/');
	
	
	//Verify the existence of necessary files and directories.
	//Create them if necessary or die with an error otherwise
	
	if(!$confFileObj->confExists()){
		$iWebStreamerConf=new iWebStreamerConf();
		if(!$confFileObj->touchConf()||!$confFileObj->saveEncObj($iWebStreamerConf)){
			$iWebStreamerErrorObj->registerCritical('Unable to create the conf file.');
		}
	}
	
	
	if((!file_exists(AUDIOFILESDIR))&&(!mkdir(AUDIOFILESDIR))){
		$iWebStreamerErrorObj->registerCritical('Unable to create or access the audio files directory.');
	}
	
	
	//Initialize user settings
	$iWebStreamerConf=$confFileObj->restoreEncObj();
	$fileInfoObj=$iWebStreamerConf->getFileInfoObj();
	$podcastInfoObj=$iWebStreamerConf->getPodcastsInfoObj();
	$webstreamInfoObj=$iWebStreamerConf->getWebStreamsInfoObj();
	
	
	//Initialize any parameters now available from objects
		//setting the default time zone based on the podcast info object
		$podcastInfoObj->initializeTimeZone();
	
	//when something has been done which requires saving the conf, set to true.
	$saveConf=false;
	register_shutdown_function("myShutdownFunction");
	
	//clean up the upload directory
		//first read all the files in there into an array
		$filesInDirArr=array();
		if ($handle = opendir(AUDIOFILESDIR)) {
   			while (false !== ($file = readdir($handle))) {
       				if ($file != "." && $file != "..") {
           				array_push($filesInDirArr, $file);
       				}
   			}
   			closedir($handle);
		}
		
		//loop through the files we know about.  If it's not there, delete
		foreach($filesInDirArr as $index => $fileName){
			$safe=false;
			foreach($fileInfoObj->getFilesArr() as $fileId => $fileObj){
				if(!strcmp($fileObj->getFileName(), $fileName)){
					$safe=true;
				}
			}
			if(!$safe){
				unlink(AUDIOFILESDIR.'/'.$fileName);
			}
		}
		
		//loop through the files that should be in the system.  If they are not there, remove from the system.
		foreach($fileInfoObj->getFilesArr() as $fileId => $fileObj){
			$safe=false;
			foreach($filesInDirArr as $index => $fileName){
				if(!strcmp($fileObj->getFileName(), $fileName)){
					$safe=true;
				}
			}
			if(!$safe){
				$fileObj->deleteFileFromPodcastsAndWebStreams();
				$fileInfoObj->removeFile($fileId);
				$saveConf=true;
			}
		}
		
		
	
?>
<html>
	<head>
	
	<script language="javascript" type="text/javascript" src="prototype.js"></script>
	<script language="javascript" type="text/javascript" src="upload.js"></script>
	<script language="javascript" type="text/javascript">
	
	function clear_form(){
		form_upload_button = document.getElementById("upload_button");
		form_upload_button.disabled=false;
		document.upload_helper_form.mp3_file.disabled=false;
		document.upload_helper_form.mp3_file.value="";
	}
	
	</script>
			<style type="text/css">
			<!--
			body,td,th {
				font-family: Verdana, Arial, Helvetica, sans-serif;
				color: #0000D2;
				font-weight: bolder;
				font-size:x-small;
			}
			a {
				font-size: xx-small;
				color: #0000D2;
				font-weight: bold;
			}
			a:visited {
				color: #0000D2;
			}
			a:hover {
				color: #66CC00;
			}
			a:active {
				color: #0000D2;
			}
			
		
			.toolBar
			{
				color:#E94D02;
				font-family:Verdana;
				font-weight: bolder;
				font-size:xx-small;
			}
			
			.iwebstreamertable
			{
				color:#E94D02;
				font-family:Verdana;
				font-weight: bolder;
				font-size:xx-small;
				
			}
			
			
			.button{
				background:#0000D2;
				color:white;
				font-weight: bolder;
			}
			
			.button:hover{
				background:#0000D2;
				color:#E94D02;
				font-weight: bolder;
			}

			
		-->	
		</style>
		
		
		
	</script>
	<link rel="stylesheet" href="upload.css" type="text/css" media="screen" title="Upload" charset="utf-8" />
	</head>
<body>
<?
