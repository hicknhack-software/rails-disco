[<img src="https://github.com/hicknhack-software/rails-disco/raw/logo/rails-disco-log.png" alt="Rails Disco Logo" width="200" />](https://github.com/hicknhack-software/rails-disco)
[![Build Status](https://travis-ci.org/hicknhack-software/rails-disco.svg?branch=master)](https://travis-ci.org/hicknhack-software/rails-disco) 
[![Coverage Status](https://coveralls.io/repos/hicknhack-software/rails-disco/badge.png)](https://coveralls.io/r/hicknhack-software/rails-disco)
[![Dependency Status](https://gemnasium.com/hicknhack-software/rails-disco.png)](https://gemnasium.com/hicknhack-software/rails-disco) 
[![Code Climate](https://codeclimate.com/github/hicknhack-software/rails-disco.png)](https://codeclimate.com/github/hicknhack-software/rails-disco)

# Rails Disco - A distributed party with commands, events and projections 

Rails Disco is a framework that extends Rails with support for the best parts of event sourcing.
The framework consists out of three main parts: commands, events and projections.

_Commands_ will be created and executed by actions of your controller, instead of directly manipulating your model. These commands are only the order to do something and after possible validations, the framework executes them by creating an event and finally manipulating the model.

The _events_ will be all stored in a separate database and also published to all projections, where they can be processed to update the projections model/database

Finally _projections_ are your representation of your data, they get the events and process them, to get the needed information for building up their models.

# Requirements

* At the moment Rails Disco uses [Rails 4](https://github.com/rails/rails). Maybe it works with Rails 3.2, but we didn't test that.

* Because Rails Disco relies on [bunny](https://github.com/ruby-amqp/bunny) for sending the events from the domain to the projection, you need [RabbitMQ](http://www.rabbitmq.com/download.html) on your system.

* Any Server which is capable of streaming, e.g. puma or thin (standard Rails server WEBrick will **not** work). If you are facing problems installing puma on Windows, here is a [tutorial](https://github.com/hicknhack-software/rails-disco/wiki/Installing-puma-on-windows).

# Getting Started

1. Install Rails Disco at the command prompt

		gem install rails-disco

1. At the command prompt, create a new Rails Disco application.

		disco new myapp

   where `myapp` is the name of you application.

   (Note: You can also add Rails Disco to an existing Rails application. Simply omit the application name and run the command inside your application.)

1. Change directory to `myapp` and migrate the databases:

		cd myapp
		rake disco:migrate:setup

   This will operate on the Rails (= projection) and the domain database.
   You can configure the domain database and more Rails Disco related configurations in `config/disco.yml`.

1. If you just want to look a some standard server output, start the disco server (Remember to use a server which is capable of streaming, which means not WEBrick). Else go ahead and skip this point.

		disco server

   This will start the domain, the projection and the web server, but you won't see much of the disco yet.

1. For a humble start, let's create the scaffold for a simple blog system:

		disco generate scaffold Post title:string text:text

   The syntax is leaned to Rails' generate style and it basically creates a resource Post with a title and a text attribute.

1. Now that we have something to rely on, lets migrate and see it in action:

	    rake disco:migrate
		disco server

1. Go to [http://localhost:3000/posts](http://localhost:3000/posts) and you'll see an empty list of our posts with a link to create a new one. Go ahead and create one.
   If you watch the console output, you can see that an event is created, published and processed by a projection.

1. If you look at your databases, you see in both of them a table `posts`, which contains your freshly created post.
   The domain database also contains a table `domain_events`. There you find an event for your post creation. Lets see this in action.

1. Clear your projection database and restart the server.

        rake disco:db:drop
        rake disco:migrate
        disco server

   You will see some console output, the projection requests the missing posts from the domain. Finally the state of your projection database will be restored.

1. That's it for now, have fun with it. For more information take a look at the [wiki](https://github.com/hicknhack-software/rails-disco/wiki)
