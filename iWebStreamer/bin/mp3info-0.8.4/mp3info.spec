Summary: An MP3 technical info viewer and ID3 tag editor
Name: mp3info
Version: 0.8.4
Release: 2
Copyright: GPL
Group: Utilities/file
Packager: Cedric Tefft <cedric@earthling.net>
Requires: gtk+ ncurses
Source: ftp://ftp.ibiblio.org/pub/linux/apps/sound/mp3-utils/mp3info/mp3info-0.8.4.tgz
BuildRoot: /tmp/mp3info

%description
MP3Info is an MP3 technical info viewer and ID3 1.x tag editor.
MP3Info has an interactive mode (using curses) and a command line mode.
A separate executable includes a GTK-based GUI version.  MP3Info can
display ID3 tag information as well as various techincal aspects of
an MP3 file including playing time, bit-rate, sampling frequency
and other attributes in a pre-defined or user-specifiable output format.

%prep

%setup -q 
mkdir -p $RPM_BUILD_ROOT/usr/doc/mp3info-0.8.4
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/X11R6/bin
mkdir -p $RPM_BUILD_ROOT/usr/man/man1

%build
make

%install
strip mp3info
strip gmp3info
mv mp3info $RPM_BUILD_ROOT/usr/bin/mp3info
mv gmp3info $RPM_BUILD_ROOT/usr/X11R6/bin/gmp3info
mv ChangeLog README INSTALL LICENSE mp3info.txt $RPM_BUILD_ROOT/usr/doc/mp3info-0.8.4
mv mp3info.1 $RPM_BUILD_ROOT/usr/man/man1

%post

%postun

%clean
rm -rf ${RPM_BUILD_ROOT}

%files
%defattr(-,root,root)
/usr/bin/mp3info
/usr/X11R6/bin/gmp3info
/usr/man/man1/mp3info.1.gz
%doc /usr/doc/mp3info-0.8.4

%changelog
* Mon Jul 16 2001 Cedric Tefft <cedric@earthling.net>
- Added %k format specifier to allow printing of the file size
  in formatted text output (-p option)
- Rearranged some items in the man page and quick help (-h)
  to make them more readable.
- Fixed minor logic bug in mp3tech
- Now compiles under CYGWIN32
- Manual page typos fixed
- Now correctly recognizes and reports MPEG version 2.5 files
- Clearing individual ID3 fields can now be accomplished
  by passing a blank argument ("") to any tag setting
  switch (-t, -a, etc.)

* Mon Feb 26 2001 Cedric Tefft <cedric@earthling.net>
- Fixed bug in GTK version that displayed track as garbage
- Fixed bug that sometimes prevented changing genres in
  curses version
- GTK version now allows MP3 file selection through a menu option
- GTK version now has technical information display

* Sun Sep 24 2000 Cedric Tefft <cedric@earthling.net>
- Fixed an error which errorenously reported some constant
  bitrate (CBR) files as variable bitrate (VBR) files.

* Fri Aug 18 2000 Cedric Tefft <cedric@earthling.net>
- Fixed an elusive bug that caused mp3info to fail to find an
  ID3 tag even though one was present.

* Sat Aug 12 2000 Cedric Tefft <cedric@earthling.net>
- Added the ability to handle VBR (Variable Bit Rate) MP3 files
- Added the ability to deal with garbage or non-standard headers
  at the beginning of a file
- Added user-specifiable output format with capabilities similar
  to printf(3)
- The GTK version now handles read-only files correctly
- Techincal Info switch (-x) is now considered reliable.
- UNIX man page created for mp3info (console version only)
- Major internal code re-engineering

* Thu Mar 9 2000 Cedric Tefft <cedric@earthling.net>
- Added extended genres (taken from WinAmp).
- Fixed minor bug in genre list display
- Fixed a bug in the GTK version which set the genre to 'Blues' if 
  the MP3 file did not have an existing ID3 tag.
- Help screen and documentation fixed up and edited for clarity.
- Added -f switch to force MP3Info to process files as if they were
  MP3's even if they don't contain the standard MP3 header.
- Added support for ID3 v1.1 tags (track numbers) - Thanks to Don
  Melton (don@blivet.com)
- Added an option (-x) to display technical information about the 
  MP3 file.  This is an experimental feature and should not be
  considered reliable.
