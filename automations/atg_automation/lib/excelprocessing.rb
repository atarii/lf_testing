require 'roo'
require 'csv'
require 'date'

class DataDriven
  # Return LF Account info from CSV data
  def self.account_info(csv_data)
    { first_name: csv_data['first_name'].to_s,
      last_name: csv_data['last_name'].to_s,
      email: csv_data['email'].to_s,
      user_name: csv_data['username'].to_s,
      password: csv_data['password'].to_s }
  end

  # Return Credit Card info from CSV data
  def self.credit_card_info(csv_data)
    { credit_card_number: csv_data['credit_card_number'].to_s.delete('{}'),
      credit_card_type: csv_data['card_type'].to_s,
      credit_card_name: csv_data['name_on_card'].to_s,
      exp_month: Date::MONTHNAMES[csv_data['exp_month'].to_i].to_s,
      exp_year: csv_data['exp_year'].to_s,
      security_code: csv_data['security_code'].to_s,
      street: csv_data['street'].to_s,
      city: csv_data['city'].to_s,
      state: csv_data['state'].to_s,
      country: csv_data['country'].to_s,
      zip_code: csv_data['zipcode'].to_s,
      phone_number: csv_data['phone_number'].to_s }
  end

  # Validate data from CSV file
  def self.validate_csv_data(hash_data)
    arr = []
    hash_data.each do |key, value|
      arr.push(key) if (value == '')
      case key
      when :email, :user_name
        arr.push(key) unless data_valid?('email', value)
      when :password
        arr.push(key) unless data_valid?('password', value)
      end
    end

    arr.uniq
  end

  def self.data_valid?(field, value)
    case field
    when 'email'
      email_match = /\A[\w\u00C0-\u017F\-]+(\.[\w\u00C0-\u017F\-]+)?@[\w\u00C0-\u017F\-]+\.[\w]{2,6}$/.match value
      is_valid = email_match.nil?
    when 'password'
      pass_match = /^[([a-z]|[A-Z])0-9_-]{6,20}$/.match value
      is_valid = pass_match.nil?
    end

    !is_valid
  end
end
