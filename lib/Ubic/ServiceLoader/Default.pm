package Ubic::ServiceLoader::Default;

# ABSTRACT: default service loader

use strict;
use warnings;

use parent qw( Ubic::ServiceLoader::Base );

=head1 SYNOPSIS

    use Ubic::ServiceLoader::Default;
    my $loader = Ubic::ServiceLoader::Default->new;
    $loader->load("/etc/ubic/service/ubic/ping");

=cut

use Scalar::Util qw(blessed);

my $eval_id = 1;

sub new {
    return bless {} => shift;
}

sub load {
    my $self = shift;
    my ($file) = @_;

    open my $fh, '<', $file or die "Can't open $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh or die "Can't close $file: $!";

    $content = "# line 1 $file\n$content";
    $content = "package UbicService".($eval_id++).";\n# line 1 $file\n$content";
    my $service = eval $content;
    if ($@) {
        die "Failed to eval '$file': $@";
    }
    unless (blessed $service) {
        die "$file doesn't contain any service";
    }
    unless ($service->isa('Ubic::Service')) {
        die "$file returned $service instead of Ubic::Service";
    }
    return $service;
}

1;
