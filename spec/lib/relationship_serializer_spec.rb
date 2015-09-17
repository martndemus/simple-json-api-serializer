require 'spec_helper'
require 'json_api/relationship_serializer'
require 'support/test_objects'

include TestObjects

RSpec.describe JSONApi::RelationshipSerializer do

  describe "#as_json" do
    it "can serialize a simple belongs to relationship" do
      object = Article.new(1, 12)
      result = subject.as_json(object, name: :author, to: :one)

      expect(result).to eq({ data: { type: 'authors', id: '12' } })
    end

    it "can serialize a relationship with foreign type name" do
      object = Article.new(1, 12)
      result = subject.as_json(object, name: :author, to: :one, type: :user)

      expect(result).to eq({ data: { type: 'users', id: '12' } })
    end

    it "can be given a custom key" do
      object = Foo.new(1, [42])
      result = subject.as_json(object, name: :bars, to: :many, key: :bars)
      expect(result).to eq({ data: [{ type: 'bars', id: '42' }] })
    end

    it "can serialize a simple has many relationship" do
      object = Post.new(1, [12, 13])
      result = subject.as_json(object, name: :comments, to: :many)
      expect(result).to eq({
        data: [
          { type: 'comments', id: '12' },
          { type: 'comments', id: '13' }
        ]
      })
    end

    it "returns nil when the foreign key is nil" do
      object = Article.new(1, nil)
      result = subject.as_json(object, name: :author, to: :one)
      expect(result).to be nil
    end
  end
end
