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
        # whose attribute "body" contains scrooge
        debugger if args[:body] =~ /scrooge/
        args
    end


Wrap existing classes in logging functionality 
Mirror object modifications?
    
    # given there is a post class in active record

    w = Wrapr::Wrapr.new(Post)
    w.after(:save) do |this,*args|
      if this.new?
        SomeAlternateDatabaseModel.new(this.attributes).save 
      else
        SomeAlternateDatabaseModel.find(this.id).update_attributes(this.attributes)
      end
    end
