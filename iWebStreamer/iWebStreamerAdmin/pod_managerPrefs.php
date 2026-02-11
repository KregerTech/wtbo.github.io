#!/usr/local/dev/bin/php
<?

	/*
		pod_manager.php
		
		main page to manage podcasts
	*/
	

	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET;
	global $_POST;
	
	//Do we need to update a language or iso code?
	if(isset($_POST['action'])){
		switch($_POST['action']){
		
			case "change_tZone":{
				if($podcastInfoObj->setTimeZone(trim($_POST['newTzone']))){
					$saveConf=true;
				}
			}
		
			case "change_isoCode":{
				if($podcastInfoObj->setIsoCode(trim($_POST['isCode']))){
					$saveConf=true;
				}
			}
		}
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
	
	
?>
Podcasts are scheduled to be broadcast when you specify.  To make this easier for you to manage, please
select your time zone. All broadcast times will be scheduled relative to your zone.<br>
<form name="change_tZone" action="<?echo $_SERVER['PHP_SELF'];?>" method="POST" enctype ="multipart/form-data">
<table width ="450">
<tr valign="bottom"> <td nowrap width="150">
Current time zone is:<br>
<font color="green">
<?
	echo $podcastInfoObj->getCurrTimeZone();
?>
</font>
</td>

<td nowrap align="right" width="150">
New Time Zone:<br>
<select name="newTzone" id="tZoneSelector">

<?
	foreach(timezone_identifiers_list() as $index => $identifier){
		$selected='';
		if($podcastInfoObj->getCurrTimeZone()==$identifier){
			$selected=' selected';
		}
		echo "<option $selected value='$identifier'>$identifier</option>\n";
	}
?>
</select>
<td nowrap align="right" width="150" valign="bottom">
<input type="hidden" name="action" value="change_tZone">
<input class="button" type="submit" value="Change Zone">
</td>
</tr>
</table>
<hr>
</form>

<form name="change_isoCode" action="<?echo $_SERVER['PHP_SELF'];?>" method="POST" enctype ="multipart/form-data">
The iTunes Catalog requires all podcasts to specify a language based on the ISO 639-1 Alpha-2 standard.  Please choose a language code from this list which most closely identfies the language of your podcasts.<br><br>
<table width ="450">
<tr valign="bottom"> 
<td nowrap width="150" align="left">
Current language<br>code is:<br>
<font color="green">
<?
	echo $podcastInfoObj->getCurrIsoCode();
?>
</font>
</td>
<td nowrap align="right" width="150">
New Language Code:<br>
<select name="isCode">

<?
	foreach($podcastInfoObj->getIsoCodes() as $isoCode => $description){
		$selected='';
		if($podcastInfoObj->getCurrIsoCode()==$isoCode){
			$selected=' selected';
		}
		echo "<option $selected value='$isoCode'>$isoCode - $description</option>\n";
	}
?>
</select>
<td nowrap align="right" width="150" valign="bottom">
<input type="hidden" name="action" value="change_isoCode">
<input class="button" type="submit" value="Change Language">
</td>
</tr>
</table>
<hr>
</form>
