class Atg < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :env, presence: true, length: { minimum: 2 }

  def self.update_data_info_to_xml(path, data)
    xml_content = Nokogiri::XML(File.read(path))
    xml_content.search('//webdriver')[0].inner_html = data[:web_driver].to_s
    xml_content.search('//testsuite')[0].inner_html = data[:suite_name].to_s
    xml_content.search('//language')[0].inner_html = data[:language].to_s
    xml_content.search('//env')[0].inner_html = data[:env].to_s
    xml_content.search('//locale')[0].inner_html = data[:locale].to_s
    xml_content.search('//accfull')[0].inner_html = data[:exist_acc].to_s
    xml_content.search('//accempty')[0].inner_html = data[:empty_acc].to_s
    xml_content.search('//accbalance')[0].inner_html = data[:balance_acc].to_s
    xml_content.search('//releasedate')[0].inner_html = data[:release_date].to_s
    xml_content.search('//data_driven_csv')[0].inner_html = data[:data_driven_csv].to_s
    xml_content.search('//device_store')[0].inner_html = data[:device_store].to_s
    xml_content.search('//payment_type')[0].inner_html = data[:payment_type].to_s
    File.open(path, 'w') { |f| f.print(xml_content.to_xml) }
  end

  def self.load_code_type
    code_type_rr = ['--- Select a code type ---']
    code_type = AtgCodeType.all.pluck(:type, :id)

    code_type.each do |type|
      code_type_rr.push(type)
    end

    code_type_rr
  end

  def get_test_suites(is_fst_parent_level = false)
    if is_fst_parent_level
      Suite.joins(:silo).where("silos.name = 'ATG' AND suites.id not in (?)", SuiteMap.select(:child_suite_id).map(&:child_suite_id)).order(order: :asc).pluck(:name, :id)
    else
      Suite.joins(:silo).where(silos: { name: 'ATG' }).order(order: :asc).pluck(:name, :id)
    end
  rescue
    []
  end

  def get_test_suite_parent(ts_id)
    parent_id = SuiteMap.where("child_suite_id = '#{ts_id}'").pluck(:parent_suite_id).first
    parent_id.nil? ? [] : Suite.where("id = '#{parent_id}'").pluck(:id, :name)
  rescue
    -1
  end

  def get_emails(records)
    exist_acc = ''
    empty_acc = ''
    balance_acc = ''
    records.each do |e|
      exist_acc = e[0] if e[0].include?('_full_')
      empty_acc = e[0] if e[0].include?('_empty_')
      balance_acc = e[0] if e[0].include?('_balance_')

      break unless exist_acc.blank? || empty_acc.blank? || balance_acc.blank?
    end

    { exist: exist_acc, empty: empty_acc, balance: balance_acc }
  end

  def self.release_date(language = 'EN')
    if language == 'EN'
      ac_model = AtgMoas
    else
      ac_model = AtgMoasFr
    end

    release_date_list = ac_model.group(:golivedate).order('golivedate desc').count.stringify_keys!

    count_all = 0
    release_date_list.each { |_key, value| count_all += value }

    { 'ALL' => count_all }.merge(release_date_list)
  end

  def self.prepare_run_data(custom_data, run_data)
    data = {}
    data[:spec_folder] = ENV['ATG_LOADPATH'] + '/spec'
    data[:language] = run_data[:locale].upcase.include?('FR_') ? 'FR' : 'EN'
    exist_emails = AtgTracking.where("email like '%atg_#{run_data[:env]}_#{run_data[:locale]}%'").order(updated_at: :desc).pluck(:email, :address1)
    atg_email = Atg.new.get_emails(exist_emails)
    data[:exist_acc] = atg_email[:exist]
    data[:empty_acc] = atg_email[:empty]
    data[:balance_acc] = atg_email[:balance]

    custom_data.merge data
  end
end
