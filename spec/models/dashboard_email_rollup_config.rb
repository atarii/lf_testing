require 'spec_helper'

class EmailRollupUnitTest
  describe 'Dashboard Rollup Email Configuration' do
    # Set variable
    repeat_min = 30
    start_time = '2015-01-23 22:31:00'
    emails_list = 'ltrc_test1_qa@leapfrog.test;ltrc_test2_qa@gmail.com;ltrc_test3_qa@yahoo.com'
    user_id = 3

    before :all do
      @dashboard_rollup = EmailRollup.find(1)
    end

    context 'TC01 - Test update repeat min' do
      it 'Update repeat min' do
        EmailRollup.update(1, repeat_min: repeat_min, start_time: @dashboard_rollup.start_time, from_time: Time.now.utc, emails_list: @dashboard_rollup.emails_list, status: @dashboard_rollup.status, user_id: @dashboard_rollup.user_id)
        expect(EmailRollup.find(1).repeat_min).to eq(repeat_min)
      end
    end

    context 'TC02 - Test update start time' do
      it 'Update start time' do
        EmailRollup.update(1, repeat_min: @dashboard_rollup.repeat_min, start_time: start_time.to_datetime, from_time: Time.now.utc, emails_list: @dashboard_rollup.emails_list, status: @dashboard_rollup.status, user_id: @dashboard_rollup.user_id)
        expect(EmailRollup.find(1).start_time).to eq('2015-01-23 22:31:00')
      end
    end

    context 'TC03 - Test update emails list' do
      it 'Update emails list' do
        EmailRollup.update(1, repeat_min: @dashboard_rollup.repeat_min, start_time: @dashboard_rollup.start_time, from_time: Time.now.utc, emails_list: emails_list, status: @dashboard_rollup.status, user_id: @dashboard_rollup.user_id)
        expect(EmailRollup.find(1).emails_list).to eq(emails_list)
      end
    end

    context 'TC04 - Test update user id' do
      it 'Update user id' do
        EmailRollup.update(1, repeat_min: @dashboard_rollup.repeat_min, start_time: @dashboard_rollup.start_time, from_time: Time.now.utc, emails_list: @dashboard_rollup.emails_list, status: @dashboard_rollup.status, user_id: user_id)
        expect(EmailRollup.find(1).user_id).to eq(user_id)
      end
    end

    context 'TC05 - Test update status' do
      it 'Update status enable' do
        EmailRollup.update(1, repeat_min: @dashboard_rollup.repeat_min, start_time: @dashboard_rollup.start_time, from_time: Time.now.utc, emails_list: @dashboard_rollup.emails_list, status: 1, user_id: @dashboard_rollup.user_id)
        expect(EmailRollup.find(1).status).to eq(1)
      end

      it 'Update status disable' do
        EmailRollup.update(1, repeat_min: @dashboard_rollup.repeat_min, start_time: @dashboard_rollup.start_time, from_time: Time.now.utc, emails_list: @dashboard_rollup.emails_list, status: 0, user_id: @dashboard_rollup.user_id)
        expect(EmailRollup.find(1).status).to eq(0)
      end
    end

    context 'TC06 - Test update mix fields' do
      it 'Update mix fields' do
        EmailRollup.update(1, repeat_min: repeat_min, start_time: start_time.to_datetime, from_time: Time.now.utc, emails_list: emails_list, status: 1, user_id: user_id)

        email_rollup = EmailRollup.find(1)
        expect(email_rollup.repeat_min).to eq(repeat_min)
        expect(email_rollup.start_time).to eq(start_time)
        expect(email_rollup.emails_list).to eq(emails_list)
        expect(email_rollup.user_id).to eq(user_id)
        expect(email_rollup.status).to eq(1)
      end
    end

    after :all do
      EmailRollup.update(1, repeat_min: @dashboard_rollup.repeat_min, start_time: @dashboard_rollup.start_time, from_time: @dashboard_rollup.from_time, emails_list: @dashboard_rollup.emails_list, status: @dashboard_rollup.status, user_id: 1)
    end
  end
end
