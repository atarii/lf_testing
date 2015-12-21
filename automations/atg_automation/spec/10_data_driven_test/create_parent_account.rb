require File.expand_path('../../spec_helper', __FILE__)
require 'atg_home_page'
require 'atg_login_register_page'
require 'atg_my_profile_page'

=begin
Data-drive creating LF Parent account(s).
=end

# Webservice info
caller_id = ServicesInfo::CONST_CALLER_ID
atg_home_page = HomeATG.new
atg_register_page = nil
atg_my_profile_page = nil
is_valid_data = true
invalid_data_arr = []
account_info = nil
credit_card_info = nil

# Get data from Data-Driven CSV file
account_arr = eval(Data::DATA_DRIVEN_CONST)

describe "Data-drive creating LF Parent account(s) - Total SKUs: #{account_arr.count}", js: true do
  # Validate all test data
  if account_arr.count == 0
    is_valid_data = false
    invalid_data_arr.push(row: 0, fields: 'Empty test data')
  else
    # Validate row data
    account_arr.each_with_index do |row, index|
      # Validate account info
      account_info = DataDriven.account_info(row)
      acc_invalid_row = DataDriven.validate_csv_data(account_info)

      # If user input Credit Card -> Validate info: cc_name. expiration_date, street, city,...
      credit_card_info = DataDriven.credit_card_info(row)
      cc_invalid_row = credit_card_info[:credit_card_number] == '' ? [] : DataDriven.validate_csv_data(credit_card_info)

      # Push all invalid fields into an array
      invalid_data_row = acc_invalid_row + cc_invalid_row
      if !invalid_data_row.empty?
        is_valid_data = false
        invalid_data_arr.push(row: index, fields: invalid_data_row.to_s)
      end
    end
  end

  if !is_valid_data
    context 'Data validation' do
      invalid_data_arr.each do |d|
        it "Invalid data: Row = #{d[:row] + 1} - Fields = #{d[:fields]}"
      end
    end
  else
    account_arr.each_with_index do |row, index|
      # Set variable to fill-in Context and It-do
      account_info = nil
      customer_id = nil
      child_id = nil
      session = nil
      locale = Data::LOCALE_CONST
      language = Data::LANGUAGE_CONST
      location = Data::LOCATION_CONST
      account_info = DataDriven.account_info(row)
      credit_card_info = DataDriven.credit_card_info(row)
      devices = (row[:devices].to_s == '') ? [] : row[:devices].split(',')
      pins = (row[:pins].to_s == '') ? [] : row[:pins].strip.split(',')

      context "#{index + 1}. Register new LF Account = '#{row['email']}'" do
        before :all do
          # Set variable
          account_info = DataDriven.account_info(row)
          credit_card_info = DataDriven.credit_card_info(row)
          devices = (row['devices'].nil?) ? [] : row['devices'].split(',')
          pins = (row['pins'].nil?) ? [] : row['pins'].strip.split(',')
        end

        context 'Register customer' do
          cus_info = nil
          before :all do
            register_cus_res = CustomerManagement.register_customer(caller_id, account_info[:first_name], account_info[:last_name], account_info[:email], account_info[:user_name], account_info[:password], location)
            customer_id = register_cus_res.xpath('//customer/@id').text
            cus_info = CustomerManagement.fetch_customer(caller_id, customer_id)
          end

          it 'Verify customer ID' do
            expect(customer_id.to_i > 0).to eq(true)
          end

          it "Verify First name: #{account_info[:first_name]}" do
            expect(cus_info.xpath('//customer/@first-name').text).to eq(account_info[:first_name])
          end

          it "Verify Last name: #{account_info[:last_name]}" do
            expect(cus_info.xpath('//customer/@last-name').text).to eq(account_info[:last_name])
          end

          it "Verify Email: #{account_info[:email]}" do
            expect(cus_info.xpath('//customer/email').text).to eq(account_info[:email])
          end

          it "Verify User name: #{account_info[:user_name]}" do
            expect(cus_info.xpath('//customer/credentials/@username').text).to eq(account_info[:user_name])
          end

          it "Verify Password: #{account_info[:password]}" do
            expect(cus_info.xpath('//customer/credentials/@password').text != '').to eq(true)
          end

          it "Verify Locale: #{location}" do
            expect(cus_info.xpath('//customer/@locale').text).to eq(location)
          end
        end

        context 'Claim device' do
          if devices.length == 0
            it 'There is no device to claim' do
            end
          else
            before :all do
              # acquire service session
              session_res = AuthenticationService.acquire_service_session(caller_id, account_info[:user_name], account_info[:password])
              session = session_res.xpath('//session').text

              # register child
              register_child_res = ChildManagementService.register_child(caller_id, session, customer_id)
              child_id = register_child_res.xpath('//child/@id').text
            end

            devices.each do |device_serial|
              list_nominated_devices_arr = nil
              before :all do
                fetch_device_res = DeviceManagementService.fetch_device(caller_id, device_serial)
                platform = fetch_device_res.xpath('//device/@platform').text

                OwnerManagementService.claim_device(caller_id, session, device_serial, platform, '0', 'ProfileName', child_id)
                DeviceProfileManagementService.assign_device_profile(caller_id, customer_id, device_serial, platform, '0', 'ProfileName', child_id)

                # get all nominated devices
                list_nominated_devices_arr = DeviceManagementService.get_nominated_devices(caller_id, session, 'service')
              end

              # claim account to each device
              it "Claim account to device: '#{device_serial}'" do
                expect(list_nominated_devices_arr).to include(device_serial)
              end
            end
          end
        end

        context 'Login account to LF.com' do
          it '1. Go to App Center home page' do
            atg_home_page.load
          end

          it '2. Go to register/login page' do
            atg_register_page = atg_home_page.goto_login
          end

          it '3. Login to existing account' do
            atg_my_profile_page = atg_register_page.login(account_info[:user_name], account_info[:password])
          end

          it '4. Verify My Profile page displays' do
            expect(atg_my_profile_page.my_profile_page_exist?).to eq(true)
          end

          it "5. Go to 'Account information' page" do
            atg_my_profile_page.goto_account_information
          end

          it '6. Verify Account information in My Profile page is correct' do
            expect(atg_my_profile_page.get_account_info).to include("#{account_info[:first_name]} #{account_info[:last_name]} #{account_info[:user_name]}")
          end
        end

        context 'Redeem PINS' do
          if pins.length == 0
            it 'There is no PIN to redeem' do
            end
          end

          pins.each do |p|
            pin = p.gsub(/-|\r/, '')

            # fetch PIN information
            pin_info = PinManagementService.get_pin_information(caller_id, pin)

            if pin_info[:has_error] == 'error'
              it "Invalid PINs: '#{pin}'"
              next
            end

            # If PIN is not available
            if pin_info[:status] != 'AVAILABLE'
              it "PIN is not available: '#{pin}'"
              next
            end

            it "Redeem value Card: #{pin}" do
              PinManagementService.redeem_value_card(caller_id, customer_id, pin, locale)
              pin_info = PinManagementService.get_pin_information(caller_id, pin)

              expect(pin_info[:status]).to eq('REDEEMED')
            end
          end
        end

        context 'Add Credit Card' do
          if credit_card_info[:credit_card_number] == ''
            it 'There is no Credit Card' do
            end
          else
            it "Add new Credit Card and Billing Address: '#{credit_card_info[:credit_card_number]}'" do
              credit_card = {
                card_number: credit_card_info[:credit_card_number],
                cart_type: credit_card_info[:credit_card_type],
                card_name: credit_card_info[:credit_card_name],
                exp_month: credit_card_info[:exp_month],
                exp_year: credit_card_info[:exp_year],
                security_code: credit_card_info[:security_code]
              }

              billing_address = {
                street_address: credit_card_info[:street],
                city: credit_card_info[:city],
                state: credit_card_info[:state],
                country: credit_card_info[:country],
                postal_code: credit_card_info[:zip_code],
                phone_number: credit_card_info[:phone_number]
              }

              atg_my_profile_page.add_new_credit_card_with_new_billing(credit_card, billing_address)
            end
          end
        end

        # Log out
        after :all do
          atg_my_profile_page.logout
        end
      end
    end
  end
end
