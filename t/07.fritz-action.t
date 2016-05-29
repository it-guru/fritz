#!perl
use Test::More tests => 9;
use warnings;
use strict;

BEGIN { use_ok('Fritz::Action') };


### public tests

subtest 'check xmltree getter' => sub {
    # given
    my $xmltree = get_xmltree();
    my $action = new_ok( 'Fritz::Action', [ xmltree => $xmltree ] );

    # when
    my $result = $action->xmltree;

    # then
    is_deeply( $result, $xmltree, 'Fritz::Action->xmltree' );
};

subtest 'check name getter' => sub {
    # given
    my $action = new_ok( 'Fritz::Action', [ xmltree => get_xmltree() ] );

    # when
    my $result = $action->name;

    # then
    is( $result, 'NAME', 'Fritz::Action->name' );
};

subtest 'check args_in' => sub {
    # given
    my $action = new_ok( 'Fritz::Action', [ xmltree => get_xmltree() ] );

    # when
    my $result = $action->args_in;

    # then
    is_deeply( $result, [ 'IN1', 'IN2' ], 'Fritz::Action->args_in' );
};

subtest 'check args_out' => sub {
    # given
    my $action = new_ok( 'Fritz::Action', [ xmltree => get_xmltree() ] );

    # when
    my $result = $action->args_out;

    # then
    is_deeply( $result, [ 'OUT' ], 'Fritz::Action->args_out' );
};

subtest 'check Fritz::IsNoError role' => sub {
    # given
    my $action = new_ok( 'Fritz::Action' );

    # when
    my $does_role = $action->does('Fritz::IsNoError');

    # then
    ok( $does_role, 'does Fritz::IsNoError role' );
};


### internal tests

subtest 'check new() with named parameters' => sub {
    # given
    my $xmltree = get_xmltree();

    # when
    my $action = new_ok( 'Fritz::Action', [ xmltree => $xmltree ] );

    # then
    is_deeply( $action->xmltree, $xmltree, 'Fritz::Action->xmltree' );
};

subtest 'check new() with odd parameter count' => sub {
    # given
    my $xmltree = get_xmltree();

    # when
    my $action = new_ok( 'Fritz::Action', [ $xmltree ] );

    # then
    is_deeply( $action->xmltree, $xmltree, 'Fritz::Action->xmltree' );
};

subtest 'check dump()' => sub {
    # given
    my $xmltree = get_xmltree();
    my $action = new_ok( 'Fritz::Action', [ xmltree => $xmltree ] );

    # when
    my $dump = $action->dump('!!!');

    # then
    foreach my $line (split /\n/, $dump) {
	like( $line, qr/^!!!(Fritz|  )/, 'line starts as expected' );
    }

    like( $dump, qr/^!!!Fritz::Action/, 'class name is dumped' );
    my $name = $action->name;
    like( $dump, qr/name\s+=\s+$name/, 'name is dumped' );
    my $args_in = 'IN1.+IN2';
    like( $dump, qr/args_in\s+=\s$args_in/, 'args_in is dumped' );
    my $args_out = 'OUT';
    like( $dump, qr/args_out\s+=\s$args_out/, 'args_out is dumped' );
};


### helper methods

sub get_xmltree
{
    my $xmltree = {
	'name' => [ 'NAME' ],
	'argumentList' => [ { 'argument' => [
				  { name      => [ 'IN1' ],
				    direction => [ 'in' ]
				  },
				  { name      => [ 'IN2' ],
				    direction => [ 'in' ]
				  },
				  { name      => [ 'OUT' ],
				    direction => [ 'out' ]
				  },
				  ]
			    }
	    ]
    };
}