#!/usr/bin/perl -w
use warnings;
use strict;

use Fritz::Box;

use Data::Dumper;

use utf8;

# get credentials (not checked in)
my ($user, $pass);
my $rcfile = $ENV{HOME}.'/.fritzrc';
if (-r $rcfile) {
    open FRITZRC, '<', $rcfile or die $!;
    while (my $line = <FRITZRC>) {
	chomp $line;
	if ($line =~ /^(\S+)\s*=\s*(.*?)$/) {
	    if ($1 eq 'username') {
		$user = $2;
	    }
	    elsif ($1 eq 'password') {
		$pass = $2
	    }
	}
    }
    close FRITZRC or die $!;
}

my $f = Fritz::Box->new(
    username => $user,
    password => $pass
    );

#$f->dump();
#print "\n\n";

my $d = $f->discover();
#$d->dump();
#print "\n\n";

if (1 == 1) {
    # get call list
    my $service = $d->find_service('X_AVM-DE_OnTel:');
    $service->errorcheck;
    my $response = $service->call('GetCallList');
    print $response->data->{NewCallListURL} . "\n";
}

if (1 == 0) {
    # get all connected WLAN devices
    my $services = $d->find_service_names('Configuration:');
    $services->errorcheck;
    print Dumper($services->data);
    for my $serviceType (@{$services->data}) {
	my $service = $d->get_service($serviceType);
	$services->errorcheck;
	my $response = $service->call('GetTotalAssociations');
	$response->errorcheck;
	print Dumper($response->data);
	# now do a loop and read device by device - my WLAN is off, so I can't test here :-)
    }
}

if (1 == 1) {
    ## list all known hosts
    my $service = $d->find_service('Hosts:1');
    $service->errorcheck;
    my $response = $service->call('GetHostNumberOfEntries');
    $response->errorcheck;
    printf "number of hosts = %d\n", $response->data->{NewHostNumberOfEntries};
    printf "%3s  %-30s  %-15s  %-17s  %-10s  %-6s  %s\n", 'act', 'hostname', 'IP address', 'MAC address', 'interface', 'source', 'lease';
    for my $host ( 0 .. $response->data->{NewHostNumberOfEntries} - 1) {
	$response = $service->call('GetGenericHostEntry', 'NewIndex' => $host);
	$response->errorcheck;
	my $d = $response->data;
	printf("%3d  %-30s  %-15s  %-17s  %-10s  %-6s  %d\n",
	       $d->{NewActive},
	       $d->{NewHostName},
	       $d->{NewIPAddress},
	       $d->{NewMACAddress},
	       $d->{NewInterfaceType},
	       $d->{NewAddressSource},
	       $d->{NewLeaseTimeRemaining},
	    );
    }
}

if (1 == 1) {
    # get security port (boooring)
    my $service = $d->find_service('DeviceInfo:1');
    $service->errorcheck;
    my $response = $service->call('GetSecurityPort');
    $response->errorcheck;
    my $port = $response->data->{NewSecurityPort};
    print "security port is $port\n";

    # now use the port for SSL!
    # GetSecurityPort needs no username/password, so omit them
    my $upnp_url = $f->upnp_url;
    $upnp_url =~ s/http:/https:/;
    $upnp_url =~ s/:49000/:$port/;
    my $f_ssl = Fritz::Box->new( upnp_url => $upnp_url );
    $f_ssl->errorcheck;
    my $d_ssl = $f_ssl->discover;
    $d_ssl->errorcheck;
    my $service_ssl = $d_ssl->find_service('DeviceInfo:1');
    $service_ssl->errorcheck;
    my $response_ssl = $service_ssl->call('GetSecurityPort');
    $response_ssl->errorcheck;
    my $port_ssl = $response_ssl->data->{NewSecurityPort};
    print "security port over SSL is $port - it worked!\n";
}

#$r->dump();


#my $s = $d->find_service( 'urn:dslforum-org:service:WANDSLInterfaceConfig:1' );
#$s->dump();
#print "\n\n";

#$s = $d->find_service( Fritz::Service::DEVICEINFO );
#$s->dump();
#print "\n\n";

#my $r;

#print Dumper( $s->scpd() );


#$r = $s->call('GetInfo');

#print Dumper($r);

#$s = $d->find_service( 'urn:dslforum-org:service:X_VoIP:1' );
#print Dumper($s->dump);
#print Dumper($s->call('X_AVM-DE_DialHangup'));
