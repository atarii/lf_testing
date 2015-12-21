namespace :db do
  task snapshot: :environment do
    desc 'LF - Dump schema and data to db/snapshot-schema.rb and db/snapshot-data.yml'

    puts '***DUMP SCHEMA AND DATA TO db/snapshot-schema.rb and db/snapshot-data.yml***'
    ENV['SCHEMA'] = "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/snapshot-schema.rb"
    Rake::Task['db:schema:dump'].invoke

    def db_dump_data_file(_extension)
      "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/snapshot-data.yml"
    end

    Rake::Task['db:data:dump'].invoke
    puts 'done!'
  end

  task :restore do
    desc 'LF - Load schema and data from db/snapshot-schema.rb and db/snapshot-data.yml'

    f_schema = "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/snapshot-schema.rb"
    f_data = "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/snapshot-data.yml"
    does_exist_schema = File.exist? f_schema
    does_exist_data = File.exist? f_data

    if does_exist_schema && does_exist_data
      puts '***LOAD SCHEMA AND DATA FROM db/snapshot-schema.rb and db/snapshot-data.yml***'

      ENV['SCHEMA'] = f_schema
      Rake::Task['db:schema:load'].invoke

      def db_dump_data_file(_extension)
        "#{ActiveRecord::Tasks::DatabaseTasks.db_dir}/snapshot-data.yml"
      end

      erb = ERB.new(File.read('config/database.yml'))
      config = YAML.load(erb.result)[ENV['RAILS_ENV']]
      ActiveRecord::Base.establish_connection(config)

      # Since max_allowed_packet does not accept decimal number when they convert to file size, so we need to remove decimal fraction and
      # plus buffer size 5Mb to make sure
      ActiveRecord::Base.connection.execute "SET GLOBAL max_allowed_packet=#{(File.size(f_data).to_f / 1024).round(0) * 1024 + 5*1024}"

      Rake::Task['db:data:load'].invoke
      puts 'done!'
    else
      puts 'There is no schema or data file. Please re-check and try it again!'
    end
  end
end
