require 'const'
require 'mysql'

# This class initiate connection to MySql and execute queries
class DBConnection
  def self.execute_statement(querystring)
    # Initiate connection to mysql database
    con = Mysql.new MySQLConst::CONST_SERVER, MySQLConst::CONST_USERNAME, MySQLConst::CONST_PASSOWRD, MySQLConst::CONST_DATABASE, MySQLConst::CONST_PORT

    # Excute query
    rs = con.query querystring

    # Close connection
    con.close

    rs
  end

  def self.get_expected_result_by_test_id(lfid)
    con = Mysql.new MySQLConst::CONST_SERVER, MySQLConst::CONST_USERNAME, MySQLConst::CONST_PASSOWRD, MySQLConst::CONST_DATABASE, MySQLConst::CONST_PORT
    rs =  con.query "select * from ws_restfulcalls_output where restfulcalls_id=#{lfid}"

    con.close

    rs
  end
end
