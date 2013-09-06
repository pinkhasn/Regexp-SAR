package Regexp::SAR;

use strict;
use warnings;


our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Regexp::SAR', $VERSION);

sub new {
  my $class = shift;

  my $rootNode = Regexp::SAR::buildRootNode();
  return bless \$rootNode, $class;
}


sub addRegexp {
  my ($rootRef, $regexpStr, $handler) = @_;
  unless ( length $regexpStr )
    {
      return;
    }
  Regexp::SAR::buildPath($$rootRef, $regexpStr, $handler);
}


sub match {
  my ($rootRef, $matchStr) = @_;
  Regexp::SAR::lookPath($$rootRef, $matchStr);
}






sub DESTROY {
  my ($rootRef) = @_;

  Regexp::SAR::cleanAll($$rootRef);
}



1;


__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Regexp::SAR - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Regexp::SAR;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Regexp::SAR, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Pinkhas Nisanov, E<lt>pinkhasn@(none)E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Pinkhas Nisanov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
