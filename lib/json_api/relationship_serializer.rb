require 'json_api/utils'

module JSONApi
  class RelationshipSerializer
    def as_json(object, **options)
      data =
        if options[:to] == :many
          ToManySerializer.new.data_for(object, options)
        else
          ToOneSerializer.new.data_for(object, options)
        end

      if data.nil? || data == []
        nil
      else
        { data: data }
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
        ids = relationship_for(object, options)
        ids.map { |id| resource_identifier_for(type_for(object, options), id) }
           .compact
      end
    end

    class ToOneSerializer < RelationshipSerializer
      def key_for(**options)
        "#{super}_id"
      end

      def data_for(object, options)
        id = relationship_for(object, options)
        resource_identifier_for(type_for(object, options), id)
      end
    end
  end
end
