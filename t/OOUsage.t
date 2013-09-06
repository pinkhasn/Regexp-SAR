
use strict;
use warnings;

use Test::More;

BEGIN { use_ok('Regexp::SAR') };



{
  my $sar = new Regexp::SAR;

  my $pathRes = 0;
  $sar->addRegexp("abcd", sub { $pathRes += 1; });
  $sar->match("qabcdef");
  is($pathRes, 1, "match once");
}






##############################################
done_testing();
