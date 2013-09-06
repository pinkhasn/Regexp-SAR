
use strict;
use warnings;

use Test::More;

BEGIN { use_ok('Regexp::SAR') };



matchTest(['abcd'], 'qabcdef', 1);
matchTest(['abcd', 'abcf'], "zqabcdwabcfr", 3);
matchTest(['abcd', 'abc'], "zqabcdwr", 3);
matchTest(['ab\cd'], "qabcdef", 1);
#matchTest(['ab\\cd'], "qabcdef", 0);
#matchTest(['ab\\cd'], "qab\cdef", 1);



matchTest(['ab\?cd'], "qabcdef", 0);
matchTest(['ab\?cd'], "qab?cdef", 1);
matchTest(['ab?cd'], "qabcdef", 1);
matchTest(['ab?cd'], "qacdef", 1);
matchTest(['ab?cd'], "qab?cdef", 0);
matchTest(['ab\?cd'], "qab?cdef", 1);
matchTest(['ab?cd', 'abce'], "qacem", 0);
matchTest(['abd', 'ab?d', 'kkk', 'abc?d'], "qabdm", 11);
matchTest(['ab?b?b?b?b?cd'], "qacdef", 1);
matchTest(['ab?b?b?cd'], "qabcdef", 1);
matchTest(['ab?b?b?cd'], "qabbcdef", 1);
matchTest(['ab+cd'], 'qabbbbcdef', 1);
matchTest(['ab+cd', 'am+ef'], "qabcdq qabbbbcdq qacdq qammmefq", 4);
matchTest(['ab+cd', 'abcf'], "abbcd", 1);
matchTest(['ab+cd', 'abcf'], "abbcf", 0);
matchTest(['ab+'], "qabcdq qabbbbcdq qacdq", 5);
matchTest(['ab+bcd'], "qabcdq", 0);
matchTest(['ab+bcd'], "qabbcdq", 1);
matchTest(['ab+b+cd'], "qabbcdq", 1);
matchTest(['ab+b+cd'], "qabcdq", 0);
matchTest(['ab+b+b+cd'], "qabbcdq", 0);
matchTest(['ab+b+b+cd'], "qabbbcdq", 1);
matchTest(['ab+b+b+cd'], "qabbbbbbbcdq", 1);
matchTest(['a\?+cd'], "qa????cdq", 1);
matchTest(['ab*cd'], 'qabbbbcdef', 1);
matchTest(['ab*cd'], 'qacdef', 1);


# matchTest(['ab?cd+d+ef'], 'q acddddef q', 1);
# matchTest(['ab?cd+d+ef'], 'q acdef q', 0);
# matchTest(['ab?cd+d+ef'], 'q acbddddef q', 1);





sub matchTest {
  my $regexps = shift;
  my $matchStr = shift;
  my $expectedRes = shift;

  my $pathRes = 0;
  my $rootNode = Regexp::SAR::buildRootNode();
  for (my $i=0; $i < @$regexps; ++$i)
    {
      my $reNum = 2**$i;
      Regexp::SAR::buildPath($rootNode, $regexps->[$i], sub { $pathRes += $reNum; });
    }
  Regexp::SAR::lookPath($rootNode, $matchStr);
  is($pathRes, $expectedRes, "\nMatch fail for: ". join(', ', @$regexps). ": in >>$matchStr<<\n");
}


{
  my $rootNode = Regexp::SAR::buildRootNode();
  my $start;
  my $length;
  Regexp::SAR::buildPath($rootNode, "abcde", sub {
			   my ($matchStart, $matchLength) = @_;
			   $start = $matchStart;
			   $length = $matchLength;
			 });
  Regexp::SAR::lookPath($rootNode, "qabcdef");
  is($start, 1, "match start");
  is($length, 5, "match length");
}


{
  my $rootNode = Regexp::SAR::buildRootNode();
  my $matchRes = 0;
  Regexp::SAR::buildPath($rootNode, "abcde", sub { $matchRes +=1; });
  Regexp::SAR::lookPath($rootNode, "qabcdef");
  Regexp::SAR::lookPath($rootNode, "qabcdef");
  Regexp::SAR::lookPath($rootNode, "qabcdef");
  is($matchRes, 3);
}





##############################################
done_testing();
