source 'https://rubygems.org'
ruby '2.1.5'

# HTML, JS, CSS, UI
gem 'bootstrap-sass', '3.3.4.1'
gem 'chart-js-rails', '0.0.9'
gem 'github-markup', '1.4.0'
gem 'jquery-rails', '4.0.3'
gem 'redcarpet', '3.3.2'              # a fast, safe and extensible Markdown to (X)HTML parser
gem 'sass-rails', '5.0.1'
gem 'turbolinks', '2.5.3'             # makes following links in your web application faster. see: https://github.com/rails/turbolinks
gem 'uglifier', '2.7.1'               # compressor for JavaScript assets

# Test Automation
gem 'capybara', '2.5.0'
# gem 'capybara-webkit', '1.7.0'
gem 'rest-client', '1.8.0'            # REST client
gem 'roadie', '3.0.5'                 # embed css to inline html
gem 'roadie-rails', '1.0.6'           # roadie 3.0.5 dependency
gem 'rspec', '3.2.0'
gem 'rspec-legacy_formatters', '1.0.0'
gem 'rspec-rails', '3.2.1'
gem 'savon', '2.10.0'                 # SOAP client
gem 'selenium-webdriver', '2.47.1'
gem 'site_prism', '2.6'
gem 'dashing-rails'
gem 'puma'
gem 'capistrano'


# System
gem 'bcrypt-ruby', '3.1.5'            # crypto
gem 'htmlentities', '4.3.3'           # encode/decode (x)html entities
gem 'jbuilder', '2.2.9'
gem 'lograge', '0.3.1'                # single-line logging
gem 'mail', '2.6.3'                   # email
gem 'mime-types', '2.4.3'             # mime-type data
gem 'mysql', '2.9.1'                  # db access
gem 'nokogiri', '1.6.6.2'             # html/xml document parser
gem 'parallel', '1.4.1'               # parallel execution
gem 'public_activity', '1.4.2'        # auditing
gem 'rails', '4.2.0'                  # rails framework
gem 'render_anywhere', '0.0.11', :require => false
gem 'responders', '2.1.0'
gem 'roo', '1.13.2'                   # spreadsheet parser for Excel, etc.
gem 'ruby-mysql', '2.9.13', github: 'CCedricYoung/ruby-mysql' # pure ruby MySQL connector, w/ JSON type
gem 'rubyzip', '1.1.7'                # read and write zip files
gem 'rufus-scheduler', '3.0.9'        # scheduler
gem 'tzinfo-data', '1.2015.1'         # time zone data
gem 'yaml_db', '0.3.0'                # save and load db data with yaml file
gem 'execjs', '2.3.0'
gem 'therubyracer', '0.12.2'

group :development, :test do
  gem 'rubocop', '0.33.0'               # automatic Ruby code style checking
  gem 'pry', '~>0.10'                 # usage in code: binding.pry
  gem 'pry-byebug', '~>3.1'           # usage in pry: next, step, finish, continue, break
  gem 'pry-clipboard', '~>0.1'        # usage in pry: copy-history, copy-result, paste
  gem 'pry-rescue', '~>1.4'           # usage in cli: rescue rails s webrick
  gem 'pry-stack_explorer', '~>0.4'   # usage in pry: up, down, frame, show-stack
  gem 'sdoc', '0.4.1', require: false # generates the API under doc/api. usage: bundle exec rake doc:rails
  gem 'web-console', '2.1.0'          # access an IRB console on exception pages or by using <%= console %>
end

group :production do
  gem 'rails_12factor', '0.0.3'
end
