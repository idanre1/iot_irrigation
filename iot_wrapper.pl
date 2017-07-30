#! /usr/bin/perl
#==========================================================================
# @file
#
# Created by Idan Regev
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
my $cache    = 1; # Shall the run will be from cached HTML file?

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
#    die "Unknown parsing"; 
    }
} #print $clean_text;


# Manipulation
my $rain = $capture{"Rainfall"}; 
if ($rain > 0) {
    print "It's raining $rain mm today :)\n";
    &water(0);
} else {
    print "Watering permitted\n";
    &water(1);
}

# Execute
sub water {
    my $cmd = shift;
    my $com = '/dev/rfcomm0';
    my $pid = open my $fhOut, "| rfcomm connect hci0 <YOUR_BT_MODULE_ADDR>", or die "Unable to fork BT";
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
    # while (1) {
        # $header = $Arduino->receive();
        # print "ARD:$header\n";
        # last if ($header =~ /GO/);
    # }

    print "Sending command to arduino\n";
    $Arduino->communicate($cmd) or die 'Warning, empty string: ', "$!\n";
    $header = $Arduino->receive();
    print "ARD:$header\n";

    # Process expectations    
    if ($header =~ /ON|OFF/) {
        last;
    }    
}
