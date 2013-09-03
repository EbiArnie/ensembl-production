=pod

=head1 LICENSE

  Copyright (c) 1999-2012 The European Bioinformatics Institute and
  Genome Research Limited.  All rights reserved.

  This software is distributed under a modified Apache license.
  For license details, please see

    http://www.ensembl.org/info/about/code_licence.html

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <dev@ensembl.org>.

  Questions may also be sent to the Ensembl help desk at
  <helpdesk@ensembl.org>.

=head1 NAME

Bio::EnsEMBL::Production::Pipeline::Flatfile::CheckFlatfile

=head1 DESCRIPTION

Takes in a file and passes it through BioPerl's SeqIO parser code. This
is just a smoke test to ensure the files are well formatted.

Allowed parameters are:

=over 8

=item file - The file to parse

=item type - The format to parse

=back

=cut

package Bio::EnsEMBL::Production::Pipeline::Flatfile::CheckFlatfile;

use strict;
use warnings;

use Bio::SeqIO;
use File::Spec;

use base qw/Bio::EnsEMBL::Production::Pipeline::Flatfile::Base/;

use Bio::EnsEMBL::Production::Pipeline::Flatfile::ValidatorFactoryMethod;

sub fetch_input {
  my ($self) = @_;

  $self->throw("No 'species' parameter specified") unless $self->param('species');
  $self->throw("No 'type' parameter specified") unless $self->param('type');

  return;
}

sub run {
  my ($self) = @_;

  my $dir = $self->data_path();
  opendir(my $dh, $dir) or die "Cannot open directory $dir";
  my @files = grep { $_ =~ /\.dat\.gz$/ } readdir($dh);
  closedir($dh) or die "Cannot close directory $dir";

  my $validator_factory = 
    Bio::EnsEMBL::Production::Pipeline::Flatfile::ValidatorFactoryMethod->new();
  my $data_path = $self->data_path();
  my $type = $self->param('type');

  foreach my $file (@files) {
    my $full_path = File::Spec->catfile($data_path, $file);
    my $validator = $validator_factory->create_instance($type);

    $validator->file($full_path);

    my $count = 0;
    eval {
      while ( $validator->next_seq() ) {
	$self->fine("%s: OK", $file);
	$count++;
      }
    };
    $@ and $self->throw("Error parsing $type file $file: $@");

    my $msg = sprintf("Processed %d record(s)", $count);
    $self->info($msg);
    $self->warning($msg);
  }

  return;
}

sub get_fh {
  my ($self, $file) = @_;
  my $data_path = $self->data_path();
  my $full_path = File::Spec->catfile($data_path, $file);
  $self->throw("Cannot find file $full_path") unless -f $full_path;
  $self->throw("File $full_path seems not to be gzipped, as expected")
    if $file !~ /\.gz$/;

  open my $fh, '-|', 'gzip -c -d '.$full_path or die "Cannot open $full_path for gunzip: $!";

  return $fh;
}

1;
