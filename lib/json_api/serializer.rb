require 'active_support/json'
require 'json_api/utils'
require 'json_api/relationship_serializer'


module JSONApi
  class Serializer
    def to_json(object, **options)
      ActiveSupport::JSON.encode({ data: data_for(object, **options) })
    end

    private

    def data_for(object, **options)
      if object.is_a? Array
        object.map { |o| resource_object_for(o, options) }
      else
        resource_object_for(object, options)
      end
    end

    def resource_object_for(object, **options)
      result = resource_identifier_for(object, options)

      if options[:attributes] && options[:attributes].any?
        result[:attributes] = attributes_for(object, options)
      end

      if options[:relationships] && options[:relationships].any?
        result[:relationships] = relationships_for(object, options)
      end

      result
    end

    def resource_identifier_for(object, **options)
      {
        type: type_for(object),
        id:   id_for(object, options)
      }
    end

    def relationships_for(object, options)
      relationship_serializer = RelationshipSerializer.new
      options[:relationships].each_with_object({}) do |relationship, hash|
        relationship_key = Utils.canonicalize_attribute_name(relationship[:name])
        data = relationship_serializer.as_json(object, relationship)
        hash[relationship_key] = data unless data.nil?
      end
    end

    def attributes_for(object, **options)
      options[:attributes].each_with_object({}) do |attribute, hash|
        attribute_key = Utils.canonicalize_attribute_name(attribute)
        hash[attribute_key] = object.send(attribute)
      end
    end

    def id_for(object, **options)
      id_attribute = options[:id_attribute] || :id
      canonicalize_id(object.send(id_attribute))
    end

    def type_for(object)
      canonicalize_type_name(object.class.name)
    end

    def canonicalize_id(id)
      Utils.canonicalize_id(id)
    end

    def canonicalize_type_name(type_name)
      Utils.canonicalize_type_name(type_name)
    end
  end
end
