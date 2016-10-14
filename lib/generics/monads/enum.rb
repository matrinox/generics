require 'generics/type_checker'

module Generics
  # Example
  # Generics::Enum[String, :to_i, Comparable].valid?("test")
  class Enum
    NotOneOfTypeError = Class.new(StandardError)

    # Creates an enum that only allows objects of the available types
    # @param [Array<Class, Module, Symbol>] types
    # @return [Generics::Enum]
    def self.[](*types)
      new(*types)
    end

    # @param [Array<Class, Module, Symbol>] types
    def initialize(*types)
      @type_checkers = types.map { |type| TypeChecker[type] }
    end

    # Checks if value is valid in the available enum types
    # @param [Object] value
    # @return [True, False]
    def valid?(value)
      @type_checkers.any? { |type_checker| type_checker.valid?(value) }
    end

    # Checks if value is valid in the available enum types
    # @param [Object] value
    # @raise [Generics::NotOneOfTypeError]
    # @return [True, False]
    def valid!(value)
      fail NotOneOfTypeError, value unless valid?(value)
    end
  end
end
