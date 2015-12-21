class PinRedemption
  def self.get_pin_number(env, code_type, status)
    pin = Connection.my_sql_connection("select pin_number from pins where env = '#{env}' and code_type = '#{code_type}' and status = '#{status}' limit 1").fetch_hash
    return '' if pin.blank?
    pin['pin_number']
  end

  def self.get_pin_info(env, code_type, status)
    pin = Connection.my_sql_connection("select env, code_type, pin_number, platform, location, amount, currency, status  from pins where env = '#{env}' and code_type = '#{code_type}' and status = '#{status}' limit 1").fetch_hash
    return {} if pin.blank?
    pin
  end

  def self.update_pin_status(env, code_type, pin_number, status)
    Connection.my_sql_connection("update pins set status = '#{status}' where env = '#{env}' and code_type = '#{code_type}' and pin_number = '#{pin_number}'")
  end
end

class ATGConfiguration
  def self.get_atg_data
    data = Connection.my_sql_connection('select data from atg_configurations order by updated_at desc limit 1').fetch_hash
    return 'Please config ATG data before running test cases' if data.nil?

    atg_data = JSON.parse(data['data'], symbolize_names: true)
    {
      acc_account: {
        empty_acc: atg_data[:ac_account][:empty_acc],
        credit_acc: atg_data[:ac_account][:credit_acc],
        balance_acc: atg_data[:ac_account][:balance_acc],
        credit_balance_acc: atg_data[:ac_account][:credit_balance_acc]
      },
      paypal_acc: {
        p_us_acc: atg_data[:paypal_account][:p_us_acc],
        p_ca_acc: atg_data[:paypal_account][:p_ca_acc],
        p_uk_acc: atg_data[:paypal_account][:p_uk_acc],
        p_ie_acc: atg_data[:paypal_account][:p_ie_acc],
        p_au_acc: atg_data[:paypal_account][:p_au_acc],
        p_row_acc: atg_data[:paypal_account][:p_row_acc]
      },
      catalog_entry: {
        prod_id: atg_data[:catalog_entry][:prod_id],
        ce_sku: atg_data[:catalog_entry][:ce_sku],
        ce_catalog_title: atg_data[:catalog_entry][:ce_catalog_title],
        ce_product_type: atg_data[:catalog_entry][:ce_product_type],
        ce_price: atg_data[:catalog_entry][:ce_price],
        ce_strike: atg_data[:catalog_entry][:ce_strike],
        ce_sale: atg_data[:catalog_entry][:ce_sale],
        ce_pdp_title: atg_data[:catalog_entry][:ce_pdp_title],
        ce_cart_title: atg_data[:catalog_entry][:ce_cart_title],
        ce_pdp_type: atg_data[:catalog_entry][:ce_pdp_type]
      },
      vin_acc: {
        vin_username: atg_data[:vin_acc][:vin_username],
        vin_password: atg_data[:vin_acc][:vin_password]
      }
    }
  end
end
