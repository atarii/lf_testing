class Sqaauto1569UntilitiesClearAccoutErrorWhileClearingAccountMysqlServerErrorDataTooLongForColumnDeviceAtRowErrorMessageDisplays < ActiveRecord::Migration
  def up
    say "SQAAUTO-1569 Untilities/Clear Accout: Error while clearing account: Mysql::ServerError::DataTooLong: Data too long for column 'device' at row... error message displays"
    drop_table :accounts
  end
end
