require "kindah/version"

require 'katuv'

require 'kindah/ast'
require 'kindah/compiler'

module Kindah
  def class_template(name, opts={}, &block)
    template = Kindah::ClassTemplate.new(name, opts.merge(parent: nil), &block)
  end

  def class_template!(name, opts={}, &block)
    compile! class_template(name, opts, &block)
  end

  def compile!(template)
    Kindah::Compiler.new(template).compile!
  end
end
