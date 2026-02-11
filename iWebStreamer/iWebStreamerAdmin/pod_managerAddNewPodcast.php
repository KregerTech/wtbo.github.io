#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET;
	global $_POST;
	require_once(dirname(__FILE__).'/navbar.php');
?>

<script language="javascript" type="text/javascript">

	function validateForm(){
		var formForm = document.getElementById("addPodcast");
		var formTitle = document.getElementById("title");
		var formAuthor = document.getElementById("author");
		var formSummary = document.getElementById("summary");
		var formEmail = document.getElementById("email");
		var submitButton = document.getElementById("submitButton");
		
		if(formTitle.value == ""){
			alert("A title for this podcast is required.");
			formTitle.focus();
			return false;
		}
		
		if(formAuthor.value == ""){
			alert("An author/maintainer/owner is required.");
			formAuthor.focus();
			return false;
		}
		
		if(formSummary.value.length>4000){
			alert("summary can not exceed 4,000 characters");
			formSummary.focus();
			return false;
		}
		
		if(formEmail.value != ""){
			var re = /@/;
			if(!re.test(formEmail.value)){
				alert("The email address you have entered does not appear to be valid.");
				formEmail.focus();
				return false;
			}
		}
		
		submitButton.disabled=true;
		document.getElementById('keywords').disabled=false;
		formForm.submit();
	}

</script>
<form name="addPodcast" action="pod_managerAddNewPodcast_process.php" method="POST" enctype="multipart/form-data" onSubmit="return validateForm()" id="addPodcast">
<table align="center" cellpadding="0" cellspacing="4" border="0">
	<tr align="center" valign="center">
		<td align="right">
			<font color="red">*</font>Title: 
		</td>
		<td align="left">
			 <input type="text" name="title" id="title">
		</td>
		<td align="left">
			Title as it will appear in iTunes.
		</td>
	</tr>
	<tr valign="center" bgcolor="#F1F2F8">
		<td align="right">
			<br>
			<br>
			Link: 
		</td>
		<td align="left" nowrap>
			<i>ex.<br>
			http://yourwebsite.com/related_link.html</i><br>
			 <input type="text" name="link" id="link" size="40">
		</td>
		<td align="left">
			Enter an entire url.  This will appear in iTunes exactly as entered here. 
			Ex. http://mydomain.com/page-I-want-associatied-with-this-podcast.html
			(Can be any page you want.  Does not have to be the page where one finds your podcast
			feed)
		</td>
	</tr>
	<tr align="center" valign="center">
		<td align="right">
			Copyright: 
		</td>
		<td align="left">
			 <input type="text" name="copyright" id="copyright">
		</td>
		<td align="left">
			If copyright information is entered a &#xA9; symbol will precede it automatically.
		</td>
	</tr>
	<tr align="center" valign="center" bgcolor="#F1F2F8">
		<td align="right">
			<font color="red">*</font>Author/Owner<br>/Maintainer: 
		</td>
		<td colspan="2" align="left">
			 <input type="text" name="author" id="author">
		</td>
	</tr>
	<tr valign="center">
		<td align="right">
			<font color="red">*</font>Block: 
		</td>
		<td align="left" nowrap>
			 <select name="block">
				<option value="no" selected>no</option>
				<option value="yes">yes</option>
			</select>
		</td>
		<td align="left">
			You can block a podcast from appearing in the iTunes catalog by setting the block tag. 
			A podcast will not appear until it is first submitted and this value can be changed at any time.
		</td>
	</tr>
	
	<tr valign="center" bgcolor="#F1F2F8">
		<td align="right">
			<font color="red">*</font>TTL (Time To Live): 
		</td>
		<td align="left" nowrap>
			 <select name="ttl">
				<?
					for($i=1;$i<2881;$i++){
						$checked='';
						if($i==60){
							$checked=' selected';
						}
						echo "<option value='$i' $checked>$i</option>";
					}
				?>
			</select>
		</td>
		<td align="left">
			The time to live of a podcast is the interval, in minutes, which the iTunes catalog will check for updates on your podcast to display in the catalog.  It is not the interval at which someone with iTunes software installed will check for new episodes.  This is set by the user's own preference.  The default setting for iTunes software is once per day.<br><br>
			A setting of 60 is a good value here.
		</td>
	</tr>
	
	<tr valign="center">
		<script language="javascript" type="text/javascript" src="dynamicSelect.js"></script>
		<?
			$catArr=$podcastInfoObj->getItunesCategoriesArr();
		?>
	
		<td align="right" colspan="2">	
			
			<table cellspacing="4">
			 	<tr bgcolor="#F1F2F8">
					<td align="right" nowrap>
						Main Category 1: 
					</td>
					<td align="left" nowrap>
						<select name="Main Category 1" id="Main Category 1">
							<option value="no category" selected>no category</option>
						<?
							foreach($catArr as $mainCat => $subCatArr){
								echo "<option value='$mainCat'>$mainCat</option>\n";
							}
						?>
						</select>
					</td>
				</tr>
				<tr  bgcolor="#F1F2F8">
					<td align="right" nowrap>
						Sub Category 1: 
					</td>
					<td align="left" nowrap width="200">
						<select name="Sub Category 1" id="Sub Category 1">
							<option value="no subcategory" selected>no subcategory</option>
						</select>
					</td>
				</tr>
				<tr>
					<td align="right" nowrap>
						Main Category 2: 
					</td>
					<td align="left" nowrap>
						<select name="Main Category 2" id="Main Category 2">
							<option value="no category" selected>no category</option>
						<?
							foreach($catArr as $mainCat => $subCatArr){
								echo "<option value='$mainCat'>$mainCat</option>\n";
							}
						?>
						</select>
					</td>
				</tr>
				<tr>
					<td align="right" nowrap>
						Sub Category 2: 
					</td>
					<td align="left" nowrap width="200">
						<select name="Sub Category 2" id="Sub Category 2">
							<option value="no subcategory" selected>no subcategory</option>
						</select>
					</td>
				</tr>
				
				<tr bgcolor="#F1F2F8">
					<td align="right" nowrap>
						Main Category 3: 
					</td>
					<td align="left" nowrap>
						<select name="Main Category 3" id="Main Category 3">
							<option value="no category" selected>no category</option>
						<?
							foreach($catArr as $mainCat => $subCatArr){
								echo "<option value='$mainCat'>$mainCat</option>\n";
							}
						?>
						</select>
					</td>
				</tr>
				<tr bgcolor="#F1F2F8">
					<td align="right" nowrap>
						Sub Category 3: 
					</td>
					<td align="left" nowrap width="200">
						<select name="Sub Category 3" id="Sub Category 3">
							<option value="no subcategory" selected>no subcategory</option>
						</select>
					</td>
				</tr>
				
			</table>
		
		
		
		</td>
		<td align="left" valign="center">
			You can optionally choose up to three categories, with or without a subcategory.
			As recommended by Apple, categories and subcategories are limited to those 
			available from iTunes.
		</td>
		
	</tr>
	
	<script language="javascript" type="text/javascript">
		var category1Chooser = new DynamicOptionList();
		category1Chooser.addDependentFields("Main Category 1","Sub Category 1");
		
		category1Chooser.forValue("no category").addOptions("no subcategory");
			
			<?
				foreach($catArr as $mainCat => $subCatArr){
					if(count($subCatArr)){
						foreach($subCatArr as $subCat){
						     echo "category1Chooser.forValue('$mainCat').addOptions('$subCat');";
						}
					   echo "category1Chooser.forValue('$mainCat').addOptions('no subcategory');";
					}else{
					   echo "category1Chooser.forValue('$mainCat').addOptions('none available');";
					}
				}
			?>
		
		category1Chooser.selectFirstOption = true;
		
		
		var category2Chooser = new DynamicOptionList();
		category2Chooser.addDependentFields("Main Category 2","Sub Category 2");
		category2Chooser.forValue("no category").addOptions("no subcategory");
			
			<?
				foreach($catArr as $mainCat => $subCatArr){
					if(count($subCatArr)){
						foreach($subCatArr as $subCat){
						     echo "category2Chooser.forValue('$mainCat').addOptions('$subCat');";
						}
					   echo "category2Chooser.forValue('$mainCat').addOptions('no subcategory');";
					}else{
					   echo "category2Chooser.forValue('$mainCat').addOptions('none available');";
					}
				}
			?>
		
		category2Chooser.selectFirstOption = true;
		
		
		var category3Chooser = new DynamicOptionList();
		category3Chooser.addDependentFields("Main Category 3","Sub Category 3");
		category3Chooser.forValue("no category").addOptions("no subcategory");
			
			<?
				foreach($catArr as $mainCat => $subCatArr){
					if(count($subCatArr)){
						foreach($subCatArr as $subCat){
						     echo "category3Chooser.forValue('$mainCat').addOptions('$subCat');";
						}
					   echo "category3Chooser.forValue('$mainCat').addOptions('no subcategory');";
					}else{
					   echo "category3Chooser.forValue('$mainCat').addOptions('none available');";
					}
				}
			?>
		
		category3Chooser.selectFirstOption = true;
		
	</script>
	
	<tr valign="center" bgcolor="#F1F2F8">
		<td align="right">
			<font color="red">*</font>Explicit: 
		</td>
		<td align="left" nowrap>
			 <select name="explicit">
			 	<option value="clean">clean</option>
				<option value="no" selected>no</option>
				<option value="yes">yes</option>
			</select>
		</td>
		<td align="left">
			If a podcast submitted to iTunes is considered explicit by the iTunes directory 
			administrators, and the explicit tag had not been set "yes" on the podcast, it may 
			result in permanent removal from the iTunes directory.  Podcasts with an 
			explicit tag set to yes will display a parental advisory warning in the iTunes
			directory.  Please use your best discretion when selecting this option. If the 
			majority of your podcast episodes would be considered appropriate for all audiences,
			you can leave this to clean or no, and set the explict tag to yes only on specific episodes.
			<ul>
				<li>Clean - A "clean" tag will appear next to the episode in itunes
				<li>No - Neither an explicit or clean tag will appear next to the episode, leaving more room for the title.
				<li>Yes - An explicit tag will appear next to this episode in iTunes.
			</ul>
		</td>
	</tr>
	
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
			Name: 
		</td>
		<td align="left" nowrap>
			<input type="text" name="name" id="name">
		</td>
		<td align="left">
			Not displayed within the iTunes software, but can be seen by viewing the feed directly.
			The owner tag is also not displayed within the iTunes catalog, but is used by iTunes to 
			address the the owner of the feed when someone reports a concern about your feed to iTunes.
		</td>
	</tr>
	
	<tr valign="center">
		<td align="right">
			Email: 
		</td>
		<td align="left" nowrap>
			<input type="text" name="email" id="email">
		</td>
		<td align="left">
			Usage is the same as the name tag above.
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
			This section can be up to 4,000 characters long.  When someone clicks the circled "i" within the 
			iTunes software, a new window will open with the content entered here.  It is also included on 
			the iTunes page for this Podcast if submitted to the iTunes catalog.
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
			<input class="button" type="button" id="submitButton" value="Create Podcast" onClick="validateForm()">
		</td>
		
		<td align="left" bgcolor="#F1F2F8">
			Don't worry if you think you might have made a mistake, you can always go back and change it later, however, it is not recommended that you change Podcast feed information after submitting it to the iTunes catalog.
		</td>
	</tr>
</table>
</form>

<script>
	initDynamicOptionLists();
</script>