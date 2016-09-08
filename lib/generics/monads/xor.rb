require 'generics/type_checker'

module Generics
  # Example
  # Generics::XOR[String, :to_i, Comparable].valid?("test")
  class XOR < Enum
    # Creates an enum that only allows objects of the available types
    # @param [Class, Module, Symbol] left
    # @param [Class, Module, Symbol] right
    # @return [Generics::XOR]
    def self.[](left, right)
      new(left, right)
    end

    # @param [Class, Module, Symbol] left
    # @param [Class, Module, Symbol] right
    def initialize(left, right)
      @left = left
      @right = right
    end

    # Checks if value is valid in the available enum types
    # @param [Object] value
    # @return [True, False]
    def valid?(value)
      TypeChecker[@left].valid?(value) ^ TypeChecker[@right].valid?(value)
    end
  end
end
