#!/usr/local/dev/bin/php
<?

	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET;
	
	
	$file_id=$_GET['file_id'];
	$fileObj=$fileInfoObj->getFileObj(intval($file_id));
	$title=$fileObj->getTitle();
	$author=$fileObj->getAuthor();
?>
<br><br><br>
<table align="center" width="350" height="0">

	<?
	if(isset($_POST['action'])){
		$fileObj->setTitle(trim($_POST['title']));
		$fileObj->setAuthor(trim($_POST['author']));
		$saveConf=true;
		
	?>
		<tr><td>Audio File Updated Successfully</td></tr>
	<?

	}else{
	?>
		<form name="form1" action="modify_fileObj.php?file_id=<?echo $file_id;?>" 
		method="post" 
		enctype="multipart/form-data"
		onSubmit="submit_button.disabled=true"
		>
		<input type="hidden" name="action" value="domodify">
			<tr><td align="right">
				Artist/Author: 
			</td>
			<td align="left">
				<input type="text" size="40" name="author" value="<?echo $author;?>">
			</td></tr>
			
			<tr><td align="right">
				Title: 
			</td>
			<td align="left">
				<input type="text" size="40" name="title" value="<?echo $title;?>">
			</td></tr>
			
			<tr><td colspan="2" align="center">
				<br>
				<input type="submit" value="Submit" name="submit_button">
			</td></tr>
			
	<?
	}
?>

