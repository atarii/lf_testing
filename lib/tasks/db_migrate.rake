# Enhance rails task to regenerate the seeds file
# Check the local Git status of migration files (if no change/commit pending then skip re-gen)

Rake::Task['db:migrate'].enhance do
  next if `git status db/migrate -s` == '' || ENV['RAILS_ENV'] != 'development'

  desc 'LF - Also reset the test database and regenerate seeds.rb'
  puts 'Regenerate seeds using test database'

  puts '-- test db:migrate:reset'
  system 'rake db:migrate:reset RAILS_ENV=test'

  puts '-- test db:seed:dump'
  system 'rake db:seed:dump RAILS_ENV=test'

  puts 'done!'
end
