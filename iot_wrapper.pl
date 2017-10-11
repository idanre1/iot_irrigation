#! /usr/bin/perl

#==========================================================================
# @file
# Check directory disk usage
#
# Sotred from big to small with readable sizes
# Created by Idan Regev (~iregev)
#==========================================================================
use strict;
use warnings;

use POSIX;
use HTML::Strip;
use Perl6::Slurp;

use lib qw(/nas/scripts/perl_lib);
use SerialArduino;

#ENV
my $path     = "/nas/iot/weather";
my $curl     = "/usr/bin/curl";
my $tmp      = "$path/curl.tmp";
my $certia   = "entry";
my $url      = "https://www.wunderground.com/il/adamit";
my $cache    = 0; # Shall the run will be from cached HTML file?
my $l2addr   = "00:00:00:00:00:00";

my $pid; # PID for rfcomm
my $u_int8; # 1Byte data type for PACK. Arduino use 7bit ASCII for strings.

#Config
my $ON  = 1;
my $OFF = 2;
my $HELP = "H";

# Direct cmd line
if (scalar(@ARGV) > 0) {
	if ($ARGV[0] eq "ON") {
		&water($ON);
	} elsif ($ARGV[0] eq "OFF") {
		&water($OFF);
	} elsif ($ARGV[0] eq "HELP") {
		&water($HELP);
	} else {
		die "Unknown cmd line parameter. use ON or OFF or HELP values to bypass oferation";
	}
	exit(0);
}

# Retrieve Form
if (not $cache) {
	print "Clean cache file\n";
	qx#\rm $tmp > /dev/null#;
	print "Fetcher HTML\n";
	qx^$curl $url > $tmp ^;
}

# Strip HTML
my $HTML = slurp($tmp);
my $hs = HTML::Strip->new();
my $clean_text = $hs->parse( $HTML );
$hs->eof; #HTML::Strip can now strip a new file

#extract values
my %values;
$values{"Pressure"}=qr/Pressure(\s|\n)*([\d.]+)(\s|\n)*hPa/s;
$values{"Visibility"}=qr/Visibility(\s|\n)*([\d.]+)(\s|\n)*kilometers/s;
$values{"Clouds"}=qr/Clouds(\s|\n)*([a-zA-Z\s]*)\n/s;
$values{"Heat Index"}=qr/Heat Index(\s|\n)*([\d.]+)\n/s;
$values{"Dew Point"}=qr/Dew Point(\s|\n)*([\d.]+)\n/s;
$values{"Humidity"}=qr/Humidity(\s|\n)*([\d.]+)(\s|\n)/s;
$values{"Rainfall"}=qr/Rainfall(\s|\n)*([\d.]+)(\s|\n)/s;
$values{"Snow Depth"}=qr/Snow Depth(\s|\n)*([\d.]+)\n/s;

my %capture;
foreach my $key (keys %values) {
my $pat = $values{$key};
	if ($clean_text =~ /$pat/) {
		$capture{$key}=$2;
	} else { 
		$capture{$key}="NA";
#	die "Unknown parsing"; 
	}
} #print $clean_text;

# Manipulation
my $rain = $capture{"Rainfall"}; 
if ($rain > 0) {
	print "It's raining $rain mm today :)\n";
	&water($OFF);
} else {
	print "Watering permitted\n";
	&water($ON);
}


# Execute
sub water {
	my $cmd = shift;
	#my $com = '/dev/ttyUSB0';
	#my $pid = undef;
	my $com = '/dev/rfcomm0';
	$pid = open my $fhOut, "| rfcomm connect hci0 $l2addr", or die "Unable to fork BT";
	# sync BT to file handler
	while (not -e $com) { print "."; sleep 1; }
	print "\n";

	# indicate
	print "BT started\n";
	
	# Send command to BT
	my $Arduino;

	$Arduino = SerialArduino->new(
	  port     => "$com",
	  baudrate => 38400,
	  databits => 8,
	  parity   => 'none',
	);
	my $header;
	
	print "Waiting for arduino to setup serial\n";
	while (not defined $pid) {
		$header = $Arduino->receive();
		 print "ARD:$header\n";
		 last if ($header =~ /Ready/);
	}

	print "Sending command to arduino\n";
	while (1) {
		# Send command
		print "Send: $cmd\n";
		$Arduino->communicate($cmd) or die 'Warning, empty string: ', "$!\n";
#		# Receive crc
#		$header = $Arduino->receive();
#		# Ack crc
#		# Loopback of 1 byte
#		$u_int8 = unpack 'C', $header;#$u_int8=$u_int8+0;
#		print "Send CRC: $u_int8\n";
#		$Arduino->communicate(chr($u_int8)) or die 'Warning, empty string: ', "$!\n";
		# Verify command
		$header = $Arduino->receive();
		print "ARD MSG:$header\n";

		# Process expectations	
		if ($header =~ /ON|OFF|HELP/) {
			last;
		}	
	}
	print "Killing BT\n";
	if (defined $pid) {
		my $result = qx^kill $pid^;
	}
	#print "Result: $result\n";

	print "Sleeping for 2 seconds for the health of Arduino\n";
	sleep 2;

	print "EXIT\n";
}


