package Google::CSE;

use warnings;
use strict;
use XML::Simple;
use Carp;
use LWP::UserAgent;
use Data::Dumper;

use URI::QueryParam;

=head1 NAME

Google::CSE - Interface to Google Custom Search Engine

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

sub new {
    my ($self, %param) = @_;
    
    croak "Required parameter 'query' is missing" 
        unless $param{query};
        
    croak "Required parameter 'cx' is missing" 
        unless $param{cx};
    
    # Set default values
    
    # Page
    $param{page} ||= 1;
    
    # Items on page
    $param{num}  ||= 10;
    
    # Cursor to current search index (starts from 1)
    my $start_index = $param{num} * ($param{page} - 1) + 1;
        
    $self = {
        request_params => {
            query   => $param{query},
            cx      => $param{cx},
            page    => $param{page},
            num     => $param{num},
            start   => $start_index,
            client  => 'google-csbe',
            output  => 'xml_no_dtd',
            ie      => 'utf8',
            oe      => 'utf8',
            filter  => 1,
        },
        options => {
            return_raw_response => $param{return_raw_response} || 0,
        },
        request_url => 'http://www.google.com/search?',
    };
    
    
    bless $self;

    return $self;
}


sub search {
    my $self = shift;
    
    my $ua = LWP::UserAgent->new(
        agent   => 'Google CSE',
        timeout => 10 
    );
    
    # Prepare request params
    my $uri = URI->new("", "http");

    while ( my ($key, $value) = each %{ $self->{request_params} } ) {
        $uri->query_param_append( $key, $value );
    }

    # Prepare request
    my $req = HTTP::Request->new( GET => $self->{request_url} . $uri->query );
    
    warn $req->as_string, "\n";
    
    # Send request
    my $response = $ua->request( $req );
    
    # Got response
    if ( $response ) {
       $self->{response} = $response->content; 
    }
    else {
        croak 'Failed to get response from Google CSE!';
    }
    
}


sub all {
    my $self = shift;
    
    return unless $self->{response};
    
    $self->{search_results} = {};
    
    # Optionally return RAW XML response
    # Sometimes you face problems with deserializing XML, so this option
    # may help in debugging
    if ( $self->{options}->{return_raw_response} ) {
        return $self->{response};
    }
    
    # Deserialize XML in response
    my $data = XMLin($self->{response}, ForceArray => [ 'R' ] );
    
    # Total items found
    if ( $data && ref $data eq 'HASH' && exists $data->{RES}{M} ) {
        $self->{search_results}{count} = $data->{RES}{M};
    }
    else {
        croak 'Error: can not get search results count! Seems like got invalid XML structure in response!';
    }
    
    # Loop though search results and get only required data
    if ( $data->{RES}{R} && ref $data->{RES}{R} eq 'ARRAY' ) {
        foreach my $search_item  ( @{ $data->{RES}{R} } ) {
            push @{ $self->{search_results}{items} },
                {
                    title       => $search_item->{T},
                    description => $search_item->{S},
                    url         => $search_item->{UE},
                }
            ;
        }
    }
    else {
        croak 'Error: can not get search results! Seems like got invalid XML structure in response!';
    }
    
    return $self->{search_results}{items};
}

sub count {
    my $self = shift;
    
    return unless $self->{response};
    
    # We have not called "all" method before so we have no any results
    unless ( exists $self->{search_results} ) {
        # Call it here
        $self->all;
    }

    return $self->{search_results}{count};    
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
        print "Search url: $search_item->{url}\n";
    }

=head1 USAGE


=head2 Google::CSE->new( ... ) 

Prepare a new search object (handle)

You can configure the search by passing the following to C<new>:

    query           The search phrase to submit to Google CSE. Required.
    
    cx              The cx parameter which represents the unique ID of the CSE.
                    
    page            Optional. Return results from C<page> page.
    
    return_raw_response     Optional. Return RAW XML response from CSE.


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

=head2 $search->count
Returns number of items found for last query.
Example:

    use Google::CSE;
    
    # Prepare request
    my $search = Google::CSE->new(
        cx      => 'YOUR_GOOGLE_CUSTOM_SEARCH_ENGINE_ID',
        query   => 'my test query', # Actually your search query
    );
    
    # Do things
    $search->search;
    
    # How many items we have found:
    print "Found $search->count items for query 'my test query'\n";

=head1 AUTHOR

Alexander Nalivayko, C<< <alexander.nal at gmail.com> >>

=head1 BUGS

Know bugs for now:
- C<count> method currentry returns VERY inaccurate number of items found
for the 1st page in set. Workaround is do request with param C<page => 2>,
save number of items and then do search as usual.

But sometimes even this workaround do not work :(

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
