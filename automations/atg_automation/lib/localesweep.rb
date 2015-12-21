require 'connection'

class Title
  def self.calculate_age_web(age_from_month, age_to_month, page = nil)
    age_from = age_from_month.to_i / 12
    age_to = age_to_month.to_i / 12

    case page
    when 'pdp' then
      'Ages ' + age_from.to_s + '-' + age_to.to_s + ' yrs.' # Age 4-7 yrs.
    else # Catalog, QuickView pages
      'Ages ' + age_from.to_s + ' - ' + age_to.to_s + ' years' # Age 4 - 7 years
    end
  end

  def self.calculate_age_device(age_from_month, age_to_month, page = 'PDP', language = 'en')
    age_from = age_from_month.to_i / 12
    age_to = age_to_month.to_i / 12

    if page == 'PDP'
      age_string = 'Ages ' + age_from.to_s + ' - ' + age_to.to_s + ' years' # Age 4 - 7 years
    else
      age_string = 'Ages ' + age_from.to_s + '-' + age_to.to_s # Age 4-7
    end

    return age_string.gsub('Ages', 'Âges').gsub('years', 'ans') if language == 'fr'
    age_string
  end

  def self.calculate_price(prices_total, price_tier_list)
    temp_price = 0.0
    currency_symbol = ''

    prices_total.split(',').each do |price|
      price_tier_array = price.strip.split(/ /, 3)
      tier = "#{price_tier_array[0]} #{price_tier_array[1]}"

      price_tier_list.data_seek(0)
      price_tier_list.each_hash do |price_tier|
        currency_symbol = price_tier['currencysymbol'].strip

        if price_tier['tier'] == tier
          temp_price += price_tier['price'].to_f
          break
        end

        next
      end
    end

    "#{currency_symbol}#{('%.2f' % temp_price)}".gsub("\u0080", '€')
  end

  def self.calculate_filesize(filesize_total)
    filesize_arr = filesize_total.split(',')
    return filesize_total if filesize_arr.size < 2

    size_total = 0
    capacity_sys = '' # Default is MB
    filesize_arr.each do |filesize|
      temp = filesize.squeeze(' ').split(' ')
      capacity_sys = temp[1]
      size_total += temp[0].include?('.') ? temp[0].to_f : temp[0].to_i
    end

    "#{size_total} #{capacity_sys}"
  end

  # data in MOAS excel file and in Web site are litle difference, so we need to adjust before checking
  # MOAS file       |   Web site
  # ==========================
  # Video           |   Learning Video
  # Just for Fun    |   Just for Fun Video
  # Ultra eBook      |   Interactive Storybook
  # ...
  # params:
  # content type,
  # direction = 'm2s' -> moas file to site
  # =>        = 's2m' -> site to moas file
  def self.map_content_type(content_type, direction = 'm2s')
    if direction == 'm2s'
      case content_type
      when 'Video' then
        'Learning Video'
      when 'Just for Fun' then
        'Just for Fun Video'
      when 'Ultra eBook' then
        'Interactive Storybook'
      else
        content_type
      end
    else
      case content_type
      when 'Learning Video' then
        'Video'
      when 'Just for Fun Video' then
        'Just for Fun'
      when 'Interactive Storybook' then
        'Ultra eBook'
      else
        content_type
      end
    end
  end

  # your tables need to have 'details' column with value "[{:title => 'detail title 1', :text => 'details text 1'}, {...}...]"
  # this return array of hash that you can get value like below:
  # for detail 1
  #   - detail[1][:title]
  #   - detail[1][:text]
  # for detail 2
  #   - detail[2][:title]
  #   - detail[2][:text]
  # ...
  # param detail is row['details'] which is string
  def self.get_details(detail)
    arr = []
    detail_val = eval(detail)

    detail_val.each do |d|
      title = RspecEncode.encode_title d[:title]
      text = RspecEncode.process_long_desc d[:text]
      arr.push(title: title, text: text)
    end

    # insert an value into first position in array
    # help user can access detail1, detail2 by detail[1], detail[2]
    arr.unshift(title: '', text: '')
  end

  #
  # This method is used to convert locale that are not matched between AC site and database
  # prod-www -> www, uk -> gb, row -> oe
  # string: site link. e.g. 'http://uat2-www.leapfrog.com/en-row/app-center/search/?Ntt=59351-96914&Nty=1'
  #
  def self.convert_locale(url)
    str = url.gsub('prod-www', 'www').gsub('preview-www', 'preview').gsub('en-uk', 'en-gb').gsub('en-row', 'en-oe')
    # If locale belong: UK or IE or AU => change: 'center' -> 'centre'
    return str.gsub('app-center', 'app-centre') if str.include?('en-gb') || str.include?('en-ie') || str.include?('en-au')
    str
  end

  #
  # Change URL env: prod-www -> www, preview-www -> preview
  #
  def self.convert_env(url)
    url.gsub('prod-www', 'www').gsub('preview-www', 'preview')
  end

  #
  # This method is used to convert price for each locale
  # e.g. Locale = US: If price_name = '$5 - $10' => price_from = '5', price_to = '10'
  #
  def self.get_price_range(price_name, locale)
    case
    when locale == 'UK'
      price_from = price_name.split('to')[0].delete('£').strip
      price_to = price_name.split('to')[1].delete('£').strip
    when locale == 'AU' # e.g. A$5 to A$10
      price_from = price_name.split('to')[0].delete('A$').strip
      price_to = price_name.split('to')[1].delete('A$').strip
    when locale == 'IE'
      price_from = price_name.split('to')[0].delete("\u0080").delete('€').strip
      price_to = price_name.split('to')[1].delete("\u0080").delete('€').strip
    when locale == 'ROW' # e.g. LF$5 to LF$10
      price_from = price_name.split('to')[0].delete('LF$').strip
      price_to = price_name.split('to')[1].delete('LF$').strip
    else # locale == 'US' or locale == 'CA' e.g. $5 - $10
      price_from = price_name.split('to')[0].delete('$').strip
      price_to = price_name.split('to')[1].delete('$').strip
    end
    { price_from: price_from, price_to: price_to }
  end

  #
  # This method is used to mapping data from English to French ATG Content :
  # E.g. field_name = 'skill', value = 'Reading & Writing|skill1' -> mapp_data = 'Lecture et ecriture'
  #
  def self.map_english_to_french(value, field_name)
    value_arr = value.tr(';', ',').split(',') # Handle for Teaches list that has more than one skill
    data_str = ''
    value_arr.each do |v|
      data_list = Connection.my_sql_connection("select french from atg_moas_fr_mapping where field_name = '#{field_name}' and english = \"#{v.strip}\"")
      if data_list.count > 0
        data_list.data_seek(0)
        data_list.each_hash do |data|
          data_str += data['french'] + ','
          break
        end
      else
        data_str += v + ','
      end
    end
    data_str.gsub(/.{1}$/, '') # Remove last ',' character
  end

  #
  # This method is used to mapping data from French to English ATG Content :
  # E.g. field_name = 'skill', value = 'Lecture et ecriture'-> mapp_data = 'Reading & Writing|skill1'
  #
  def self.map_french_to_english(value, field_name)
    value_temp = value.gsub("\"", "\\\"")
    str = "select english from atg_moas_fr_mapping where field_name = \"#{field_name}\" and french = \"#{value_temp.strip}\""
    data_list = Connection.my_sql_connection(str)
    if data_list.count > 0
      data_list.data_seek(0)
      data_list.each_hash do |data|
        return data['english'] # Get first returned result
      end
    else
      return value # If there is no mapped data, return french value
    end
  end

  #
  # This method is used to convert data for French ATG Content
  # Use to convert: Compatible Platforms, Publisher, Format, Licensors
  # E.g. Content type = 'Learning game|cont12' -> 'Learning game'
  #
  def self.convert_french_moas_data(value)
    value_arr = value.tr(';', ',').split(',')
    str = ''
    value_arr.each do |v|
      str += v.split('|')[0].strip + ','
    end
    str.gsub(/.{1}$/, '')
  end

  def self.map_currency(locale)
    case locale
    when 'UK'
      '£'
    when 'AU'
      'A$'
    when 'IE'
      '€'
    when 'ROW'
      'LF$'
    else
      '$'
    end
  end

  def self.cal_account_balance(value, range, locale = 'US')
    currency = map_currency locale
    val = '%.2f' % (value.split(currency)[-1].strip.to_f + range.to_f)
    currency + val
  end

  def self.teach_info(teaches)
    # teaches: two Teaches information is separated by "," character, if it have a space after "," character, it's a only Teaches information and should only display in a line
    teaches.to_s.gsub(/,[[:space:]]+/, '***').split(',').each { |t| t.gsub!('***', ', ') }
  end

  # SQAAUTO-1503: [F6Q2_S15] 08/18 Narnia release: CONTENT Automation: PDP: Works With information in PDP will display "LeapPad Epic" if MOAS document mentions "Epic" for Platform Compatibility information
  def self.replace_epic_platform(platform)
    platform.map! { |x| x == 'Epic' ? 'LeapFrog Epic' : x }
  end

  def self.get_52_first_chars_of_long_title(long_title)
    return long_title if long_title.length < 56
    long_title[0..51] + '...'
  end
end
