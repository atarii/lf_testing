require 'spec_helper'
require 'read_config_xml'

class RailsAppConfigUnitTest
  describe 'Admin Configuration: Limit Test Run Setting' do
    before :all do
      run_queue_info = ReadXML.new.run_queue_info
      @limit_number_before = run_queue_info[:limit_run_test]
      @rate_number_before = run_queue_info[:refresh_run_rate]
    end

    context 'TC01 - Update limit test run' do
      before :all do
        RailsAppConfig.new.update_run_queue_option('6', @rate_number_before.to_s)
      end

      it 'Verify limit test run updates successfully' do
        expect(ReadXML.new.run_queue_info[:limit_run_test]).to eq('6')
      end
    end

    context 'TC02 - Update refresh rate' do
      before :all do
        RailsAppConfig.new.update_run_queue_option('6', '3')
      end

      it 'Verify refresh rate updates successfully' do
        expect(ReadXML.new.run_queue_info[:refresh_run_rate]).to eq('3')
      end
    end

    context 'TC03 - Update both limit run test ans refresh rate' do
      run_queue_info = nil
      before :all do
        RailsAppConfig.new.update_run_queue_option('10', '5')
        run_queue_info = ReadXML.new.run_queue_info
      end

      it 'Verify limit test run updates successfully' do
        expect(run_queue_info[:limit_run_test]).to eq('10')
      end

      it 'Verify refresh rate updates successfully' do
        expect(run_queue_info[:refresh_run_rate]).to eq('5')
      end
    end

    after :all do
      RailsAppConfig.new.update_run_queue_option(@limit_number_before, @rate_number_before)
    end
  end
end
