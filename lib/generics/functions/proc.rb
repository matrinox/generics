require 'generics/type_checker'

class Object
  # Example:
  # typedproc(String, :to_i, returns: String) { |string, times| string * times.to_i }
  # @param [Array<Class, Module, Symbol>] types
  # @param [Generics::Proc] block
  # @return [Generics::Proc]
  def typedproc(*types, &block)
    Generics::Proc.typed(*types, &block)
  end
end

module Generics
  class Proc
    # Example:
    # Generics::Proc.typed(String, :to_i, returns: String) { }
    # @param [Array<Class, Module, Symbol>] types
    # @param [Proc] block
    # @param [optional, Class, Module, Symbol] returns the return type or nil for void
    # @return [Generics::Proc]
    def self.typed(*types, returns: nil, &block)
      return proc do |*args|
        unless types.length == args.length
          fail ArgumentError, args, "wrong number of arguments (given #{args.length}, expected #{types.length})"
        end
        types.each_with_index do |type, index|
          arg = args[index]
          TypeChecker[type].valid!(arg)
        end
        block.call(*args).tap do |result|
          TypeChecker[returns].valid!(result)
        end
      end
    end
  end
end
