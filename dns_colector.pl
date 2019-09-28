use Net::DNS::Simple;
use lib './lib';
use DNSResolver::SyncResolution;
use Data::Dumper;

use warnings;
use strict;
use v5.20;
no warnings "experimental";
use feature qw(signatures switch);

my @domain_list = ();

sub usage() {
    say "open using `file` or `sample`";
    exit 0;
}

# Top 1 milion alexa domains
# Open Domain name for resolution
sub alexa_csv_open {
    my $limit = 32500;
    my $filename = "bases/top-1m-alexa.csv";
    open(my $fh, "<", $filename) or die "Could not find file: $filename";
    for my $line (<$fh>) {
        $limit--;
        if ($limit == 0){last;}
        chomp $line;
        my ($did,$domain) = split(/\,/,$line);
        push @domain_list, $domain;
    }
    close($fh);
}

### Generic load domains from file sytem
sub load_domain_file() {
#TODO Load File here
    alexa_csv_open();
}

### sample domain load
## add your sample test here
sub load_domain_samples() {
    push @domain_list, "kaiux.com";
    push @domain_list, "debian.org";
    push @domain_list, "fsf.org";
    push @domain_list, "perl.org";
    push @domain_list, "www.instagram.com";
}

# Load the module defined
# file is the defult module
sub load_domain_list($mode = "file" ) {

    given ($mode) {
        when ( /file/) { load_domain_file() }
        when (/sample/) { load_domain_samples() }
        default { usage() }
    }
}

#Main code
sub main_code () {

    # Load Domains to process
    # sample or file
    load_domain_list("sample");

    for my $domain (@domain_list) {
        say "Searchig for... = " . $domain;

        my $syncRes = DNSResolver::SyncResolution->new({
            domain => $domain,
        });
        say $syncRes->domain_search(); # A-type default
        say $_ foreach (@{$syncRes->{answer}});
    }
}

## Main code
main_code();
