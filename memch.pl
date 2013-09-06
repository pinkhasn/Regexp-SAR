#!/home/pinkhasn/apps/run/perl/bin/perl

use strict;
use warnings;

use lib '/home/pinkhasn/work/en/Dropbox/my/src/perl/SAR/Regexp-SAR/lib';

use Regexp::SAR;


my $text = "kjahlf lha sabcddljhl abbbbbbbbcd asdhbbbbfljhal skdhlfh alsdhf";



my $incCnt = sub { my $ty = "hghhghg"; };
foreach (1..100000)
  {

    my $sar = new Regexp::SAR;

    $sar->addRegexp("zqzqzqzq", $incCnt);
    $sar->addRegexp("zmzmzm", $incCnt);
    $sar->addRegexp("ab+cd", $incCnt);
    $sar->addRegexp("ab?cd", $incCnt);
    $sar->addRegexp("zzzz", $incCnt);
    $sar->addRegexp("xxxx", $incCnt);
    $sar->addRegexp("mmmm", $incCnt);
    $sar->addRegexp("bbbb", $incCnt);
    $sar->addRegexp("bb?b?b?", $incCnt);

    foreach (1..100)
      {
	$sar->match($text);
      }


# 	my $rootNode = Regexp::SAR::buildRootNode();
# 	my $incCnt = sub { my $ty = "hghhghg"; };
# 	Regexp::SAR::buildPath($rootNode, , $incCnt);
# 	Regexp::SAR::buildPath($rootNode, "zmzmzm", $incCnt);
#  	Regexp::SAR::buildPath($rootNode, "zzzz", $incCnt);
# 	Regexp::SAR::buildPath($rootNode, "xxxx", $incCnt);
# 	Regexp::SAR::buildPath($rootNode, "mmmm", $incCnt);
# 	Regexp::SAR::buildPath($rootNode, "bbbb", $incCnt);
# 	Regexp::SAR::lookPath($rootNode, $text);

# 	Regexp::SAR::cleanAll($rootNode);

      }


