class Case < ActiveRecord::Base
  has_many :case_suite_maps

  def self.get_case_comment(file_path)
    str = ''
    File.open(file_path, 'r') do |f|
      is_begin = is_end = 0
      f.each_line do |line|
        is_begin = 1 if line.include?('=begin')
        str += line if is_begin == 1 && is_end == 0
        is_end = 1 if line.include?('=end')

        if is_begin == 1 && is_end == 1
          f.close
          return str.gsub('=begin', '').gsub('=end', '').strip
        end
      end

      f.close
      str.gsub('=begin', '').gsub('=end', '').strip
    end
  end

  def self.get_case(silo, case_script_path)
    query = '
      select c.* from cases as c
      join case_suite_maps as m on m.case_id = c.id
      join suites on suites.id = m.suite_id
      join silos on silos.id = suites.silo_id
      where silos.name like ? and script_path like ?'
    results = Case.find_by_sql([query, silo, case_script_path])
    results[0] if !results.nil? && results.count > 0
  end

  def self.info(id)
    tc = Case.find_by(id: id)
    tc.blank? ? {} : { name: tc[:name], description: tc[:description], script_path: tc[:script_path] }
  end
end
