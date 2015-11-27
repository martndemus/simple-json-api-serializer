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

    it "can be told to lookup the type for a has one relation" do
      object = Bar.new(1, 2, 'SpecialBaz')
      result = subject.as_json(object, name: :baz, to: :one, polymorphic: true)

      expect(result).to eq({ data: { type: 'special-bazs', id: '2' } })
    end

    it "can be told to lookup the type for a has one relation with a special key" do
      object = Anchor.new(1, 2, 'NoFollow')
      result = subject.as_json(object, name: :link,
                                       to: :one,
                                       polymorphic: true,
                                       foreign_type_key: :link_relation)

      expect(result).to eq({ data: { type: 'no-follows', id: '2' } })
    end

    it "can be given a custom key" do
      object = Foo.new(1, [42])
      result = subject.as_json(object, name: :bars, to: :many, key: :bars, data: true, links: false)
      expect(result).to eq({ data: [{ type: 'bars', id: '42' }] })
    end

    it "can serialize a simple has many relationship" do
      object = Post.new(1, [12, 13])
      result = subject.as_json(object, name: :comments, to: :many, data: true, links: false)
      expect(result).to eq({
        data: [
          { type: 'comments', id: '12' },
          { type: 'comments', id: '13' }
        ]
      })
    end

    it "can add links to a has many relationship" do
      object = Post.new(1)
      result = subject.as_json(object, name: :comments, to: :many, data: false, parent_type: 'posts')
      expect(result).to eq({ links: { related: '/posts/1/comments' } })
    end

    it "can add links to a belongs to relationship" do
      object = Article.new(1, 12)
      result = subject.as_json(object, name: :author, to: :one, data: false, links: true, parent_type: 'articles')
      expect(result).to eq({ links: { related: '/articles/1/author' } })
    end

    it "returns nil when the foreign key is nil" do
      object = Article.new(1, nil)
      result = subject.as_json(object, name: :author, to: :one)
      expect(result).to be nil
    end
  end
end
