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
my $desc = "perl webdriver bindings and selenium to test a local server!";
# Get some settings so you don't learn my username & API key >-D
open(DATA, "<", "settings.txt");
my $login = <DATA>;
my $apiKey = <DATA>;
close(DATA);
chomp($login);
chomp($apiKey);
my $host = "$login:$apiKey\@ondemand.saucelabs.com";
#my $host = "$login:$apiKey\@localhost:4445";

# For more documentation on these features, check out
# http://search.cpan.org/~aivaturi/Selenium-Remote-Driver-0.15/lib/Selenium/Remote/Driver.pm#USAGE_(read_this_first)
$driver = new Selenium::Remote::Driver(
                          'remote_server_addr' => $host,
                          'port' => "80",
                          'browser_name' => "firefox",
                          'version' => "37",
                          'platform' => "WINDOWS",
                          'extra_capabilities' => {'name' => $desc},
                          );

# Load a tiny website hosted from localhost
print "\nGetting localhost...";
checkExit($driver->get('http://localhost'), "Failed to load localhost in Sauce OnDemand");

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
my $itWorks = $driver->find_element('h1', 'tag_name');
print "\nContent: '$itWorks'\n";
print Dumper($itWorks);
checkExit(!defined($itWorks), "Failed to see the expected page; missing elements");
checkExit($itWorks->get_text() ne "It works, just a bit!", "Failed to see the expected page; incorrect text");

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

