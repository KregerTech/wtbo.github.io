#!/usr/local/dev/upload-only-php-dev/bin/php
<?php
ob_start();
require_once(dirname(__FILE__).'/initialize-5.0.3-only.php');
global $_FILES, $_POST;

$title = $_POST['title'];
$artist= $_POST['artist'];
$fileName = $_FILES['filename1']['name'];
$fileTempName = $_FILES['filename1']['tmp_name'];
$uploadError = $_FILES['filename1']['error'];

//Start error checking.

if($title==""||$artist==""){
	$iWebStreamerErrorObj->registerCritical("You must enter something for both the title and artist.");
}

//any php upload errors?

switch ($uploadError) {
   case UPLOAD_ERR_OK:
       break;
   case UPLOAD_ERR_INI_SIZE:
       $iWebStreamerErrorObj->registerCritical("The uploaded file exceeds the upload_max_filesize directive (".ini_get("upload_max_filesize").") in php.ini.");
       break;
   case UPLOAD_ERR_FORM_SIZE:
       $iWebStreamerErrorObj->registerCritical("The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form.");
       break;
   case UPLOAD_ERR_PARTIAL:
       $iWebStreamerErrorObj->registerCritical("The uploaded file was only partially uploaded.");
       break;
   case UPLOAD_ERR_NO_FILE:
       $iWebStreamerErrorObj->registerCritical("No file was uploaded.");
       break;
   case UPLOAD_ERR_NO_TMP_DIR:
       $iWebStreamerErrorObj->registerCritical("Missing a temporary folder.");
       break;
   case UPLOAD_ERR_CANT_WRITE:
       $iWebStreamerErrorObj->registerCritical("Failed to write file to disk");
       break;
   default:
       $iWebStreamerErrorObj->registerCritical("Unknown File Error");
}

if(!is_uploaded_file($fileTempName)){
	$iWebStreamerErrorObj->registerCritical($fileTempName." does not appear to be an uploaded file");
}

//creating a url friendly file name

$simple_fileName=makeNonConflictingFileName(makeSimpleFileName($fileName));

if(file_exists(AUDIOFILESDIR.'/'.$simple_fileName)){

	$simple_fileName=makeNonConflictingFileName($simple_fileName);	
}

$availableMb=AUDIOQUOTAMEGS-$fileInfoObj->getAudioDiskUsageMegs();


$uploadeFilesizeMb=floor( filesize($fileTempName) / 1048576 );
if($availableMb<$uploadeFilesizeMb){
	$iWebStreamerErrorObj->registerCritical("The uploaded file size exceeds the available audio quota.");
}



if(move_uploaded_file($fileTempName, AUDIOFILESDIR.'/'.$simple_fileName) ){
	if($fileInfoObj->addFile($simple_fileName, $title, $artist)){
		$saveConf=true;
		
		$numOfUploadedFiles = count(scandir(AUDIOFILESDIR))-2;
		
		if($numOfUploadedFiles>1){
		
			?>
				<script language="javascript" type="text/javascript">
					function load(url) {
  						self.parent.location.href = url;
					}
					setTimeout("load('file_manager.php')",3000);
				</script>
				<br><br>
				<center><p>Upload Successful!</p></center>
				
			<?
		
		}else{
			?>
				<center><p>Upload Successful!</p></center>
				<center></p>It appears this may be the first file you have uploaded to iWebStreamer.  Now that you
				have uploaded your first file, you are one step closer to getting audio on your website.  You can 
				continue to upload more mp3's if you would like.  Once finished there are a few more steps needed to 
				get audio on your website</p></center>
				
					<font color="#E94D02">
					<ul>
						<li>Click Podcasts or WebStreams above</li>
						<li>Create a Podcast or WebStream</li>
						<li>Add your Audio file to the Podcast or WebStream</li>
						<li>Generate the html code for the Podcast or WebStream</li>
						<li>Enter the html code into your website's source code</li>
					</ul>
					</font>
				
				<center>
					<p>Once you enter the code into your website source code, you never have to edit it again!
					You can continue to add and remove Mp3 files and your Podcast or WebStream on your site will 
					update automatically...wow!</p>
					
					<p>If at any time you need a little assistance getting a Podcast or WebStream set up, please click 
					on the <a href="help.php" target="main">Help</a> link above to watch the video tutorials.</p>
				</center>
			<?
		}
		
		
	}else{
		$iWebStreamerErrorObj->registerCritical("Error adding the uploaded file info to the iWebStreamer data file.");
	}
	
}else{
	$iWebStreamerErrorObj->registerCritical("Error when trying to copy the uploaded file from the temporary directory.");
}


function makeNonConflictingFileName($simple_fileName,$count=0){

	if(file_exists(AUDIOFILESDIR.'/'.$simple_fileName)){
		$new_simple_fileName=$count.'-'.$simple_fileName;
		if(file_exists(AUDIOFILESDIR.'/'.$new_simple_fileName)){
			$count++;
			return makeNonConflictingFileName($simple_fileName,$count);
		}else{
			return $new_simple_fileName;
		}
	}else{
		return $simple_fileName;
	}
	
}

?>
