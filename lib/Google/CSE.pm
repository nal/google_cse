package Google::CSE;

use warnings;
use strict;
use XML::Simple;
use Carp;
use LWP::UserAgent;
use Data::Dumper;

use URI;
#use URI::QueryParam;


=head1 NAME

Google::CSE - Interface to Google Custom Search Engine

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

sub new {
    my ($self, %param) = @_;
    
    croak "Required parameter 'query' is missing" 
        unless $param{query};
        
    croak "Required parameter 'cx' is missing" 
        unless $param{cx};
        
    $self = {
        query   => $param{query},
        cx      => $param{cx},
        page    => $param{page} || 1
    };
    
    
    bless $self;

    return $self;
}


sub search {
    my $self = shift;
    
    return $self;   
    
}


sub all {
    my $self = shift;
    
    return $self;   
}


=head1 SYNOPSIS

Interface to Google Custom Search Engine XML API.

Its documentation is located here: L<http://www.google.com/cse/docs/resultsxml.html>

Please also check out information about Google CSE here:
L<http://www.google.com/cse/docs/>

In order to use this module you have to create your custom search engine here:
L<http://www.google.com/cse/> and obtain your unique custom search engine
identifier.

It is passed as C<cx> parameter to C<new> method.

The most commonly used request parameters are:

C<num> - the requested number of search results

C<q> - the search term(s)

C<start> - the starting index for the results


    use Google::CSE;
    
    # Prepare request
    my $search = Google::CSE->new(
        cx      => 'YOUR_GOOGLE_CUSTOM_SEARCH_ENGINE_ID',
        query   => 'my test query', # Actually your search query
    );
    
    # Do things
    $search->search;
    
    # Get results
    while my $search_item ( $search->all ) {
        print "Search title: $search_item->{title}\n";
        print "Search description: $search_item->{description}\n";
        print "Search link: $search_item->{link}\n";
    }

=head1 USAGE


=head2 Google::CSE->new( ... ) 

Prepare a new search object (handle)

You can configure the search by passing the following to C<new>:

    query           The search phrase to submit to Google CSE. Required.
    
    cx              The cx parameter which represents the unique ID of the CSE.
                    
    page            Optional. Return results from C<page> page.


Both C<query> and C<cx> are required

=head2 $search->search

Do actual request to Google.

=head2 $search->all

Returns array reference of hash references which includes every result Google has returned for the query on current "page".
Example of such structure for query "perl":

    [
        {
            title       => 'The Perl Programming Language - www.perl.org',
            description => 'The Perl Programming Language at Perl.org. Links and other helpful resources for new and experienced Perl programmers.',
            link        => 'http://www.perl.org'
        },
        {
            title       => 'Download Perl - www.perl.org',
            description => 'Perl runs on over 100 platforms. The latest version (5.12.3) is recommended ...',
            link        => 'http://www.perl.org/get.html'
        },
        ...
    ]

An empty list is returned if nothing was found.

=head1 AUTHOR

Alexander Nalivayko, C<< <alexander.nal at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<alexander dot nal at gmail dot com>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Google::CSE


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alexander Nalivayko.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Google::CSE
