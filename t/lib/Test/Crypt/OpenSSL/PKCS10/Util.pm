package Test::Crypt::OpenSSL::PKCS10::Util;
use warnings;
use strict;

# ABSTRACT: Utils for testsuite of Crypt::OpenSSL::PKCS10

use Test::More;

use File::Slurper qw/ write_text /;
use File::Temp qw/ tempfile /;

use Crypt::OpenSSL::Guess qw/find_openssl_prefix find_openssl_exec/;

use Crypt::OpenSSL::PKCS10;

require Exporter;

my $openssl_bin = find_openssl_exec(find_openssl_prefix());

our @ISA    = qw(Exporter);
our @EXPORT = qw(
    get_openssl_output
 );

our @EXPORT_OK;

our %EXPORT_TAGS = (
    all => [@EXPORT, @EXPORT_OK],
);

sub get_openssl_output {
    my $csr = shift;

    my ($fh, $filename) = tempfile;
    write_text($filename, $csr);
    my $output = `"$openssl_bin" req -in $filename -text`;

    return $output;
}

