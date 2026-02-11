;This is the main configuration file used by the iWebStreamer
;Changes here will affect all domains on the server

[UserConfSettings]
conf_name = _iWebStreamer.conf  ;assumes /home/user
audio_dir = .iWebStreams	;assumes /home/user/domain-www
session_lockMins	=	10	;how long a user must be inactive for someone else to use it
session_lockFile	=	_iWebStreamer-session	;assumes /home/user

[Audio File Quota]
;All quotas are in Megs, determined from the number of email addresses on domain

Default	=	50

Express Pack	=	50	

Pack A 		= 	10000
Pack B		=	200
Pack C		= 	400
Pack D		=	1000

Package A	=	10000
Package B	=	200
Package C	=	400
Package D	=	1000

[RF Audio]
host	=	christianwebhost.com	;host to connect
ftpuser	= 	removed	
ftppass	=	removed
rfConfName	=	.RFAudio	;holds the royalty free audio encrypted conf object
sourceConfPath	=	/christianwebhost-www/iWebStreamer-RFAudio-Admin	;relative to /home/ftpuser
destinationConfPath	=	/home/httpd/iWebStreamer
sourceMp3DirPath	=	/christianwebhost-www/iWebStreamer-RFAudio-Admin/mp3s ;relative to /home/ftpuser
destinationMp3DirPath	=	/home/httpd/iWebStreamer/iWebStreamer-RF-Audio
relativeUrl	=	iWebStreamer-RF-Audio

[languages]
languages_file	=	../languages.list	;uses format - two letter code|description

[iTunes]
categories_file	=	../includes/itunes_categories.list

[programs]
readMp3SecondsCmd	=	../bin/mp3info.php-cli	;Command line utitlity to read the
										;number of seconds of an mp3 file's
										;audio tag.  Don't worry about newline
										;characters, etc.  It will be trimmed.
										;Just need something here that when 
										;passed an mp3 file, it will read the 
										;duration, in seconds, of the mp3 file.
										
previewUrl	=	/iWebStreamer-UserWeb/flash/previewPlayer/preview.php	;pass fileId or rfAudioFile_id to generate
										;an mp3 player preview of this file
										
flashPlayersRoot	=	/iWebStreamer-UserWeb/flash/player		;Top level directory where all flash players for this
										;program live. This directory must also be
										;to be accessible via this exact url. 
										;The naming convention used under this
										;directory is
										;directory name = player type
										;playerColor.swf = replace color with color name
										;all directories should include playerDefault.swf
										
flashPlayersRootFullPath	=	../iWebStreamer-UserWeb/flash/player	;direct path to root players directory
