// Ultimate client-side JavaScript client sniff. 
// (C) Netscape Communications 1999.  Permission granted to reuse and distribute. 
// Revised 17 May 99 to add is.nav5up and is.ie5up (see below). 

// Everything you always wanted to know about your JavaScript client 
// but were afraid to ask ... "Is" is the constructor function for "is" object, 
// which has properties indicating: 
// (1) browser vendor: 
//     is.nav, is.ie, is.opera 
// (2) browser version number: 
//     is.major (integer indicating major version number: 2, 3, 4 ...) 
//     is.minor (float   indicating full  version number: 2.02, 3.01, 4.04 ...) 
// (3) browser vendor AND major version number 
//     is.nav2, is.nav3, is.nav4, is.nav4up, is.ie3, is.ie4, is.ie4up, is.ie5, is.ie5up 
// (4) JavaScript version number: 
//     is.js (float indicating full JavaScript version number: 1, 1.1, 1.2 ...) 
// (5) OS platform and version: 
//     is.win, is.win16, is.win32, is.win31, is.win95, is.winnt, is.win98 
//     is.os2 
//     is.mac, is.mac68k, is.macppc 
//     is.unix 
//        is.sun, is.sun4, is.sun5, is.suni86 
//        is.irix, is.irix5, is.irix6 
//        is.hpux, is.hpux9, is.hpux10 
//        is.aix, is.aix1, is.aix2, is.aix3, is.aix4 
//        is.linux, is.sco, is.unixware, is.mpras, is.reliant 
//        is.dec, is.sinix, is.freebsd, is.bsd 
//     is.vms 
// 
// See http://www.it97.de/JavaScript/JS_tutorial/bstat/navobj.html and 
// http://www.it97.de/JavaScript/JS_tutorial/bstat/Browseraol.html 
// for detailed lists of userAgent strings. 
// 
// Note: you don't want your Nav4 or IE4 code to "turn off" or 
// stop working when Nav5 and IE5 (or later) are released, so 
// in conditional code forks, use is.nav4up ("Nav4 or greater") 
// and is.ie4up ("IE4 or greater") instead of is.nav4 or is.ie4 
// to check version in code which you want to work on future 
// versions. 
  

function Is () 
{   // convert all characters to lowercase to simplify testing 
    var agt=navigator.userAgent.toLowerCase(); 

    // *** BROWSER VERSION *** 
    // Note: On IE5, these return 4, so use is.ie5up to detect IE5. 
    this.major = parseInt(navigator.appVersion); 
    this.minor = parseFloat(navigator.appVersion); 

    this.nav  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1) 
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1) 
                && (agt.indexOf('webtv')==-1)); 
    this.nav2 = (this.nav && (this.major == 2)); 
    this.nav3 = (this.nav && (this.major == 3)); 
    this.nav4 = (this.nav && (this.major == 4)); 
    this.nav4up = (this.nav && (this.major >= 4)); 
    this.navonly      = (this.nav && ((agt.indexOf(";nav") != -1) || 
                          (agt.indexOf("; nav") != -1)) ); 
    this.nav5 = (this.nav && (this.major == 5)); 
    this.nav5up = (this.nav && (this.major >= 5)); 

    this.ie   = (agt.indexOf("msie") != -1); 
    this.ie3  = (this.ie && (this.major < 4)); 
    this.ie4  = (this.ie && (this.major == 4) && (agt.indexOf("msie 5.0")==-1) ); 
    this.ie4up  = (this.ie  && (this.major >= 4)); 
    this.ie5  = (this.ie && (this.major == 4) && (agt.indexOf("msie 5.0")!=-1) ); 
    this.ie5up  = (this.ie  && !this.ie3 && !this.ie4); 

    // KNOWN BUG: On AOL4, returns false if IE3 is embedded browser 
    // or if this is the first browser window opened.  Thus the 
    // properties is.aol, is.aol3, and is.aol4 aren't 100% reliable. 
    this.aol   = (agt.indexOf("aol") != -1); 
    this.aol3  = (this.aol && this.ie3); 
    this.aol4  = (this.aol && this.ie4); 

    this.opera = (agt.indexOf("opera") != -1); 
    this.webtv = (agt.indexOf("webtv") != -1); 

    // *** JAVASCRIPT VERSION CHECK *** 
    // Useful to workaround Nav3 bug in which Nav3 
    // loads <SCRIPT LANGUAGE="JavaScript1.2">. 
    if (this.nav2 || this.ie3) this.js = 1.0 
    else if (this.nav3 || this.opera) this.js = 1.1 
    else if ((this.nav4 && (this.minor <= 4.05)) || this.ie4) this.js = 1.2 
    else if ((this.nav4 && (this.minor > 4.05)) || this.ie5) this.js = 1.3 
    else if (this.nav5) this.js = 1.4 
    // NOTE: In the future, update this code when newer versions of JS 
    // are released. For now, we try to provide some upward compatibility 
    // so that future versions of Nav and IE will show they are at 
    // *least* JS 1.x capable. Always check for JS version compatibility 
    // with > or >=. 
    else if (this.nav && (this.major > 5)) this.js = 1.4 
    else if (this.ie && (this.major > 5)) this.js = 1.3 
    // HACK: no idea for other browsers; always check for JS version with > or >= 
    else this.js = 0.0; 

    // *** PLATFORM *** 
    this.win   = ( (agt.indexOf("win")!=-1) || (agt.indexOf("16bit")!=-1) ); 
    // NOTE: On Opera 3.0, the userAgent string includes "Windows 95/NT4" on all 
    //        Win32, so you can't distinguish between Win95 and WinNT. 
    this.win95 = ((agt.indexOf("win95")!=-1) || (agt.indexOf("windows 95")!=-1)); 

    // is this a 16 bit compiled version? 
    this.win16 = ((agt.indexOf("win16")!=-1) || 
                  (agt.indexOf("16bit")!=-1) || (agt.indexOf("windows 3.1")!=-1) || 
                  (agt.indexOf("windows 16-bit")!=-1) ); 

    this.win31 = ((agt.indexOf("windows 3.1")!=-1) || (agt.indexOf("win16")!=-1) || 
                  (agt.indexOf("windows 16-bit")!=-1)); 

    // NOTE: Reliable detection of Win98 may not be possible. It appears that: 
    //       - On Nav 4.x and before you'll get plain "Windows" in userAgent. 
    //       - On Mercury client, the 32-bit version will return "Win98", but 
    //         the 16-bit version running on Win98 will still return "Win95". 
    this.win98 = ((agt.indexOf("win98")!=-1) || (agt.indexOf("windows 98")!=-1)); 
    this.winnt = ((agt.indexOf("winnt")!=-1) || (agt.indexOf("windows nt")!=-1)); 
    this.win32 = ( this.win95 || this.winnt || this.win98 || 
                   ((this.major >= 4) && (navigator.platform == "Win32")) || 
                   (agt.indexOf("win32")!=-1) || (agt.indexOf("32bit")!=-1) ); 

    this.os2   = ((agt.indexOf("os/2")!=-1) || 
                  (navigator.appVersion.indexOf("OS/2")!=-1) || 
                  (agt.indexOf("ibm-webexplorer")!=-1)); 

    this.mac    = (agt.indexOf("mac")!=-1); 
    this.mac68k = (this.mac && ((agt.indexOf("68k")!=-1) || 
                               (agt.indexOf("68000")!=-1))); 
    this.macppc = (this.mac && ((agt.indexOf("ppc")!=-1) || 
                               (agt.indexOf("powerpc")!=-1))); 

    this.sun   = (agt.indexOf("sunos")!=-1); 
    this.sun4  = (agt.indexOf("sunos 4")!=-1); 
    this.sun5  = (agt.indexOf("sunos 5")!=-1); 
    this.suni86= (this.sun && (agt.indexOf("i86")!=-1)); 
    this.irix  = (agt.indexOf("irix") !=-1);    // SGI 
    this.irix5 = (agt.indexOf("irix 5") !=-1); 
    this.irix6 = ((agt.indexOf("irix 6") !=-1) || (agt.indexOf("irix6") !=-1)); 
    this.hpux  = (agt.indexOf("hp-ux")!=-1); 
    this.hpux9 = (this.hpux && (agt.indexOf("09.")!=-1)); 
    this.hpux10= (this.hpux && (agt.indexOf("10.")!=-1)); 
    this.aix   = (agt.indexOf("aix") !=-1);      // IBM 
    this.aix1  = (agt.indexOf("aix 1") !=-1); 
    this.aix2  = (agt.indexOf("aix 2") !=-1); 
    this.aix3  = (agt.indexOf("aix 3") !=-1); 
    this.aix4  = (agt.indexOf("aix 4") !=-1); 
    this.linux = (agt.indexOf("inux")!=-1); 
    this.sco   = (agt.indexOf("sco")!=-1) || (agt.indexOf("unix_sv")!=-1); 
    this.unixware = (agt.indexOf("unix_system_v")!=-1); 
    this.mpras    = (agt.indexOf("ncr")!=-1); 
    this.reliant  = (agt.indexOf("reliantunix")!=-1); 
    this.dec   = ((agt.indexOf("dec")!=-1) || (agt.indexOf("osf1")!=-1) || 
         (agt.indexOf("dec_alpha")!=-1) || (agt.indexOf("alphaserver")!=-1) || 
         (agt.indexOf("ultrix")!=-1) || (agt.indexOf("alphastation")!=-1)); 
    this.sinix = (agt.indexOf("sinix")!=-1); 
    this.freebsd = (agt.indexOf("freebsd")!=-1); 
    this.bsd = (agt.indexOf("bsd")!=-1); 
    this.unix  = ((agt.indexOf("x11")!=-1) || this.sun || this.irix || this.hpux || 
                 this.sco ||this.unixware || this.mpras || this.reliant || 
                 this.dec || this.sinix || this.aix || this.linux || this.bsd || 
                 this.freebsd); 

    this.vms   = ((agt.indexOf("vax")!=-1) || (agt.indexOf("openvms")!=-1)); 
} 

var is; 
var isIE3Mac = false; 

// this section is designed specifically for IE3 for the Mac 


if ((navigator.appVersion.indexOf("Mac")!=-1) && 
	(navigator.userAgent.indexOf("MSIE")!=-1) &&
	(parseInt(navigator.appVersion)==3)) 
	isIE3Mac = true; 

else
	is = new Is();  



