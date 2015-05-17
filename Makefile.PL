use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(NAME	      => 'Pod::Tree',
	      VERSION_FROM    => 'lib/Pod/Tree.pm', # finds $VERSION
	      DISTNAME        => 'Pod-Tree',
	      ($] >= 5.005 ?
	       (ABSTRACT_FROM => 'lib/Pod/Tree.pm',
		AUTHOR        => 'Steven McDougall (swmcd@world.std.com)') : 
	       ()),
	      clean           => { FILES => "t/pod2html.d/*.html* t/pods2html.d/A t/pods2html.d/html_act* t/pods2html.d/podR/HTML t/*/*.act lib/Pod/Tree/*~" },
	      dist            => { COMPRESS => 'gzip --best',
			 	   SUFFIX   => '.gz' },
	      EXE_FILES	      => [qw(mod2html podtree2html pods2html perl2html)],
	      PREREQ_PM       => { File::Find	  => 1,
				   HTML::Stream   => 1.49,
				   IO::File	  => 1,
				   IO::String	  => 1,
	                           Pod::Escapes   => 1.02,
				   Text::Template => 1      },
);
