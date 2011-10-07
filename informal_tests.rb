  # These examples  written for samples of code in the documentation 

  $: << File.dirname(__FILE__)+"/lib"
  require 'wrapr' 
  require 'logger'
  log = Logger.new(STDOUT)



  
   w = Wrapr::Wrapr.new(Exception)
   # #before can mutate the instance and args as well
   w.before(:initialize) do |this,*args|
     args[0].upcase!
     args
   end
   puts Exception.new("foo").to_s # FOO
   w.around(:to_s) do |this,method,*args|
     puts "Before to_s" 
     result = method.call() 
     result+=" "
  end
  puts Exception.new("foo").to_s  # FOO, "Before to_s OOF "
  w.after(:to_s) do |this,result|
    result.downcase
  end
  puts Exception.new("foo").to_s  # FOO, "Before to_s foo"

  Wrapr::Wrapr.new(Exception).before(:initialize) do |this,*args|
    log.debug("New exception is being created "+args.inspect)
    args
  end

  5/0
