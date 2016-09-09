module Generics
  # Example uses:
  # Generics::TypeChecker[String].valid?("3") # true
  # Generics::TypeChecker[String].valid?(3) # false
  # Generics::TypeChecker[String].valid!(3) # exception
  # Generics::TypeChecker[:to_f].valid!(3) # true
  class TypeChecker
    class WrongTypeError < StandardError
    end

    # @param [Class, Symbol, Module] type
    # @return [Generics::TypeChecker]
    def self.[](type)
      new(type)
    end

    # @param [Class, Symbol, Module] type
    def initialize(type)
      @type = type
    end

    # Checks if the value provided would be valid for this type
    # @param [Object] value
    # @return [True, False]
    def valid?(value)
      case @type
      when Class
        value.is_a?(@type)
      when Symbol
        value.respond_to?(@type)
      when Enum
        @type.valid?(value)
      end
    end

    # Checks if the value provided would be valid for this type
    # @param [Object] value
    # @raise [Generics::WrongTypeError] value is not of the correct type
    # @return [True, False]
    def valid!(value)
      fail WrongTypeError, value unless valid?(value)
    end

    # Example uses:
    # Generics::TypeChecker::List[String].valid?(["1", "2"]) # true
    # Generics::TypeChecker::List[String].valid?(["1", 2]) # false
    class List < TypeChecker
      # @param [Array<Object>] values
      # @return [True, False]
      def valid?(values)
        values.all? { |value| TypeChecker[@type].valid?(value) }
      end
    end

    # Example uses:
    # Generics::TypeChecker::Hash[String => Integer].valid?('test' => 3) # true
    class Hash < TypeChecker
      # @param [Hash<Object, Object >] hash
      # @return [True, False]
      def valid?(hash)
        hash.all? do |key, value|
          TypeChecker[@type.keys[0]].valid?(key)
          TypeChecker[@type.values[0]].valid?(value)
        end
      end
    end
  end
end
