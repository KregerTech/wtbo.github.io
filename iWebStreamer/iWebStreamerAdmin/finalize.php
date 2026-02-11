<?
	/*
		finalize.php
		//saves the conf file if needed
	*/
	
	function myShutdownFunction(){
		global $iWebStreamerConf, $confFileObj, $saveConf, $iWebStreamerErrorObj;
		if($saveConf){
			if(!$confFileObj->saveEncObj($iWebStreamerConf)){
				$iWebStreamerErrorObj->registerCritical("Failed to save the conf file.");
			}
		}
	}
?>