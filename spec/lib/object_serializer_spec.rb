require 'spec_helper'
require 'json'
require 'json_api/object_serializer'
require 'support/test_objects'

include TestObjects

RSpec.describe JSONApi::ObjectSerializer do
  describe "#serialize" do
    it "serializes a simple object" do
      result = subject.serialize(Duck.new(1))
      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'ducks',
          'id'   => '1'
        }
      })
    end

    it "serializes an array of simple objects" do
      result = subject.serialize([Duck.new(1), Duck.new(2)])
      expect(JSON.parse(result)).to eq({
        'data' => [
          { 'type' => 'ducks', 'id' => '1' },
          { 'type' => 'ducks', 'id' => '2' }
        ]
      })
    end

    it "can be told to use a specific attribute for the id" do
      result = subject.serialize(Car.new('AB-123-Z'), id_attribute: :number_plate)
      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'cars',
          'id'   => 'AB-123-Z'
        }
      })
    end

    it "can be told to set a specific type" do
      result = subject.serialize(Duck.new(1), type: :bird)
      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'birds',
          'id'   => '1'
        }
      })
    end

    it "can serialize attributes" do
      object     = Address.new(1, 'Smithons Street', 12, '8493AB', 'Smithons')
      attributes = %i{street number zip_code city}
      result     = subject.serialize(object, attributes: attributes)

      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'addresses',
          'id'   => '1',
          'attributes' => {
            'street'   => 'Smithons Street',
            'number'   => 12,
            'zip-code' => '8493AB',
            'city'     => 'Smithons'
          }
        }
      })
    end

    it "can serialize a simple belongs to relationship" do
      object = Article.new(1, 12)
      result = subject.serialize(object, relationships: [{ name: :author }])

      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'articles',
          'id'   => '1',
          'relationships' => {
            'author' => {
              'data' => { 'type' => 'authors', 'id' => '12' }
            }
          }
        }
      })
    end

    it "skips empty custom settings" do
      result = subject.serialize(Duck.new(1),
                               id_attribute: nil,
                               relationships: [],
                               attributes: [])

      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'ducks',
          'id'   => '1'
        }
      })
    end
  end
end
