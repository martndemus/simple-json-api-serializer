require 'json_api/object_serializer'

module JSONApi
  class ObjectSerializerDefinition
    class << self
      def serialize(object)
        ObjectSerializer.new.serialize(object, {
          id_attribute:  id_attribute,
          attributes:    attributes,
          relationships: relationships
        })
      end

      def inherited(specialization)
        specialization.attributes(*attributes)
        specialization.relationships(*relationships)
        specialization.id_attribute(id_attribute)
      end

      def attributes(*attrs)
        @attributes ||= []
        @attributes |= attrs
      end

      def id_attribute(attr = @id_attribute)
        @id_attribute = attr
      end

      def relationship(name, **config)
        config[:name] = name
        relationships(config)
      end

      def relationships(*configs)
        @relationships ||= []
        @relationships |= configs
      end

      def has_one(name, **config)
        config[:to] = :one
        relationship(name, config)
      end

      def has_many(name, **config)
        config[:to] = :many
        relationship(name, config)
      end
    end
  end
end
