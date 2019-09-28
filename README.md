# DNSCollector
DNS Collector used during my PhD to track malicious and legitimate domains

# Dependencies

* Net::DNS::Simple
* Net::DNS::Async
* Net::DNS

# Synchronous mode examples

DNS resolutions domain `example.com` using 
* MX-type
* A-type
* NS-type

```perl
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => 'example.com',
            qtype => 'mx'
            });
    say $syncRes->get_domain_name();
    say $syncRes->{qtype};
    say $syncRes->domain_search(); # using MX-type default
    say $_ foreach (@{$syncRes->{answer}});

    say $syncRes->domain_search({qtype => "A"}); # overload qtype
    say $_ foreach (@{$syncRes->{answer}});

    say $syncRes->domain_search({qtype => "NS"}); # overload qtype
    say $_ foreach (@{$syncRes->{answer}});
```

PTR-type resolution:

```perl
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => '209.51.188.174',
            qtype => 'PTR'
            });
    say $syncRes->domain_search(); # PTR-type default
    say $_ foreach (@{$syncRes->{answer}});
```

Resolution to obtain Answer, Auth, and Addtional sections:

```perl
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
```

# Asynchronous mode examples

Asynchronous mode is quite similar to Synchronous, but full mode: `mode => full` is not currently supported.

```perl
    my $syncRes = DNSResolver::ASyncResolution->new({
        domain => 'fsf.org',
    });
    say $syncRes->domain_search(); # A-type default
    say $_ foreach (@{$syncRes->{answer}});
```


Resolution to obtain Answer, Auth, and Addtional sections using Async:

```perl
    my $syncRes = DNSResolver::ASyncResolution->new({
            domain => 'google.com',
            });
    $syncRes->domain_search(); # using A-type default
    say "Answer:";
    say $_ foreach (@{$syncRes->{answer}});

    say "Auth:";
    $syncRes->domain_search({qtype => "NS"});
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
        $syncRes->domain_search({qtype => "A"});
        say $_ foreach (@{$syncRes->{answer}});
    }
```
