#!/usr/bin/perl

################################################################################
# Sauce Labs / Selenium WebDriver Remote Test
# By Stephen Wylie
# 4/13/2015
################################################################################

use strict;
use warnings;
use Selenium::Remote::Driver;    # make sure you've installed this from CPAN
use Data::Dumper;
use HTTP::Request;

# Set the name of the test
my $desc = "perl webdriver bindings and selenium!";
# Get some settings so you don't learn my username & API key >-D
open(DATA, "<", "settings.txt");
my $login = <DATA>;
my $apiKey = <DATA>;
close(DATA);
chomp($login);
chomp($apiKey);
my $host = "$login:$apiKey\@ondemand.saucelabs.com";

# For more documentation on these features, check out
# http://search.cpan.org/~aivaturi/Selenium-Remote-Driver-0.15/lib/Selenium/Remote/Driver.pm#USAGE_(read_this_first)
my $driver = new Selenium::Remote::Driver(
                          'remote_server_addr' => $host,
                          'port' => "80",
                          'browser_name' => "firefox",
                          'version' => "37",
                          'platform' => "WINDOWS",
                          'extra_capabilities' => {'name' => $desc},
                          );

# Begin the automated test on Amazon's site by navigating to it
checkExit($driver->get('http://www.amazon.com'), "Failed to load localhost in Sauce OnDemand");

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

# Find the search box and enter a product to search for
# We'll find the search query input element by ID
my $searchQuery = "super 150 suit";
print "\nSearching for '$searchQuery'...";
my $inputElement = $driver->find_element('twotabsearchtextbox', 'id');
$inputElement->send_keys($searchQuery);
# We'll find the search button by its class
my $searchButton = $driver->find_element('nav-input', 'class');
$searchButton->click();
# Wait for the search results page to load
my $searchResultCountElement = $driver->find_element('s-result-count','id');
# Functions you can perform on WebElements are described in
# http://search.cpan.org/~aivaturi/Selenium-Remote-Driver-0.15/lib/Selenium/Remote/WebElement.pm
my $searchResultCount = $searchResultCountElement->get_text();
print "\nSearch Result count field for $searchQuery says:\n'$searchResultCount'";
# Now run a basic test on the element's text
#checkExit($searchResultCount !~ /1-16 of \d+ results for "$searchQuery"/,
#    "\nFAILED to find the expected text in the search result count for '$searchResultCount'"
#);
# Obtain the first result
# We'll find it by tag name; however, there are many other such tags
# So get an array back
my @searchResults = $driver->find_elements('h2', 'tag_name');
# Splice the h2 elements that aren't results -- only elements 2-17 are results
# (based on order of appearance in the code)
splice(@searchResults, 0, 1);    # Remove the 1st <h2> result; it's the search result count
splice(@searchResults, 16);      # Remove beyond the 16th result; it's not a store item
# Click on the first result
$searchResults[0]->click();
# Wait for the item to load
# Make sure there is an item written in strikeout font that indicates original price
# We'll look for this item based on its CSS indicator;
# it's a <td> inside of a <tr> and styled with the classes shown below,
# concatenated by dots
my $originalPriceElement = $driver->find_element('tr td.a-span12.a-color-secondary.a-size-base.a-text-strike', 'css');
# Make sure $originalPrice actually contains a price
my $originalPrice = $originalPriceElement->get_text();
if ($originalPrice !~ /\$[\d,]+\.\d{2}/) {
    print "FAILED to find the List Price on the page for Item 1'";
}
# Get the Amazon price
my $amznPriceElement = $driver->find_element('priceblock_ourprice', 'id');
my $amznPrice = $amznPriceElement->get_text();
# Make sure the Amazon price is less than or equal to the list price
$originalPrice =~ s/[\$\,]//g;
$amznPrice =~ s/[\$\,]//g;
if ($originalPrice < $amznPrice) {
    print "\nWhoops, the Amazon price is higher than the list price!";
}
# Click on all the images available on the side, and make sure the large image 
# actually becomes the image selected

# Acquire the list of images by means of their XPath
my @thumbnailElements = $driver->find_elements('//li[@class="a-spacing-small item"]//span/img');
my @bigPictures = $driver->find_element('li.image.item', 'css');
print "\nNumber of thumbnails of the item: " . scalar @thumbnailElements;
for my $activeThumbIdx (0 .. $#thumbnailElements) {
    # Move the mouse to click on each thumbnail
    my $thumb = $thumbnailElements[$activeThumbIdx];
    $driver->mouse_move_to_location(element => $thumb, xoffset => 2, yoffset => 2);
    # Make sure the larger image displays the prescribed picture and not the others
    for my $bigPicIdx (0 .. $#bigPictures) {
        my $bigPic = $bigPictures[$bigPicIdx];
        my $class = $bigPic->get_attribute('class');
        my $wrongPicShown = (($activeThumbIdx == $bigPicIdx) xor ($class =~ /selected/));
        if ($wrongPicShown) {
            print "\nFAILURE: Mouse is over picture #$activeThumbIdx but picture #$bigPicIdx is showing";
        }
    }
    # Sleep just a bit so we can see what's going on in the demo
    sleep(1);
}
# Select a size for the item
# Hit the Customer Reviews link based on partial text
# Make sure the top bar shows up after a little while
# Run some JavaScript to navigate us back to the top of the page
# Add the item to your cart
# Verify that the item is present in your cart and that it's the only thing

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
