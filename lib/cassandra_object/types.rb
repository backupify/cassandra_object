module CassandraObject
  module IntegerType
    REGEX = /\A[-+]?\d+\Z/
    def encode(int)
      return '' if int.nil?
      raise ArgumentError.new("#{self} requires an Integer. You passed #{int.inspect}") unless int.kind_of?(Integer)
      int.to_s
    end
    module_function :encode

    def decode(str)
      return nil if str.empty?
      raise ArgumentError.new("#{str} isn't a String that looks like a Integer") unless str.kind_of?(String) && str.match(REGEX)
      str.to_i
    end
    module_function :decode
  end

  module FloatType
    REGEX = /\A[-+]?\d+(\.\d+)\Z/
    def encode(float)
      return '' if float.nil?
      raise ArgumentError.new("#{self} requires a Float") unless float.kind_of?(Float)
      float.to_s
    end
    module_function :encode

    def decode(str)
      return nil if str == ''
      raise ArgumentError.new("#{str} isn't a String that looks like a Float") unless str.kind_of?(String) && str.match(REGEX)
      str.to_f
    end
    module_function :decode
  end
  
  module DateType
    FORMAT = '%Y-%m-%d'
    REGEX = /\A\d{4}-\d{2}-\d{2}\Z/
    def encode(date)
      raise ArgumentError.new("#{self} requires a Date") unless date.kind_of?(Date)
      date.strftime(FORMAT)
    end
    module_function :encode

    def decode(str)
      raise ArgumentError.new("#{str} isn't a String that looks like a Date") unless str.kind_of?(String) && str.match(REGEX)
      Date.strptime(str, FORMAT)
    end
    module_function :decode
  end

  module TimeType
    # lifted from the implementation of Time.xmlschema and simplified
    REGEX = /\A\s*
              (-?\d+)-(\d\d)-(\d\d)
              T
              (\d\d):(\d\d):(\d\d)
              (\.\d*)?
              (Z|[+-]\d\d:\d\d)?
              \s*\z/ix

    def encode(time)
      raise ArgumentError.new("#{self} requires a Time") unless time.kind_of?(Time)
      time.xmlschema(6)
    end
    module_function :encode

    def decode(str)
      raise ArgumentError.new("#{str} isn't a String that looks like a Time") unless str.kind_of?(String) && str.match(REGEX)
      Time.xmlschema(str)
    end
    module_function :decode
  end
  
  module TimeWithZoneType
    def encode(time)
      TimeType.encode(time.utc)
    end
    module_function :encode

    def decode(str)
      TimeType.decode(str).in_time_zone
    end
    module_function :decode
  end
  
  module StringType
    def encode(str)
      raise ArgumentError.new("#{self} requires a String") unless str.kind_of?(String)
      # thrift forces encoding to ascii-8bit, so we have to first convert to utf8, then
      # force encoding, so that on decode we can safely force to utf-8
      str.encode("utf-8").force_encoding('ascii-8bit')
    end
    module_function :encode

    def decode(str)
      str.clone.force_encoding('utf-8')
    end
    module_function :decode
  end

  module HashType
    def encode(hash)
      raise ArgumentError.new("#{self} requires a Hash") unless hash.kind_of?(Hash)
      # to_json on HWIA barfs: https://rails.lighthouseapp.com/projects/8994/tickets/4726-hashwithindifferentaccessto_json-will-raise-a-systemstackerror-stack-level-too-deep
      hash.to_hash.to_json.encode("utf-8").force_encoding('ascii-8bit')
    end
    module_function :encode

    def decode(str)
      ActiveSupport::HashWithIndifferentAccess.new(JSON::parse(str.force_encoding('utf-8')))
    end
    module_function :decode
  end

  module BooleanType
    ALLOWED = [true, false, nil]
    def encode(bool)
      unless ALLOWED.any?{ |a| bool == a }
          raise ArgumentError.new("#{self} requires a Boolean or nil")
      end
      bool ? '1' : '0'
    end
    module_function :encode

    def decode(bool)
      bool == '1'
    end
    module_function :decode
  end

  module ArrayType
    def encode(array)
      raise ArgumentError.new("#{self} requires an Array") unless array.kind_of?(Array)
      array.to_json.encode("utf-8").force_encoding('ascii-8bit')
    end
    module_function :encode

    def decode(str)
      JSON::parse(str.force_encoding('utf-8'))
    end
    module_function :decode
  end
end
