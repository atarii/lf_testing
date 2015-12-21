class Generate
  # this function will generate unique guest email
  def self.email(type = 'atg', env = 'uat', locale = 'us')
    time = Time.now.strftime('%m%d%Y%H%M%S%3N')
    "ltrc_#{type}_#{env}_#{locale}_#{time}@sharklasers.com"
  end

  # this function will get state name of a state code
  def self.state_name(state_code)
    case state_code
    when 'AB'
      return 'Alberta'
    when 'BC'
      return 'British Columbia'
    when 'MB'
      return 'Manitoba'
    when 'NB'
      return 'New Brunswick'
    when 'NL'
      return 'Newfoundland and Labrador'
    when 'NT'
      return 'Northwest Territories'
    when 'NS'
      return 'Nova Scotia'
    when 'NU'
      return 'Nunavut'
    when 'ON'
      return 'Ontario'
    when 'PE'
      return 'Prince Edward Island'
    when 'QC'
      return 'Quebec'
    when 'SK'
      return 'Saskatchewan'
    when 'YT'
      return 'Yukon Territory'
    end
  end

  #
  # generate gift value
  #
  def self.get_gift_value(locale, email)
    # get cus id from email
    cus_id = CustomerManagement.search_for_customer(ServicesInfo::CONST_CALLER_ID, email).xpath('//customer/@id')

    # reserve gift pin
    # locale = 'en_US'...
    sof_goo_res = SoftGoodManagement.reserve_gift_pin ServicesInfo::CONST_CALLER_ID, locale
    pin = sof_goo_res.xpath('//reserved-pin').text

    # purchase gift pin
    res_pin = SoftGoodManagement.purchase_gift_pin(ServicesInfo::CONST_CALLER_ID, cus_id, pin)

    # return pin value
    res_pin.xpath('//pin/@pin').to_s
  end

  def self.get_current_time
    time = Time.new
    time.year.to_s + time.month.to_s + time.day.to_s + time.hour.to_s + time.min.to_s + time.sec.to_s + Random.rand(1...100).to_s
  end
end
