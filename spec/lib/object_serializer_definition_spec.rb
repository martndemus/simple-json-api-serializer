require 'spec_helper'
require 'json_api/object_serializer_definition'

def make_definition(base = JSONApi::ObjectSerializerDefinition, &block)
  Class.new(base, &block)
end

RSpec.describe JSONApi::ObjectSerializerDefinition do
  describe ".type" do
    it "stores given attributes on the class definition" do
      example = make_definition { type :foo }
      expect(example.type).to eq(:foo)
    end

    it "can be inherited" do
      base = make_definition { type :foo }
      specialized = make_definition(base) { }
      expect(specialized.type).to eq(:foo)
    end
  end

  describe ".attributes" do
    it "stores given attributes on the class definition" do
      example = make_definition { attributes :foo, :bar }
      expect(example.attributes).to eq([:foo, :bar])
    end

    it "can be inherited" do
      base = make_definition { attributes :foo, :bar }
      specialized = make_definition(base) { attributes :baz }
      expect(specialized.attributes).to eq([:foo, :bar, :baz])
    end
  end

  describe ".base_url" do
    it "stores given base_url on the class definition" do
      example = make_definition { base_url 'http://example.com' }
      expect(example.base_url).to eq 'http://example.com'
    end

    it "can be inherited" do
      base = make_definition { base_url 'http://example.com' }
      specialized = make_definition(base) {  }
      expect(specialized.base_url).to eq 'http://example.com'
    end
  end

  describe ".id_attribute" do
    it "stores given id_attribute on the class definition" do
      example = make_definition { id_attribute :foo }
      expect(example.id_attribute).to be :foo
    end

    it "is inherited" do
      base = make_definition { id_attribute :foo }
      specialized = make_definition(base) { }
      expect(specialized.id_attribute).to be(:foo)
    end
  end

  describe ".relationship" do
    it "stores definitions of relationships on the class definition" do
      example = make_definition { relationship :foo }
      expect(example.relationships).to eq [{ name: :foo }]
    end

    it "can be inherited" do
      base = make_definition { relationship :foo }
      specialized = make_definition(base) { relationship :bar }
      expect(specialized.relationships).to eq [{ name: :foo }, { name: :bar }]
    end

    it "overrides relationships from its parent" do
      base = make_definition { has_many :foos, links: false }
      specialized = make_definition(base) { has_many :foos, links: true }
      expect(specialized.relationships)
        .to eq [{links: true, to: :many, name: :foos}]
    end
  end

  describe ".has_one" do
    it "is sugar for #relationship :foo, to: :one" do
      example = make_definition { has_one :foo }
      expect(example.relationships).to eq [{ name: :foo, to: :one }]
    end
  end

  describe ".has_many" do
    it "is sugar for #relationship :foo, to: :many" do
      example = make_definition { has_many :foos }
      expect(example.relationships).to eq [{ name: :foos, to: :many }]
    end
  end

  describe ".serialize" do
    let(:object)     { double(:object) }
    let(:serializer) { double(:serializer) }

    before do
      expect(JSONApi::ObjectSerializer).to receive(:new) { serializer }
    end

    it "passes the object with the definition to JSONApi::Serializer#serialize" do
      definition = make_definition do
        type         :quux
        id_attribute :bar
        attributes   :foo
        relationship :baz
      end

      expect(serializer).to receive(:serialize).with(object, {
        type:          :quux,
        id_attribute:  :bar,
        attributes:    [:foo],
        relationships: [{ name: :baz }]
      })

      definition.serialize(object)
    end

    it "passes includes to ther serializer" do
      definition = make_definition {}

      expect(serializer).to receive(:serialize).with(object, {
        type:          nil,
        include:       [:foo],
        id_attribute:  nil,
        attributes:    [],
        relationships: []
      })

      definition.serialize(object, include: [:foo])
    end
  end
end
