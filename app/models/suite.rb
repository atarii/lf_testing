class Suite < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :silo
  has_many :suite_maps
  has_many :case_suite_maps

  def self.test_suite_name(id)
    suite = Suite.find_by(id: id)
    return '' if suite.blank?
    suite.name
  end

  def self.test_suite_list(silo_name, user_role = 1)
    return [] if silo_name.blank?

    silo = Silo.find_by name: silo_name
    child_suites = SuiteMap.select(:child_suite_id).map(&:child_suite_id)
    suites = Suite.where('silo_id = (?) and id not in (?)', silo.id, child_suites).order(order: :asc).pluck(:name, :id)

    suites.reject! { |s| s[1] == 43 || s[1] == 55 } unless user_role == 1
    suites.each_with_index { |x, i| x[0] = "#{i + 1} - #{x[0]}" }

    case silo.name
    when 'ATG'
      suites.push(['Create / Save NEW test suite', 'new_testsuite'])
    when 'WS'
      suites.unshift('-- Select test suite --')
    end

    suites
  end

  def self.suite_name(test_suite_id)
    suite_map = SuiteMap.find_by(child_suite_id: test_suite_id)
    parent_suite = Suite.find_by(id: suite_map.parent_suite_id) unless suite_map.nil?
    suite = Suite.find_by(id: test_suite_id) || test_suite_id

    return "#{parent_suite.name}/#{suite.name}" if parent_suite
    suite.is_a?(String) ? suite : suite.name
  end
end
