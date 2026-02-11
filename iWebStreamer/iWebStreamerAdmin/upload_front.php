#!/usr/local/dev/upload-only-php-dev/bin/php
<?
	
	require_once(dirname(__FILE__).'/initialize-5.0.3-only.php');
	$id = rand();
	$mth = ini_get('upload_progress_meter.store_method');
	$dir = ini_get('upload_progress_meter.file.filename_template');
	
	$max_upload = intval(rtrim(ini_get('upload_max_filesize'), 'M'));
	
	$availableMb=AUDIOQUOTAMEGS-$fileInfoObj->getAudioDiskUsageMegs();

?>
	<script language="javascript" type="text/javascript">
	
	function validateform(){
		
		var fileInput=document.upload_helper_form.mp3_file;
		var titleInput=document.upload_helper_form.title;
		var authorInput=document.upload_helper_form.author;
		
		var extensionStr=fileInput.value;
		extensionSubStr=extensionStr.substring(extensionStr.lastIndexOf(".")+1,extensionStr.length).toLowerCase();
		if(extensionSubStr!="mp3"){
   			alert("Please select an mp3.");
			fileInput.value="";
   			fileInput.focus();
   			return false;
  		}
		
		titleVal=titleInput.value;
		if(titleVal==""){
			alert("A title is required.");
			titleInput.focus();
			return false;
		}
		
		authorVal=authorInput.value;
		if(authorVal==""){
			alert("A artist\\author is required.");
			authorInput.focus();
			return false;
		}
		
		return true;
	}
	
	
		var request = null;

   		function createRequest() {
     			try {
       				request = new XMLHttpRequest();
     			} catch (trymicrosoft) {
       				try {
         				request = new ActiveXObject("Msxml2.XMLHTTP");
       				} catch (othermicrosoft) {
         				try {
           					request = new ActiveXObject("Microsoft.XMLHTTP");
         				} catch (failed) {
           					request = null;
         				}
       				}
     			}

     			if (request == null){
       				alert("Error creating request object!");
			}
   		}
		
		var UploadId = <?=$id?>;
		
		
		function getProgressInfo(){
			//Create our url to grab the info.  Dummy data is to prevent
			//browser caching.
			var url = "progress.php?UPLOAD_IDENTIFIER=" + UploadId + "&dummyData=" + new Date().getTime();
			request.open("GET", url, true);
			request.onreadystatechange = monitorUpload;
			request.send(null);
		}
		
		function startMonitoring(){
			//Initialize the request object
			//request and send it.  
			//The first response doesn't seem
			//to say much.
			
			//Let the upload sort of initialize before 
			//asking the browser to do more.
			createRequest();
			getProgressInfo();
		}
		
		
		function monitorUpload(){
				if(request.readyState == 4){
			     
					try{
						if(request.status == 200){
							var responseXMLData = request.responseXML;
							updatePage(responseXMLData);
					}
					}catch(firefoxNonStatus){
						request = null;
					}
					//create a new request object
					createRequest();
					//wait a few seconds and then check for new data
					setTimeout("getProgressInfo()",3000);
				}
		}
		
		function updatePage(responseXMLData){
			var mainForm=document.getElementById("mainForm");
			
			var uploadedJS=responseXMLData.getElementsByTagName('uploadedXML')[0].childNodes[0].nodeValue;
			var sizeNiceJS=responseXMLData.getElementsByTagName('sizeNiceXML')[0].childNodes[0].nodeValue;
			var sizeMbJS=responseXMLData.getElementsByTagName('sizeMbXML')[0].childNodes[0].nodeValue;
			var percentCompleteJS=responseXMLData.getElementsByTagName('percentCompleteXML')[0].childNodes[0].nodeValue;
			var speedJS=responseXMLData.getElementsByTagName('speedXML')[0].childNodes[0].nodeValue;
			var etaJS=responseXMLData.getElementsByTagName('etaXML')[0].childNodes[0].nodeValue;
			
			//using this as a final check to make sure we have some data
			var dummyDataJS=responseXMLData.getElementsByTagName('dummyDataXML')[0].childNodes[0].nodeValue;
			
			if(dummyDataJS=="howdy"){
			
				if(sizeMbJS><?=$max_upload?>){
					window.location='upload_front.php?upload_error=1&upload_size=' + sizeMbJS;
					
				} else if(sizeMbJS><?=$availableMb?>){
					window.location='upload_front.php?upload_error=2&upload_size=' + sizeMbJS;
				}else{
					document.getElementById('percentComplete').style.width=percentCompleteJS*2.5;
					document.getElementById('percentLeft').style.width=250-(percentCompleteJS*2.5);
					document.getElementById('percentCompleteTxt').innerHTML=percentCompleteJS + "%";
					document.getElementById('size').innerHTML=sizeNiceJS;
					document.getElementById('uploaded').innerHTML=uploadedJS;
					document.getElementById('eta').innerHTML=etaJS;
					document.getElementById('speed').innerHTML=speedJS;
				}
			}
		}
		
		function process_form(){
			var mainForm=document.getElementById("mainForm");
			var fileInput=document.getElementById("filename1");
                	var titleInput=document.getElementById("title");
                	var artistInput=document.getElementById("artist");
			

                	artistVal=artistInput.value;
                	if(artistVal==""){
                        	artistInput.focus();
                        	nice_warn("Error: An artist/author is required.");
				return false;
                	}
			
			titleVal=titleInput.value;
                	if(titleVal==""){
                        	titleInput.focus();
                        	nice_warn("Error: A title is required.");
				return false;
                	}
			
			var extensionStr=fileInput.value;
			
                	extensionSubStr=extensionStr.substring(extensionStr.lastIndexOf(".")+1,extensionStr.length).toLowerCase();
                	
			if(extensionSubStr!="mp3"){
                        	//fileInput.value="";
                        	fileInput.focus();
                        	nice_warn("Error: Please select an Mp3 file.");
				return false;
                	}
			
			mainForm.submit();
			startMonitoring();
			showMonitoring();
			disableFields();
			showUploadingMessage();
			
		}
		
		function showMonitoring(){
			document.getElementById("hidden1").style.visibility="visible";
			document.getElementById("hidden2").style.visibility="visible";
			document.getElementById("hidden3").style.visibility="visible";
			document.getElementById("hidden4").style.visibility="visible";
		}
		
		
		function disableFields(){
			document.getElementById("formdiv1").style.visibility="hidden";
			document.getElementById("formdiv2").style.visibility="hidden";
			document.getElementById("formdiv3").style.visibility="hidden";
			document.getElementById("formdiv4").style.visibility="hidden";
			document.getElementById("formdiv5").style.visibility="hidden";
			document.getElementById("formdiv6").style.visibility="hidden";
			document.getElementById("formdiv7").style.visibility="hidden";
		}
		
		
		function showUploadingMessage(){
			var trackTitle = document.getElementById("title").value;
			nice_warn("Uploading " + trackTitle + "...Please wait");
		}
		
		
		
		function nice_warn(warningStr){
			document.getElementById("warningsDiv").innerHTML=warningStr;
			document.getElementById("warningsDiv").style.visibility="visible";
		}
		
	</script>
	
<FORM id="mainForm" name="mainForm" METHOD="POST"  ENCTYPE="multipart/form-data" action="upload_done.php?UPLOAD_IDENTIFIER=<?=$id?>">
<table valign="middle" align="center" cellpadding="0" cellspacing="0" border="0">

	   <tr>
	    <td align="right" valign="bottom"><div id="formdiv1">
		

		<input type=hidden name=UPLOAD_IDENTIFIER value="<?=$id?>">
		
		Artist/Author:
	
	    </div></td>
	    <td align="left"><div id="formdiv2">
		
		<input type="text" name="artist" id="artist" SIZE="30">
		
		
	    </div></td>
	   </tr>
	   
	   <tr align="left">
		<td align="left" colspan="2">
			<div id="hidden1" style="visibility:hidden;">
				<font color="black" size="-3"><span id="uploaded">0.00KB</span></font>&nbsp;&nbsp;
				<font size="-2">of</font>&nbsp;
				<font color="black" size="-3"><span id="size">0.00KB</span></font>&nbsp;&nbsp;
				<font size="-2">uploading at</font>&nbsp;&nbsp;
				<font color="black" size="-3"><span id="speed">0.0 kb/s</span></font>
			</div>
		</td>
	</tr>
	   
	   <tr>
	     <td align="right">	<div id="formdiv3">
		Title:&nbsp;
	     </div></td>
	     <td align="left">	<div id="formdiv4">
		<input type="text" name="title" id="title" SIZE="30">
	     </div><td>
	   </tr>
	   
	   <tr>
		<td colspan="2">
			<div id="hidden2" style="visibility:hidden;">
				<table align="left" border="0" cellpadding="0" cellspacing="0" border="0" valign="top" width="280" bgcolor="#EEE9BF">
					<tr bgcolor="#8B5A00" width="250" height="10">
						<td align="left" valign="middle" bgcolor="orange" width="0" id="percentComplete"></td>
						<td align="left" valign="middle" width="250" id="percentLeft"></td>
						
						<td width="30" align="right" valign="middle" bgcolor="white">
						<font color="black" size="-3"> 
						<span id="percentCompleteTxt">0%</span>
						</td>
					 </tr>
				</table>
			</div>
		</td>
	</tr>
	   
	   
	   <tr>
	    <td align="right"><div id="formdiv5">
	       Your Mp3 File:
	    </div></td>
	    <td align="left">	<div id="formdiv6">
		<INPUT TYPE="file" SIZE="20" NAME="filename1" id="filename1">
	    </div></td>
	   </tr>
	   
	   <tr>
		<td colspan="2" align="left">
			<div id="hidden3" style="visibility:hidden;">
				<font size="-2">Estimated Time Remaining: </font>
					<font color="black" size="-3"><span id="eta">00:00</span></font>
			</div>
		</td>
	</tr>
	   
	   
	   <tr>
		<td colspan="2" align="left">
			<br><br>
			<font color="orange" size="-3">
				<div id="warningsDiv" style="visibility:hidden;">filler text</div>
			</font>
		</td>
           </tr>
	   <tr>
	    <td colspan="2" align="center">
	    <div id="formdiv7">
		<INPUT TYPE="button" value="Upload" class="button" onClick="process_form();">
            </div>
	    </td>
	 </tr>	
	 
	 <tr>
		<td colspan="2" align="left"><br>
			<div id="hidden4" style="visibility:hidden;">
				<form><input type="button" onClick="window.location='upload_front.php';" class="button" value="Abort Upload"></form>
			<div id="hidden4" style="visibility:hidden;">
		</td>
	</tr>
	 			
	</table>
	 </FORM>
	 
	<?
		global $_GET;
		if($_GET['upload_error']==1){
			?>
			<script language="javascript" type="text/javascript">
			nice_warn("Error: <?echo $_GET['upload_size']?>MB exceeds the maximum upload size of <?=$max_upload?>MB.");
			</script>
			<?
		}
		if($_GET['upload_error']==2){
			?>
			<script language="javascript" type="text/javascript">
			nice_warn("Error: <?echo $_GET['upload_size']?>MB exceeds your available quota of <?=$availableMb?>MB.");
			</script>
			<?
		}
	?>
	   
</body>
</html>
