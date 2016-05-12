require 'active_support/json'
require 'json_api/utils'
require 'json_api/relationship_serializer'

module JSONApi
  class ObjectSerializer
    def serialize(object, **options)
      ActiveSupport::JSON.encode(hashify(object, **options))
    end

    def hashify(object, **options)
      hash = { data: data_for(object, **options) }

      if options[:include].is_a?(Array)
        hash[:included] = options[:include]
      end

      if options[:meta].is_a?(Hash)
        hash[:meta] = options[:meta]
      end

      hash
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

      if options[:links] == true
        result[:links] = links_for(object, options)
      end

      result
    end

    def resource_identifier_for(object, **options)
      resource_identifier = {
        type: type_for(object, options)
      }

      unless options[:new_record] == true
        resource_identifier[:id] = id_for(object, options)
      end

      resource_identifier
    end

    def relationships_for(object, options)
      relationship_serializer = RelationshipSerializer.new

      defaults = {
        parent_type: type_for(object, options),
        base_url:    options[:base_url]
      }

      options[:relationships].each_with_object({}) do |relationship, hash|
        relationship_key = Utils.canonicalize_attribute_name(relationship[:name])
        data = relationship_serializer.as_json(object, defaults.merge(relationship))
        hash[relationship_key] = data unless data.nil?
      end
    end

    def attributes_for(object, **options)
      options[:attributes].each_with_object({}) do |attribute, hash|
        attribute_key = Utils.canonicalize_attribute_name(attribute)
        hash[attribute_key] = object.send(attribute)
      end
    end

    def links_for(object, **options)
      id   = id_for(object, options)
      type = type_for(object, options)

      { self: "#{options[:base_url] || ""}/#{type}/#{id}" }
    end

    def id_for(object, **options)
      id_attribute = options[:id_attribute] || :id
      canonicalize_id(object.send(id_attribute))
    end

    def type_for(object, **options)
      type_name = options[:type] || object.class.name
      canonicalize_type_name(type_name)
    end

    def canonicalize_id(id)
      Utils.canonicalize_id(id)
    end

    def canonicalize_type_name(type_name)
      Utils.canonicalize_type_name(type_name)
    end
  end
end
