module Generics
  # Example use:
  # TypeChecker[String].valid?("3") # true
  # TypeChecker[String].valid?(3) # false
  # TypeChecker[String].valid!(3) # exception
  # TypeChecker[:to_f].valid!(3) # true
  class TypeChecker
    class WrongTypeError < StandardError
    end

    # @param [Class, Symbol] type
    # @return [TypeChecker]
    def self.[](type)
      new(type)
    end

    # @param [Class, Symbol] type
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
      end
    end

    # Checks if the value provided would be valid for this type
    # @param [Object] value
    # @raise [WrongTypeError] value is not of the correct type
    # @return [True, False]
    def valid!(value)
      fail WrongTypeError unless valid?(value)
    end

    # Example use:
    # TypeChecker::List[String].valid?(["1", "2"]) # true
    # TypeChecker::List[String].valid?(["1", 2]) # false
    class List < TypeChecker
      # @param [Array<Object>] values
      # @return [True, False]
      def valid?(values)
        values.all? { |value| TypeChecker[@type].valid?(value) }
      end
    end

    # Example use:
    # TypeChecker::Hash[String => Integer].valid?('test' => 3) # true
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
