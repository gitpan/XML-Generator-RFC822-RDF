use strict;
use Test::More;
use Digest::SHA1 qw (sha1_hex);

plan tests => 9;

SKIP: {

  eval {
    require XML::SAX::Writer;
  };
  
  if ($@) {
    skip("XML::SAX::Writer not installed", 10);
  }
  
  my $msg = "t/example.txt";
  
  use_ok("XML::Generator::RFC822::RDF");
  use_ok("XML::SAX::Writer");
  use_ok("Email::Simple");
  
  ok((-f $msg),"found $msg");
  
  my $txt = undef;
  
  {
    local $/;
    undef $/;
    
    open FH, $msg;
    $txt = <FH>;
    close FH;
  }
      
  ok($txt,"read $msg");
  
  my $email = Email::Simple->new($txt);
  isa_ok($email,"Email::Simple");
  
  my $str_xml = "";
  my $writer  = XML::SAX::Writer->new(Output=>\$str_xml);
  isa_ok($writer,"XML::Filter::BufferText");
    
  my $parser = XML::Generator::RFC822::RDF->new(Handler=>$writer);
  isa_ok($parser,"XML::Generator::RFC822::RDF");

  cmp_ok(sha1_hex($str_xml),"eq","da39a3ee5e6b4b0d3255bfef95601890afd80709");
}
