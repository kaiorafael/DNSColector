package DNSResolver::SyncResolution;

use Net::DNS::Simple;
use Carp;

use warnings;
use strict;
use v5.20;
use feature qw(say);

# domain = the domain name to be resolved (required)
# qtype = optional having A-type resoltion as default
# mode =
#       minimum (default)
#       full (all sessions)
sub new {
    my ($class, $args) = @_;

    die "Error, inform `domain` name"  if not $args->{domain};

    my $self = {
        domain_name => $args->{domain},
        qtype => $args->{qtype} || 'A',
        mode => $args->{mode} || 'minimum',
        answer => [], # Answer session
        auth => [], # Authority session,
        additional => [], # Additional session
    };

    return bless $self, $class;
}

sub get_domain_name {
    my $self = shift;
    return $self->{domain_name};
}

# Returns DNS section
# section:
#   answer, auth, additional
sub get_generic_section {
    my ($self, $args) = @_;

    if ( scalar @{$self->{ $args->{section} }} >= 1 ) {
        return $self->{ $args->{section}} ;
    } else {
        carp uc($args->{section}) . " Session is empty for domain! " . $self->get_domain_name();
        # empty response
        return [];
    }
}

# Return Answer Section
sub get_answer_section {
    my $self = shift;
    return $self->get_generic_section({section => 'answer'});
}

# Return Auth Section
sub get_auth_section {
    my $self = shift;
    return $self->get_generic_section({section => 'auth'});
}

# Return Additional Section
sub get_additional_section {
    my $self = shift;
    return $self->get_generic_section({section => 'additional'});
}


# qtype = A, PTR, MX, NS....
# send mininum or full DNS request
sub domain_search {
    my ($self, $args) = @_;

    # sending new query different RR-type
    if ( $args->{qtype} ) {
        $self->{answer} = () ; # clear all results
        $self->{qtype} = $args->{qtype};
    }

    # mininum request
    $self->send_dns_request() if ( $self->{mode} eq "minimum" );

    # full request
    $self->send_full_dns_request() if ( $self->{mode} eq "full" );
}

# real dns resolution goes here
sub send_dns_request {
    my ($self, $args) = @_;
    my $res = Net::DNS::Simple->new($self->{domain_name}, $self->{qtype});

    if ( $res->get_rcode() ne "NOERROR" ) {
        return "Error: " . $res->get_rcode();
    }

    if($res->get_ancount == 0){
        say "Answer Empty!";
        next;
    }

    for my $entry ($res->get_answer_section()) {
        push @{$self->{answer}}, $entry;
    }
}

sub send_full_dns_request {
    my ($self, $args) = @_;

    ### Answer
    $self->{qtype} = "A";
    my $res = Net::DNS::Simple->new($self->{domain_name}, $self->{qtype});
    if ( $res->get_rcode() eq "NOERROR" ) {
        for my $entry ($res->get_answer_section()) {
            push @{$self->{answer}}, $entry;
        }
    }

    ### Auth
    $self->{qtype} = "NS";
    $res = Net::DNS::Simple->new($self->{domain_name}, $self->{qtype});
    if ( $res->get_rcode() eq "NOERROR" ) {

        # Auth
        for my $entry ($res->get_answer_section()) {

            # clean possible errors
            $entry =~ s/\n//g;
            $entry =~ s/\(//g;
            $entry =~ s/ \)//g;
            push @{$self->{auth}}, $entry;
        }
    }

    ### Additional
    ### DNS domains should have minimum 2 NS
    ## size of auth
    if ( scalar @{$self->{auth}} > 1 ) {
        for my $entry (@{$self->{auth}}) {
            ### ns entry is the last on array
            my @ns_entry = split(/\s+/,$entry);
            $self->{qtype} = "A";
            $res = Net::DNS::Simple->new($ns_entry[-1], $self->{qtype});
            if ( $res->get_rcode() eq "NOERROR" ) {
                for my $entry ($res->get_answer_section()) {
                    push @{$self->{additional}}, $entry;
                }
            }
        }
    }

}

1;

=item
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

sub test3() {
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => 'aws.com',
            mode => 'full'
            });
    say $syncRes->domain_search(); # using MX-type default

    say "Answer";
    say $_ foreach (@{$syncRes->{answer}});

    say "Auth";
    say $_ foreach (@{$syncRes->{auth}});

    say "Additional";
    say $_ foreach (@{$syncRes->{additional}});
}

sub test4() {
    my $syncRes = DNSResolver::SyncResolution->new({
            domain => 'yahoo.com',
            mode => 'full'
            });
    say $syncRes->domain_search(); # using MX-type default

    say $_ foreach (@{$syncRes->get_answer_section()});
    say $_ foreach (@{$syncRes->get_auth_section()});
    say $_ foreach (@{$syncRes->get_additional_section()});
}

test4();
=cut
