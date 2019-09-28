use lib './lib';
use DNSResolver::ASyncResolution;
use feature 'say';
use strict;
use warnings;

# this code is similar example of full mode from Synchronous module
#
    my $syncRes = DNSResolver::ASyncResolution->new({
            domain => 'google.com',
            });
    $syncRes->domain_search(); # using A-type default
    say "Answer:";
    say $_ foreach (@{$syncRes->{answer}});

    say "Auth:";
    $syncRes->domain_search({qtype => "NS"}); # overload qtype
    say $_ foreach (@{$syncRes->{answer}});

    my @ns_servers = ();
    foreach my $entry (@{$syncRes->{answer}}) {
            # split by white space, and get the last position (domain) from
            # the response
             my $d = (split(/\s+/,$entry))[-1];
             push @ns_servers, $d;
    }

    say "Additional:";
    ## changing attribute type
    foreach my $ns (@ns_servers) {
        $syncRes->{domain_name} = $ns;
        $syncRes->domain_search({qtype => "A"}); # overload qtype
        say $_ foreach (@{$syncRes->{answer}});
    }

