require 'spec_helper'

describe Kindah do
  before :all do
    module TestModule; end

    Kindah.class_template! :Test, location: TestModule do
      superclass { Super }

      class_methods do |bar|
        def foo_class
          bar + 1
        end
      end

      instance_methods do
        def foo_instance
          bar + 1
        end

        def initialize
          @ivar = 1
        end

        attr_reader :ivar
      end
    end

    class Super
      def supermethod
        :super
      end
    end
  end

  after :all do
    TestModule.instance_eval { undef Test }
    Object.send(:remove_const, :Super)
    Object.send(:remove_const, :TestModule)
    Kindah::Cache.clear!
  end

  subject(:test_instance) { TestModule::Test(1).new }

  it { should respond_to :bar }
  it { should respond_to :foo_instance }
  it { should respond_to :ivar }

  it { should respond_to :supermethod }
  its(:supermethod) { should == :super }

  its(:ivar) { should == 1 }

  its(:class) { should < Super }
  its(:class) { should respond_to :bar }
  its(:class) { should respond_to :foo_class }
end
