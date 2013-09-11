# Rails Disco - A distributed party with commands, events and projections

Rails Disco is a framework on top of the rails framework to provide cqrs and simple event sourcing possibilities to rails.
The framework consists out of three main parts, commands, events and projections.

_Commands_ will be created and executed by actions of your controller, instead of directly manipulating your model. These commands are only the order to do something and after possible validations, the framework executes them by creating an event and finally manipulating the model.

The _events_ will be all stored in a separate database and also published to all projections, where they can be processed to update the projections model/database

Finally _projections_ are your representation of your data, they get the events and process them, to get the needed informations for building up their models.

# Requirements

* At the moment Rails Disco uses [Rails 4](https://github.com/rails/rails). Maybe it works with Rails 3.2, but we didn't test that.

* Because Rails Disco relies on [bunny](https://github.com/ruby-amqp/bunny) for sending the events from the domain to the projection, you need [RabbitMQ](http://www.rabbitmq.com/download.html) on your system.

# Getting Started

1. Rails Disco depends heavily on [RubyOnRails](http://rubyonrails.org/), so you should install that first if you haven't yet.

2. Install Rails Disco at the command prompt 

		gem install rails-disco

3. At the command prompt, create a new Rails Disco application.

		drails new myapp

   where "myapp" is the application name.

   (Note: You can also add Rails Disco to an existing rails application. Simply omit the application name and run the command inside your application.)

4. Change directory to `myapp`, if you haven't yet and migrate the databases:

		cd myapp
		drails rake db:setup

   This will create the two databases domain and projection (for database details look in config/disco.yml)

5. If you just want to look a some standard server output, start the drails server. Else go ahead and skip this point.

		drails server

   This will start the domain, the projection and the standard rails server, but you won't see much of the disco yet.

6. For a humble begin, scaffolding is the way to go. Lets create a simple blog system:

		drails generate scaffold Post title:string text:text

   The syntax is leant to rails' generate style and it basically creates a resource Post with a title and a text attribute.

7. Before we can start, we need to tell rails that we have some shiny new db. Open up config/database.yml and edit the config for your environment (propably development) to the projection database. So basically:

		- ~~database: db/development.sqlite3~~
		+ database: db/projection_dev.sqlite3

8. Now that we have something to rely on, lets see it in action:
	
		drails server

9. Go to http://localhost:3000/posts and you'll see an empty list of our posts with a link to create a new one. Go ahead and create one. If you watch the console output, you can see that an event will be created for the creating of the post and will be published to the projection.

10. If you look at your databases, you see in both of them a table `posts`, which contains your freshly created post. The domain database also contains a table `domain_events`. There you find an event for your post creation. Lets see this in action.

11. Clear your projection database and restart the server. You will see some console output, where the projection is requesting the missing posts from the domain and there you have your projection database complete again.

12. Thats it for now, have fun with it. For more informations take a look at the [wiki](https://github.com/hicknhack-software/rails-disco/wiki)