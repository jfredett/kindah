# kindah [![Gem Version](https://badge.fury.io/rb/kindah.png)](http://badge.fury.io/rb/kindah)[![Build Status](https://travis-ci.org/jfredett/kindah.png?branch=master)](http://travis-ci.org/jfredett/kindah)[![Code Climate](https://codeclimate.com/github/jfredett/kindah.png)](https://codeclimate.com/github/jfredett/kindah)[![Coverage Status](https://coveralls.io/repos/jfredett/kindah/badge.png?branch=master)](https://coveralls.io/r/jfredett/kindah)

Kindah is an implementation of Parameterized Classes for Ruby.

Kindah is unreleased, pre-alpha software, use at your own risk, not all of this
readme may be implemented fully, but it expresses the direction of the project.

## Description

A parameterized class is a 'higher order' class, it's similar to (but definitely
not equivalent or as powerful as) a dependently-typed class. If you're familiar
with type theory (and particularly with haskell), it's analogous to a 'kind',
but one rank lower. So whereas a rank-2 type is the 'type of types' and is built
of types and other 'kinds' (ie, rank-1 and rank-2 types), these parameterized
classes occupy some of the same space as dependent types (ie, rank-1 types which
are parameterized by rank-0 types (that is, values)).

This library is not a rigorous implementation of any type system, it's merely
inspired by the concept, and built for a very specific purpose. The static
injection pattern.

### Static Injection

Static injection is a type of dependency injection which happens once, generally
at compile-time, or at interpretation/loading time for interpeted languages.
Compared with setter/constructor injection, this is more akin to setter
injection, but where the setter is promoted to the class itself. This is useful
particularly where you need multiple versions of the same class which have
different 'engines' which drive them. A motivating example is an Indexing
interface for a database. Consider


    class Index
      attr_reader :indexing_engine

      def initialize(indexing_engine = DefaultIndexingEnging)
        @indexing_engine = indexing_engine.new
      end

      def insert(data)
        indexing_engine.insert(data)
      end

      #snip
    end

    #later

    Index.new(BTree)

Here, we use constructor injection to manage which indexing engine to use,
however, this leaks the abstraction to an inappropriate place, it should never
be possible to change the engine after it's been chosen the first time. In
particular it expresses the wrong relationship. An index does not _have a_
engine, an index, in some sense, _is it's_ engine. That is, a BTree Index _is_
a BTree, with some pleasant interface adhered to it. Similarly, a Hash Index
_is_ fundamentally a hashtable, with the _same pleasant interface_.

One method for accomplishing this type of abstraction in ruby is via modules,
but Modules ought to expose cross-cutting functionality and ought to bear no
statefullness of their own, and in the case of Index, there is a fair amount of
desire to include some statefulness. Further, an aesthetic desire exists to
invert this relationship to better express the dominant status of the _Index_
over it's _Engine_. The solution that Kindah offers looks something like this:

     parameterized_class :Index do |engine|
       def indexing_engine
         @engine ||= engine.new
       end

       def insert(data)
         indexing_engine.insert(data)
       end

       #snip
     end

     #later

     Index(BTree).new

So, looking at that last line, you're probably thinking, "Okay, so what? You
moved the BTree bit to the left." Yes. Precisely, I've also imposed a set of
restrictions and implemented some pleasant features for talking about
`Index(BTree)` as a type in it's own right. For instance,
`Index(BTree).new.is_a? Index` will return `true`, but `Index(BTree).new.is_a?
Index(HashTable)` will return `false`. Similarly, depending on defaults provided
to the above block, `Index` will be an instantiable class. 


### Other uses

In this way you can hopefully see how to use this to manage some basic
dependency injection problems, however, Kindah lends itself to other uses, one
of the chief uses is metaprogramming based on values (rather than classes).

Consider the implementation of a classic Dependent Type, the finite vector.

A Vector is a list of length `n` with `O(1)` access to any element of the list
for read or write, and at most `O(n)` memory use. A simple implementation in
ruby is to metaprogram `n` 'slots' into a class, and wrap them in an interface
so that the usual `#[]` and `#[]=` operations work as expected, with bounds
checking and the like.

An implementation follows using pure ruby and using Kindah.

    #pure ruby
    class Vector
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def [](slot)
        bounds_check! slot
        instance_variable_get("@slot_#{slot}")
      end

      def []=(slot, value)
        bounds_check! slot
        instance_variable_set("@slot_#{slot}", value)
      end

      private

      def bounds_check!(value)
        0 <= value && value < order
      end
    end

    #usage

    v = Vector.new(2)
    v[0] = :test_value
    v[1] = :please_ignore

    v[0] #=> :test_value

    #with kindah

    parameterized_class :Vector do |size|
      def order
        size
      end

      def [](slot)
        bounds_check! slot
        instance_variable_get("@slot_#{slot}")
      end

      def []=(slot, value)
        bounds_check! slot
        instance_variable_set("@slot_#{slot}", value)
      end

      private

      def bounds_check!(value)
        0 <= value && value < order
      end
    end

    v = Vector(2).new
    v[0] = :test_value
    v[1] = :please_ignore

    v[0] #=> :test_value

So... what's the difference? It's basically the same, arguably the latter is
more complicated.

Well, there are a couple advantages beyond the aesthetic API the latter
provides. First, in the former, we have to allocate some extra storage for the
order, whereas in the latter it's hardcoded (via metaprogramming) into the class
proper. Second, imagine an implementation of dot-product, which requires the two
vectors to be of the same length. In the former, we must examine orders
directly, eg:

    class Vector
      def dot(other)
        raise unless order == other.order
        #impl
      end
    end

In the latter case, we can check the class, which is only the same if the two
instances were created via the same `Vector(n)` function, eg:

    parameterized_class :Vector do |order|
      def dot(other)
        raise unless other.is_a?(self.class)
        #impl
      end
    end

This becomes more valuable when you have a few of these parameters to throw
around, for instance, imagine a `n x m` matrix class. In pure ruby, if you want
to add two instances together, you must first ensure that it matches both width
and height, with a kindah-based parameterized class, you can simply compare that
the classes are the same. Essentially, it's poor man's type checking.

## Installation

Add this line to your application's Gemfile:

    gem 'kindah'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kindah

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
