require "kindah/version"

require 'katuv'
require 'forwardable'
require 'singleton'

require 'kindah/ast'
require 'kindah/compiler'

module Kindah
  def self.class_template(name, opts={}, &block)
    Kindah::ClassTemplate.new(name, opts.merge(parent: nil), &block)
  end

  def self.class_template!(name, opts={}, &block)
    compile! class_template(name, opts, &block)
  end

  def self.compile!(template)
    Kindah::Compiler.new(template).compile!
  end
end
