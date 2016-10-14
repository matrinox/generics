require 'immutable'
require 'generics/type_checker'

module Generics
  class List
    include SharedEnumerable
    include SharedList

    class NotSameTypeError < StandardError
    end

    def self.new(*args)
      Immutable.new(*args)
    end

    # Return a list of objects of the same type
    # @param [Class, Module, Symbol] type
    # @return [Class] subclass of Generics::List
    def self.[](type)
      Class.new(self).tap do |klass|
        klass.instance_variable_set('@type', type)
        klass.instance_variable_set('@type_checker', TypeChecker[type])
        klass.define_singleton_method(:name) { klass.superclass.name }
      end
    end

    # @return [Class, Module, Symbol] type
    def self.type
      @type
    end

    # @return [TypeChecker] type_checker
    def self.type_checker
      @type_checker
    end

    # @param [Object] value
    # @return [True, False]
    def compatible?(value)
      self.class.type_checker.valid?(value)
    end

    # @param [Object] value
    # @raise [NotSameTypeError] value is not of the correct type
    # @return [True, False]
    def compatible!(value)
      fail NotSameTypeError, value unless compatible?(value)
      true
    end

    # @!group Object

    # @return [String]
    def inspect
      "#<#{self.class.name}[#{self.class.type}]: #{to_s}>"
    end

    # @return [String]
    def to_s
      @collection.to_a.to_s
    end

    # @!endgroup

    module SharedEnumerable
      def self.included(base)
        base.include Enumerable
      end

      # @param [Integer] index
      # @return [Object]
      def [](index)
        @collection[index]
      end

      # @yield
      # @return [Generics::List]
      def each
        @collection.each { |item| yield item }
        return self
      end

      # @yield
      # @return [Generics::List]
      def map
        self.class.new(super)
      end
    end

    module SharedList
      # @return [Integer]
      def size
        @collection.size
      end

      # @return [Integer]
      def length
        @collection.length
      end

      # @return [True, False]
      def empty?
        @collection.empty?
      end

      # @return [Object]
      def last
        @collection.last
      end

      # @return [Object]
      def sample
        @collection.sample
      end

      # @yield
      # @return [Generics::List]
      def uniq(&block)
        self.class.new(*@collection.uniq(&block))
      end
    end

    class Immutable
      # @param [Array<Object>] collection
      def initialize(*collection)
        collection.each { |value| compatible!(value) }
        @collection = ::Immutable::Vector.new(collection)
      end

      # Does not preserve frozen state and does not copy singleton state
      # @return [Generics::List::Immutable]
      def dup
        self.class.new(*@collection.dup)
      end

      # Preserves frozen state and does copies singleton state
      # @return [Generics::List::Immutable]
      def clone
        self.class.new(*@collection.clone)
      end

      # Quick dup; does not duplicate, just relies on immutability
      # @return [Generics::List::Immutable]
      def qdup
        self.class.new(*@collection)
      end

      # @!group Chainable

      # @param [Object] value
      # @return [Generics::List::Immutable]
      def add(value)
        compatible!(value)
        self.class.new(*@collection.add(value))
      end

      # @param [Object] value
      # @return [Generics::List::Immutable]
      def delete(value)
        compatible!(value)
        self.class.new(*@collection.delete(value))
      end

      # @param [Integer] index
      # @return [Generics::List::Immutable]
      def delete_at(index)
        self.class.new(*@collection.delete_at(index))
      end

      # @param [Integer] index
      # @return [Generics::List::Immutable]
      def insert(index, *values)
        values.each { |value| compatible!(value) }
        self.class.new(*@collection.insert(index, *values))
      end

      # @return [Generics::List::Immutable]
      def pop
        self.class.new(@collection.pop)
      end

      # @return [Generics::List::Immutable]
      def reverse
        self.class.new(@collection.reverse)
      end

      # @param [Integer] index
      # @param [Object] value
      # @yield
      # @return [Generics::List::Immutable]
      def set(index, value, &block)
        compatible!(value)
        self.class.new(*@collection.set(index, value, &block))
      end

      # @return [Generics::List::Immutable]
      def shift
        self.class.new(*@collection.shift)
      end

      # @param [Array] args
      # @return [Generics::List::Immutable]
      def slice(*args)
        self.class.new(@collection.slice(*args))
      end

      # @param [Object] value
      # @return [Generics::List::Immutable]
      def unshift(value)
        compatible!(value)
        self.class.new(*@collection.unshift(value))
      end
    end

    class Mutable < List
      # @param [Array<Object>] collection
      def initialize(*collection)
        collection.each { |value| compatible!(value) }
        @collection = collection.freeze
      end

      # Does not preserve frozen state and does not copy singleton state
      # @return [Generics::List::Mutable]
      def dup
        self.class.new(*@collection.dup)
      end

      # Preserves frozen state and does copies singleton state
      # @return [Generics::List::Mutable]
      def clone
        self.class.new(*@collection.clone)
      end

      # @!endgroup

      # @!group Destructive

      # @param [Integer] index
      # @param [Object] value
      # @return [Generics::List::Immutable]
      def []=(index, value)
        compatible!(value)
        @collection[index] = value
      end

      # @param [Object] value
      # @return [Generics::List::Mutable]
      def add(value)
        compatible!(value)
        @collection.push(value)
      end

      # @param [Object] value
      # @return [Object] same value or nil if not found
      def delete(value)
        compatible!(value)
        @collection.delete(value)
      end

      # @param [Integer] index
      # @return [Object] deleted object
      def delete_at(index)
        @collection.delete_at(index)
      end

      # @param [Integer] index
      # @param [Array<Object>] values
      # @return [Generics::List::Mutable]
      def insert(index, *values)
        values.each { |value| compatible!(value) }
        self.class.new(*@collection.insert(index, *values))
      end

      # @return [Object] value popped
      def pop
        @collection.pop
      end

      # @return [Generics::List::Mutable]
      def reverse
        self.class.new(@collection.reverse)
      end

      # @param [Integer] index
      # @param [Object] value
      # @yield
      # @return [Object] value set
      def set(index, value, &_block)
        compatible!(value)
        if block_given?
          @collection[index] = yield @collection[index]
        else
          @collection[index] = value
        end
      end

      # @return [Object] value shifted
      def shift
        @collection.shift
      end

      # @param [Array] args
      # @return [Generics::List::Mutable]
      def slice(*args)
        self.class.new(@collection.slice(*args))
      end

      # @param [Object] value
      # @return [Generics::List::Mutable]
      def unshift(value)
        compatible!(value)
        self.class.new(*@collection.unshift(value))
      end

      # @!endgroup
    end
  end
end
