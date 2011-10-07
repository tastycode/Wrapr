Wrapr
====

Modify class behavior at runtime. Similar to before/after/around filters in Rails ActionController::Base

Example
------

    require 'wrapr' 
    require 'logger'
    log = Logger.new(STDOUT)

    Wrapr::Wrapr.new(Exception).before(:initialize) do |this,*args|
      log.debug("New exception is being created "+args.inspect)
      args
    end

  5/0 # we can hijack any class's instance methods and inject our own functionality


Potential Uses
--------------

Use with ruby-debug to set conditional break points

    require 'ruby-debug'
    Wrapr::Wrapr.new(Post).before(:find) do |this,*args|
        # Open debug when a post is instantiated 
        debugger if args[:conditions][:
        args
    end

Use with analytics packages to track application events from a single location

