module Generics
  # Example uses:
  # Generics::TypeChecker[String].valid?("3") # true
  # Generics::TypeChecker[String].valid?(3) # false
  # Generics::TypeChecker[String].valid!(3) # exception
  # Generics::TypeChecker[:to_f].valid!(3) # true
  class TypeChecker
    attr_reader :type

    class WrongTypeError < StandardError
    end

    # @param [Class, Symbol, Module] type
    # @return [Generics::TypeChecker]
    def self.[](type)
      new(type)
    end

    # Check if the type is valid or requires stricter definition
    # @param [Class, Symbol, Module] type
    # @return [True, False]
    def self.valid_type?(type)
      return false unless [Class, Module, Symbol, Enumerable].any? { |valid_type| type.is_a?(valid_type) }
      if type.is_a?(Class) && type.included_modules.include?(Enumerable)
        false
      elsif type.to_s =~ /.*Struct/
        false
      elsif type.is_a?(Enumerable)
        return false if type.count == 0
        type.all? do |*args|
          args.all? { |arg| valid_type?(arg) }
        end
      else
        true
      end
    end

    # @param [Class, Symbol, Module] type
    def initialize(type)
      fail ArgumentError unless self.class.valid_type?(type)
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
      when Array
        # Value must also be an array type
        return false unless value.is_a?(Array)
        # Check all values against any type
        @type.any? do |t|
          type_checker = TypeChecker[t]
          value.all? { |v| type_checker.valid?(v) }
        end
      when Hash
        # TODO: hashes
      when Enumerable
        # TODO: other enumerables, perhaps use the same here for both Array/Hash
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
        type_checker = TypeChecker[@type]
        values.all? { |value| type_checker.valid?(value) }
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
