package DNSResolver::ASyncResolution;

use Net::DNS::Async;
#use Net::DNS::RR;
#use Data::Dumper;

use warnings;
use strict;
use v5.20;
use feature qw(say);

# domain = the domain name to be resolved (required)
# qtype = optional having A-type resoltion as default
# mode =
#       minimum (default)
# 
my $instance = undef; #For Singleton

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

    $instance = bless $self, $class;
    return $instance;
}

# real dns resolution goes here
sub send_dns_request {
    my ($self, $args) = @_;
    #my $res = Net::DNS::Simple->new($self->{domain_name}, $self->{qtype});
    my $c = new Net::DNS::Async(QueueSize => 20, Retries => 3);
    $c->add(\&callback, $self->{domain_name}, $self->{qtype});
    $c->await();

}

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

sub get_instance {
    $instance = bless {}, shift unless $instance;
    return $instance;
}

#ASync callback
sub callback {
	my $response = shift;
    my $singleton = DNSResolver::ASyncResolution->get_instance();

	my $packet = new Net::DNS::Packet( \$response);
	##	$rr = new Net::DNS::RR($response->answer->print);
	my @answer  = map $_->string, $response->answer;
	foreach my $res (@answer) {
        push @{$singleton->{answer}}, $res;
	}
}

1;
