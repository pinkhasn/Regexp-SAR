
use strict;
use warnings;

use Test::More;

BEGIN { use_ok('Regexp::SAR') };


{
  my $rootNode = Regexp::SAR::buildRootNode();
  is(Regexp::SAR::getCharsNumber($rootNode), 0, "Number of characters in node");
  is(Regexp::SAR::getCharsAsStr($rootNode), "", "characters in node");
}

{
  my $rootNode = Regexp::SAR::buildRootNode();
  foreach my $char (qw/g a c d b f e/)
    {
      Regexp::SAR::nodeAddCharSorted($rootNode, $char);
    }
  is(Regexp::SAR::getCharsNumber($rootNode), 7, "Number of characters in node");
  is(Regexp::SAR::getCharsAsStr($rootNode), "abcdefg", "characters in node");
  is(Regexp::SAR::searchNode($rootNode, "z"), -1, "path does not exist in node");
  is(Regexp::SAR::searchNode($rootNode, "d"), 3, "path found");
  is(Regexp::SAR::searchNode($rootNode, "a"), 0, "path found");
  is(Regexp::SAR::searchNode($rootNode, "g"), 6, "path found");
}

{
  my $rootNode = Regexp::SAR::buildRootNode();
  foreach my $char (qw/m n a b b c b/)
    {
      Regexp::SAR::nodeAddCharSorted($rootNode, $char);
    }
  is(Regexp::SAR::getCharsNumber($rootNode), 5, "Check duplicate chars");
}




##############################################
done_testing();
