module Kindah
  class Compiler
    extend Forwardable

    def initialize(ast)
      @ast = ast
    end

    def class_methods
      safe_fetch ClassMethods
    end

    def instance_methods
      safe_fetch InstanceMethods
    end

    delegate [:arity, :block, :children] => :@ast
    def class_name
      @ast.name
    end

    def each_parameter
      class_methods.parameters.each.with_index do |(_, name), idx|
        yield name, idx if block_given?
      end
    end

    def compile!(location = Object)
      compiler = self

      location.send(:define_method, class_name) do |*args|
        Class.new do
          compiler.each_parameter do |name, idx|
            define_singleton_method(name) { args[idx] }
            define_method(name) { self.class.send(name) }
          end

          #because ruby is weird...
          instance_eval &compiler.class_methods
          class_eval &compiler.instance_methods
        end
      end

      nil
    end

    private

    def safe_fetch(klass)
      return proc {} unless children.has_key?(klass)
      children[klass].block
    end
  end
end
