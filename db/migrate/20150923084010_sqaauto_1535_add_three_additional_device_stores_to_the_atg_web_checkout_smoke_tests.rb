class Sqaauto1535AddThreeAdditionalDeviceStoresToTheAtgWebCheckoutSmokeTests < ActiveRecord::Migration
  def up
    say 'SQAAUTO-1535 [F6Q2_S16] Add three additional device stores to the ATG Web Checkout Smoke Tests'
    @connection = ActiveRecord::Base.connection
    @connection.execute "UPDATE cases SET name='ATG Web Checkout Smoke Tests', description='ATG Web Checkout Smoke Tests', script_path='13_dv_soft_good_smoke_test/dvst01_atg_web_checkout_smoke_test.rb' WHERE id=438"
    @connection.execute 'DELETE FROM case_suite_maps WHERE suite_id=65 AND case_id=384'

    say 'Update Code Type'
    @connection.execute 'DELETE FROM `atg_code_type`'
    @connection.execute "INSERT INTO `atg_code_type` VALUES ('USV1','USV1 - U.S. Retail Physical Card'),('USV2','USV2 - U.S. LF.com Physical Card'),('USV3','USV3 - U.S. LF.com Virtual Code (email delivery)'),('CAV1','CAV1 - Canada Retail Physical Card'),('CAV2','CAV2 - Card LF.ca Virtual Code (email delivery)'),('CAV3','CAV3 - Canada. LF.com 10 CAD (email delivery)'),('UKV1','UKV1 - UK Retail Physical Card'),('AUV1','AUV1 - AU/NZ Retail Physical Card '),('IRV1','IRV1 - Ireland Retail Physical Card'),('OTHR','OTHR - Rest of World Retail Physical Card '),('FRV1','FRV1 - France Retail Physical Cards (legacy Leaplet system)-'),('FRV2','FRV2 - French Canada Retail Physical Cards (legacy Leaplet system)'),('FRV3','FRV3 - French Canada Virtual codes for French App Center');"
  end
end
