
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 plugin support subroutines
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


sub InitPlugin
{
	my ($plugin) = @_;
	my $method;
	my $module;

	print "\n----\nPlugin $plugin:\n";

	# Make sure this is a valid plugin name
	unless (defined($plugins{$plugin}))
	{
		print "Unknown plugin name.\n";
		return;
	}

	# Only initialize module type plugins
	unless (defined($plugins{$plugin}->{'module'}))
	{
		print "Initialization is not supported.\n";
		return;
	}

	# Only initialize module type plugins with an active 'init' setting
	unless (lc $plugins{$plugin}->{'init'} eq 'yes')
	{
		print "Initialization is not allowed.\n";
		return;
	}

	# Load the module for this plugin
	unless (eval "require '$plugins{$plugin}->{'module'}'")
	{
		print "Could not find plugin module $plugins{$plugin}->{'module'} :\n$@\n";
		return;
	}

	# Get the raw module name
	($module) = split(/\./, $plugins{$plugin}->{'module'});

	# Generate the plugin module initialization method name
	$method = '&' . $module . '::Initialize';

	# Return now if the plugin module initialization method doesn't exist
	unless (eval("defined($method)"))
	{
		print "No initialization is possible.\n";
		return;
	}

	# Attempt to execute the plugin module initialization method
	if ($result = eval($method))
	{
		# Display test initialization results
		print "$result\n";
	}

	else
	{
		# Display the error message
		print "Plugin Initialization error:\n$@";
	}
}


sub InitializePlugins
{
	# Get the local time on the web server
	my $now = StoreTime(time());

	# Complete the http header
	print "\n";

	print qq(
<head>
<title>Perlshop Plugin Initialization</title>
</head>
<body>
<h1>Perlshop Plugin Initialization</h1>

<pre>
Store name       : $company_name
Server address   : $server_address
Local time       : $now
Software version : $PerlShop_version

);

	# Was a plugin name specified ?
	if ($input{'PLUGIN'} ne '')
	{
		# Initialize the specified plugin
		InitPlugin($input{'PLUGIN'});
	}

	# Attempt to initialize all plugins
	else
	{
		foreach my $plugin (sort keys %plugins)
		{
			InitPlugin($plugin);
		}
	}

	print qq(
</pre>

Plugin Initialization complete.

</body>
</html>
);
}


##############################
# Library file return code
1;


