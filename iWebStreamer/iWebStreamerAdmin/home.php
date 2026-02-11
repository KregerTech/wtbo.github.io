#!/usr/local/dev/bin/php
<?
	require_once(dirname(__FILE__).'/initialize.php');

?>
    
<script type="text/javascript" src="flashobject.js"></script>
<table height="100%" width="100%" align="center"><tr align="center"><td align="center">
<div id="flashcontent"></div>
<script type="text/javascript">
	
   		var fo = new FlashObject("flash/home.swf", "mymovie", "550", "255", "7", "");
   		fo.write("flashcontent");
	
</script>
</td></tr></table>
</body>
</html>


