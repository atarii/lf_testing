# Deploy TC on Ubuntu
## Prerequisites

1. Ubuntu 14.04 LTS 64-bit
2. Make sure system is up to date: `$ sudo apt-get update && sudo apt-get upgrade`

### Ruby installation method:
[ruby-install](https://www.ruby-lang.org/en/documentation/installation/#ruby-install) allows you to compile and install different versions of Ruby into arbitrary directories. There is also a sibling, chruby, which handles switching between Ruby versions. It is available for OS X, Linux, and other UNIX-like operating systems.

## I> Install ruby-install
Instruction reference:

[Installs Ruby, JRuby, Rubinius, MagLev or MRuby](https://github.com/postmodern/ruby-install#readme)

Steps:

	$ wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
	$ tar -xzvf ruby-install-0.5.0.tar.gz
	$ cd ruby-install-0.5.0/
	$ sudo make install

## II> Install ruby 2.1.5, rails 4.2.0, git and gems
Install ruby 2.1.5:

	$ sudo ruby-install ruby 2.1.5 --install-dir /usr/local
	$ sudo gem update --system
	
Install rails 4.2.0:

	$ sudo gem install rails -v 4.2.0
	
Install mysql gem:

	$ sudo apt-get install libmysqlclient-dev
	$ sudo gem install mysql -v 2.9.1

Install git:

	$ sudo apt-get install git-core
	Clone sqaauto_testcentral source code
	
Install gems:	

	$ cd sqaauto_testcentral
	$ sudo bundle install

## III> Configuration
Set environment variables in /etc/environment:

	RAILS_DB_USER=user
	RAILS_DB_PASS=pass
	RAILS_DB_HOST=host
	RAILS_DB_PORT=port
	RAILS_ENV=production
	RAILS_SERVER_IP=ip
	RAILS_SERVER_PORT=443
	RAILS_TIME_ZONE=time_zone
	
Log out to refresh Env

## Troubleshooting
**1. Javascript runtime error:**

	test@test-OptiPlex-390:~/Desktop/sqaauto_testcentral$ rails s
	WARN: Unresolved specs during Gem::Specification.reset:
      rake (>= 0.8.7)
	WARN: Clearing out unresolved specs.
	Please report a bug if this causes problems.
	/usr/local/lib/ruby/gems/2.1.0/gems/execjs-2.3.0/lib/execjs/runtimes.rb:45:in `autodetect': Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable)
	from /usr/local/lib/ruby/gems/2.1.0/gems/execjs-2.3.0/lib/execjs.rb:5:in `<module:ExecJS>'

==> add 'therubyracer' gem into Gemfile

**2. Cannot start rails server on port 443:**

	in 'start_tcp_server': no acceptor (port is in use or requires root privileges) (RuntimeError)

==> steps to resolve:

+ list port used: `lsof -i :443`

+ kill process established on 443 port: `kill -9 <PID>`

+ start rails server: `sudo rails s webrick -b 0.0.0.0`

**3. Bundle install stuck:**

During bundle installation, if a gem takes a lot of time to install, please cancel bundle and try again.

# Deploy Test Central with nginx + passenger
## Installing Passenger + Nginx

Reference: [Installing Passenger + Nginx](https://www.phusionpassenger.com/library/install/nginx/install/oss/trusty/)

### Step 1: Install passenger

	# Install our PGP key and add HTTPS support for APT
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
	sudo apt-get install -y apt-transport-https ca-certificates

	# Add our APT repository
	sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
	sudo apt-get update

	# Install Passenger + Nginx
	sudo apt-get install -y nginx-extras passenger

### Step 2: Enable the Passenger Nginx module and restart Nginx

Edit /etc/nginx/nginx.conf and uncomment passenger_root and passenger_ruby. For example, you may see this:

	# passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
	# passenger_ruby /ruby-interpreter-path;
	
Remove the '#' characters, like this:

	passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
	passenger_ruby /ruby-interpreter-path;	
	
To know where  [ruby interpreter](https://www.phusionpassenger.com/library/config/nginx/reference/#passenger_ruby) is:

	$ which ruby
	/usr/local/bin/ruby
	
When you are finished with this step, restart Nginx:

	$ sudo service nginx restart
	
### Step 3: Check installation	

After installation, please validate the install by running sudo passenger-config validate-install. For example:

	sudo passenger-config validate-install
	 * Checking whether this Phusion Passenger install is in PATH... ✓
	 * Checking whether there are no other Phusion Passenger installations... ✓
	 
All checks should pass. If any of the checks do not pass, please follow the suggestions on screen.

Finally, check whether Nginx has started the Passenger core processes. Run sudo passenger-memory-stats. You should see Nginx processes as well as Passenger processes. For example:

	sudo passenger-memory-stats
	Version: 5.0.8
	Date   : 2015-05-28 08:46:20 +0200
	...

	---------- Nginx processes ----------
	PID    PPID   VMSize   Private  Name
	-------------------------------------
	12443  4814   60.8 MB  0.2 MB   nginx: master process /usr/sbin/nginx
	12538  12443  64.9 MB  5.0 MB   nginx: worker process
	### Processes: 3
	### Total private dirty RSS: 5.56 MB

	----- Passenger processes ------
	PID    VMSize    Private   Name
	--------------------------------
	12517  83.2 MB   0.6 MB    PassengerAgent watchdog
	12520  266.0 MB  3.4 MB    PassengerAgent server
	12531  149.5 MB  1.4 MB    PassengerAgent logger
	...
	
Navigate to localhost, you will see Nginx message below:
	
	Welcome to nginx on Ubuntu!

	If you see this page, the nginx web server is successfully installed and working on Ubuntu. Further configuration is required.

	For online documentation and support please refer to nginx.org

	Please use the ubuntu-bug tool to report bugs in the nginx package with Ubuntu. However, check existing bug reports before reporting a new bug.

	Thank you for using Ubuntu and nginx.
	
## Public Test Central to Nginx

Reference: [How To Set Up Nginx Server Blocks (Virtual Hosts) on Ubuntu 14.04 LTS](https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-14-04-lts)	

There are 2 main folders of Nginx

+ sites-available: contains web applications' configuration files

+ sites-enabled: to make web applications available

### Step 1: Create Test Central configuration file

	sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/test_central.conf
	
Now, open the new file you created in your text editor with root privileges:

	sudo gedit /etc/nginx/sites-available/test_central.conf
	
Ignoring the commented lines, the file will look similar to this:

	server {
		# SSL configuration
		#
		listen 443 ssl;
		listen [::]:443 ssl;
		ssl on;
		ssl_certificate     /home/test/master_ubuntu/ssl/server.crt;
		ssl_certificate_key /home/test/master_ubuntu/ssl/server.key;

		root /home/test/master_ubuntu/public;

		server_name localhost;
		passenger_enabled on;
		passenger_spawn_method direct; # resolve App 3848 stderr: env: not found
	}
	
### Step 2: Enable Test Central web application

	sudo ln -s /etc/nginx/sites-available/test_central.conf /etc/nginx/sites-enabled/
	
### Step 3: [Passing environment variables](http://old.blog.phusion.nl/2008/12/16/passing-environment-variables-to-ruby-from-phusion-passenger/) to Ruby from Phusion Passenger

Since rails application does not know where gems are and environment variables, we need to do the following steps:

1: Create a new executable file (chmod +x), e.g. **ruby__with__env** in /usr/local/bin with content:

	#!/bin/sh
	export PATH="/usr/local/bin" # path of executable gems
	export RAILS_DB_USER=user
	export RAILS_DB_PASS=pass
	export RAILS_DB_HOST=host
	export RAILS_DB_PORT=port
	export RAILS_ENV=production
	export RAILS_SERVER_IP=ip
	export RAILS_SERVER_PORT=443
	export RAILS_TIME_ZONE=time_zone
	exec "/usr/local/bin/ruby" "$@"
	
2: Open /etc/nginx/nginx.conf

3: Update *passenger_ruby* to */usr/local/bin/ruby_with_env*

Now, we are ready to restart Nginx to enable your changes and the **Test Central will be started**. You can do that by typing:

	sudo service nginx restart
	
4: Navigate to Test Central and then you will see the app
	
# Troubleshooting
### 1. Permission deny: [reference](https://www.digitalocean.com/community/questions/permission-denied-on-deploying-rails)

	App 3708 stdout: ActionView::Template::Error (Permission denied @ utime_internal - /home/test/master_ubuntu/tmp/cache/assets/production/sprockets/v3.0/oJ4y4y5nYkZ7si9wK2dZyoBImSsvJbfPpvyLqxGjwtc.cache):
	App 3708 stdout:     2: <html>
	App 3708 stdout:     3:   <head>
	App 3708 stdout:     4:     <title><%= full_title(yield(:title)) %></title>
	App 3708 stdout:     5:     <%= favicon_link_tag 'favicon.ico', rel: 'shortcut icon', type: 'image/x-icon' %>
	App 3708 stdout:     6:     <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true %>
	App 3708 stdout:     7:     <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
	App 3708 stdout:     8:     <%= javascript_include_tag params[:controller] if ::Rails.application.assets.find_asset("#{params[:controller]}.js") %>

#### To resolve:
	sudo chgrp -R test /home/test/master_ubuntu/tmp
	chmod -R g+w /home/test/master_ubuntu/tmp
	
### 2. If you encounter any problems, please take a look on /var/log/nginx/error.log	