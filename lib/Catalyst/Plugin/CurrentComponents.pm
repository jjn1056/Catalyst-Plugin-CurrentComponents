package Catalyst::Plugin::CurrentComponents;

use Moose::Role;
use Scalar::Util ();

requires 'model', 'view', 'stash';

our $VERSION = '0.004';

has 'model_instance_from_return' => (
  is=>'ro',
  isa=>'Bool',
  lazy=>1,
  builder=>'_build_model_instance_from_return');

  sub _build_model_instance_from_return {
    if(my $config = shift->config->{'Plugin::CurrentComponents'}) {
      return exists $config->{model_instance_from_return} ? $config->{model_instance_from_return} : 0;
    } else {
      return 0;
    }
  }

sub current_model {
  my ($self, $model) = @_;
  return unless ref $self;
  if(defined($model)) {
    $self->stash->{current_model} = $model;
  }
  return $self->stash->{current_model};
}

sub current_model_instance {
  my ($self, $model, @args) = @_;
  return unless ref $self;
  if(defined($model)) {
    $model = $self->model($model, @args) unless ref $model;
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
  my ($self, $view, @args) = @_;
  return unless ref $self;
  if(defined($view)) {
    $view = $self->view($view, @args) unless ref $view;
    $self->stash->{current_view_instance} = $view;
  }
  return $self->stash->{current_view_instance};
}

around 'execute', sub {
  my ($orig, $self, $class, $code, @rest ) = @_;
  my $state = $self->$orig($class, $code, @rest);

  if(
    defined $state &&
    Scalar::Util::blessed($state) &&
    $self->model_instance_from_return
  ) {
    $self->current_model_instance($state);
  }

  return $state;
};

around 'model', sub {
  my ($orig, $self, $name, @args) = @_;
  if(!defined($name) && ref($self)) {
    if(
      !defined($self->stash->{current_model_instance}) &&
      $self->controller->can('current_model_instance')
    ) {
      $self->current_model_instance(
        $self->controller->current_model_instance($self));
    } elsif(
      !defined($self->stash->{current_model}) &&
      $self->controller->can('current_model')
    ) {
      $self->current_model($self->controller->current_model($self));
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
      $self->current_view_instance(
        $self->controller->current_view_instance($self));
    } elsif(
      !defined($self->stash->{current_view}) &&
      $self->controller->can('current_view')
    ) {
      $self->current_view($self->controller->current_view($self));
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

You may also enable a global option to set the current_model_instance via the
return value of a match method.  See L</CONFIGURATION>

Please Seee documention about Views and Models in L<Catalyst>.

=head1 METHODS

This plugin adds the following methods to your context.

=head2 current_model

Sets $c->stash->{current_model} if an argument is passed.  Always returns the
current value of this stash key.  Expects the string name of a model.

=head2 current_model_instance

Sets $c->stash->{current_model_instance} if an argument is passed.  Always returns the
current value of this stash key.  Expects either the instance of an already created
model or can accept arguments that can be validly submitted to $c->model.

=head2 current_view

Sets $c->stash->{current_view} if an argument is passed.  Always returns the
current value of this stash key.  Expects the string new of a view.

=head2 current_view_instance

Sets $c->stash->{current_view_instance} if an argument is passed.  Always returns the
current value of this stash key.  Expects either the instance of an already created
view or can accept arguments that can be validly submitted to $c->view.

=head1 CONFIGURATION

This plugin supports configuration under the "Plugin::CurrentComponents" key.
For example:

    MyApp->config(
      'Plugin::CurrentComponents' => {
        model_instance_from_return => 1,
      },
    );

=head2 model_instance_from_return

Allows one to set the current_model_instance from the return value of a matched
action.  Please note this is an experimental option which is off by default.
The return value must be a defined, blessed objected for this behavior to take
place.

=head1 AUTHOR

John Napiorkowski L<email:jjnapiork@cpan.org>
  
=head1 SEE ALSO
 
L<Catalyst>, L<Catalyst::Response>

=head1 COPYRIGHT & LICENSE
 
Copyright 2015, John Napiorkowski L<email:jjnapiork@cpan.org>
 
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
 
=cut
