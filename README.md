# Generics

The philosophy here is to bring as much modern language features that help developers code better, safer, and more reliably. Here are some top priorities of this library:

- Immutability first with mutability as an option (e.g for speed)
- Type safety
- Follow functional practices
- Use standard interfaces of Ruby
- Fail early, throw fast

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'generics'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install generics

## Usage

```ruby
list_of_ints = Generics::List[Integer].new(1, 2, 3, 4)
list_of_ints.add(5) # ok
list_of_ints.add('6') # NotSameType exception
list_of_ints.count # 4 (immutable)
list_of_ints.add(5).add(6).add(7).count # 7
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

- Other collection types (at least the same list as core ruby data types and the Hamster immutable library)
- More complex generics
  - Responds to generics (another form of duck type, though modules are preferable)
  - Array generics (e.g. list of strings)
  - Hash generics (e.g. keys are numbers and values are list of strings)
  - Either/enums (e.g. list of strings or integers of anything that responds to :x). This would require either adopting a library or creating one ourselves as a separate gem
- Generics in functions/closures
- Generics in methods
- Generics in classes


Examples of some of the above todos:

```ruby
# Responds to generics
Generics::List[:to_s, :to_a].new(...)

# Array Generics (?)
Generics::Hash[[String]].new(...)

# Hash Generics
Generics::Hash[String => [Integer, :to_s]].new(...)

# Either
EitherStringOrInteger = Either[String, Integer]
Generics::List[EitherStringOrInteger].new(...)

# Enums
EnumMultiples = Enum[String, Integer, :to_s, :to_a]
Generics::List[EnumMultiples].new(...)

# Function/closure generics
repeater = typedproc(String, #to_i, returns: String) { |string, times| string * times.to_i }
repeater.('a', 3) # 'aaa'
repeater.(1, 3) # exception

# Method generics
class Foo
  type params(:T)
  def initialize(value)
    @value = value
    @values = [value]
  end

  type params(Integer)
  type return(:T)
  def [](index)
    return @values[index]
  end

  type params(Object)
  type return([:T, Object])
  def join(other)
    [@value, other]
  end
end

# Class Generics
class Foo < Generics::Class[:T, :B]
  restrict(:B) do
    :add_to_integer
  end

  type params([:T], :B)
  def initialize(values, constant)
    @values = values
    @constant = constant
  end

  type params(Integer)
  type return([:T])
  def [](index)
    return @values[index]
  end

  type return(:B)
  def sum
    5 + constant
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/generics. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

