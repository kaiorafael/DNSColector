package DNSResolver::SyncResolution;

use Net::DNS::Simple;
use Data::Dumper;

use warnings;
use strict;
use v5.20;
no warnings "experimental";
use feature qw(say switch);

# domain = the domain name to be resolved (required)
# qtype = optional having A-type resoltion as default
sub new {
    my ($class, $args) = @_;

    die "Error, inform `domain` name"  if not $args->{domain};

    my $self = {
        domain_name => $args->{domain},
        qtype => $args->{qtype} || 'A',
        answer => []
    };

    return bless $self, $class;
}

sub get_domain_name {
    my $self = shift;
    return $self->{domain_name};
}

# qtype = A, PTR, MX, NS....
# session = answer, auth, additional, all (all sesssions)
sub domain_search {
    my ($self, $args) = @_;

    # sending new query different RR-type
    if ( $args->{qtype} ) {
        $self->{answer} = () ; # clear all results
        $self->{qtype} = $args->{qtype};
    }
#    $self->{qtype} = $args->{qtype} if not $self->{qtype};
    $self->send_dns_request();
}

# real dns resolution goes here
sub send_dns_request {
    my ($self, $args) = @_;
    my $res = Net::DNS::Simple->new($self->{domain_name}, $self->{qtype});

    given ($res->get_rcode) {
        when (/SERVFAIL/) { return "SERVFAIL" }
        when (/NXDOMAIN/) { return "NXDOMAIN" }
    }

    if($res->get_ancount == 0){
        say "Answer Empty!";
        say "---------------------------------------------";
        next;
    }

    for my $entry ($res->get_answer_section()) { 
        push @{$self->{answer}}, $entry;
    }
}

1;

#### Testing
sub test1() {
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => 'kaiux.com',
            qtype => 'mx'
            });
    say $syncRes->get_domain_name();
    say $syncRes->{qtype};
    say $syncRes->domain_search(); # using MX-type default
    say $_ foreach (@{$syncRes->{answer}});

    say $syncRes->domain_search({qtype => "A"}); # overload qtype
    #say scalar @{$syncRes->{answer}};
    #say @{$syncRes->{answer}};
    say $_ foreach (@{$syncRes->{answer}});

    say $syncRes->domain_search({qtype => "NS"}); # overload qtype
    say $_ foreach (@{$syncRes->{answer}});
}

sub test2() {
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => '45.32.169.70',
            qtype => 'PTR'
            });
    say $syncRes->domain_search(); # PTR-type default
    say $_ foreach (@{$syncRes->{answer}});
}

#test1();
