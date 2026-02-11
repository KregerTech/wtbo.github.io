//Used to simply code entered into the browser by the iWebstreamer user
isdefined = typeof registeredRewritesDivs;
 
if(isdefined == 'undefined'){
       registeredRewritesDivs=new Array();
       registeredRewritesObjs=new Array();
       document.write("<!--[if IE]><script defer src='\/iWebStreamer-UserWeb\/flash\/ie_onload.js'><\/script><![endif]-->");
       document.write("<script type='text\/javascript' src='\/iWebStreamer-UserWeb\/flash\/flashobject.js'><\/script>");
}
 

function createWebStreamCode(divName, shockwavePath, webStreamId, autoplay, repeat_playlist,playerWidth,playerHeight,playerVersion){

	document.write("<div id='" + divName + "'><\/div>\n");
	var flashObjectArg1="http://" + document.domain + shockwavePath;
	flashObjectArg1 = flashObjectArg1 + "?playlist_url=http://" + document.domain + '/cgi-sys/iWebStreamer/playlist.xspf';
	flashObjectArg1 = flashObjectArg1 + "?webStreamId=" + webStreamId;
	
	if(autoplay){
		flashObjectArg1 = flashObjectArg1 + '&autoplay=true';
	}
	
	if(repeat_playlist){
		flashObjectArg1 = flashObjectArg1 + '&repeat_playlist=true';
	}
	
	fo = new FlashObject(flashObjectArg1, divName+'_movie', playerWidth, playerHeight, playerVersion, '');
	fo.addParam('allowScriptAcces', 'sameDomain');
	fo.addParam('quality', 'high');
	fo.addParam('xn_auth', 'no');
	
	if(navigator.appName != 'Microsoft Internet Explorer'){
		fo.write(divName);
	}else{
		registeredRewritesDivs.push(divName);
		registeredRewritesObjs.push(fo);
	}
	
}

function delayedWrite(){
	for (i=0;i<registeredRewritesDivs.length;i++)
	{
		registeredRewritesObjs[i].write(registeredRewritesDivs[i]);
	}
}

