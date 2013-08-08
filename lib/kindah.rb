require "kindah/version"

require 'katuv'
require 'forwardable'
require 'singleton'

require 'kindah/ast'
require 'kindah/cache'
require 'kindah/compiler'

module Kindah
  def self.class_template(name, opts={}, &block)
    Kindah::ClassTemplate.new(name, opts.merge(parent: nil), &block)
  end

  def self.class_template!(name, opts={}, &block)
    compile! class_template(name, opts, &block), opts.delete(:location) || Object
  end

  def self.compile!(template, location = Object)
    Kindah::Compiler.new(template).compile!(location)
  end
end
