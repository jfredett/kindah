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

    def parameter_block(target, *args)
      each_parameter do |name, idx|
        target.define_singleton_method(name) { args[idx] }
        target.send(:define_method, name) { self.class.send(name) }
      end
    end

    def compile!(location = Object)
      compiler = self

      location.send(:define_method, compiler.class_name) do |*args|
        Kindah::Cache[compiler.class_name, *args] ||= Class.new do
          compiler.parameter_block(self, *args)

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
