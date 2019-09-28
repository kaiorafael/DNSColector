use lib './lib';
use DNSResolver::SyncResolution;
use feature 'say';
use strict;
use warnings;

# you can use 
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => 'aws.com',
            mode => 'full'
            });
    say $syncRes->domain_search(); # using A-type default

    say "Answer";
    say $_ foreach (@{$syncRes->{answer}});

    say "Auth";
    say $_ foreach (@{$syncRes->{auth}});

    say "Additional";
    say $_ foreach (@{$syncRes->{additional}});

