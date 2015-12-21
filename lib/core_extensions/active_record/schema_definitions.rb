require 'active_record/connection_adapters/abstract/schema_definitions'

puts 'Monkey-patch >>> ActiveRecord::ConnectionAdapters::TableDefinition'

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      [:json].each do |column_type|
        define_method column_type do |*args|
          options = args.extract_options!
          column_names = args
          column_names.each { |name| column(name, column_type, options) }
        end
      end
    end
  end
end
