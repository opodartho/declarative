require "test_helper"
require "declarative/schema"

module Schema
  module Inspect
    def inspect
      each { |n, dfn|
        dfn.extend(::Inspect)
        dfn[:nested].extend(::Inspect) if dfn[:nested]
      }
      super
    end

    def get(*)
      super.extend(::Inspect)
    end
  end
end

class SchemaTest < Minitest::Spec
  let (:schema) { Declarative::Schema.new(Declarative::Schema::Definition).extend(Schema::Inspect) }

  it "what" do
    # #add works with name
    schema.add :id
    # get works with symbol
    schema.get(:id).inspect.must_equal '#<Declarative::Schema::Definition: @options={}, @name="id">'
    # get works with string
    schema.get("id").inspect.must_equal '#<Declarative::Schema::Definition: @options={}, @name="id">'

    # #add with name and options
    schema.add(:id, unique: true)
    schema.get(:id).inspect.must_equal '#<Declarative::Schema::Definition: @options={:unique=>true}, @name="id">'

    pp schema
  end

  it "overwrites old when called twice" do
    schema.add :id
    schema.add :id, cool: true
    schema.inspect.must_equal '{"id"=>#<Declarative::Schema::Definition: @options={:cool=>true}, @name="id">}'
  end

  class Decorator
    def self.add(*args, &block)
      Declarative::Schema.new(Declarative::Schema::Definition)
    end
  end

  it "#add with block" do
    NestedBuilder = ->(*) { Declarative::Schema.new(Declarative::Schema::Definition).instance_eval do
      def module_eval(&block) # FIXME: that's because build_nested calls #module_eval.
        instance_exec(&block)
      end
      self
    end }

    schema.add :artist, build_nested: NestedBuilder do
      add :name
    end

    schema.inspect.must_equal '{"artist"=>#<Declarative::Schema::Definition: @options={:nested=>{"name"=>#<Declarative::Schema::Definition: @options={}, @name="name">}}, @name="artist">}'

    pp schema
  end


end