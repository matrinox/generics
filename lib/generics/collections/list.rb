require 'hamster'
require 'generics/type_checker'

module Generics
  class List
    include Enumerable

    # Shared

    class NotSameTypeError < StandardError
    end

    # @param [Class, Module] type
    # @return [Class]
    def self.[](type)
      Class.new(self).tap do |klass|
        klass.instance_variable_set('@type', type)
        klass.define_singleton_method(:name) { klass.superclass.name }
      end
    end

    def self.type
      @type
    end

    def compatible?(value)
      TypeChecker[self.class.type].valid?(value)
    end

    def compatible!(value)
      fail NotSameTypeError unless compatible?(value)
      true
    end

    # Object

    def inspect
      "#<#{self.class.name}[#{self.class.type}]: #{to_s}>"
    end

    def to_s
      @collection.to_a.to_s
    end

    # Enumerable

    def [](index)
      @collection[index]
    end

    def each
      @collection.each { |item| yield item }
      return self
    end

    def map
      self.class.new(super)
    end

    # Array

    # Getters

    def size
      @collection.size
    end

    def length
      @collection.length
    end

    def empty?
      @collection.empty?
    end

    def last
      @collection.last
    end

    def pop
      @collection.pop
    end

    def reverse
      @collection.reverse
    end

    def sample
      @collection.sample
    end

    def slice(*args)
      @collection.slice(*args)
    end

    # Methods that returns self

    def delete_at(index)
      self.class.new(*@collection.delete_at(index))
    end

    def shift
      self.class.new(*@collection.shift)
    end

    def uniq(&block)
      self.class.new(*@collection.uniq(&block))
    end

    # Immutable (default) only

    # @param [Class, Module] type
    def initialize(*collection)
      collection.each { |value| compatible!(value) }
      @collection = ::Hamster::Vector.new(collection)
    end

    # Does not preserve frozen state and does not copy singleton state
    # @return [List]
    def dup
      self.class.new(*@collection.dup)
    end

    # Preserves frozen state and does copies singleton state
    # @return [List]
    def clone
      self.class.new(*@collection.clone)
    end

    # Quick dup; does not duplicate, just relies on immutability
    # @return [List]
    def qdup
      self.class.new(*@collection)
    end

    # Destructive

    def add(value)
      compatible!(value)
      self.class.new(*@collection.add(value))
    end

    def set(index, value, &block)
      compatible!(value)
      self.class.new(*@collection.set(index, value, &block))
    end

    def insert(index, *values)
      values.each { |value| compatible!(value) }
      self.class.new(*@collection.insert(index, *values))
    end

    def delete(value)
      compatible!(value)
      self.class.new(*@collection.delete(value))
    end

    def delete_at(index)
      self.class.new(*@collection.delete_at(index))
    end

    def unshift(value)
      compatible!(value)
      self.class.new(*@collection.unshift(value))
    end

    class Mutable < List
      # @param [Class, Module] type
      def initialize(*collection)
        collection.each { |value| compatible!(value) }
        @collection = collection.freeze
      end

      # Does not preserve frozen state and does not copy singleton state
      # @return [List::Mutable]
      def dup
        self.class.new(*@collection.dup)
      end

      # Preserves frozen state and does copies singleton state
      # @return [List::Mutable]
      def clone
        self.class.new(*@collection.clone)
      end

      # Destructive

      def add(value)
        compatible!(value)
        @collection.push(value)
      end

      def set(index, value, &_block)
        compatible!(value)
        if block_given?
          @collection[index] = yield @collection[index]
        else
          @collection[index] = value
        end
      end

      def []=(index, value)
        compatible!(value)
        @collection[index] = value
      end

      def insert(index, *values)
        values.each { |value| compatible!(value) }
        self.class.new(*@collection.insert(index, *values))
      end

      def delete(value)
        compatible!(value)
        @collection.delete(value)
      end

      def delete_at(index)
        @collection.delete_at(index)
      end

      def unshift(value)
        compatible!(value)
        self.class.new(*@collection.unshift(value))
      end
    end
  end
end
