# Limit the commits output to ones with log message that matches the specified pattern
# e.g. rake tc:gen-notes Sprint_5
namespace :tc do
  task 'gen-notes' do
    desc 'LF - Generate tagged release notes from Git commits'
    release = ARGV.last
    prev_release = `git describe --abbrev=0 --tags "#{release}^"`.chomp

    command = "git log --no-merges --format=%s \"#{prev_release}..#{release}\""
    output = `#{command}`
    notes = output.split("\n")
    notes.reject!(&:empty?)
    notes.reject! { |n| n.downcase.start_with? 'revert' }
    notes.uniq!

    if notes && notes.length > 0
      puts '===GENERATE RELEASE NOTE FROM GIT COMMIT NOTES==='
      erb = ERB.new(File.read('config/database.yml'))
      config = YAML.load(erb.result)[ENV['RAILS_ENV']]

      ActiveRecord::Base.establish_connection(config)
      # Insert a new search query if not exists
      result = ActiveRecord::Base.connection.execute("select count(`id`) from `tc_release_notes` where `release` = '#{release}'")
      if result.fetch[0].to_i > 0
        puts 'Update search query'
        stmt = ActiveRecord::Base.connection.raw_connection.prepare('update `tc_release_notes` set `notes` = ?, `updated_at` = ? where `release` = ?')
        stmt.execute("{\"data\":#{notes}}", Time.now, release)
      else
        puts 'Insert into database'
        stmt = ActiveRecord::Base.connection.raw_connection.prepare('insert into `tc_release_notes`(`notes`, `release`, `updated_at`) values(?, ?, ?)')
        stmt.execute("{\"data\":#{notes}}", release, Time.now)
      end
      puts notes
      puts '===DONE==='
    else
      puts '===There are no any notes matching your given patterns==='
    end
    task release.to_sym {}
  end
end
