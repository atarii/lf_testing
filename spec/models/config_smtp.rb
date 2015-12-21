require 'spec_helper'
require 'read_config_xml'

class RailsAppConfigUnitTest
  describe 'Admin Configuration: SMTP Setting' do
    # Set variable
    smtp_info = nil

    before :all do
      smtp_info = ReadXML.new.smtp_info
      @address = smtp_info[:address]
      @port = smtp_info[:port]
      @domain = smtp_info[:domain]
      @username = smtp_info[:username]
      @password = smtp_info[:password]
      @attach_type = smtp_info[:attachment_type]
    end

    context 'TC01 - Update SMTP address' do
      it 'Update SMTP address' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', @port, @domain, @username, @password, @attach_type)
        expect(ReadXML.new.smtp_info[:address]).to eq('smtp1.gmail.com')
      end
    end

    context 'TC02 - Update SMTP port' do
      it 'Update SMTP port' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', '588', @domain, @username, @password, @attach_type)
        expect(ReadXML.new.smtp_info[:port]).to eq('588')
      end
    end

    context 'TC03 - Update SMTP domain' do
      it 'Update SMTP domain' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', '588', 'testcentral1.com', @username, @password, @attach_type)
        expect(ReadXML.new.smtp_info[:domain]).to eq('testcentral1.com')
      end
    end

    context 'TC04 - Update SMTP username' do
      it 'Update SMTP username' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', '588', 'testcentral1.com', 'lflgautomation@gmail1.com', @password, @attach_type)
        expect(ReadXML.new.smtp_info[:username]).to eq('lflgautomation@gmail1.com')
      end
    end

    context 'TC05 - Update SMTP password' do
      it 'Update smtp password' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', '588', 'testcentral1.com', 'lflgautomation@gmail1.com', '1234567', @attach_type)
        expect(ReadXML.new.smtp_info[:password]).to eq('1234567')
      end
    end

    context 'TC06 - Update SMTP attach type' do
      it 'Update SMTP attach type - ZIP' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', '588', 'testcentral1.com', 'lflgautomation@gmail1.com', '1234567', 'ZIP')
        expect(ReadXML.new.smtp_info[:attachment_type]).to eq('ZIP')
      end

      it 'Update SMTP attach type - HTML' do
        RailsAppConfig.new.update_smtp_settings('smtp1.gmail.com', '588', 'testcentral1.com', 'lflgautomation@gmail1.com', '1234567', 'HTML')
        expect(ReadXML.new.smtp_info[:attachment_type]).to eq('HTML')
      end
    end

    context 'TC07 - Update SMTP mix fields' do
      before :all do
        RailsAppConfig.new.update_smtp_settings('smtp.gmail.com', '587', 'testcentral.com', 'lflgautomation@gmail.com', '123456', 'NONE')
        smtp_info = ReadXML.new.smtp_info
      end

      it 'Verify SMTP info updates correctly' do
        expect(smtp_info).to eq(address: 'smtp.gmail.com',
                                port: '587',
                                domain: 'testcentral.com',
                                username: 'lflgautomation@gmail.com',
                                password: '123456',
                                attachment_type: 'NONE')
      end
    end

    after :all do
      RailsAppConfig.new.update_smtp_settings(@address, @port, @domain, @username, @password, @attach_type)
    end
  end
end
