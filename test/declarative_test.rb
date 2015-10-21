require "test_helper"

class DeclarativeTest < Minitest::Spec
  module Inspect
    def inspect
      super.sub(/0x\w+/, "")
    end
  end

  module RepresenterA
    include Declarative


    # TODO: test options cloning.
    def self.property(name, options={}, &block)
      declarative_attrs[:property] ||= []
      declarative_attrs[:property] << [name, options, block.extend(Inspect)]
    end

    property :id
    property :artist do

    end
  end

  class DecoratorA
    def self.property(name, options={}, &block)
      declarative_attrs[:property] ||= []
      declarative_attrs[:property] << [name, options, block.extend(Inspect)]
    end

    include Declarative
    include RepresenterA

    # add more.
  end

  it { RepresenterA.declarative_attrs.inspect.must_equal  "{:property=>[[:id, {}, nil], [:artist, {}, #<Proc:@test/declarative_test.rb:20>]]}" }
  it { DecoratorA.declarative_attrs.inspect.must_equal    "{:property=>[[:id, {}, nil], [:artist, {}, #<Proc:@test/declarative_test.rb:20>]]}" }

  # attrs[:property] when it wasn't initialized
end