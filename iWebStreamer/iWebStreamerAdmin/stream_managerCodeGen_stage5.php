#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_REQUEST;
	
	$webStreamId=trim($_REQUEST['webStreamId']);
	if(!$webStreamObj=$webstreamInfoObj->getWebStreamObj($webStreamId)){
		$iWebStreamerErrorObj->registerCritical('Invalid WebStream Id.');
	}
	
	require_once(dirname(__FILE__).'/navbar.php');
	
	?>
		<p>
			Step 5 (final step):<br><br>
			<i>Copy and paste code</i><br><br>
		</p>
		<p>
			This is how your WebStream will appear on your web site.  Below the player you will 
			find the html source code for this player.  Copy the code and paste it into the html 
			source of the web page you would like this player to appear.
		</p>
		
		<hr>
		<table border="1" cellpadding="3" align="left" width="90%">
	<?
	
	$type=$_REQUEST['type'];
	$color=$_REQUEST['color'];
	$autoplay=$_REQUEST['autoplay'];
	$repeat_playlist=$_REQUEST['repeat_playlist'];
	
	if($autoplay=='true'){
		$autoplay=true;
	}else{
		$autoplay=false;
	}
	
	if($repeat_playlist=='true'){
		$repeat_playlist=true;
	}else{
		$repeat_playlist=false;
	}
	
	
		echo "<tr><td>The player as it will appear on your web page:</td></tr>\n";
		echo "<tr><td><br><br>\n";
			echo $webStreamObj->getFlashPlayerCode($type, $color, $autoplay, false, $repeat_playlist)."\n";
		echo "</td></tr>\n";
		echo "<tr><td>\n";
			echo "<br><br>Source code:\n";
			echo "<br>(right-click the text and choose 'copy' then paste into the html source of your web page)";
			echo "<p>
			NOTE: <i>Once you have enter this code into your web page, you do not have to edit the 
			source code any further to update this WebStream.  You can add and remove tracks using this 
			tool, and the player on your web site will update automatically....how cool!</i>
			</p>";
		echo "</td></tr>\n";
		echo "<tr><td><br><br><textarea rows='30' cols='110' readonly='readonly' onClick='this.select();' onFocus='this.select();' style='font-family:Verdana;font-size: 10;font-weight: bold;'>";
		echo htmlentities($webStreamObj->getFlashPlayerCode($type, $color, $autoplay, false, $repeat_playlist));
		echo "</textarea></td></tr>\n";
	
	?>
		</table>
	<?
	
?>