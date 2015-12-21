class Sqaauto16331013ReleaseContentAutomationDatabaseUsUpSpecialmsgColumnTo500 < ActiveRecord::Migration
  def down
    change_column :atg_moas, :specialmsg, :string, limit: 255, null: false
  end

  def up
    say "SQAAUTO-1633 10/13 release: CONTENT Automation: Database: US Test Central: Request to update the number of character in 'specialmsg' column to '500'"
    change_column :atg_moas, :specialmsg, :string, limit: 500, null: false
  end
end
