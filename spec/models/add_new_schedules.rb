require 'spec_helper'

class ScheduleUnitTest
  describe 'Run Schedule Checking' do
    context 'TC01 - Add new some ATG schedules into schedules table' do
      it 'Add new ATG schedule - repeat minutes' do
        schedule_count = Schedule.count
        Schedule.new.add_schedule(silo: 'ATG', note: 'run ATG', data: "{silo: 'ATG',browser:'FIREFOX',env:'UAT',locale:'US',testsuite:'43',testcases:'219,226',release_date: '',emaillist:'ltrc_vn@leapfrog.test',description:''}", start_time: '2015-01-12 00:01:00'.to_datetime, minute: 30, weekly: '', user_id: 6, location: '')
        expect(Schedule.count).to eq(schedule_count + 1)
      end

      it 'Add new ATG schedule - repeat weekly' do
        schedule_count = Schedule.count
        Schedule.new.add_schedule(silo: 'ATG', note: 'run ATG', data: "{silo: 'ATG',browser:'FIREFOX',env:'UAT',locale:'US',testsuite:'43',testcases:'219,226',release_date: '',emaillist:'ltrc_vn@leapfrog.test',description:''}", start_time: '2015-01-12 00:01:00'.to_datetime, minute: '', weekly: '2,4,6', user_id: 6, location: '')
        expect(Schedule.count).to eq(schedule_count + 1)
      end

      after :all do
        Schedule.destroy_all(data: "{silo: 'ATG',browser:'FIREFOX',env:'UAT',locale:'US',testsuite:'43',testcases:'219,226',release_date: '',emaillist:'ltrc_vn@leapfrog.test',description:''}")
      end
    end

    context 'TC02 - Add new some WS schedules into schedules table' do
      it 'Add new WS schedule - repeat minutes' do
        schedule_count = Schedule.count
        Schedule.new.add_schedule(silo: 'WS', note: 'run WS', data: "{silo: 'WS',browser:'',env:'QA',locale:'',testsuite:'25',testcases:'113',release_date: '',emaillist:'ltrc_vn@leapfrog.test',description:'run WS'}", start_time: '2015-01-12 00:01:00'.to_datetime, minute: 30, weekly: '', user_id: 5, location: '')
        expect(Schedule.count).to eq(schedule_count + 1)
      end

      it 'Add new WS schedule - repeat weekly' do
        schedule_count = Schedule.count
        Schedule.new.add_schedule(silo: 'WS', note: 'run WS', data: "{silo: 'WS',browser:'',env:'QA',locale:'',testsuite:'25',testcases:'113',release_date: '',emaillist:'ltrc_vn@leapfrog.test',description:'run WS'}", start_time: '2015-01-12 00:01:00'.to_datetime, minute: '', weekly: '1,2,3,4,5', user_id: 5, location: '')
        expect(Schedule.count).to eq(schedule_count + 1)
      end

      after :all do
        Schedule.destroy_all(data: "{silo: 'WS',browser:'',env:'QA',locale:'',testsuite:'25',testcases:'113',release_date: '',emaillist:'ltrc_vn@leapfrog.test',description:'run WS'}")
      end
    end
  end
end
