require 'active_record/connection_adapters/abstract_mysql_adapter'

puts 'Monkey-patch >>> ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      alias_method :orig_type_to_sql, :type_to_sql
      alias_method :orig_initialize_type_map, :initialize_type_map

      def blob_or_text_column?
        sql_type =~ /blob/i || type == :text || type == :json
      end

      def type_to_sql(type, limit = nil, precision = nil, scale = nil)
        if type.to_s == 'text' && limit == -1
          'json'
        else
          orig_type_to_sql type, limit, precision, scale
        end
      end

      protected

      def initialize_type_map(m)
        orig_initialize_type_map m
        m.register_type %r(json)i,       Type::Text.new(limit: -1)
      end
    end
  end
end
