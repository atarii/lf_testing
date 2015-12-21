class CaseSuiteMap < ActiveRecord::Base
  belongs_to :suites
  belongs_to :cases

  def self.get_test_cases(ts_id)
    CaseSuiteMap.where(suite_id: ts_id).map(&:case_id)
  end
end
