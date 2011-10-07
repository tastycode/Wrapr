require "wrapr/version"

module Wrapr

  


  # Allows method wrapping
  #
  # Usage
  #   w = Wrapr::Wrapr.new(Exception)
  #   # #before can mutate the instance and args as well
  #   w.before(:initialize) do |this,*args|
  #     args[0].upcase!
  #     args
  #   end
  #   puts Exception.new("foo").to_s # FOO
  #   w.around(:to_s) do |this,method,*args|
  #     puts "Before to_s" 
  #     result = method.call() 
  #     result+=" "
  #  end
  #  puts Exception.new("foo").to_s  # FOO, "Before to_s OOF "
  #  w.after(:to_s) do |this,result|
  #    result.downcase
  #  end
  #  puts Exception.new("foo").to_s  # FOO, "Before to_s foo"

  class Wrapr
    def initialize(klass)
      @klass=klass 
    end
    # Executes block around
    # Call of wrapped method is responsibility of the passed block
    #
    # Transparently 
    #
    #   Wrapr.new(Exception).around(:to_s) { |self,method,*outer_args|
    #     method.call(*outer_args) 
    #   }
    def around(method,&block)
      # fetch the unbound instance method
      unbound = @klass.instance_method(method)
      @klass.class_eval do 
        # create a new method with the same name
        define_method(method) do |*outer_args|
          # we pass the current instance and overridden method
          block.call(self,unbound.bind(self),*outer_args)
          # We cannot do self.send(method,...) because we are redefining @method, causes recursion
        end
      end
    end
    # Executes block before method is called
    # Passes the return of the block to method
    #
    # Transparent before
    #
    #   Wrapr.new(Exception).before(:to_s) { |self,*outer_args| 
    #     return outer_args  
    #   }
    def before(method,&block)
      unbound = @klass.instance_method(method)
      @klass.class_eval do
        define_method(method) do |*outer_args|
          unbound.bind(self).call(*block.call(self,*outer_args)) 
        end
      end
    end
    # Executes block after method is called
    # Passes the response of method into block
    # 
    # Transparent after
    #
    #   Wrapr.new(Exception).after(:to_s) do |self,*result|
    #     return result
    #   end
    def after(method,&block)
      unbound = @klass.instance_method(method)
      @klass.class_eval do
        define_method(method) do |*outer_args|
          block.call(self, *unbound.bind(self).call(*outer_args))
        end
      end
    end
  end
end
