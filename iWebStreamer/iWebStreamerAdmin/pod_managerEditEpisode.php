#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET, $_POST;

	$podcastId=intval($_GET['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist.');
	}
	
	$podcastFileId=intval($_GET['podcastFileId']);
	if(!$podcastFileObj=$podcastObj->getPodcastFileObj($podcastFileId)){
		$iWebStreamerErrorObj->registerCritical('Episode Id does not exist.');
	}
	
	$isRFAudio=$podcastFileObj->getIsRFAudio();
	
	$fileId=$podcastFileObj->getFileId();
	
	//since the only thing need from either an rf or file object are methods
	//by the same name, just using fileObj for either one.
	if($isRFAudio){
		if(!$fileObj=$rfaudio_infoObj->getRfAudioFileObjById($fileId)){
			$iWebStreamerErrorObj->registerCritical('File id does not exist');
		}
	}else{
		if(!$fileObj=$fileInfoObj->getFileObj($fileId)){
			$iWebStreamerErrorObj->registerCritical('File id does not exist');
		}
	}

require_once(dirname(__FILE__).'/navbar.php');	

?>

<script language="javascript" type="text/javascript">

		// Removes leading whitespaces
		function LTrim( value ) {

			var re = /\s*((\S+\s*)*)/;
			return value.replace(re, "$1");

		}
		function RTrim( value ) {

			var re = /((\s*\S+)*)\s*/;
			return value.replace(re, "$1");

		}
		function trim( value ) {

			return LTrim(RTrim(value));

		}
		

		/**--------------------------
		//* Validate Date Field script- By JavaScriptKit.com
		//* For this script and 100s more, visit http://www.javascriptkit.com
		//* This notice must stay intact for usage
		---------------------------**/

		function checkdate(input){
			var validformat=/^\d{2}\/\d{2}\/\d{4}$/ //Basic check for format validity
			var returnval=false
			if (!validformat.test(input.value))
				return false;
			else{ //Detailed check for valid date ranges
				var monthfield=input.value.split("/")[0]
				var dayfield=input.value.split("/")[1]
				var yearfield=input.value.split("/")[2]
				var dayobj = new Date(yearfield, monthfield-1, dayfield)
				
				if ((dayobj.getMonth()+1!=monthfield)||(dayobj.getDate()!=dayfield)||(dayobj.getFullYear()!=yearfield))
				return false;
				
				else
				return true;
			}
		}


	function validateForm(){
	
		var formSummary = document.getElementById("summary");
		var duration = document.getElementById("duration");
		var pubDateDay = document.getElementById("pubDateDay");
		var formForm = document.getElementById("editEpisode");
		var submitButton = document.getElementById("submitButton");
		
		if(formSummary.value.length>4000){
			alert("summary can not exceed 4,000 characters");
			formSummary.focus();
			return false;
		}
		
		if(isNaN(trim(duration.value))){
			alert("you must enter the duration in the number of seconds.");
			duration.focus();
			return false;
		}
		
		if(!checkdate(pubDateDay)){
			alert("The date you have entered is not valid.");
			pubDateDay.focus();
			return false;
		}
		
		submitButton.disabled=true;
		document.getElementById('keywords').disabled=false;
		formForm.submit();
	}
</script>
<form name="editEpisode" 
action="pod_managerEditEpisode_process.php?podcastId=<?echo $podcastId;?>&podcastFileId=<?echo $podcastFileId;?>" 
method="POST" enctype="multipart/form-data" onSubmit="return validateForm()" 
id="editEpisode">
<input type="hidden" name="fileId" id="fileId" value="<?echo $fileId;?>">
<input type="hidden" name="isRFAudio" id="isRFAudio" value="<?echo $isRFAudio ? "true" : "false";?>">
<table align="center" cellpadding="0" cellspacing="4" border="0">
	<tr align="center" valign="center">
		<td align="right" nowrap>
			<font color="red">*</font>Title: 
		</td>
		<td align="left">
			 <input type="text" name="title" id="title" value="<?echo $fileObj->getTitle();?>" disabled>
		</td>
		<td align="left">
			Title as it will appear in iTunes. This can not be edited here.  You can change the title 
			under the "Available Audio" section by clicking "modify" next to this file.Changing the 
			title on this file will affect any podcasts or WebStreams which use it.
			<?if($isRFAudio){echo "This can not be edited for Royalty Free Audio.";}?>
		</td>
	</tr>
	
	<tr align="center" valign="center" bgcolor="#F1F2F8">
		<td align="right" nowrap>
			<font color="red">*</font>Author/Artist: 
		</td>
		<td align="left">
			 <input type="text" name="author" id="author" value="<?echo $fileObj->getAuthor();?>" disabled>
		</td>
		<td align="left">
			Author/Artist as it will appear in iTunes. This can not be edited here.  You can change the 
			author/artist under the "Available Audio" section by clicking "modify" next to the file. 
			Changing the author/artist on this file will affect any podcasts or WebStreams which use it.
			<?if($isRFAudio){echo "This can not be edited for Royalty Free Audio.";}?>
		</td>
	</tr>
	
	<script language="javascript" src="CalendarPopup.js"></script>
	<SCRIPT LANGUAGE="JavaScript" ID="pubDate">
			var cal2 = new CalendarPopup();
			cal2.showYearNavigation();
	</script>
	<tr align="center" valign="center">
		<td align="right" nowrap>
			<font color="red">*</font>Publish Date: 
		</td>
		<td align="left">
		  <table valign="top">
		   <tr valign="top">
        	      <td>
			 Date<br>
		      </td>
		      <td>
		      	 Hour
		      </td>
		      <td>
		      	 Minute
		      </td>
		      <td>
		         Meridiem
		      </td>
	           </tr> 
		   <tr  valign="top">
		    <td>
		    	 <?
			 	$pubDateDay=date('m/d/Y', $podcastFileObj->getPubDate());
				$pubDateHour=intval(date('g', $podcastFileObj->getPubDate()));
				$pubDateMin=intval(date('i', $podcastFileObj->getPubDate()));
				$pubDateMeridiem=date('a', $podcastFileObj->getPubDate());
			 ?>
			 <input type="text" name="pubDateDay" id="pubDateDay" size="10" maxlenth="10" 
			 value="<?echo $pubDateDay;?>"><br><i>MM/DD/YYYY</i><br>
			 <A HREF="#" onClick="cal2.select(document.forms[0].pubDateDay,'anchor1','MM/dd/yyyy'); return false;" 
			TITLE="cal2.select(document.forms[0].pubDateDay,'anchor3','MM/dd/yyyy'); return false;" NAME="anchor1" 
			ID="anchor1">select</A>
		    </td>
		    <td>
		    	<select name="pubDateHour" id="pubDateHour">
				<?
					for($i=1;$i<13;$i++){
						echo "<option value='$i'";
						 if($i==$pubDateHour){
						 	echo " selected";
						 }
						echo ">$i</option>";
					}
				?>
			</select>
		    </td>
		    
		     <td>
		    	<select name="pubDateMinute" id="pubDateMinute">
				<?
					for($i=1;$i<61;$i++){
						echo "<option value='$i'";
							if($pubDateMin==$i){
								echo " selected";
							}
						echo ">$i</option>";
					}
				?>
			</select>
		    </td>
		    
		    <td>
		    	<input type="radio" name="pubDateMeridiem" value="am"<?
				if(strcmp($pubDateMeridiem, 'am')==0){
					echo " checked";
				}
			?>>am</input>
			<br>
			<input type="radio" name="pubDateMeridiem" value="pm"<?
				if(strcmp($pubDateMeridiem, 'pm')==0){
					echo " checked";
				}
			?>>pm</input>
		    </td>
		    
		    </tr>
		   </table>
		</td>
		<td align="left">
			When would you like this episode broadcast?  The publish date will also be 
			displayed within the iTunes software. Leaving it to the default (now), will not 
			result in the episode not being available if you take a few minutes to complete this 
			form, or in other words, any date in the past will still result in the episode being 
			downloaded by the iTunes software.
		</td>
	</tr>
	
	<tr valign="center" bgcolor="#F1F2F8">
		<td align="right" nowrap>
			<font color="red">*</font>Block: 
		</td>
		<td align="left" nowrap>
			 <select name="block">
				<option value="no" <?if(strcmp($podcastFileObj->getBlock(), 'no')==0) echo "selected";?>>no</option>
				<option value="yes" <?if(strcmp($podcastFileObj->getBlock(), 'yes')==0) echo "selected";?>>yes</option>
			</select>
		</td>
		<td align="left">
			You can block a specific episode from appearing in the iTunes catalog by setting the block 
			tag, however, those running the iTunes software and have already added the podcast will 
			still download this episode.
		</td>
	</tr>
	
	
	<?
		$secs=$fileObj->getDuration();
	?>
	<tr valign="center">
		<td align="right" nowrap>
			<font color="red">*</font>Duration: 
		</td>
		<td align="left">
			<input type="text" name="duration" id="duration" value="<?echo $podcastFileObj->getDuration();?>" size="5" 
			<?if($isRFAudio) echo "disabled";?>> 
			seconds
		</td>
		<td align="left">
			This information is read from the id3 tag of your uploaded mp3 file.  This is most likely 
			an accurate value, so unless you are sure it is not correct for some reason, 
			it is recommend that you do not change this value.
		</td>
	</tr>
	
	
	<tr valign="center" bgcolor="#F1F2F8" bgcolor="#F1F2F8">
		<td align="right">
			<font color="red">*</font>Explicit: 
		</td>
		<td align="left" nowrap>
			 <select name="explicit">
			 	<option value="clean"<?if(strcmp($podcastFileObj->getExplicit(), 'clean')==0) echo " selected";?>>clean</option>
				<option value="no"<?if(strcmp($podcastFileObj->getExplicit(), 'no')==0) echo " selected";?>>no</option>
				<option value="yes"<?if(strcmp($podcastFileObj->getExplicit(), 'yes')==0) echo " selected";?>>yes</option>
			</select>
		</td>
		<td align="left">
			If an episode submitted to iTunes is considered explicit by the iTunes directory 
			administrators, and the explicit tag had not been set "yes" on the episode, it may 
			result in permanent removal from the iTunes directory.  If the explicit tag on the 
			podcast itself has been set, it will override a clean or no setting here on this specific 
			episode. This setting is useful when a Podcast is most always appropriate for all audiences, 
			but an individual episode may not be.
		</td>
	</tr>
	
	<script language="javascript" type="text/javascript">
		
		var keywordsArr=new Array();
		var keywordsArr=new Array();
		<?
			foreach(preg_split('/\,/', $podcastFileObj->getKeywords()) as $index => $value){
				$value=trim($value);
				if(strlen($value)>0){
					echo "keywordsArr.push('$value');\n";
				}
			}
		?>
		function addKeyWord(){
			var keywordStr = trim(document.getElementById("newKeyword").value);
			var re = /\s/;
			if(re.test(keywordStr)){
				alert("Only single key words,not phrases, may be entered as keywords.");
				return false;
			}else{
				keywordsArr.push(keywordStr);
				var textArrStr='';
				var i = 0;
				for(i = 0; i < keywordsArr.length; i++){
					textArrStr = textArrStr + keywordsArr[i] + ',';
				}
				textArrStr=textArrStr.substr(0, textArrStr.length-1);
				document.getElementById("newKeyword").value='';
				document.getElementById("keywords").value=textArrStr;
			}
		}
		
		function removeKeyword(){
			keywordsArr.pop();
			var textArrStr='';
			var i = 0;
			for(i = 0; i < keywordsArr.length; i++){
				textArrStr = textArrStr + keywordsArr[i] + ',';
			}
			textArrStr=textArrStr.substr(0, textArrStr.length-1);
			document.getElementById("newKeyword").value='';
			document.getElementById("keywords").value=textArrStr;
		}
	</script>
	
	<tr valign="center">
		<td align="right">
			Keywords: 
		</td>
		<td align="left" nowrap>
			enter a keyword here and<br>
			press click "Add Keyword"<br>
			<input type="text" name="newKeyword" id="newKeyword"><br>
			<input class="button" type="button" value="Add Keyword" onClick="addKeyWord();"><br><br>
			Current keywords:<br>
			<textarea cols="30" rows="3" name="keywords" id="keywords" disabled="true"
			 style='background-color:#F1F2F8; overflow:auto;'><?
			 
			 	echo $podcastFileObj->getKeywords();
			 
			 ?></textarea><br>
			<input class="button" type="button" value="Remove Last Keyword" onClick="removeKeyword();">
		</td>
		<td align="left">
			Apple recommends minimizing keyword usage.  Keywords are not visible, but are 
			searchable within the iTunes catalog.  The recommended best usage is for 
			common misspellings of your name or title to ensure your podcost can still 
			be found within a search.
		</td>
	</tr>
	
	<tr valign="center" bgcolor="#F1F2F8">
		<td align="right">
			Subtitle: 
		</td>
		<td align="left" nowrap>
			<textarea name="subtitle" cols="30" rows="3"><?echo $podcastFileObj->getSubtitle();?></textarea>
		</td>
		<td align="left">
			No official limitations are placed on the subtitle, but iTunes recommends limiting usage to a few words if it is used at all.
		</td>
	</tr>
	
	<script language="javascript" type="text/javascript">
	function textCounter(field,cntfield,maxlimit) {
			if(field.value.length<=4000){
				cntfield.value = maxlimit - field.value.length;
			}else{
				field.value = field.value.substring(0, maxlimit);
				alert("Summary can not exceed 4000 characters");
				cntfield.value = 0;
				field.focus();
			}
	}
	</script>
	
	<tr valign="center">
		<td align="right">
			Summary: 
		</td>
		<td align="left" nowrap>
			<textarea cols="30" rows="20" name="summary" id="summary" 
			onKeyDown="textCounter(document.editEpisode.summary,document.editEpisode.remLen1,4000)" 
			onKeyUp="textCounter(document.editEpisode.summary,document.editEpisode.remLen1,4000)"><?echo $podcastFileObj->getSummary();?></textarea>
			
		</td>
		<td align="left">
			This section can be up to 4,000 characters long.  When someone clicks the circled "i" within 
			the iTunes software, a new window will open with the content entered here.  It is also 
			included on the iTunes page for this Podcast if submitted to the iTunes catalog.
			<br>
			<br>
			<input readonly type="text" name="remLen1" size="3" maxlength="3" value="<?echo 4000-strlen($podcastFileObj->getSummary());?>">
			characters left
			<br>
		</td>
	</tr>
	
	<tr align="center">
		<td align="right">
		</td>
		
		<td bgcolor="#F1F2F8">
			<input class="button" type="button" id="submitButton" value="Edit Episode" onClick="validateForm()">
		</td>
		
		<td align="left">
		</td>
	</tr>