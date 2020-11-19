=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2020] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package Bio::EnsEMBL::Production::Pipeline::FileDump::README;

use strict;
use warnings;
use base ('Bio::EnsEMBL::Production::Pipeline::FileDump::Base');

use File::Spec::Functions qw/catdir/;

sub param_defaults {
  my ($self) = @_;

  return {
    %{$self->SUPER::param_defaults},
    root_readmes => ['README'],
  };
}

sub run {
  my ($self) = @_;
  my $root_readmes  = $self->param_required('root_readmes');
  my $data_category = $self->param_required('data_category');
  my $output_dir    = $self->param_required('output_dir');

  my $relative_dir;
  if ($data_category eq 'geneset') {
    $relative_dir = catdir('..', '..', '..', '..', '..');
  } else {
    $relative_dir= catdir('..', '..', '..', '..');
  }

  foreach my $readme (@$root_readmes) {
    my $from = catdir($relative_dir, $readme);
    unless (-e catdir($output_dir, $from)) {
      $self->throw("README does not exist: $output_dir/$from");
    }
    my $to = catdir($output_dir, $readme);

    $self->create_symlink($from, $to);
  }
}

1;
