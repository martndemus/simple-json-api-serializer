module JSONApi
  class ParamsDeserializer
    def self.deserialize(data, **options)
      self.new.deserialize(data, **options)
    end

    def deserialize(data, **options)
      type = sanitize_type_name(data.fetch('type'))

      attributes    = sanitize_hash(data.fetch('attributes', {}))
      relationships = data.fetch('relationships', {})

      attributes['id'] = data['id'] unless data['id'].nil?

      deserialize_relationships(relationships, attributes)

      if options[:root] == false
        attributes
      else
        { type => attributes }
      end
    end

    private

    def deserialize_relationships(relationships, attributes)
      relationships.each do |name, data|
        data = data['data']
        name = sanitize_attribute_name(name)

        if data
          attributes["#{name}_id"]   = data.fetch('id')
          attributes["#{name}_type"] = sanitize_type_name(data.fetch('type')).classify
        else
          attributes["#{name}_id"]   = nil
        end
      end
    end

    def sanitize_hash(hash)
      hash.map do |key, value|
        value = sanitize_hash(value) if value.is_a?(Hash)
        [sanitize_attribute_name(key), value]
      end.to_h
    end

    def sanitize_attribute_name(attribute_name)
      attribute_name
        .downcase
        .underscore
    end

    def sanitize_type_name(type_name)
      sanitize_attribute_name(type_name)
        .singularize
    end
  end
end
