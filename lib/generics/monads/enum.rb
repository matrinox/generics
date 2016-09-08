require 'generics/type_checker'

module Generics
  # Example
  # Generics::Enum[String, :to_i, Comparable].valid?("test")
  class Enum
    class NotOneOfTypeError < StandardError
    end

    # Creates an enum that only allows objects of the available types
    # @param [Array<Class, Module, Symbol>] options
    # @return [Generics::Enum]
    def self.[](*options)
      new(options)
    end

    # @param [Array<Class, Module, Symbol>] options
    def initialize(options)
      @options = options
    end

    # Checks if value is valid in the available enum types
    # @param [Object] value
    # @return [True, False]
    def valid?(value)
      @options.any? { |type| TypeChecker[type].valid?(value) }
    end

    # Checks if value is valid in the available enum types
    # @param [Object] value
    # @raise [Generics::NotOneOfTypeError]
    # @return [True, False]
    def valid!(value)
      fail NotOneOfTypeError unless valid?(value)
    end
  end
end
