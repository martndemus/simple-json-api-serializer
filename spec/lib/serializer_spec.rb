require 'spec_helper'
require 'json'
require 'json_api/serializer'
require 'support/test_objects'

include TestObjects

RSpec.describe JSONApi::Serializer do
  describe "#to_json" do
    it "serializes a simple object" do
      result = subject.to_json(Duck.new(1))
      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'ducks',
          'id'   => '1'
        }
      })
    end

    it "serializes an array of simple objects" do
      result = subject.to_json([Duck.new(1), Duck.new(2)])
      expect(JSON.parse(result)).to eq({
        'data' => [
          { 'type' => 'ducks', 'id' => '1' },
          { 'type' => 'ducks', 'id' => '2' }
        ]
      })
    end

    it "can be told to use a specific attribute for the id" do
      result = subject.to_json(Car.new('AB-123-Z'), id_attribute: :number_plate)
      expect(JSON.parse(result)).to eq({
        'data' => {
          'type' => 'cars',
          'id'   => 'AB-123-Z'
        }
      })
    end

    it "can serialize attributes" do
      object     = Address.new(1, 'Smithons Street', 12, '8493AB', 'Smithons')
      attributes = %i{street number zip_code city}
      result     = subject.to_json(object, attributes: attributes)

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
      result = subject.to_json(object, relationships: [{ name: :author }])

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
      result = subject.to_json(Duck.new(1),
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
