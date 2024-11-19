package Mojolicious::Command::morbo;
use Mojo::Base 'Mojolicious::Command', -signatures;

use Mojo::Server::Morbo;
use Mojo::Util qw(extract_usage getopt);

has description => 'Show versions of available modules';
has usage       => sub { shift->extract_usage };

sub run ($self, @args) {
  $self->app->log->warn('Switching to morbo');
  getopt \@args,
    'b|backend=s' => \$ENV{MOJO_MORBO_BACKEND},
    'h|help'      => \my $help,
    'l|listen=s'  => \my @listen,
    'm|mode=s'    => \$ENV{MOJO_MODE},
    'v|verbose'   => \my $verbose,
    'w|watch=s'   => \my @watch;

  die extract_usage if $help || !(my $app = $0);
  my $morbo = Mojo::Server::Morbo->new(silent => !$verbose);
  if (my $listen = $self->app->config->{morbo}->{listen} || $self->app->config->{listen}) {
    @listen = @$listen unless @listen;
  }
  $morbo->daemon->listen(\@listen) if @listen;
  $morbo->backend->watch(\@watch)  if @watch;
  $morbo->run($app);
}

1;