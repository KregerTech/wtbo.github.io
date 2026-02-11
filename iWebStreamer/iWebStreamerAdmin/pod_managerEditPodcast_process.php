#!/usr/local/dev/bin/php
<?
	//Add podcasts
	require_once(dirname(__FILE__).'/initialize.php');
	global $_GET;
	global $_POST;
	$podcastId=intval($_POST['podcastId']);
	$title=$_POST['title'];
	$link=$_POST['link'];
	$copyright=$_POST['copyright'];
	$author=$_POST['author'];
	$block=$_POST['block'];
	$ttl=$_POST['ttl'];
	$MainCategory1=$_POST['Main_Category_1'];
	$SubCategory1=$_POST['Sub_Category_1'];
	$MainCategory2=$_POST['Main_Category_2'];
	$SubCategory2=$_POST['Sub_Category_2'];
	$MainCategory3=$_POST['Main_Category_3'];
	$SubCategory3=$_POST['Sub_Category_3'];
	$explicit=$_POST['explicit'];
	$keywords=$_POST['keywords'];
	$name=$_POST['name'];
	$email=$_POST['email'];
	$subtitle=$_POST['subtitle'];
	$summary=$_POST['summary'];
	
	//do some pre-processing before attempting to add.
	$title=trim($title);
	$link=trim($link);
	$copyright=trim($copyright);
	$author=trim($author);
	$ttl=intval($ttl);
	$catArr=array();
	$catArr['MainCategory1']=$MainCategory1;
	$catArr['MainCategory2']=$MainCategory2;
	$catArr['MainCategory3']=$MainCategory3;
	$catArr['SubCategory1']=$SubCategory1;
	$catArr['SubCategory2']=$SubCategory2;
	$catArr['SubCategory3']=$SubCategory3;
	
	$keywords=trim($keywords);
	$name=trim($name);
	$email=trim($email);
	$subtitle=trim($subtitle);
	$summary=trim($summary);
	
	$podcastObj=$podcastInfoObj->getPodcastObj($podcastId);
	if(
	$podcastObj->setTitle($title)&&
	$podcastObj->setLink($link)&&
	$podcastObj->setCopyright($copyright)&&
	$podcastObj->setAuthor($author)&&
	$podcastObj->setBlock($block)&&
	$podcastObj->setCategory($catArr)&&
	$podcastObj->setExplicit($explicit)&&
	$podcastObj->setKeywords($keywords)&&
	$podcastObj->setName($name)&&
	$podcastObj->setEmail($email)&&
	$podcastObj->setSubtitle($subtitle)&&
	$podcastObj->setSummary($summary)&&
	$podcastObj->setTTL($ttl)
	){
		$saveConf=true;
		require_once(dirname(__FILE__).'/navbar.php');
		?>
			<br><br><br>
			<table align="center" cellpadding="5" cellspacing="5">
				<tr align="center">
					<td colspan="2">
						Podcast edited successfully.
					</td>
				</tr>
			</table>
		<?
		
	}else{
		?>Error Editing Podcast<?
	}
?>