require 'wrapr'
describe Wrapr::Wrapr do
  before do
    class Foo
      attr_accessor :stack
      def initialize
        @stack = [:initialize]
      end
      def instance_m
        @stack.push([:instance_m])
      end
      def instance_m_arg(x)
        @stack.push x
      end
      def self.static_m(stack,item)
        stack << item
      end
    end
    @wrapper = Wrapr::Wrapr.new(Foo)
  end
  context "around"  do
    it "wraps something around a method" do
      @wrapper.around(:instance_m) do |this,method,*args|
        this.stack << :around_before
        method.call(*args)
        this.stack << :around_after
      end
      instance = Foo.new
      instance.instance_m
      instance.stack.should include(:around_before,:around_after)
    end
    it "even works with arguments" do
      @wrapper.around(:instance_m) do |this,method,a,b|
        this.stack << a << b
        method.call()
      end
      instance = Foo.new
      instance.instance_m(:argument_one,:argument_two)
      instance.stack.should include(:argument_one,:argument_two)
    end
    it "even works with layers of arguments" do
      @wrapper.around(:instance_m_arg) do |this,method,a,b|
        this.stack.push(b)
        method.call( (a.to_s+b.to_s).to_sym )
      end
      instance = Foo.new
      instance.instance_m_arg(:argument_one, :argument_two) 
      instance.stack.should_not include(:argument_one)
      instance.stack.should include(:argument_oneargument_two)
    end
  end
  context "before" do
    it "passes through arguments to a method" do
      @wrapper.before(:instance_m_arg) do |this,x|
        x.to_s
      end
      instance = Foo.new
      instance.instance_m_arg(:argument)
      instance.stack.should include("argument")
    end
    it "works transparently" do
      @wrapper.before(:instance_m) do |this,*args|
        this.stack.shift
        args
      end
      instance = Foo.new
      instance.instance_m
      instance.stack.should_not include(:initialize)
    end
  end
  context "after" do
    it "passes return values into block" do
      @wrapper.after(:instance_m) do |this,result|
        result.to_s.upcase 
      end
      instance = Foo.new
      instance.instance_m.should == "INITIALIZE"
    end
  end
  it "works with static methods"
end
