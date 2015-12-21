require 'lib/generate'
require 'lib/localesweep'
require 'connection'
require 'date'
require 'rails'
require 'json'
require 'automation_common'

xml_content = File.read $LOAD_PATH.detect { |path| path.index('data.xml') } || 'TEMPORARY DATA FILE IS MISSING. PLEASE RECHECK!'
$doc = Nokogiri::XML(xml_content)
$atg_data = ATGConfiguration.get_atg_data

class CreditInfo
  FIRST_NAME_CONST = 'ltrc'
  LAST_NAME_CONST = 'vn'
  NAME_ON_CARD_CONST = 'ltrc vn'
  SECURITY_CARD_CONST = '123'
  EXPIRED_MONTH_CONST = '01'
  EXP_MONTH_NAME_CONST = Date::MONTHNAMES[EXPIRED_MONTH_CONST.to_i]
  EXPIRED_YEAR_CONST = '2016'
end

class Data
  def self.get_xml_data(path)
    $doc.search(path).text
  end

  TESTSUITE_CONST = get_xml_data '//testsuite'
  LANGUAGE_CONST = get_xml_data '//language'
  LOCALE_CONST = get_xml_data('//locale').upcase.presence || 'US'
  LOCALE_DOWNCASE_CONST = LOCALE_CONST.downcase
  DATA_DRIVEN_CONST = get_xml_data '//data_driven_csv'
  DEVICE_STORE_CONST = get_xml_data '//device_store'
  PAYMENT_TYPE_CONST = get_xml_data '//payment_type'
  LOCATION_CONST = LANGUAGE_CONST.downcase + '_' + LOCALE_CONST

  release_date = get_xml_data('//releasedate').upcase
  if release_date == 'ALL'
    CONST_RELEASE_DATE_SQL = ''
    CONST_RELEASE_DATE_EXIST_SQL = ''
  else
    CONST_RELEASE_DATE_SQL = "golivedate in ('#{release_date.gsub(';', "','")}') and"
    CONST_RELEASE_DATE_EXIST_SQL = "where golivedate in ('#{release_date.gsub(';', "','")}')"
  end

  if LOCALE_CONST.include?('FR_')
    URL_CONST = LOCALE_CONST.tr('_', '-').gsub('FR-ROW', 'FR-OF').downcase # E.g. if locale = 'FR_ROW' => 'FR-OF'
  else
    URL_CONST = 'en-' + LOCALE_DOWNCASE_CONST
  end

  CONST_GROUP_BY = 'group by prodnumber, longname'
  CONST_CONCAT_GROUP = 'group_concat(pricetier) as \'prices_total\', group_concat(filesize) as \'filesizes_total\''
  CONST_SELECTED_FIELDS = 'sku, prodnumber, shortname, longname, agefrommonths, agetomonths, pricetier, contenttype, curriculum, skills, format, lfchar, platformcompatibility, group_concat(pricetier) as \'prices_total\''

  ENV_CONST = get_xml_data '//env'
  downcase_env = ENV_CONST.downcase
  EMAIL_EXIST_FULL_CONST = get_xml_data '//accfull'
  EMAIL_EXIST_EMPTY_CONST = get_xml_data '//accempty'
  EMAIL_EXIST_BALANCE_CONST = get_xml_data '//accbalance'
  EMAIL_GUEST_CONST = Generate.email 'atg', downcase_env, LOCALE_DOWNCASE_CONST
  EMAIL_GUEST_FULL_CONST = Generate.email 'atg', downcase_env, "#{LOCALE_DOWNCASE_CONST}_full"
  EMAIL_GUEST_EMPTY_CONST = Generate.email 'atg', downcase_env, "#{LOCALE_DOWNCASE_CONST}_empty"
  EMAIL_BALANCE_CONST = Generate.email 'atg', downcase_env, "#{LOCALE_DOWNCASE_CONST}_balance"
  EMAIL_NEW_CSC_CONST = Generate.email 'csc', downcase_env, LOCALE_DOWNCASE_CONST

  # ATG account info
  FIRSTNAME_CONST = 'ltrc'
  LASTNAME_CONST = 'vn'
  PASSWORD_CONST = '123456'
  EMAIL_EXP_CREDIT_CARD_CONST = 'ltrc_atg_qa_exp_credit_card@sharklasers.com'

  case LOCALE_CONST
  when 'US'
    COUNTRY_CONST = 'USA'
    COUNTRY_DETAIL_CONST = 'United States'
    CSC_SITE_CONST = 'US Web' # 'CA Web' for CA locale
  when 'CA'
    COUNTRY_CONST = 'Canada'
    COUNTRY_DETAIL_CONST = 'Canada'
    CSC_SITE_CONST = 'CA Web'
  end

  # CSC account info
  CSC_USERNAME_CONST = 'service'
  CSC_PASSWORD_CONST = 'welcome1'

  # Vindicia account info
  VIN_USERNAME_CONST = $atg_data[:vin_acc][:vin_username]
  VIN_PASSWORD_CONST = $atg_data[:vin_acc][:vin_password]

  # Get information of an existing account
  account = Connection.my_sql_connection(
    <<-INTERPOLATED_SQL
      SELECT firstname, lastname, email, country, atg_tracking.address1, city, state, postal, phone_number, card_type, atg_tracking.credit_number, exp_month, exp_year, order_id, created_at, updated_at
      FROM atg_tracking INNER JOIN atg_credit INNER JOIN atg_address
      ON (atg_address.address1 = atg_tracking.address1 and atg_credit.card_number = atg_tracking.credit_number)
      WHERE email = '#{EMAIL_EXIST_FULL_CONST}'
  INTERPOLATED_SQL
  ).fetch_hash

  account = {} if account.nil?

  # Credit card info
  CARD_NUMBER_CONST = account['credit_number'].to_s
  CARD_TYPE_CONST = CARD_NUMBER_CONST.empty? ? '' : Connection.my_sql_connection("SELECT card_type from atg_credit where card_number = '#{CARD_NUMBER_CONST}'").fetch_hash['card_type']
  CARD_CODE_CONST = CARD_NUMBER_CONST[-4..-1] # this get 4 latest digits Ex.'1128' #'4113'
  CARD_TEXT_CONST = "#{CARD_TYPE_CONST} X- #{CARD_CODE_CONST}" # 'Visa X- 4113'
  NAME_ON_CARD_CONST = "#{FIRSTNAME_CONST} #{LASTNAME_CONST}" # Ex. 'ltrc dn'
  EXP_MONTH_NUMBER_CONST = account['exp_month'].to_s # 01
  EXP_MONTH_NAME_CONST = Date::MONTHNAMES[EXP_MONTH_NUMBER_CONST.to_i] # 'January'
  EXP_YEAR_CONST = account['exp_year'].to_s # '2016'
  SECURITY_CODE_CONST = '123'

  # Address info
  ADDRESS1_CONST = account['address1']
  ADDRESS1_BAD_CONST = 'bad_address'
  CITY_CONST = account['city']
  STATE_CODE_CONST = account['state']
  ZIP_CONST = account['postal']
  PHONE_CONST = account['phone_number']

  # Info string for checking
  ADDRESS_INFO_CONST = "#{FIRSTNAME_CONST} #{LASTNAME_CONST} #{ADDRESS1_CONST} #{CITY_CONST}, #{STATE_CODE_CONST} #{ZIP_CONST} #{PHONE_CONST}"
  BAD_ADDRESS_INFO_CONST = "#{ADDRESS1_BAD_CONST}  #{CITY_CONST} #{STATE_CODE_CONST} #{ZIP_CONST} #{LOCALE_CONST}"
  BILLING_ADDRESS_INFO_CONST = "#{NAME_ON_CARD_CONST} #{ADDRESS1_CONST} #{CITY_CONST}, #{STATE_CODE_CONST} #{ZIP_CONST} #{PHONE_CONST}"
  PAYMENTED_INFO_CONST = "#{CARD_TYPE_CONST} XXXXXXXXXXXX#{CARD_NUMBER_CONST[-4..-1]} Exp. #{EXP_MONTH_NUMBER_CONST}/#{EXP_YEAR_CONST[-2..-1]}"
  ADDRESS_MAIL_FROM_CSC_CONST = "#{FIRSTNAME_CONST} #{LASTNAME_CONST} #{ADDRESS1_CONST} #{CITY_CONST} , #{STATE_CODE_CONST} , #{ZIP_CONST} #{LOCALE_CONST} #{PHONE_CONST}"

  # Get root path of project
  CONST_PROJECT_PATH = File.expand_path('..', File.dirname(__FILE__))

  # Leapfrog URL
  CONST_LF_URL = "http://#{ENV_CONST.downcase}-www.leapfrog.com"

  atg_locales = Connection.my_sql_connection('SELECT DISTINCT locale FROM atg_address').to_a

  if atg_locales.flatten.to_s.include? LOCALE_CONST
    # Get address info form atg_address table
    address = Connection.my_sql_connection(
      <<-INTERPOLATED_SQL
        SELECT * FROM atg_address
        WHERE locale LIKE '%#{LOCALE_CONST}%'
        ORDER BY RAND()
        LIMIT 1
    INTERPOLATED_SQL
    ).fetch_hash

    ADDRESS = {
      first_name: FIRSTNAME_CONST,
      last_name: LASTNAME_CONST,
      street: address['address1'],
      city: address['city'],
      state: address['state'],
      postal: address['postal'],
      phone_number: address['phone_number']
    }

    BILLING_ADDRESS = {
      street_address: address['address1'],
      city: address['city'],
      state: address['state'],
      country: COUNTRY_CONST,
      postal_code: address['postal'],
      phone_number: address['phone_number']
    }

    EX_ADDRESS_INFO = "#{FIRSTNAME_CONST} #{LASTNAME_CONST} #{address['address1']} #{address['city']}, #{address['state']} #{address['postal']} #{address['phone_number']}"
    EX_BILLING_ADDRESS_INFO = "#{NAME_ON_CARD_CONST} #{address['address1']} #{address['city']}, #{address['state']} #{address['postal']} #{address['phone_number']}"

    # Get random credit card info from atg_credit table
    credit = Connection.my_sql_connection(
      <<-INTERPOLATED_SQL
        SELECT * FROM atg_credit
        ORDER BY RAND()
        LIMIT 1
    INTERPOLATED_SQL
    ).fetch_hash

    CREDIT_CARD = {
      card_number: credit['card_number'],
      cart_type: credit['card_type'],
      card_name: CreditInfo::NAME_ON_CARD_CONST,
      exp_month: CreditInfo::EXP_MONTH_NAME_CONST,
      exp_year: CreditInfo::EXPIRED_YEAR_CONST,
      security_code: CreditInfo::SECURITY_CARD_CONST
    }

    EX_PAYMENT_INFO = "#{credit['card_type']} XXXXXXXXXXXX#{credit['card_number'][-4..-1]} Exp. #{CreditInfo::EXPIRED_MONTH_CONST}/#{CreditInfo::EXPIRED_YEAR_CONST[-2..-1]}"
  end
end

class ProductInformation
  BILLING_TYPE_CONST = "#{Data::CARD_TYPE_CONST} - #{Data::CARD_CODE_CONST}" # 'Visa - 4113' this is to check billing information in TC33, 34
  ADDRESS_CONST = "#{Data::FIRSTNAME_CONST} #{Data::LASTNAME_CONST} #{Data::ADDRESS1_CONST} #{Data::CITY_CONST}, #{Data::STATE_CODE_CONST} #{Data::ZIP_CONST} #{Data::PHONE_CONST}"
  ORDER_FULLFILL_STATUS_CONST = 'Status: Submitted to fulfillment'

  case Data::LOCALE_CONST
  when 'US'
    SHIPPING_METHOD_CONST = '2nd Day Air'
    CURRENCY_CONST = '$'
  when 'CA'
    SHIPPING_METHOD_CONST = 'Expedited'
    CURRENCY_CONST = 'CAD'
  end

  # Information for check out item on Confirmation page
  ORDER_COMPLETE_MESSAGE_CONST = 'Thank you. Your order has been completed. Your order confirmation number is .* Print'
  ORDER_SUMMARY_TEXT_CONST = "Order Summary Bill To Ship To #{Data::FIRSTNAME_CONST} #{Data::LASTNAME_CONST} #{Data::ADDRESS1_CONST} #{Data::CITY_CONST}, #{Data::STATE_CODE_CONST} #{Data::ZIP_CONST} #{Data::PHONE_CONST} %s #{Data::FIRSTNAME_CONST} #{Data::LASTNAME_CONST} #{Data::ADDRESS1_CONST} #{Data::CITY_CONST}, #{Data::STATE_CODE_CONST} #{Data::ZIP_CONST} #{Data::PHONE_CONST} Shipping Method %s"
  SG_ORDER_SUMMARY_TEXT_CONST = "Order Summary Bill To #{Data::NAME_ON_CARD_CONST} #{Data::ADDRESS1_CONST} #{Data::CITY_CONST}, #{Data::STATE_CODE_CONST} #{Data::ZIP_CONST} #{Data::PHONE_CONST} %s"

  # Information for check out item on Email page
  SHIPPING_DETAIL_TEXT_EMAIL_PAGE_CONST = "#{Data::FIRSTNAME_CONST} #{Data::LASTNAME_CONST}, #{Data::ADDRESS1_CONST} #{Data::CITY_CONST}, #{Data::STATE_CODE_CONST} #{Data::ZIP_CONST} #{Data::PHONE_CONST}%s"

  # Info in CSC tool
  PAYMENT_METHOD_CSC_CONST = "#{Data::CARD_TYPE_CONST}-#{Data::CARD_CODE_CONST}"
  ADDRESS_CSC_CONST = "#{Data::FIRSTNAME_CONST} #{Data::LASTNAME_CONST} #{Data::ADDRESS1_CONST} #{Data::CITY_CONST} , #{Data::STATE_CODE_CONST} , #{Data::ZIP_CONST} #{Data::LOCALE_CONST} #{Data::PHONE_CONST}"
  SG_SHIPPING_METHOD_CONST = 'Shipping Electronic Address %s Status The goods have been shipped'
end

class URL
  # ATG Digital Web urls
  ATG_CONST = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST.downcase}/store/c"
  ATG_APP_CENTER_URL = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST.downcase}/app-center/c"

  # ATG Device Store App Center urls
  device_store_info = JSON.parse(File.read("#{Data::CONST_PROJECT_PATH}/data/device_store_urls.json"))[Data::DEVICE_STORE_CONST]
  ATG_DV_APP_CENTER_URL = device_store_info.nil? ? '' : device_store_info['url']

  # Get approriate csc url on UAT or UAT2
  case Data::ENV_CONST
  when 'UAT'
    CSC_CONST = 'http://emrlatgcsc01.leapfrog.com:7007/agent/login.jsp'
  when 'UAT2'
    CSC_CONST = 'http://emrlatgcsc02.leapfrog.com:7007/agent/login.jsp'
  else # Handle for PROD env
    CSC_CONST = '#'
  end

  # Vindicia url
  VIN_CONST = 'https://secure.prodtest.sj.vindicia.com/login/secure/index.html'
end

class SortOption
  # Sort option on ATG page
  FEATURE_CONST = 'Featured'
  HIGH_TO_LOW_CONST = 'Price (High to Low)'
  LOW_TO_HIGH_CONST = 'Price (Low to High)'
  NEW_CONST = 'New'
  BEST_SELLING_CONST = 'Bestselling'
  ALPHABETICAL_CONST = 'Alphabetical (A-Z)'
end

class TimeOut
  READTIMEOUT_CONST = 260 # for page load
  WAIT_CONTROL_CONST = 45 # for control
  WAIT_SMALL_CONST = 2
  WAIT_MID_CONST = 5
  WAIT_BIG_CONST = 40 # for ajax
  WAIT_EMAIL = 60 # time to wait email from server
end

class TableName
  if Data::LANGUAGE_CONST == 'EN'
    CONST_TITLE_TABLE = 'atg_moas' # English data table
  else
    CONST_TITLE_TABLE = 'atg_moas_fr' # French data table
  end

  CONST_ATG_FILTER_LIST_TABLE = 'atg_filter_list'
  CONST_ATG_CABO_FILTER_LIST_TABLE = 'atg_cabo_filter_list'
  CONST_ATG_ULTRA_FILTER_LIST_TABLE = 'atg_ultra_filter_list'
end

class AppCenterContent
  # Digital Web and LFC Content URL const
  if Data::TESTSUITE_CONST.downcase == 'english atg lfc content'
    ac_path = 'app-center-lfc'
    ac_search_path = 'app-center-lfc'
    ac_quickview_search_path = 'app-center-lfc'
    ac_param = '?Endeca_user_segments=UsrSeg_50_SGSite&'
  else
    ac_path = 'app-center'
    ac_search_path = 'store'
    ac_quickview_search_path = 'app-center'
    ac_param = '?'
  end

  CONST_CHECKOUT_URL = Title.convert_locale "#{Data::CONST_LF_URL}/en-#{Data::LOCALE_DOWNCASE_CONST}/#{ac_path}/checkout/"
  CONST_LOGIN_URL = Title.convert_locale "#{Data::CONST_LF_URL}/en-#{Data::LOCALE_DOWNCASE_CONST}/#{ac_path}/profile/login.jsp?"
  CONST_SEARCH_URL = Title.convert_locale "#{Data::CONST_LF_URL}/en-#{Data::LOCALE_DOWNCASE_CONST}/#{ac_search_path}/search/#{ac_param}Ntt=%s&Nty=1"
  CONST_QUICK_VIEW_SEARCH_URL = Title.convert_locale "#{Data::CONST_LF_URL}/en-#{Data::LOCALE_DOWNCASE_CONST}/#{ac_quickview_search_path}/search/#{ac_param}Ntt=%s&Nty=1"
  CONST_CHARACTER_URL = Title.convert_locale "#{Data::CONST_LF_URL}%s#{ac_param}No=0&Nrpp=2000&Ns=P_NewUntil%%7C1&showMoreIds=3"
  CONST_FILTER_URL = Title.convert_locale "#{Data::CONST_LF_URL}%s#{ac_param}No=0&Nrpp=2000&Ns=P_NewUntil%%7C1"
  CONST_FILTER_URL2 = Title.convert_locale "#{Data::CONST_LF_URL}%s#{ac_param}No=1000&Nrpp=1000&Ns=P_NewUntil%%7C1"
  CONT_PDP_URL = Title.convert_locale "#{Data::CONST_LF_URL}%s"

  # Getting price tier based on locale
  CONST_PRICE_TIER = Connection.my_sql_connection("select * from atg_pricetier where locale like '#{Data::LOCALE_CONST}%';")

  # SQL query for Search
  CONST_QUERY_CHECK_APP_EXIST = "select * from #{TableName::CONST_TITLE_TABLE} #{Data::CONST_RELEASE_DATE_EXIST_SQL}"
  CONST_QUERY_SEARCH_TITLE = "select *, #{Data::CONST_CONCAT_GROUP} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' #{Data::CONST_GROUP_BY}"
  CONST_QUERY_SEARCH_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = '' #{Data::CONST_GROUP_BY}"

  # SQL query for Skill
  CONST_QUERY_SKILL_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Skills'"
  CONST_QUERY_SKILL_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and skills like '%%%s%%' #{Data::CONST_GROUP_BY}"
  CONST_QUERY_SKILL_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (#{Data::LOCALE_CONST} = '' or skills not like '%%%s%%') #{Data::CONST_GROUP_BY}"

  # SQL query for Age
  CONST_QUERY_AGE_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Age'"
  CONST_QUERY_AGE_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and agefrommonths/12 <= %s and agetomonths/12 >= %s #{Data::CONST_GROUP_BY}"
  CONST_QUERY_AGE_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (#{Data::LOCALE_CONST} = '' or agefrommonths/12 > %s or agetomonths/12 < %s) #{Data::CONST_GROUP_BY}"

  # SQL query for Product
  CONST_QUERY_PRODUCT_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Product'"
  CONST_QUERY_PRODUCT_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%%s%%' #{Data::CONST_GROUP_BY}"
  CONST_QUERY_PRODUCT_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (#{Data::LOCALE_CONST} = '' or platformcompatibility not like '%%%s%%') #{Data::CONST_GROUP_BY}"

  # SQL query for Character
  CONST_QUERY_CHARACTER_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Character'"
  CONST_QUERY_CHARACTER_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and concat(',',lfchar,',') like '%%,%s,%%' and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"
  CONST_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (#{Data::LOCALE_CONST} = '' or concat(',',lfchar,',') not like '%%,%s,%%') and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"

  # SQL query for Price
  CONST_PRICE = "sum((select price from atg_pricetier where tier = left(pricetier, locate('-', pricetier) - 2) and locale like '#{Data::LOCALE_CONST}')) as 'price'"
  CONST_QUERY_PRICE_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Price'"
  CONST_QUERY_PRICE_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS}, #{CONST_PRICE} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' #{Data::CONST_GROUP_BY} having (price >= %s and price <= %s)"
  CONST_QUERY_PRICE_CATALOG_NEGATIVE_TITLE = <<-INTERPOLATED_SQL
    select #{Data::CONST_SELECTED_FIELDS}, #{CONST_PRICE} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = '' #{Data::CONST_GROUP_BY}
    union all
    select #{Data::CONST_SELECTED_FIELDS}, #{CONST_PRICE} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' #{Data::CONST_GROUP_BY} having (price < %s or price > %s)
  INTERPOLATED_SQL

  # SQL query for Type/Format
  CONST_QUERY_TYPE_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Type'"
  CONST_QUERY_TYPE_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and format = '%s' #{Data::CONST_GROUP_BY}"
  CONST_QUERY_TYPE_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (#{Data::LOCALE_CONST} = '' or format != '%s') #{Data::CONST_GROUP_BY}"

  # SQL query for platform compatibility
  CONST_QUERY_CATEGORY_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Category'"
  CONST_QUERY_CATEGORY_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and contenttype in ('%s', '%s') #{Data::CONST_GROUP_BY}"
  CONST_QUERY_CATEGORY_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (#{Data::LOCALE_CONST} = '' or contenttype not in ('%s', '%s')) #{Data::CONST_GROUP_BY}"

  # SQL query for YMAL
  CONST_QUERY_GET_YMAL_INFO = "select sku, prodnumber, longname, platformcompatibility, us, ca, uk, ie, au, row from #{TableName::CONST_TITLE_TABLE} where prodnumber = '%s' and #{Data::LOCALE_CONST} = 'x' #{Data::CONST_GROUP_BY}"
end

class CaboAppCenterContent
  # Cabo ATG Content URL const
  CONST_CABO_SEARCH_URL = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST}/app-center-lpad3e/search/?Ntt=%s&Nty=1"
  CONST_CABO_FILTER_URL = Title.convert_locale "#{Data::CONST_LF_URL}%s?No=0&Nrpp=2000&Ns=P_NewUntil%%7C1"
  CONST_CABO_SHOP_ALL_APP_URL1 = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST}/app-center-lpad3e/c?No=0&Nrpp=2000&Ns=P_NewUntil%7C1"
  CONST_CABO_SHOP_ALL_APP_URL2 = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST}/app-center-lpad3e/c?No=1000&Nrpp=1000&Ns=P_NewUntil%7C1"

  # SQL query for Searching
  CONST_CABO_QUERY_SEARCH_TITLE = "select *, #{Data::CONST_CONCAT_GROUP} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' #{Data::CONST_GROUP_BY}"
  CONST_CABO_QUERY_SEARCH_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} != 'x') #{Data::CONST_GROUP_BY}"

  # SQL query for Skill Catalog
  CONST_CABO_QUERY_SKILL_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_CABO_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Skills'"
  CONST_CABO_QUERY_SKILL_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' and skills like \"%%%s%%\" #{Data::CONST_GROUP_BY}"
  CONST_CABO_QUERY_SKILL_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} = '' or skills not like \"%%%s%%\") #{Data::CONST_GROUP_BY}"

  # SQL query for Age Catalog
  CONST_CABO_QUERY_AGE_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_CABO_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Age'"
  CONST_CABO_QUERY_AGE_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' and agefrommonths/12 <= %s and agetomonths/12 >= %s #{Data::CONST_GROUP_BY}"
  CONST_CABO_QUERY_AGE_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} = '' or agefrommonths/12 > %s or agetomonths/12 < %s) #{Data::CONST_GROUP_BY}"

  # SQL query for Character Catalog
  CONST_CABO_QUERY_CHARACTER_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_CABO_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Character'"
  CONST_CABO_QUERY_CHARACTER_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' and concat(',',lfchar,',') like \"%%,%s,%%\" and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"
  CONST_CABO_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} = '' or concat(',',lfchar,',') not like \"%%,%s,%%\") and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"
  CONST_CABO_FRENCH_QUERY_CHARACTER_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' and concat(';',lfchar,';') like \"%%;%s|%%\" and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"
  CONST_CABO_FRENCH_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} = '' or concat(';',lfchar,';') not like \"%%;%s|%%\") and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"

  # SQL query for Content/Type - Cabo (Category)
  CONST_CABO_QUERY_CATEGORY_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_CABO_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Category'"
  CONST_CABO_QUERY_CATEGORY_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' and contenttype in ('%s', '%s') #{Data::CONST_GROUP_BY}"
  CONST_CABO_QUERY_CATEGORY_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} = '' or contenttype not in ('%s', '%s')) #{Data::CONST_GROUP_BY}"
  CONST_CABO_FRENCH_QUERY_CATEGORY_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' and contenttype = \"%s\" #{Data::CONST_GROUP_BY}"
  CONST_CABO_FRENCH_QUERY_CATEGORY_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad3%%' or #{Data::LOCALE_CONST} = '' or contenttype != \"%s\") #{Data::CONST_GROUP_BY}"

  # SQL query for YMAL
  CONST_CABO_QUERY_GET_YMAL_INFO = "select sku, prodnumber, longname, platformcompatibility, us, ca, uk, ie, au, row from #{TableName::CONST_TITLE_TABLE} where prodnumber = '%s' and #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad3%%' #{Data::CONST_GROUP_BY}"
end

class UltraAppCenterContent
  # LeapPad Ultra ATG Content URL const
  CONST_ULTRA_SEARCH_URL = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST}/app-center-dv/search/?Ntt=%s&Nty=1"
  CONST_ULTRA_FILTER_URL = Title.convert_locale "#{Data::CONST_LF_URL}%s?No=0&Nrpp=2000&Ns=P_NewUntil%%7C1"
  CONST_ULTRA_SHOP_ALL_APP_URL1 = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST}/app-center-dv/c?No=0&Nrpp=2000&Ns=P_NewUntil%7C1"
  CONST_ULTRA_SHOP_ALL_APP_URL2 = Title.convert_locale "#{Data::CONST_LF_URL}/#{Data::URL_CONST}/app-center-dv/c?No=1000&Nrpp=1000&Ns=P_NewUntil%7C1"

  # SQL query for Searching
  CONST_ULTRA_QUERY_SEARCH_TITLE = "select *, #{Data::CONST_CONCAT_GROUP} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad Ultra%%' #{Data::CONST_GROUP_BY}"
  CONST_ULTRA_QUERY_SEARCH_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad Ultra%%' or #{Data::LOCALE_CONST} != 'x') #{Data::CONST_GROUP_BY}"

  # SQL query for Skill Catalog
  CONST_ULTRA_QUERY_SKILL_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_ULTRA_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Skills'"
  CONST_ULTRA_QUERY_SKILL_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad Ultra%%' and skills like \"%%%s%%\" #{Data::CONST_GROUP_BY}"
  CONST_ULTRA_QUERY_SKILL_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad Ultra%%' or #{Data::LOCALE_CONST} = '' or skills not like \"%%%s%%\") #{Data::CONST_GROUP_BY}"

  # SQL query for Age Catalog
  CONST_ULTRA_QUERY_AGE_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_ULTRA_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Age'"
  CONST_ULTRA_QUERY_AGE_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad Ultra%%' and agefrommonths/12 <= %s and agetomonths/12 >= %s #{Data::CONST_GROUP_BY}"
  CONST_ULTRA_QUERY_AGE_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad Ultra%%' or #{Data::LOCALE_CONST} = '' or agefrommonths/12 > %s or agetomonths/12 < %s) #{Data::CONST_GROUP_BY}"

  # SQL query for Character Catalog
  CONST_ULTRA_QUERY_CHARACTER_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_ULTRA_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Character'"
  CONST_ULTRA_QUERY_CHARACTER_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad Ultra%%' and concat(',',lfchar,',') like \"%%,%s,%%\" and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"
  CONST_ULTRA_QUERY_CHARACTER_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad Ultra%%' or #{Data::LOCALE_CONST} = '' or concat(',',lfchar,',') not like \"%%,%s,%%\") and trim(prodnumber) <> '' #{Data::CONST_GROUP_BY}"

  # SQL query for Content/Type - Cabo (Category)
  CONST_ULTRA_QUERY_CATEGORY_CATALOG_DRIVE = "select name, href from #{TableName::CONST_ATG_ULTRA_FILTER_LIST_TABLE} where locale = '#{Data::LOCALE_CONST}' and type = 'Category'"
  CONST_ULTRA_QUERY_CATEGORY_CATALOG_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} #{Data::LOCALE_CONST} = 'x' and platformcompatibility like '%%LeapPad Ultra%%' and contenttype in ('%s', '%s') #{Data::CONST_GROUP_BY}"
  CONST_ULTRA_QUERY_CATEGORY_CATALOG_NEGATIVE_TITLE = "select #{Data::CONST_SELECTED_FIELDS} from #{TableName::CONST_TITLE_TABLE} where #{Data::CONST_RELEASE_DATE_SQL} (platformcompatibility not like '%%LeapPad Ultra%%' or #{Data::LOCALE_CONST} = '' or contenttype not in ('%s', '%s')) #{Data::CONST_GROUP_BY}"
end

class PayPalInfo
  paypal_acc = $atg_data[:paypal_acc]

  case Data::LOCALE_CONST
  when 'US'
    CONST_P_EMAIL = paypal_acc[:p_us_acc][0]
    CONST_P_PASSWORD = paypal_acc[:p_us_acc][1]
  when 'CA'
    CONST_P_EMAIL = paypal_acc[:p_ca_acc][0]
    CONST_P_PASSWORD = paypal_acc[:p_ca_acc][1]
  when 'UK'
    CONST_P_EMAIL = paypal_acc[:p_uk_acc][0]
    CONST_P_PASSWORD = paypal_acc[:p_uk_acc][1]
  when 'IE'
    CONST_P_EMAIL = paypal_acc[:p_ie_acc][0]
    CONST_P_PASSWORD = paypal_acc[:p_ie_acc][1]
  when 'AU'
    CONST_P_EMAIL = paypal_acc[:p_au_acc][0]
    CONST_P_PASSWORD = paypal_acc[:p_au_acc][1]
  when 'ROW'
    CONST_P_EMAIL = paypal_acc[:p_row_acc][0]
    CONST_P_PASSWORD = paypal_acc[:p_row_acc][1]
  end
end

class AppCenterAccount
  acc_account = $atg_data[:acc_account]
  EMPTY_ACC = acc_account[:empty_acc]
  CREDIT_ACC = acc_account[:credit_acc]
  BALANCE_ACC = acc_account[:balance_acc]
  CREDIT_BALANCE_ACC = acc_account[:credit_balance_acc]
end

class SmokeCatalogData
  catalog_entry = $atg_data[:catalog_entry]

  PRODUCT = {
    prod_id: catalog_entry[:prod_id],
    ce_sku: catalog_entry[:ce_sku],
    title: catalog_entry[:ce_catalog_title],
    type: catalog_entry[:ce_product_type],
    price: catalog_entry[:ce_price],
    strike: catalog_entry[:ce_strike],
    sale: catalog_entry[:ce_sale],
    pdp_type: catalog_entry[:ce_pdp_type],
    cart_title: catalog_entry[:ce_cart_title]
  }
end

class ServicesInfo
  CONST_PROJECT_PATH = File.expand_path('..', File.dirname(__FILE__))
  CONST_CALLER_ID = '755e6f29-b7c8-4b98-8739-a1a7096f879e'

  if Data::ENV_CONST == 'PROD'
    CONST_INMON_URL = 'http://evplcis.leapfrog.com:8080/inmon/services/'
    CONST_GAME_LOG_UPLOAD_ENDPOINT = 'http://devicelog.leapfrog.com/upca/device_log_upload'
  elsif Data::ENV_CONST == 'PREVIEW' || Data::ENV_CONST == 'STAGING'
    CONST_INMON_URL = 'http://evslcis2.leapfrog.com:8080/inmon/services/'
    CONST_GAME_LOG_UPLOAD_ENDPOINT = 'http://qa-devicelog.leapfrog.com/upca/device_log_upload'
  else # QA, UAT, UAT2
    CONST_INMON_URL = 'http://emqlcis.leapfrog.com:8080/inmon/services/'
    CONST_GAME_LOG_UPLOAD_ENDPOINT = 'http://qa-devicelog.leapfrog.com/upca/device_log_upload'
  end

  CONST_GAME_LOG_UPLOAD_NAMESPACE = 'http://services.leapfrog.com/inmon/device/logs/upload/'

  inmon_endpoints = JSON.parse(File.read("#{File.expand_path('../..', File.dirname(__FILE__))}/lib/inmon_endpoints.json"), symbolize_names: true)
  inmon_endpoints.each_key { |k|
    inmon_endpoints[k][:endpoint] = CONST_INMON_URL + inmon_endpoints[k][:endpoint]
  }

  CONST_INMON_ENDPOINTS = inmon_endpoints
end

class ConstMessage
  PRE_CONDITION_FAIL = 'Blocked: Precondition failed'
end
