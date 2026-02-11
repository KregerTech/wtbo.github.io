#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET, $_POST;

	$podcastId=intval($_GET['podcastId']);
	if(!$podcastObj=$podcastInfoObj->getPodcastObj($podcastId)){
		$iWebStreamerErrorObj->registerCritical('Error, podcast does not exist');
	}
	
	$rfAudioFile_id=intval($_POST['rfAudioFile_id']);
	$isRFAudio=true;
	
	if(!$rfAudioFileObj=$rfaudio_infoObj->getRfAudioFileObjById($rfAudioFile_id)){
		$iWebStreamerErrorObj->registerCritical('Royalty Free Audio file id does not exist');
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
		var formForm = document.getElementById("addEpisode");
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
<form name="addEpisode" 
action="pod_managerAddNewEpisodeFromRFAudio_process_stage2.php?podcastId=<?echo $podcastId;?>" 
method="POST" enctype="multipart/form-data" onSubmit="return validateForm()" 
id="addPodcast">
<input type="hidden" name="rfAudioFile_id" id="rfAudioFile_id" value="<?echo $rfAudioFile_id;?>">
<table align="center" cellpadding="0" cellspacing="4" border="0">
	<tr align="center" valign="center">
		<td align="right" nowrap>
			<font color="red">*</font>Title: 
		</td>
		<td align="left">
			 <input type="text" name="title" id="title" value="<?echo $rfAudioFileObj->getTitle();?>" disabled>
		</td>
		<td align="left">
			Title as it will appear in iTunes. This value can not be edited for royalty free audio.
		</td>
	</tr>
	
	<tr align="center" valign="center" bgcolor="#F1F2F8">
		<td align="right" nowrap>
			<font color="red">*</font>Author/Artist: 
		</td>
		<td align="left">
			 <input type="text" name="author" id="author" value="<?echo $rfAudioFileObj->getAuthor();?>" 
			 disabled>
		</td>
		<td align="left">
			Author/Artist as it will appear in iTunes. This value can not be edited for royalty free audio.
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
		    	
			 <input type="text" name="pubDateDay" id="pubDateDay" size="10" maxlenth="10" 
			 value="<?echo date('m/d/Y');?>"><br><i>MM/DD/YYYY</i><br>
			 <A HREF="#" onClick="cal2.select(document.forms[0].pubDateDay,'anchor1','MM/dd/yyyy'); return false;" 
			TITLE="cal2.select(document.forms[0].pubDateDay,'anchor3','MM/dd/yyyy'); return false;" NAME="anchor1" 
			ID="anchor1">select</A>
		    </td>
		    <td>
		    	<select name="pubDateHour" id="pubDateHour">
				<?
					$currHour=intval(date('g'));
					for($i=1;$i<13;$i++){
						echo "<option value='$i'";
						 if($i==$currHour){
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
					$currMinute=intval(date('i'));
					for($i=1;$i<61;$i++){
						echo "<option value='$i'";
							if($currMinute==$i){
								echo " selected";
							}
						echo ">$i</option>";
					}
				?>
			</select>
		    </td>
		    
		    <td>
		    	<input type="radio" name="pubDateMeridiem" value="am"<?
				if(strcmp(date('a'), 'am')==0){
					echo " checked";
				}
			?>>am</input>
			<br>
			<input type="radio" name="pubDateMeridiem" value="pm"<?
				if(strcmp(date('a'), 'pm')==0){
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
				<option value="no" selected>no</option>
				<option value="yes">yes</option>
			</select>
		</td>
		<td align="left">
			You can block a specific episode from appearing in the iTunes catalog by setting the block 
			tag, however, those running the iTunes software and have already added the podcast will 
			still download this episode.
		</td>
	</tr>
	
	
	<?
		$secs=$rfAudioFileObj->getDuration();
	?>
	<tr valign="center">
		<td align="right" nowrap>
			<font color="red">*</font>Duration: 
		</td>
		<td align="left">
			<input type="text" name="duration" id="duration" value="<?echo $secs;?>" size="5" disabled> seconds
		</td>
		<td align="left">
			Duration, in seconds, that will be displayed in the iTunes software.  This value can not be edited for 
			royalty free audio.
		</td>
	</tr>
	
	<tr valign="center" bgcolor="#F1F2F8" bgcolor="#F1F2F8">
		<td align="right">
			<font color="red">*</font>Explicit: 
		</td>
		<td align="left" nowrap>
			 <select name="explicit">
			 	<option value="clean">clean</option>
				<option value="no"  selected>no</option>
				<option value="yes">yes</option>
			</select>
		</td>
		<td align="left">
			If an episode submitted to iTunes is considered explicit by the iTunes directory 
			administrators, and the explicit tag had not been set "yes" on the episode, it may 
			result in permanent removal from the iTunes directory.  If the explicit tag on the 
			podcast itself has been set, it will override a clean or no setting here on this specific 
			episode. This setting is useful when a Podcast is most always appropriate for all audiences, 
			but an individual episode may not be.<br><br>
			We honestly expect all royalty free audio to be free from being even questionable, but as it is still 
			a podcasts which you manage, the final choice is up to you.
			
		</td>
	</tr>
	
	<script language="javascript" type="text/javascript">
		
		var keywordsArr=new Array();
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
			 style='background-color:#F1F2F8; overflow:auto;'></textarea><br>
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
			<textarea name="subtitle" cols="30" rows="3"></textarea>
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
			onKeyDown="textCounter(document.addPodcast.summary,document.addPodcast.remLen1,4000)" 
			onKeyUp="textCounter(document.addPodcast.summary,document.addPodcast.remLen1,4000)"></textarea>
			
		</td>
		<td align="left">
			This section can be up to 4,000 characters long.  When someone clicks the circled "i" within 
			the iTunes software, a new window will open with the content entered here.  It is also 
			included on the iTunes page for this Podcast if submitted to the iTunes catalog.
			<br>
			<br>
			<input readonly type="text" name="remLen1" size="3" maxlength="3" value="4000">
			characters left
			<br>
		</td>
	</tr>
	
	<tr align="center">
		<td align="right">
		</td>
		
		<td bgcolor="#F1F2F8">
			<input class="button" type="button" id="submitButton" value="Add Episode to Podcast" onClick="validateForm()">
		</td>
		
		<td align="left">
		</td>
	</tr>