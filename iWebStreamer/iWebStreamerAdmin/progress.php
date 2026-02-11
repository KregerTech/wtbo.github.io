#!/usr/local/dev/upload-only-php-dev/bin/php -q
<?
	ob_start();

	$X = upload_progress_meter_get_info( $_GET["UPLOAD_IDENTIFIER"] );
	
	$upl   = nice_value($X['bytes_uploaded']);
   	$sizeNice = nice_value($X['bytes_total']);
	
	$sizeMb=floor($X['bytes_total']/1048576);
	
	
	if($X['bytes_uploaded']){
		$percentComplete = round( (($X['bytes_uploaded']/$X['bytes_total'])*100) );
	}else{
		$percentComplete=0;
	}
	
	$eta = sprintf("%02d:%02d", $X['est_sec'] / 60, $X['est_sec'] % 60 );
	
	$sp = $X['speed_last'];
	
   	if ($sp < 1024) {
		$speed  = sprintf("%.2f", $sp)." b/s";
	}else{
		$speed  = sprintf("%.1f", $sp / 1024)." kb/s";
	}
	
	
	$ouput= '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	$ouput.= '<uploadDataXML>'."\n";
	$ouput.= "\t".'<uploadedXML>'.trim($upl).'</uploadedXML>'."\n";
	$ouput.= "\t".'<sizeNiceXML>'.trim($sizeNice).'</sizeNiceXML>'."\n";
	$ouput.= "\t".'<sizeMbXML>'.trim($sizeMb).'</sizeMbXML>'."\n";
	$ouput.= "\t".'<percentCompleteXML>'.trim($percentComplete).'</percentCompleteXML>'."\n";
	$ouput.= "\t".'<speedXML>'.trim($speed).'</speedXML>'."\n";
	$ouput.= "\t".'<etaXML>'.trim($eta).'</etaXML>'."\n";
	$ouput.= "\t".'<dummyDataXML>howdy</dummyDataXML>'."\n";
	$ouput.= '</uploadDataXML>'."\n";
	
	ob_clean ();
	header("Content-Type: text/xml; charset=UTF-8");
	echo utf8_encode($ouput);
	
	function nice_value($x) {
   		if ($x < 100)  $x;
   		if ($x < 10240)  return sprintf("%.2fKB", $x/1024);
   		if ($x < 921600) return sprintf("%dKB", $x/1024);
   		return sprintf("%.2fMB", $x/1024/1024);
	}
?>
