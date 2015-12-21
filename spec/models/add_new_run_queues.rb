require 'spec_helper'

class RunQueueUnitTest
  describe 'Run Queue Checking' do
    # Set variable
    user_email = 'ltrc_vn_test@leapfrog.test'
    user_id = nil
    ws_data = '{"silo": "WS","web_driver":"","env":"QA","locale":"","testsuite":"25","testcases":"113","release_date": "","emaillist":"ltrc_vn_test@leapfrog.test","description":"run WS"}'
    atg_data = '{"silo": "ATG","web_driver":"FIREFOX","env":"UAT","locale":"US","testsuite":"43","testcases":"219,226","release_date": "","emaillist":"ltrc_vn_test@leapfrog.test","description":""}'
    ep_data = '{"silo": "EP","web_driver":"FIREFOX","env":"qa","locale":"","testsuite":"41","testcases":"201","release_date": "2014-12-31","emaillist":"ltrc_vn_test@leapfrog.test","description":""}'
    run = nil
    run_count1 = nil
    run_count2 = nil
    status = 'queued'

    # Pre-condition: Create new user
    before :all do
      User.new.do_create_user('ltrc', 'vn', user_email, '123456', 1, 1)
      user_id = User.find_by(email: user_email).id
    end

    context 'TC01 - Add a WebService Queue into Run Queues' do
      before :all do
        run_count1 = Run.count(status: status)
        run = Run.create(data: ws_data, status: status, user_id: user_id)
        run_count2 = Run.count(status: status)
      end

      it 'Verify WebService Queue is added successfully' do
        expect(run_count2).to eq(run_count1 + 1)
      end

      after :all do
        run.destroy
      end
    end

    context 'TC02 - Add a ATG Queue into Run Queues' do
      before :all do
        run_count1 = Run.count(status: status)
        run = Run.create(data: atg_data, status: status, user_id: user_id)
        run_count2 = Run.count(status: status)
      end

      it 'Verify ATG Queue is added successfully' do
        expect(run_count2).to eq(run_count1 + 1)
      end

      after :all do
        run.destroy
      end
    end

    context 'TC03 - Add a EP Queue into Run Queues' do
      before :all do
        run_count1 = Run.count(status: status)
        run = Run.create(data: ep_data, status: status, user_id: user_id)
        run_count2 = Run.count(status: status)
      end

      it 'Verify EP Queue is added successfully' do
        expect(run_count2).to eq(run_count1 + 1)
      end

      after :all do
        run.destroy
      end
    end

    after :all do
      User.find_by(id: user_id).destroy
    end
  end
end
