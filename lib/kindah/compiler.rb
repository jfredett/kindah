module Kindah
  class Compiler
    extend Forwardable

    def initialize(ast)
      @ast = ast
    end

    def class_methods
      @ast.children[ClassMethods].block
    end

    def instance_methods
      @ast.children[InstanceMethods].block
    end

    delegate [:arity, :block] => :@ast
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
  end
end
