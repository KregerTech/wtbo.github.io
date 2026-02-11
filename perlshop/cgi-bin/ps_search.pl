
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 search related subroutines
#
# Copyright (c) 1999, 2000, 2001, 2002 by David M. Godwin
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
# Version changes:
#
# Version 1.1
#	Search results are now displayed by html file title, not by html file name.
#	This behavior can be overridden by using the pssearch tag.
#
# Version 1.2
#	Bug corrections.
#
# Version 1.3
#	- Added support for the $form_submission_method setting.
#
#


my @searchResult;


sub add_search_screen 
{
	print qq(
<br>
<hr align="center">

<h3>Enter the keyword to search for in the box below.</h3>

<form name="searchForm" method=$form_submission_method 
	action="http://$cgi_prog_location">

<table border=0 cellpadding=3 cellspacing=3>

<tr>
<td><b><small>Search Keyword:</small></b></td>
<td>
<input type=text name="SEARCHSTRING" maxlength=45 size=45
	title="Enter a single keyword to search for">
</td>
</tr>

<tr>
<td><b><small>Match Case?</small></b></td>
<td>
<input type=checkbox name="MATCHCASE" value=true
	title="Check this box to make the search exactly match the case of your keyword">
</td>
</tr>

<tr>
<td><b><small>Match Whole Word?</small></b></td>
<td>
<input type=checkbox checked name="MATCHWORD" value=true
	title="Check this box to make the search match your keyword exactly">
</td>
</tr>

<tr>
<td><b><small>Find all hits on page?</small></b></td>
<td>
<input type=checkbox name="MATCHALL" value=true
	title="Check this box to search for every incidence of your keyword on every page in the store">
</td>
</tr>
);

	if (lc $searchRegExp eq 'yes')
	{
		print qq(
<tr>
<td><b><small>Treat as 
<a target="_blank" 
	href="http://$server_address/regexp.html">
Regular Expression</a>?</small></b></td>
<td>
<input type=checkbox name="REGEXP" value=true>
</td>
</tr>
);
	}

	print qq(
</table>

<input type=hidden name="ORDER_ID" value=$unique_id>

<div align="center">
);

	AddButton('SEARCH CATALOG');

	# Finish up the form
	print qq(
</div>

<input type=hidden name="DOSEARCH" value="SEARCH CATALOG">
<input type=hidden name="thispage" value="$input{'THISPAGE'}">
</form>
);

	# If this is the initial search screen,
	# add JavaScript to focus on the keyword field
	print qq(
<script type="text/javascript" language="JavaScript1.1">
document.forms.searchForm.SEARCHSTRING.focus();
</script>
<!--
Action is $action
DS is $input{'DOSEARCH'}
-->
) if ($action eq 'SEARCH');

	print qq(
<hr align="center"><br>
);

}


sub ExecuteCatalogSearch
{
	my $psdbi_matches = 0;
	my $psdbi_result = '';

	# Initialize the search result display
	@searchResult = ();

	# Generate the page header
	&PageHeader("Search Results");
	&add_menu_bar('SEARCH', 'CONTINUE SHOPPING');
	&add_company_header;

	# Get and validate the search string
	$pattern = $input{'SEARCHSTRING'};
	if ($pattern eq '')
	{
		print '<b>You did not enter a keyword to search for.<b>';
		&add_button_bar('SEARCH', 'CONTINUE SHOPPING');
		&add_company_footer;
		exit;
	}

	# Escape all non-alphabetic characters unless we're
	# using regexp mode.
	$pattern = "\Q$pattern\E"
		unless (lc $input{'REGEXP'} eq 'true');

	# Force word boundry checking ?
	$pattern = '\b' . $pattern . '\b'
		if (lc $input{'MATCHWORD'} eq 'true');

	# Do a case-insensitive search ?
	$pattern = '(?i)' . $pattern
		unless (lc $input{'MATCHCASE'} eq 'true');

	# No matches so far
	$matches = 0;

	# Search the catalog directory and subdirectories
	MatchFile($catalog_directory);

	DisplaySearchResults();

	# Do we also need to search the product database ?
	if ($useInternalSearch eq 'psdbi')
	{
		# Load the database search module
		LoadLibrary('PSDBS.pm');

print "<!-- SEARCHING DATABASE -->\n";
		# Match against the database
		($psdbi_matches, $psdbi_result) = 
			PSDBS::SearchDatabase($input{'SEARCHSTRING'}, 
			                      $cgi_prog_location, $unique_id);

		# Did we find anything?
		if ($psdbi_matches > 0)
		{
			StartTable()
				if ($matches == 0);

			$matches += $psdbi_matches;

			print $psdbi_result;
		}
	}

	# Did we find anything ?
	if ($matches == 0)
	{
		print qq(
<br>
<h3>The keyword: "$input{'SEARCHSTRING'}" was not found!</h3><br>
);
	}

	# Complete the table started in sub MatchFile
	else
	{
		print qq(
</table><br>
<small><b>Number of search results : $matches</b></small><br>
</div><br>
);
	}

	# Add search screen interface to page bottom, if enabled
	&add_search_screen
		if ($useInternalSearch ne 'no') &&
		   ($button_data{'SEARCH'}->{'visible'});

	# Add a continue shopping link, if we have the data to drive it
	&add_button_bar('CONTINUE SHOPPING')
		if ($input{'THISPAGE'} ne '');

	# Create page footer
	&add_company_footer;

	# Create search log entry
	create_log('Searches', $input{'SEARCHSTRING'}, $matches)
		if ($create_search_log eq 'yes');
}


sub MatchFile 
{
	local($_, $file);
	local(@list);     

	my $fileName;
	my $pageTitle;

	# Search every file in the given parameter list
	FILE: while (defined ($file = shift(@_))) 
	{
		# Skip all files on the ignore list
		foreach $searchFileName (@searchIgnoreFiles)
		{
			next FILE if ($file =~ /$searchFileName/);
		}
	
		# Is this file actually a directory ?
		if (-d $file) 
		{
			# Skip it if we can't open it
			next FILE unless opendir(DIR, $file);
	
			# Create a list of the files in this directory
			@list = ();
			for (sort readdir(DIR)) 
			{
				# Skip '.' and '..'
				push(@list, "$file/$_") unless /^\.{1,2}$/;
			} 
			closedir(DIR);
		   
			# Match against the list of files we've made
			&MatchFile(@list);
	
			next FILE;
		} 
	
		# Try to open the given file
		next FILE unless open(FILE, $file);
	
		# Read the entire file in at once
		undef $/;
		$_ = <FILE>;
		close(FILE);
	
		# Use pssearch tag data, if present
		if (m:<!--#pssearch\s+title="(.*?)"\s*-->:ims)
		{
			$pageTitle = $1;
		}

		# Otherwise, use title tag data, if present
		elsif (m:<title>(.*?)</title>:ims)
		{
			$pageTitle = $1;
		}

		# Delete all comments
		s/<!--(.*?)-->//gos;
	
		# Remove all psdbi query sections in their entirity
		s:<psdbi[^>]+query.*?>.*?</psdbi>::gios;

		# Remove all psdbi execute sections in their entirity
		s:<psdbi[^>]+execute.*?>.*?</psdbi>::gios;

		# Remove all script sections in their entirity
		s:<script.*?>.*?</script>::gios;

		# Remove all style sections in their entirity
		s:<style>.*?</style>::gios;

		# Delete all HTML tags
		s/<[\/]?[a-z]+?.*?>//gios;
	
		# Delete all words to be ignored
		foreach $word (@searchIgnoreWords)
		{
			s/\b$word\b//gis;
		}
	
		# Is the pattern in the file ?
		if (/$pattern/) 
		{
			# Break the file string up into a list of lines containing the pattern
			@foundLines = /(^.*?$pattern.*?$)/gm;
	
			# If no previous match, start the output table
			StartTable()
				if ($matches == 0);
					
			$matches++;
	
			# Generate the name of the file to be listed

			# Extract the base file name
			$fileName = substr($file, rindex($file, '/') + 1);

			# Display the file name if we haven't already got a display title
			($pageTitle) = split(/\./, $fileName)
				if ($pageTitle eq '');

			# Do we need to show all matches on a given page ?
			$max = (lc $input{'MATCHALL'} eq 'true') ? $#foundLines : 0;
	
			# Generate table rows
			foreach $foundLine (@foundLines[0..$max])
			{
				# Highlight all matches on this line
				$foundLine =~ s/$pattern/${SO}$&${SE}/go;  		 
	
				# Record the data for this match
				push(@searchResult, "$pageTitle===$foundLine===$fileName");
			}
		}
	}	# FILE while loop
}


sub StartTable
{
	print qq(
<br>
<div align="center">
<h3>The keyword: "$input{'SEARCHSTRING'}" was found on the following pages:</h3>
<table border=$searchResultBorder cellpadding=2 bgcolor="white">
);

	print qq(
<tr class="searchResultHeader">
<th class="searchResultHeader">Page</th>
<th class="searchResultHeader">Keyword</th>
</tr>
)
		unless $searchResultColumns == 1;
}


sub DisplaySearchResults
{
	# Sort the results, and generate one table row per result
	foreach my $row (sort @searchResult)
	{
		($pageTitle, $foundLine, $fileName) = split('===', $row);

		print qq(
<tr class="searchResultData">
<td class="searchResultData" align="top">
<a href="http://$cgi_prog_location?ACTION=thispage&thispage=$fileName&ORDER_ID=$unique_id"
	title="Click here to go to this page">$pageTitle</a><br>
);

		print qq(
</td>
<td class="searchResultData">
)
			unless $searchResultColumns == 1;

		print qq(
$foundLine
</td>
</tr>
);
	}
}


##############################
# Library file return code
1;


