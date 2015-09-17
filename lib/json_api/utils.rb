require 'active_support/all'

module JSONApi
  module Utils
    class << self
      def canonicalize_id(id)
        id.nil? ? '' : id.to_s
      end

      def canonicalize_type_name(type_name)
        type_name.to_s
          .demodulize
          .underscore
          .pluralize
          .dasherize
      end

      def canonicalize_attribute_name(attribute_name)
        attribute_name.to_s
          .dasherize
      end
    end
  end
end
