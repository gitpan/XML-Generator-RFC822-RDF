use strict;
use Test::More;

plan tests => 12;

SKIP: {

  eval {
    require XML::SAX::Writer;
  };
  
  if ($@) {
    skip("XML::SAX::Writer not installed", 12);
  }
  
  eval { 
    require RDF::Simple::Parser;
  };

  if ($@) {
    skip("RDF::Simple::Parser not installed", 12);
  }

  my $msg = "t/example.txt";
  
  use_ok("XML::Generator::RFC822::RDF");
  use_ok("XML::SAX::Writer");

  use_ok("Email::Simple");
  use_ok("RDF::Simple::Parser");
  
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
  
  ok($parser->parse($email),"parsed $msg");

  my $rdf_parser = RDF::Simple::Parser->new(base => "");
  isa_ok($rdf_parser,"RDF::Simple::Parser");
  
  my @triples = $rdf_parser->parse_rdf($str_xml);

  cmp_ok(scalar(@triples),"==",45,"found 45 triples");
}
