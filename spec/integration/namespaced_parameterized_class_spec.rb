require 'spec_helper'

describe Kindah do
  before :all do
    module TestModule; end
    Kindah.class_template! :Test, location: TestModule do
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
  end

  subject(:test_instance) { TestModule::Test(1).new }

  it { should respond_to :bar }
  it { should respond_to :foo_instance }
  it { should respond_to :ivar }

  its(:ivar) { should == 1 }

  its(:class) { should respond_to :bar }
  its(:class) { should respond_to :foo_class }
end
