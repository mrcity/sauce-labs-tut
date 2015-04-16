#!/usr/bin/perl

################################################################################
# Sauce Labs / Selenium WebDriver Local Test
# By Stephen Wylie
# 4/13/2015
################################################################################

use strict;
use warnings;
use Selenium::Remote::Driver;    # make sure you've installed this from CPAN
use Data::Dumper;
use HTTP::Request;

my $driver;

$SIG{__WARN__} = sub {
   my $wn = shift;
   print "\nFATAL: $wn";
   $driver->quit();
};

# Set the name of the test
my $desc = "perl webdriver bindings and appium to test an Android app!";
# Get some settings so you don't learn my username & API key >-D
open(DATA, "<", "settings.txt");
my $login = <DATA>;
my $apiKey = <DATA>;
close(DATA);
chomp($login);
chomp($apiKey);
my $host = "$login:$apiKey\@ondemand.saucelabs.com";

# Build the driver now
# For more documentation on these features, check out
# http://search.cpan.org/~aivaturi/Selenium-Remote-Driver-0.15/lib/Selenium/Remote/Driver.pm#USAGE_(read_this_first)
# and
# https://github.com/appium/sample-code/blob/master/sample-code/examples/perl/ios_simple.pl
$driver = Selenium::Remote::Driver->new_from_caps(
                          'remote_server_addr' => $host,
                          'port' => "80",
                          'desired_capabilities' => {'name' => $desc, 
                                                     'appiumVersion' => "1.2.2",
                                                     'app' => "sauce-storage:SpeechPipeScribe.apk",
                                                     'platformName' => "Android",
                                                     'platformVersion' => "4.4",
                                                     'browserName' => '',
                                                     'deviceName' => "Android Emulator",
                                                     'deviceType' => "phone"
                                                    }
                          );

## Make a quick API call to Sauce Labs to find this job's ID
## This way, we can send along status & metadata
#print "\nFetching current job info from Sauce Labs...";
## Make sure LWP::Protocol::https is installed
## This may require openssl-dev in Ubuntu
#my $httpRequest = HTTP::Request->new(GET => "https://saucelabs.com/rest/v1/$login/jobs?limit=1");
#$httpRequest->authorization_basic($login, $apiKey);
#my $ua = LWP::UserAgent->new;
#my $response = $ua->request($httpRequest);
#print Dumper($response);
## Check for a successful response
#if ($response->{is_success}) {
#    my $message = $response->{decoded_content};
#    print "\nReceived reply: $message\n";
#} else {
#    print "\nFailed to get current job ID from Sauce Labs.";
#    print "\nHTTP GET error code: $response->{code}";
#    print "\nHTTP GET error message: $response->{message}";
#    print "\nExiting...";
#    $driver->quit();
#}

# Make sure it actually loaded content as expected
#my $bluetoothBtn = $driver->find_element('button1', 'id');
#$bluetoothBtn->click();
#my $scanBtn = $driver->find_element('button_scan', 'id');

#checkExit(!defined($scanBtn), "Failed to see the 'Scan for devices' button on-screen");
#checkExit($scanBtn->get_text() ne "Scan for devices", "Failed to see the expected text for the 'Scan for devices' button");

# Conclude the test
$driver->quit();
print "\nDone running the test.\n";


sub checkExit {
    my ($status, $message) = @_;
    if (not $status) {
        print "\n$message\nExiting...";
        $driver->quit();
    }
}

