require 'mysql'

class Connection
  attr_accessor :con

  #
  # static method: execute sql statement
  #
  def self.execute_sql_statement(query_string)
    config = Rails.configuration.database_configuration
    host = config[Rails.env]['host']
    port = config[Rails.env]['port']
    database = config[Rails.env]['database']
    username = config[Rails.env]['username']
    password = config[Rails.env]['password']

    # Initiate connection to mysql database
    con = Mysql.new host, username, password, database, port

    # Execute query
    rs = con.query query_string

    # Close connection
    con.close

    rs
  end

  #
  # open connection
  #
  def open_connection(host, port, username, password, database)
    @con = Mysql.new host.to_s.strip, username.to_s.strip, password.to_s.strip, database.to_s.strip, port.to_s.strip.to_i
  end

  #
  # open connection with information from database.yml
  #
  def open_connection_in_config
    config = Rails.configuration.database_configuration
    host = config[Rails.env]['host']
    port = config[Rails.env]['port']
    database = config[Rails.env]['database']
    username = config[Rails.env]['username']
    password = config[Rails.env]['password']
    @con = Mysql.new host.to_s.strip, username.to_s.strip, password.to_s.strip, database.to_s.strip, port.to_s.strip.to_i
  end

  #
  # execute sql statement
  #
  def execute_sql_statement(statement)
    @con.query statement
  end

  #
  # close connection
  #
  def close_connection
    @con.close if @con
  end
end
