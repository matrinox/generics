module Generics
  # Example use:
  # TypeChecker[String].valid?("3") # true
  # TypeChecker[String].valid?(3) # false
  # TypeChecker[String].valid!(3) # exception
  class TypeChecker
    class WrongTypeError < StandardError
    end

    def self.[](type)
      new(type)
    end

    def initialize(type)
      @type = type
    end

    def valid?(value)
      value.is_a?(@type)
    end

    def valid!(value)
      fail WrongTypeError unless valid?(value)
    end

    # Example use:
    # TypeChecker::List[String].valid?(["1", "2"]) # true
    # TypeChecker::List[String].valid?(["1", 2]) # false
    class List < TypeChecker
      def valid?(values)
        values.all? { |value| value.is_a?(@type) }
      end
    end

    # Example use:
    # TypeChecker::Hash[String => Integer].valid?('test' => 3) # true
    class Hash < TypeChecker
      def valid?(hash)
        hash.all? do |key, value|
          key.is_a?(@type.keys[0])
          value.is_a?(@type.values[0])
        end
      end
    end
  end
end
