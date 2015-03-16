package Catalyst::Plugin::CurrentComponents;

use Moose::Role;

requires 'model', 'view', 'stash';

our $VERSION = '0.001';

sub current_model {
  my ($self, $model) = @_;
  return unless ref $self;
  if(defined($model)) {
    $self->stash->{current_model} = $model;
  }
  return $self->stash->{current_model};
}

sub current_model_instance {
  my ($self, $model) = @_;
  return unless ref $self;
  if(defined($model)) {
    $self->stash->{current_model_instance} = $model;
  }
  return $self->stash->{current_model_instance};
}

sub current_view {
  my ($self, $view) = @_;
  return unless ref $self;
  if(defined($view)) {
    $self->stash->{current_view} = $view;
  }
  return $self->stash->{current_view};
}

sub current_view_instance {
  my ($self, $view) = @_;
  return unless ref $self;
  if(defined($view)) {
    $self->stash->{current_view_instance} = $view;
  }
  return $self->stash->{current_view_instance};
}

around 'model', sub {
  my ($orig, $self, $name, @args) = @_;
  if(!defined($name) && ref($self)) {
    if(
      !defined($self->stash->{current_model_instance}) &&
      $self->controller->can('current_model_instance')
    ) {
      my $model = $self->controller->current_model_instance($self);
      $self->stash->{current_model_instance} = $model if defined($model);
    } elsif(
      !defined($self->stash->{current_model}) &&
      $self->controller->can('current_model')
    ) {
      my $model = $self->controller->current_model($self);
      $self->stash->{current_model} = $model if defined($model);
    }
  }
  return $self->$orig($name, @args);
};

around 'view', sub {
  my ($orig, $self, $name, @args) = @_;
  if(!defined($name) && ref($self)) {
    if(
      !defined($self->stash->{current_view_instance}) &&
      $self->controller->can('current_viewl_instance')
    ) {
      my $view = $self->controller->current_view_instance($self);
      $self->stash->{current_view_instance} = $view if defined($view);
    } elsif(
      !defined($self->stash->{current_view}) &&
      $self->controller->can('current_view')
    ) {
      my $view = $self->controller->current_view($self);
      $self->stash->{current_view} = $view if defined($view);
    }
  }
  return $self->$orig($name, @args);
};

1;

=head1 NAME

Catalyst::Plugin::CurrentComponents - Declare current components more easily.

=head1 SYNOPSIS

Use the plugin in your application class:

    package MyApp;
    use Catalyst 'CurrentComponents';

    MyApp->setup;

Then you can use it in your controllers:

    package MyApp::Controller::Example;

    use base 'Catalyst::Controller';

    sub current_model_instance {
      my ($self, $c) = @_;
      return $c->model("Form::Login", user_database => $c->model('Users'));
    }

    sub myaction :Local {
      my ($self, $c) = @_;
      my $c->model; # Isa 'MyApp::Model::Form::Login', or whatever that returns;
    }

=head1 DESCRIPTION

This plugin gives you an alternative to setting the current_view|model(_instance)
via a controller method or via context helper methods.  You may find this a
more readable approach than setting it via the stash.

Please Seee documention about Views and Models in L<Catalyst>.

=head1 METHODS

This plugin adds the following methods to your context.

=head2 current_model

Sets $c->stash->{current_model} if an argument is passed.  Always returns the
current value of this stash key

=head2 current_model_instance

Sets $c->stash->{current_model_instance} if an argument is passed.  Always returns the
current value of this stash key

=head2 current_view

Sets $c->stash->{current_view} if an argument is passed.  Always returns the
current value of this stash key

=head2 current_view_instance

Sets $c->stash->{current_view_instance} if an argument is passed.  Always returns the
current value of this stash key

=head1 AUTHOR

John Napiorkowski L<email:jjnapiork@cpan.org>
  
=head1 SEE ALSO
 
L<Catalyst>, L<Catalyst::Response>

=head1 COPYRIGHT & LICENSE
 
Copyright 2015, John Napiorkowski L<email:jjnapiork@cpan.org>
 
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
 
=cut
