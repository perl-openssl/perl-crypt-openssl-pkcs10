# NAME

Crypt::OpenSSL::PKCS10 - Perl extension to OpenSSL's PKCS10 API.

# SYNOPSIS

```perl
use Crypt::OpenSSL::PKCS10 qw( :const );

my $req = Crypt::OpenSSL::PKCS10->new;
$req->set_subject("/C=RO/O=UTI/OU=ssi");
$req->add_ext(Crypt::OpenSSL::PKCS10::NID_key_usage,"critical,digitalSignature,keyEncipherment");
$req->add_ext(Crypt::OpenSSL::PKCS10::NID_ext_key_usage,"serverAuth, nsSGC, msSGC, 1.3.4");
$req->add_ext(Crypt::OpenSSL::PKCS10::NID_subject_alt_name,"email:steve@openssl.org");
$req->add_custom_ext('1.2.3.3',"My new extension");
$req->add_ext_final();
$req->sign();
$req->write_pem_req('request.pem');
$req->write_pem_pk('pk.pem');
print $req->get_pem_pubkey();
print $req->pubkey_type();
print $req->get_pem_req();

Crypt::OpenSSL::PKCS10->new()     # Defaults to a 1024-bit RSA private key

Crypt::OpenSSL::PKCS10->new(2048) # Specify a 2048-bit RSA private key

# With 2 arguements the keysize must be first
Crypt::OpenSSL::PKCS10->new(
                              2048,   # 2048-bit RSA keysize 
                              {
                                  type    => 'rsa',      # Private key type ('rsa' or 'ec')
                                  hash    => 'SHA256',   # Hash Algorithm name 
                              });

Crypt::OpenSSL::PKCS10->new(
                              {
                                  type    => 'ec',        # Private key type ('rsa' or 'ec')
                                  curve   => 'secp384r1', # Eliptic Curve type (secp384r1 default)
                                  hash    => 'SHA256',    # Hash Algorithm name   
                              });
```

# ABSTRACT

```
Crypt::OpenSSL::PKCS10 - Perl extension to OpenSSL's PKCS10 API.
```

# DESCRIPTION

Crypt::OpenSSL::PKCS10 provides the ability to create PKCS10 certificate requests using RSA key pairs.

# Class Methods

- new

    Create a new Crypt::OpenSSL::PKCS10 object by generating a new key pair. There
    are two optional arguments, the key size which defaults to 1024, and a hash of
    options which can be used to customize options.

    ```perl
    Crypt::OpenSSL::PKCS10->new()     # Defaults to a 1024-bit RSA private key

    Crypt::OpenSSL::PKCS10->new(2048) # Specify a 2048-bit RSA private key

    # With 2 arguements the keysize must be first
    Crypt::OpenSSL::PKCS10->new(
                                  2048,   # 2048-bit RSA keysize 
                                  {
                                      type    => 'rsa',      # Private key type ('rsa' or 'ec')
                                      hash    => 'SHA256',   # Hash Algorithm name 
                                  });

    Crypt::OpenSSL::PKCS10->new(
                                  {
                                      type    => 'ec',        # Private key type ('rsa' or 'ec')
                                      curve   => 'secp384r1', # Eliptic Curve type (secp384r1 default)
                                      hash    => 'SHA256',    # Hash Algorithm name   
                                  });
    ```

- new\_from\_rsa( $rsa\_object )

    Create a new Crypt::OpenSSL::PKCS10 object by using key information from a Crypt::OpenSSL::RSA object. Here is an example:

    ```perl
    my $rsa = Crypt::OpenSSL::RSA->generate_key(512);
    my $req = Crypt::OpenSSL::PKCS10->new_from_rsa($rsa);

    my $rsa = Crypt::OpenSSL::RSA->generate_key(1024);
    my $req = Crypt::OpenSSL::PKCS10->new_from_rsa($rsa, {type => 'rsa', hash => 'SHA384'});
    ```

    OpenSSL 3.0 has deprecated the RSA object which Crypt::OpenSSL::RSA creates.  new\_from\_rsa() is now a perl sub which obtains the private key as a string that is also passed to the \_new\_from\_rsa() XS function.

- new\_from\_file( $filename )

    Create a new Crypt::OpenSSL::PKCS10 object by reading the request and key information from a PEM formatted file. Here is an example:

    ```perl
    my $req = Crypt::OpenSSL::PKCS10->new_from_file("CSR.csr");
    ```

    You can also specify the format of the PKCS10 file, either DER or PEM format.  Here are some examples:

    ```perl
    my $req = Crypt::OpenSSL::PKCS10->new_from_file("CSR.csr", Crypt::OpenSSL::PKCS10::FORMAT_PEM());

    my $req = Crypt::OpenSSL::PKCS10->new_from_file("CSR.der", Crypt::OpenSSL::PKCS10::FORMAT_ASN1());
    ```

# Instance Methods

- set\_subject($subject, \[ $utf8 \])

    Sets the subject DN of the request.
    Note: $subject is expected to be in the format /type0=value0/type1=value1/type2=... where characters may be escaped by \\.
    If $utf8 is non-zero integer, $subject is interpreted as UTF-8 string.

- add\_ext($nid, $extension)

    Adds a new extension to the request. The first argument $nid is one of the exported constants (see below).
    The second one $extension is a string (for more info read `openssl(3)`).

    ```perl
    $req->add_ext(Crypt::OpenSSL::PKCS10::NID_key_usage,"critical,digitalSignature,keyEncipherment");
    $req->add_ext(Crypt::OpenSSL::PKCS10::NID_ext_key_usage,"serverAuth, nsSGC, msSGC, 1.3.4");
    $req->add_ext(Crypt::OpenSSL::PKCS10::NID_subject_alt_name,"email:steve@openssl.org");
    ```

- add\_custom\_ext($oid, $desc)

    Adds a new custom extension to the request. The value is added as a text string, using ASN.1 encoding rules inherited from the Netscape Comment OID. 

    ```
    $req->add_custom_ext('1.2.3.3',"My new extension");
    ```

- add\_custom\_ext\_raw($oid, $bytes)

    Adds a new custom extension to the request. The value is added as a raw DER octet string. Use this if you are packing your own ASN.1 structures and need to set the extension value directly.

    ```
    $req->add_custom_ext_raw($oid, pack('H*','1E06006100620063')) # BMPString 'abc'
    ```

- add\_ext\_final()

    This must be called after all extensions has been added. It actually copies the extension stack to request structure.

    ```perl
    $req->add_ext(Crypt::OpenSSL::PKCS10::NID_subject_alt_name,"email:my@email.org");
    $req->add_ext_final();
    ```

- sign()

    This adds the signature to the PKCS10 request.

    ```perl
    $req->sign();

    $req->sign("SHA256");     # Set the hash to use for the signature
    ```

- pubkey\_type()

    Returns the type of the PKCS10 public key - one of (rsa|dsa|ec).

    ```
    $req->pubkey_type();
    ```

- get\_pubkey()

    Returns the PEM encoding of the PKCS10 public key.

    ```
    $req->get_pubkey();
    ```

- get\_pem\_req()

    Returns the PEM encoding of the PKCS10 request.

    ```
    $req->get_pem_req();
    ```

- write\_pem\_req($filename)

    Writes the PEM encoding of the PKCS10 request to a given file.

    ```
    $req->write_pem_req('request.pem');
    ```

- get\_pem\_pk()

    Returns the PEM encoding of the private key.

    ```
    $req->get_pem_pk();
    ```

- write\_pem\_pk($filename)

    Writes the PEM encoding of the private key to a given file.

    ```
    $req->write_pem_pk('request.pem');
    ```

- subject()

    returns the subject of the PKCS10 request

    ```perl
    $subject = $req->subject();
    ```

- keyinfo()

    returns the human readable info about the key of the PKCS10 request

    ```
    $keyinfo = $req->keyinfo();
    ```

## EXPORT

None by default.

On request:

```perl
    NID_key_usage NID_subject_alt_name NID_netscape_cert_type NID_netscape_comment
    NID_ext_key_usage
```

# BUGS

If you destroy $req object that is linked to a Crypt::OpenSSL::RSA object, the RSA private key is also freed, 
thus you can't use latter object anymore. Avoid this:

```perl
my $rsa = Crypt::OpenSSL::RSA->generate_key(512);
my $req = Crypt::OpenSSL::PKCS10->new_from_rsa($rsa);
undef $req;
print $rsa->get_private_key_string();
```

# SEE ALSO

`Crypt::OpenSSL::RSA`, `Crypt::OpenSSL::X509`.

# AUTHOR

JoNO, <jonozzz@yahoo.com>

# COPYRIGHT AND LICENSE

Copyright (C) 2006 by JoNO

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.
