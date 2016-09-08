require 'json_api/object_serializer'

module JSONApi
  class ObjectSerializerDefinition
    class << self
      def serialize(object, **options)
        options = merge_options(**options)
        ObjectSerializer.new.serialize(object, **options)
      end

      def hashify(object, **options)
        options = merge_options(**options)
        ObjectSerializer.new.hashify(object, **options)
      end

      def inherited(specialization)
        specialization.attributes(*attributes)
        specialization.relationships(*relationships)
        specialization.id_attribute(id_attribute)
        specialization.base_url(base_url)
        specialization.type(type)
      end

      def attributes(*attrs)
        @attributes ||= []
        @attributes |= attrs
      end

      def id_attribute(attr = @id_attribute)
        @id_attribute = attr
      end

      def base_url(url = @base_url)
        @base_url = url
      end

      def type(type = @type)
        @type = type
      end

      def relationship(name, **config)
        config[:name] = name
        relationships(config)
      end

      def relationships(*configs)
        @relationships ||= []
        if @relationships.empty?
          @relationships |= configs
        else
          configs.each do |new_hash|
            if find_index(new_hash)
              @relationships[find_index(new_hash)] = new_hash
            else
              @relationships << new_hash
            end
          end
          @relationships
        end
      end

      def find_index(other_hash = nil)
        @name_index ||= begin
          @relationships.each_with_index do |relation, i|
            return i if relation[:name] == other_hash[:name]
          end
          false
        end
      end

      def has_one(name, **config)
        config[:to] = :one
        relationship(name, config)
      end

      def has_many(name, **config)
        config[:to] = :many
        relationship(name, config)
      end

      private

      def merge_options(**options)
        options[:id_attribute]  ||= id_attribute
        options[:attributes]    ||= attributes
        options[:relationships] ||= relationships
        options[:type]          ||= type
        options
      end
    end
  end
end
