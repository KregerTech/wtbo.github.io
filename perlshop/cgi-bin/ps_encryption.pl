
use strict 'refs';
use strict 'subs';

###################################
#
# Waverider Systems
# http://www.WaveriderSystems.com
#
# Perlshop 4 data encryption related subroutines
#
# Copyright (c) 2002 by David M. Godwin
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
# Version History
#
# Version 1.0
# 	- Initial version
#
#


sub initialize_cryptography
{
	my ($index) = @_;

	# Don't do anything if this encryption index is undefined
	return 0 unless defined $encryption_table{$index};

	# Don't do anything if we're already initialized
	return 1 if defined $encryption_table{$index}->{'crypto'};

	# Do we have a CBC cipher defined?
	if (defined $encryption_table{$index}->{'cipher'})
	{
		# Use the Cipher Block Chaining data encryption library
		LoadLibrary('Crypt/CBC.pm');

		# Create a CBC encryption object using the specified key and cipher module
		$encryption_table{$index}->{'crypto'} = new Crypt::CBC(
			{
				'key'             => $encryption_table{$index}->{'key'},
				'cipher'          => $encryption_table{$index}->{'cipher'},
				'iv'              => '$KJh#(}q',
				'regenerate_key'  => 0,
				'padding'         => 'space',
				'prepend_iv'      => 0
			}
		);
	}
	
	# Attempt to use the default encryption mechanism
	else
	{
		# Use the RC4 data encryption library
		LoadLibrary('Crypt/RC4.pm');

		# Create an RC4 encryption object
		$encryption_table{$index}->{'crypto'} = 
			Crypt::RC4->new($encryption_table{$index}->{'key'});
	}

	return 1;
}


sub encrypt_data
{
	my ($data) = @_;

	# Prepare to encrypt the specified data
	return $data unless initialize_cryptography($encryption_index);

	# Return the encrypted data stream
	if (defined $encryption_table{$encryption_index}->{'cipher'})
	{
		# Use CBC and the specified algorithm
		return "ENC:$encryption_index:" . $encryption_table{$encryption_index}->{'crypto'}->encrypt_hex($data);
	}

	else
	{
		# Use RC4
		return "ENC:$encryption_index:" . pack('u', ($encryption_table{$encryption_index}->{'crypto'}->RC4($data)));
	}
}


sub decrypt_data
{
	my ($data) = @_;

	# If the data isn't encoded, return it as given
	return $data unless $data =~ /^ENC:(.+?):(.+)/;

	# Break into encryption index and encrypted data
	my ($index, $encoded) = ($1, $2);

	# Prepare to decrypt the specified data
	return $data unless initialize_cryptography($index);

	# Return the decrypted data stream
	if (defined $encryption_table{$encryption_index}->{'cipher'})
	{
		# Use CBC and the specified algorithm
		$plain = $encryption_table{$encryption_index}->{'crypto'}->decrypt_hex($encoded);
	}

	else
	{
		# Use RC4
		#$plain = $encryption_table{$encryption_index}->{'crypto'}->RC4(unpack('u', $encoded));
		$plain = Crypt::RC4::RC4($encryption_table{$encryption_index}->{'key'}, unpack('u', $encoded));
	}

	# Remove left over white space padding
	$plain =~ s/\s+$//;

	# Return the decrypted data
	return $plain;
}


##############################
# Library file return code
1;


