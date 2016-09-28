require 'json_api/utils'

module JSONApi
  class RelationshipSerializer
    def as_json(object, **options)
      serializer =
        (options[:to] == :many ? ToManySerializer : ToOneSerializer).new

      data  = serializer.data_for(object, options)
      links = serializer.links_for(object, options)

      result = {}
      result[:data]  = data unless data.nil?
      result[:links] = links unless links.nil?

      if result.empty?
        nil
      else
        result
      end
    end

    protected

    def type_for(object, options)
      if options[:polymorphic]
        foreign_type_key =
          options[:foreign_type_key] ||  "#{key_base_for(options)}_type"
        object.send(foreign_type_key)
      else
        options[:type] || options[:name]
      end
    end

    def key_base_for(options)
      options[:name].to_s.singularize
    end

    def key_for(options)
      key_base_for(options)
    end

    def relationship_for(object, **options)
      object.send(options[:key] || key_for(options))
    end

    def resource_identifier_for(type_name, id)
      return nil if id.nil? || id == ""

      {
        type: Utils.canonicalize_type_name(type_name),
        id:   Utils.canonicalize_id(id)
      }
    end

    class ToManySerializer < RelationshipSerializer
      def key_for(**options)
        "#{super}_ids"
      end

      def data_for(object, options)
        return if options[:data] != true

        ids = relationship_for(object, options)
        ids.map { |id| resource_identifier_for(type_for(object, options), id) }
           .compact
      end

      def links_for(object, options)
        return if options[:links] == false

        id   = Utils.canonicalize_id(object.send(options[:id_attribute] || :id))
        type = Utils.canonicalize_attribute_name(options[:name])

        { related: "#{options[:base_url] || ""}/#{options[:parent_type]}/#{id}/#{type}" }
      end
    end

    class ToOneSerializer < RelationshipSerializer
      def key_for(**options)
        "#{super}_id"
      end

      def data_for(object, options)
        return if options[:data] == false

        id = relationship_for(object, options)
        resource_identifier_for(type_for(object, options), id)
      end

      def links_for(object, options)
        return if options[:links] != true

        id   = Utils.canonicalize_id(object.send(options[:id_attribute] || :id))
        type = Utils.canonicalize_attribute_name(options[:name])

        { related: "#{options[:base_url] || ""}/#{options[:parent_type]}/#{id}/#{type}" }
      end
    end
  end
end
