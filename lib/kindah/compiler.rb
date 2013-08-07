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
      compiler = self # this trick carries the outer scope past ruby's stupid block-scoping rules.

      location.send(:define_method, compiler.class_name) do |*args|
        Kindah::Cache[compiler.class_name, *args] ||= compiler.create_klass_with_args *args
      end

      nil
    end

    def create_klass_with_args(*args)
      compiler = self # this trick carries the outer scope past ruby's stupid block-scoping rules.

      Class.new do
        compiler.install_template_arg_methods(self, *args)
        compiler.install_class_methods(self)
        compiler.install_instance_methods(self)
      end
    end

    def install_template_arg_methods(target, *args)
      each_parameter do |name, idx|
        target.define_singleton_method(name) { args[idx] }
        target.send(:define_method, name) { self.class.send(name) }
      end
    end

    def install_class_methods(target)
      target.instance_eval &class_methods
    end

    def install_instance_methods(target)
      target.class_eval &instance_methods
    end

    private

    def safe_fetch(klass)
      return proc {} unless children.has_key?(klass)
      children[klass].block
    end
  end
end
