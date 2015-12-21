require 'active_support/core_ext/string/strip'

namespace :db do
  namespace :seed do
    task dump: [:environment, :load_config] do
      desc 'LF - Create a db/seeds.rb file from the database'

      # get information from config/database.yml file
      erb = ERB.new(File.read('config/database.yml'))
      config = YAML.load(erb.result)[ENV['RAILS_ENV']]
      database = config['database']
      username = config['username']
      password = config['password']

      puts "Using '#{database}' database"

      seeds_path = File.join('db', 'seeds.rb').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)

      command = "mysqldump #{database} -u #{username} -p#{password} --host #{config['host']} --port #{config['port']} --no-create-info --no-create-db --ignore-table=#{database}.schema_migrations  --ignore-table=#{database}.stations"
      output = `#{command}`

      ActiveRecord::Base.establish_connection(config)
      version = ActiveRecord::Base.connection.exec_query('select * from schema_migrations order by version desc limit 1').first.first[1]

      tables = output.scan(/(insert into `([^`]+).*)/i)
      puts " generated #{output.lines.size} lines for #{tables.size} tables"

      File.open(seeds_path, 'w') do |file|
        file.puts <<-INTERPOLATED_HEREDOC.strip_heredoc
          # encoding: UTF-8
          # This file is auto-generated from the current state of the database.
          #
          # #{version} database version used
          # #{tables.size} tables had data

          puts 'Seeding #{tables.size} tables for database version #{version}'

        INTERPOLATED_HEREDOC

        file.puts <<-'HEREDOC'.strip_heredoc
          @connection = ActiveRecord::Base.connection
          def insert_data(number, table_name, insert_sql)
            before = @connection.exec_query("select count(1) from #{table_name}").first.first[1].to_i
            @connection.execute insert_sql
            after = @connection.exec_query("select count(1) from #{table_name}").first.first[1].to_i
            puts "#{number}.\t#{after - before}\t#{after}\t#{table_name}"
          end

          puts "#\tadded\ttotal\ttable"

        HEREDOC

        tables.each_with_index do |table, index|
          names = ''
          selected_columns = []
          array_length = []
          columns_name = ActiveRecord::Base.connection.exec_query("show columns from #{table[1]}").rows
          columns_name.delete_if { |x| x[0].end_with? '_at' }

          columns_name.each do |x|
            selected_columns.push "`#{x[0]}`"
            record_values = ActiveRecord::Base.connection.exec_query("select `#{x[0]}` from #{table[1]}").rows.flatten.compact.max_by(&:length)
            max_length = record_values.nil? ? 1 : record_values.length

            if x[0].to_s.length >= max_length
              names += x[0] + ',   '
              array_length.push x[0].to_s.length
            else
              names += x[0] + ',   ' + ' ' * (max_length - x[0].length)
              array_length.push max_length
            end
          end

          names.slice! names.rindex(',')
          names.gsub! 'order', '`order`'

          value_data = ActiveRecord::Base.connection.exec_query("select #{selected_columns.join(',')} from #{table[1]}").rows
          array_data = []

          value_data.each do |e|
            text = ''

            e.each_with_index do |item, ind|
              if item.nil?
                text << 'NULL' + ',   ' + ' ' * (array_length[ind] - 4)
              else
                text << "'" + item.to_s.gsub("'", "\\\\'") + "'" + ', ' + ' ' * (array_length[ind] - item.to_s.length)
              end
            end

            text.slice! text.rindex(',')
            array_data.push text.chop
          end

          print_data = ''
          array_data.each { |element| print_data += '(' + element.to_s.gsub("\n", '\\n') + "),\n            " }

          file.puts <<-INTERPOLATED_HEREDOC.strip_heredoc
            insert_data #{index + 1}, '#{table[1]}', <<-'HEREDOC'
            INSERT INTO `#{table[1]}`
            (#{names.chop}) VALUES
            #{print_data.strip.chop + ';'}
            HEREDOC

          INTERPOLATED_HEREDOC
        end

        file.puts "puts 'done!'"
      end
    end
  end
end
