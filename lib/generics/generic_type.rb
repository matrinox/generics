module Generics
  class NotCompatibleError < StandardError
  end

  class StrictType
    # Return a subclass of StrictType that can be instantiated with a type
    # Use it in a generic class and use the instantiated version in the instantiated object
    # @param [String] name
    # @return [Class] subclass of Generics::StrictType
    def self.[](name)
      Class.new(self).tap do |klass|
        klass.define_singleton_method(:name) { name }
      end
    end

    # @param [Class, Module, Symbol] tpye
    def initialize(type)
      @type_checker = TypeChecker[type]
      @type = type
    end

    def valid?(value)
      @type_checker.valid?(value)
    end

    # Check if value is valid in current state with exception
    # @param [Object] value
    # @raise [NotCompatibleError]
    # @return [True, False]
    def valid!(value)
      fail NotCompatibleError unless @type_checker.valid?(value)
    end
  end

  class GenericType
    # @param [Symbol] name
    # @return [GenericType]
    def self.[](name)
      new(name)
    end

    # @param [Symbol] name
    def initialize(name)
      @name = name
      @values = []
      @shared_superclass = nil
      @shared_modules = []
    end

    # Add value, narrowing (possibly) the shared class or modules
    # @param [Object] value
    # @return [Object] same value
    def <<(value)
      if @values.empty?
        @shared_superclass = value.class
        @shared_modules = value.class.included_modules
      else
        common_ancestor = find_common_ancestor(@shared_superclass, value.class)
        # Ignore Object/BasicObject ancestors
        common_ancestor = nil if common_ancestor == BasicObject || common_ancestor == Object
        shared_modules = value.class.included_modules & @shared_modules - [Kernel]

        if !common_ancestor && shared_modules.empty?
          fail NotCompatibleError
        end

        @shared_superclass = common_ancestor
        @shared_modules = shared_modules
      end
      @values << value
    end

    # Check if value is valid in current state. This is not the same as adding it as adding it could change the
    # strictness to a level that will make the value valid again
    # @param [Object] value
    # @return [True, False]
    def valid?(value)
      return true if value.is_a?(@shared_superclass)
      @shared_modules.any? { |m| value.is_a?(m) }
    end

    # Check if value is valid in current state with exception
    # @param [Object] value
    # @raise [NotCompatibleError]
    # @return [True, False]
    def valid!(value)
      fail NotCompatibleError unless valid?(value)
    end

    private def find_common_ancestor(klassA, klassB)
      return klassA if klassA == klassB
      return nil unless klassA && klassB
      klassAAncestors = klassA.ancestors.grep(Class).to_set
      klassBAncestors = klassB.ancestors.grep(Class).to_set
      return klassAAncestors.find do |klass|
        klassBAncestors.include?(klass)
      end
      nil
    end
  end
end
