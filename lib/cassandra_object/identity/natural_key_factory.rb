module CassandraObject
  module Identity
    class NaturalKeyFactory < AbstractKeyFactory
      class NaturalKey
        include Key

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def to_s
          value
        end

        def to_param
          value
        end

        def ==(other)
          other.is_a?(NaturalKey) && other.value == value
        end

        def eql?(other)
          other == self
        end
      end

      attr_reader :attributes, :separator

      def initialize(options)
        @attributes = [*options[:attributes]]
        @separator  = options[:separator] || "-"
      end

      def next_key(object)
        attribs = attributes.map do |a|
          column_name = a.to_s
          attr = object.model_attributes[column_name]
          attr.encode(object.attributes[column_name])
        end
        key = attribs.join(separator)
        NaturalKey.new(key)
      end

      def parse(paramized_key)
        NaturalKey.new(paramized_key)
      end

      def create(paramized_key)
        NaturalKey.new(paramized_key)
      end
    end
  end
end

