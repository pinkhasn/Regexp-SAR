package Regexp::SAR;
# ABSTRACT: Regexp::SAR - a Perl module implementing a regular expression engine for handling matching events (Simple API for Regexp)

=head1 NAME

Regexp::SAR - a Perl module implementing a regular expression engine for handling matching events (Simple API for Regexp)

=head1 SYNOPSIS

    use Regexp::SAR;
    
    my $sar1 = Regexp::SAR->new;
    my $matched = 0;
    $sar1->addRegexp('abc', sub {$matched = 1;});
    $sar1->match('mm abc nn');
    if ($matched) {
        #proc matching        
    }
    
    #################################################
    #index many regexp for single match run
    my @matched;
    my $sar2 = Regexp::SAR->new;
    my $regexps = [
                    ['ab+c', 'First Match'],
                    ['\d+', 'Second Match'],
                  ];
    my $string;
    foreach my $re (@$regexps) {
        my ($reStr, $reTitle) = @$re;
        $sar2->addRegexp( $reStr,
                        sub {
                            my ($from, $to) = @_;
                            my $matchStr = substr($string, $from, $to - $from);
                            push @matched, "$reTitle: $matchStr";
                            $sar2->continueFrom($to);
                        } );
    }
    $string = 'first abbbbc second 123 end';
    $sar2->match(\$string);
    # @matched has ('First Match: abbbbc', 'Second Match: 123')

    #################################################
    #get third match and stop
    my $sar3 = Regexp::SAR->new;
    my $matchedStr3;
    my $matchCount = 0;
    my $string3 = 'aa11 bb22 cc33 dd44';
    $sar3->addRegexp('\w+', sub {
                                my ($from, $to) = @_;
                                ++$matchCount;
                                if ($matchCount == 3) {
                                    $matchedStr3 = substr($string3, $from, $to - $from);
                                    $sar3->stopMatch(); 
                                }
                                else {
                                    $sar3->continueFrom($to);
                                }
                            });
    $sar3->match($string3);
    # $matchCount is 3, $matchedStr3 is 'cc33'
    
    #################################################
    #get match only at certain position
    my $sar4 = Regexp::SAR->new;
    my $matchedStr4;
    my $string4 = 'aa11 bb22 cc33 dd44';
    $sar4->addRegexp('\w+', sub {
                                my ($from, $to) = @_;
                                $matchedStr4 = substr($string4, $from, $to - $from);
                            });
    $sar4->matchAt($string4, 5);
    #$matchedStr4 is 'bb22'
    
    #################################################
    #negative matching
    my $sar5 = Regexp::SAR->new;
    $sar5->addRegexp('a\^\d+b', sub { print "Matched\n"; });
    $sar5->match('axyzb');

=head1 DESCRIPTION

The Regexp::SAR (= "Simple API for Regexp") module builds a trie structure
for many regular expressions and stores a match handler for each
regular expression that will be called when a match occurs.
There is no limit for the number of regular expressions.
A handler is called immediately on match and it gets matching start
and end positions in the matched string. Matching can be started from
any point in the matched string. A match handler can decide from which
point matching should continue, or it can completely stop matching.

=head1 METHODS

=head2 new()

Create a new Regexp::SAR object. Every object stores its own trie
structure separately. When the object goes out of scope, the object and
its internal data structures will be cleared from memory.

=head2 addRegexp

Add a regular expression to handle. The first parameter is a regular
expression string. The Second parameter is a reference to a subroutine
that will be called when a match on this regexp occurs. The handler
subroutine receives two integers as input, the match’s start and the
match’s end. The start is the position of the first matched character.
The end is the position after the last matched character.

  my $sar = new Regexp::SAR;
  my $string = 'a123b';
  $sar->addRegexp('\d+', sub {
                              my ($from, $to) = @_;
                              # $from is 1
                              # $to is 4
                              $sar->stopMatch();
                          });
  $sar->match($string);

=head2 match

Process matching all the added regular expressions on the matched string
passed to C<match> as parameter. C<match> can accept the matched string
as a reference to a scalar, which is useful when the matched string is
very long.

=head2 $sar->matchFrom($str, $pos)

Perform the matching from a specific position. Receives two parameters:
the matched string and a number from which to start processing. The C<match>
method calls C<matchFrom> with the second paramater as 0.

=head2 matchAt

Perform the matching from a specific position, and do not continue on the next
characters.

=head2 continueFrom

The C<continueFrom> method can be called in the matching handler, and defines
from which position to continue matching, after it finished matching
the current position.

=head2 stopMatch

The C<stopMatch> subroutine can be called in the matching handler, and
instructs the Regexp::SAR object to not continue matching the next characters.

=head1 Matching rules

=over

=item *

Continue the matching process, character by character, even if there was a
match.

  my $sar = Regexp::SAR->new;
  my $string = 'a123b';
  $sar->addRegexp('\d+', sub {
                              my ($from, $to) = @_;
                              $matchedStr = substr($string, $from, $to - $from);
                              print "Found number is: $matchedStr\n";
                          });
  $sar->match($string);

The above code will print 3 strings: '123', '23', '3'
In case it should be matched only once use C<continueFrom>.

=item *

Call all the matching handlers that could be found from the matching position.

  my $sar = Regexp::SAR->new;
  $sar->addRegexp('new', sub { print "new found\n"; });
  $sar->addRegexp('new york', sub { print "new york found\n"; });
  $sar->match('new york');

Above code will print "new found", then print "new york found"

=item *

Call all the matching handlers from different regular expressions,
which match the same matched string.

  my $sar = Regexp::SAR->new;
  $sar->addRegexp('1', sub { print "one found\n"; });
  $sar->addRegexp('\d', sub { print "digit found\n"; });
  $sar->match('1');

The above code will print both 'one found' and 'digit found'

=back

=head1 Character class abbreviations

=over

=item *

'.' matches any character

=item *

'\s' matches space character (checked by internal isSPACE)

=item *

'\d' matches digit character (checked by internal isDIGIT)

=item *

'\w' matches alphanumeric character (checked by internal isALNUM)

=item *

'\a' matches alpha character (checked by internal isALPHA)

=item *

'\^' matches any character that is not followed character or class abbreviation

=back

=head1 Matching repetitions

=over

=item *

'?' means: match 1 or 0 times

=item *

'*' means: match 0 or more times

=item *

'+' means: match 1 or more times

=back

=head1 '\' escape character

For matching '\' character in matching string regular expression string should
iclude it 4 times '\\\\'.

  my $sar = new Regexp::SAR;
  my $string = 'a b\c d';
  $sar->addRegexp('b\\\\c', sub { print "Matched\n"; });
  $sar->match($string);

=head1 Unicode support

Currently this module does not support Unicode matching

=head1 Examples

Many usage examples can be found in "OOUsage.t" file

=cut



use strict;
use warnings;


require XSLoader;
XSLoader::load( 'Regexp::SAR' );


sub new {
    my $class = shift;

    my $rootNode = Regexp::SAR::buildRootNode();
    return bless \$rootNode, $class;
}

sub addRegexp {
    my ( $rootRef, $regexpStr, $handler ) = @_;
    my $reLength = length $regexpStr;
    unless ($reLength) {
        return;
    }
    Regexp::SAR::buildPath( $$rootRef, $regexpStr, $reLength, $handler );
}

sub match {
    my ( $rootRef, $matchStr ) = @_;
    if (ref $matchStr) {
        Regexp::SAR::lookPathRef( $$rootRef, $matchStr, 0 );
    }
    else {
        Regexp::SAR::lookPath( $$rootRef, $matchStr, 0 );
    }
}

sub matchRef {
    my ( $rootRef, $matchStr ) = @_;
    Regexp::SAR::lookPathRef( $$rootRef, $matchStr, 0 );
}

sub matchFrom {
    my ( $rootRef, $matchStr, $pos ) = @_;
    if (ref $matchStr) {
        Regexp::SAR::lookPathRef( $$rootRef, $matchStr, $pos );
    }
    else {
        Regexp::SAR::lookPath( $$rootRef, $matchStr, $pos );
    }
}

sub matchAt {
    my ( $rootRef, $matchStr, $pos ) = @_;
    Regexp::SAR::lookPathAtPos( $$rootRef, $matchStr, $pos );
}

sub stopMatch {
    my ( $rootRef ) = @_;
    Regexp::SAR::stop($$rootRef);
}

sub continueFrom {
    my ( $rootRef, $from ) = @_;
    Regexp::SAR::continue($$rootRef, $from);
}

sub DESTROY {
    my ( $rootRef ) = @_;
    Regexp::SAR::cleanAll($$rootRef);
}

1;

