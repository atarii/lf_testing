This is to setup MySql for Test Central.

# Setup of MySql Labs 5.7.8-rc w/ JSON support using docker Virtual-Box instance

## Snapshot Database
1. From Windows CMD
```
cd C:
cd \dev\sqaauto-testcentral
rake db:snapshot
```

## Shutdown local MySQL server
1. Stop any local MySQL instance
2. From Windows CMD, expose MySQL to localhost - verify no other listners on MySQL port 3306
```
netstat -a -n | findstr 3306
```

## MySQL Labs 5.7.8-RC Setup on Windows [reference]( http://mysqlserverteam.com/getting-started-with-mysql-json-on-windows)
1. Download and install docker for Windows
2. Run "Boot2Docker Start" from Windows Start Menu to start Docker CLI
3. From Docker window, install and run mysql instance (replace [PASSWORD] with root mysql password)
```
docker run -p 3306:3306 --name ml -e MYSQL_ROOT_PASSWORD=[PASSWORD] -d mysql:5.7.8-rc
```
4. From Docker window, test connection (replace [PASSWORD] with root mysql password)
```
docker exec -it ml bash
mysql -p
[PASSWORD]
exit
exit
```
5. Configure Docker VM network setting from Open VirtualBox UI => Settings\Network\Advanced\Port Forwarding
  add rule using the following

| Name | Protocol | Host IP   | Host Port | Guest IP | Guest Port |
-------------------------------------------------------------------
|MySQL | TCP      | 127.0.0.1 | 3306      |           | 3306      |

6. Shutdown Docker VM from VirtualBox UI => Close\ACPI Shutdown


## Starting Docker MySQL instance
1. Stop any local MySQL instance
2. Run "Boot2Docker Start"
3. From Docker window, start the 'ml' mysql instance
```
docker run ml
```
4. From Docker window, verify 'ml' is running
```
docker ps
```

## Migrate Database
1. From Windows CMD
```
cd C:
cd \dev\sqaauto-testcentral
bundle install
rake db:create
rake db:restore
rake db:migrate
```

## Done!
Now you should have:
1. A running Docker instance of MySQL with JSON
2. Test Central db migrated to the Docker MySQL server

## Notes
Before starting the Docker Virtual-Box instance, you need to have your local MySQL server off so that network port goes to Docker.



# Add another MySQL docker container instance to an existing docker host
Use a different external port and the same IP.
1. Shutdown the Docker VM in VirtualBox
2. Add the new port number (Ex. 3308) to the network config
3. Start Docker (Windows Firewall should prompt, select okay)
4. Start the existing docker containers (i.e. your original MySQL instance)
5. Create a new MySQL docker container with the new port mapped to the default MySQL port (Ex. -p 3308:3306)
```
docker run -p 3308:3306 --name ml-[NEW_NAME] -e MYSQL_ROOT_PASSWORD=[PASSWORD] -d mysql:5.7.8-rc
```
6. For your TC server set the System Environment variables
```
setx RAILS_DB_HOST=[IP here]
setx RAILS_DB_PORT=3308
```
7. Start your TC server

# Make MySQL instance available for remote access
1. Shutdown the Docker VM in VirtualBox
2. Open the network config and then update the instance's Host IP to 0.0.0.0
3. Start the Docker VM
