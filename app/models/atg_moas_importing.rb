class AtgMoasImporting
  attr_accessor :moas_model

  def initialize(table = nil)
    @moas_model = (table == 'atg_moas') ? AtgMoas : AtgMoasFr
  end

  def import_atg_data(moas_file, catalog_file, ymal_file, language)
    message = ''

    # Validate file format
    moas_spreadsheet = catalog_spreadsheet = ymal_spreadsheet = nil
    moas_headers = catalog_headers = ymal_headers = nil

    if moas_file
      moas_spreadsheet = ModelCommon.open_spreadsheet(moas_file)
      return ModelCommon.error_message(
        <<-INTERPOLATED_HEREDOC.strip_heredoc
          Please ensure that: <br/>
          1. The MOAS file is saved with Excel format.<br/>
          2. The MOAS data in the first sheet.
      INTERPOLATED_HEREDOC
      ) if moas_spreadsheet.nil?

      moas_headers = Header.get_required_header_row(moas_spreadsheet, ['Go Live Date', 'Product Number', 'SKU'])
      return ModelCommon.error_message('The MOAS file is empty or missing headers. Please re-check!') if moas_headers == -1

      fail_moas_headers = Header.verify_header(moas_headers[:headers], language)
      return ModelCommon.error_message("The MOAS column headers are missing: <br/>#{fail_moas_headers}") unless fail_moas_headers.blank?
    end

    if catalog_file
      catalog_spreadsheet = ModelCommon.open_spreadsheet(catalog_file)
      return ModelCommon.error_message(
        <<-INTERPOLATED_HEREDOC.strip_heredoc
          Please ensure that: <br/>
          1. The Catalog file is saved with Excel format.<br/>
          2. The Catalog data in the first sheet.
      INTERPOLATED_HEREDOC
      ) if catalog_spreadsheet.nil?

      catalog_headers = Header.get_required_header_row(catalog_spreadsheet, ['skuCode', 'trailerLink', 'trailerSizes', 'screenshots'])
      return ModelCommon.error_message(
        <<-INTERPOLATED_HEREDOC.strip_heredoc
          Please ensure that: <br/>
          The Catalog file contains headers: 'skuCode', 'trailerLink', 'trailerSizes' and 'screenShots'
      INTERPOLATED_HEREDOC
      ) if catalog_headers == -1
    end

    if ymal_file
      ymal_spreadsheet = ModelCommon.open_spreadsheet(ymal_file)
      return ModelCommon.error_message(
        <<-INTERPOLATED_HEREDOC.strip_heredoc
          Please ensure that: <br/>
          1. The YMAL file is saved with Excel format.<br/>
          2. The YMAL data in the first sheet.
      INTERPOLATED_HEREDOC
      ) if ymal_spreadsheet.nil?

      ymal_headers = Header.get_required_header_row(ymal_spreadsheet, ['Source SKU', 'Target SKU'])
      return ModelCommon.error_message(
        <<-INTERPOLATED_HEREDOC.strip_heredoc
          Please ensure that: <br/>
          The YMAL file contains headers: 'Source SKU', 'Target SKU'.
      INTERPOLATED_HEREDOC
      ) if ymal_headers == -1
    end

    # Import MOAS, Catalog and YMAL files
    ActiveRecord::Base.transaction do
      begin
        # 1. Update data from MOAS file
        if moas_file
          @moas_model.delete_all

          moas_records = moas_records(moas_spreadsheet, moas_headers, language)
          @moas_model.create(moas_records)

          # Update locales
          update_locale

          # Update Trailer from '' to "No"
          @moas_model.where(trailer: '').update_all(trailer: 'No')
        end

        # 2. Import data from Catalog file
        if catalog_file
          start_index = catalog_headers[:index] + 1
          (start_index..catalog_spreadsheet.last_row).each do |i|
            row = ModelCommon.replace_hash_value(Hash[[catalog_headers[:headers], catalog_spreadsheet.row(i)].transpose], nil, '')
            @moas_model.where(sku: row['skucode']).update_all(trailerlink: row['trailerlink'], trailersizes: row['trailersizes'], screenshots: row['screenshots'])
          end
        end

        # 3. Import data from YMAL file
        if ymal_file
          temp = []
          start_index = ymal_headers[:index] + 1
          (start_index..ymal_spreadsheet.last_row).each do |i|
            row = ModelCommon.replace_hash_value(Hash[[ymal_headers[:headers], ymal_spreadsheet.row(i)].transpose], nil, '')
            temp << { sku: row['source sku'], ymal: row['target sku'] }
          end

          yaml_array = temp.group_by { |x| x[:sku] }.values
          yaml_array.map! { |x| { sku: x[0][:sku], ymal: x.map { |y| y[:ymal] }.join(',') } }

          yaml_array.each do |el|
            @moas_model.where(prodnumber: el[:sku]).update_all(ymal: el[:ymal])
          end
        end

        message = ModelCommon.success_message('The MOAS file is imported successfully') if moas_file
        message << ModelCommon.success_message('The Catalog file is imported successfully') if catalog_file
        message << ModelCommon.success_message('The YMAL file is imported successfully') if ymal_file
      rescue => e
        message = ModelCommon.error_message('Error while importing: <br/>' << e.message)
        raise ActiveRecord::Rollback
      end
    end

    message
  end

  def moas_records(moas_spreadsheet, moas_headers, language)
    records_arr = []
    start_index = moas_headers[:index] + 1
    headers_arr = moas_headers[:headers]

    (start_index..moas_spreadsheet.last_row).each do |i|
      row = ModelCommon.replace_hash_value(Hash[[headers_arr, moas_spreadsheet.row(i)].transpose], nil, '')
      next if row['sku'].include?('MDL') || row['product number'].include?('MDL')

      details = []
      (1..10).each do |num|
        title = row["#{Header::MOAS_HEADERS[:"DETAIL#{num}TITLE"]}"]
        text = row["#{Header::MOAS_HEADERS[:"DETAIL#{num}TEXT"]}"]
        details.push(title: title, text: text) unless title.blank?
      end

      if language == Header::FRENCH
        platform = row["#{Header::MOAS_HEADERS_FRENCH[:PLATFORMCOMPATIBILITY]}"]
        teaches = row["#{Header::MOAS_HEADERS_FRENCH[:TEACHES]}"]
        fr_fr = row["#{Header::MOAS_HEADERS[:FRANCE]}"] || ''
        fr_ca = row["#{Header::MOAS_HEADERS[:FRENCH_CANADA]}"] || ''
        fr_row = row["#{Header::MOAS_HEADERS[:FRENCH_ROW]}"] || ''
      else
        platform = row["#{Header::MOAS_HEADERS[:PLATFORMCOMPATIBILITY]}"]
        teaches = row["#{Header::MOAS_HEADERS[:TEACHES]}"]
        fr_fr = ''
        fr_ca = ''
        fr_row = ''
      end

      records_arr.push(
        golivedate: date_default_value(row["#{Header::MOAS_HEADERS[:GOLIVEDATE]}"]),
        appstatus: row["#{Header::MOAS_HEADERS[:APPSTATUS]}"],
        prodnumber: row["#{Header::MOAS_HEADERS[:PRODNUMBER]}"],
        sku: row["#{Header::MOAS_HEADERS[:SKU]}"],
        shortname: row["#{Header::MOAS_HEADERS[:SHORTNAME]}"],
        longname: row["#{Header::MOAS_HEADERS[:LONGNAME]}"],
        gender: row["#{Header::MOAS_HEADERS[:GENDER]}"],
        agefrommonths: number_default_value(row["#{Header::MOAS_HEADERS[:AGEFROMMONTHS]}"]),
        agetomonths: number_default_value(row["#{Header::MOAS_HEADERS[:AGETOMONTHS]}"]),
        skills: row["#{Header::MOAS_HEADERS[:SKILLS]}"],
        curriculum: row["#{Header::MOAS_HEADERS[:CURRICULUM]}"],
        lfdesc: row["#{Header::MOAS_HEADERS[:LFDESC]}"],
        onesentence: row["#{Header::MOAS_HEADERS[:ONESENTENCE]}"],
        moreinfolb: row["#{Header::MOAS_HEADERS[:MOREINFOLB]}"],
        moreinfotxt: row["#{Header::MOAS_HEADERS[:MOREINFOTXT]}"],
        platformcompatibility: platform,
        specialmsg: row["#{Header::MOAS_HEADERS[:SPECIALMSG]}"],
        teaches: teaches,
        legaltop: row["#{Header::MOAS_HEADERS[:LEGALTOP]}"],
        legalbottom: row["#{Header::MOAS_HEADERS[:LEGALBOTTOM]}"],
        licensed: row["#{Header::MOAS_HEADERS[:LICENSED]}"],
        licensors: row["#{Header::MOAS_HEADERS[:LICENSORS]}"],
        language: row["#{Header::MOAS_HEADERS[:LANGUAGE]}"],
        pricetier: row["#{Header::MOAS_HEADERS[:PRICETIER]}"],
        contenttype: row["#{Header::MOAS_HEADERS[:CONTENTTYPE]}"],
        trailer: row["#{Header::MOAS_HEADERS[:TRAILER]}"],
        us: row["#{Header::MOAS_HEADERS[:US]}"] || '',
        ca: row["#{Header::MOAS_HEADERS[:CA]}"] || '',
        uk: row["#{Header::MOAS_HEADERS[:UK]}"] || '',
        ie: row["#{Header::MOAS_HEADERS[:IE]}"] || '',
        au: row["#{Header::MOAS_HEADERS[:AU]}"] || '',
        row: row["#{Header::MOAS_HEADERS[:ROW]}"] || '',
        fr_fr: fr_fr,
        fr_ca: fr_ca,
        fr_row: fr_row,
        lfshoppingcartname: row["#{Header::MOAS_HEADERS[:LFSHOPPINGCARTNAME]}"],
        format: row["#{Header::MOAS_HEADERS[:FORMAT]}"],
        filesize: row["#{Header::MOAS_HEADERS[:FILESIZE]}"],
        lfchar: row["#{Header::MOAS_HEADERS[:LFCHAR]}"],
        publisher: row["#{Header::MOAS_HEADERS[:PUBLISHER]}"],
        length: row["#{Header::MOAS_HEADERS[:LENGTH]}"].to_i,
        highlights: row["#{Header::MOAS_HEADERS[:HIGHLIGHTS]}"],
        learningdifference: row["#{Header::MOAS_HEADERS[:LEARNINGDIFFERENCE]}"],
        details: details.to_s,
        miscnotes: row["#{Header::MOAS_HEADERS[:MISCNOTES]}"],
        baseassetname: row["#{Header::MOAS_HEADERS[:BASEASSETNAME]}"]
      )
    end

    records_arr
  end

  # update locale of titles table after insert completely
  def update_locale
    @moas_model.update_all("lp2 = CASE WHEN lower(platformcompatibility) like '%leappad2%' or lower(platformcompatibility) like '%leappad 2%' THEN 'X' ELSE '' END")
    @moas_model.update_all("lp1 = CASE WHEN lower(platformcompatibility) like '%leappad explorer%' or lower(platformcompatibility) like '%leappad1%' or lower(platformcompatibility) like '%leappad 1%' THEN 'X' ELSE '' END")
    @moas_model.update_all("lpu = CASE WHEN lower(platformcompatibility) like '%leappad ultra%' or lower(platformcompatibility) like '%leappadultra%' THEN 'X' ELSE '' END")
    @moas_model.update_all("lex = CASE WHEN lower(platformcompatibility) like '%leapster explorer%' THEN 'X' ELSE '' END")
    @moas_model.update_all("lgs = CASE WHEN lower(platformcompatibility) like '%leapstergs explorer%' THEN 'X' ELSE '' END")
    @moas_model.update_all("lpr = CASE WHEN lower(platformcompatibility) like '%leapreader%' THEN 'X' ELSE '' END")
    @moas_model.update_all("lp3 = CASE WHEN lower(platformcompatibility) like '%leappad3%' THEN 'X' ELSE '' END")
  end

  # return default value for number data type
  def number_default_value(text)
    text.to_s.blank? ? 0 : text
  end

  # return default value for date data type
  def date_default_value(date)
    default_date = date.to_s
    default_date.blank? ? '0000-00-00' : default_date
  end
end

class Header
  FRENCH = 'french'
  ENGLISH = 'english'
  MOAS_HEADERS = {
    GOLIVEDATE: 'go live date',
    APPSTATUS: 'app status',
    PRODNUMBER: 'product number',
    SKU: 'sku',
    SHORTNAME: 'lf short name',
    LONGNAME: 'lf long name',
    GENDER: 'gender',
    AGEFROMMONTHS: 'age from (months)',
    AGETOMONTHS: 'age to (months)',
    SKILLS: 'skills',
    CURRICULUM: 'curriculum',
    LFDESC: 'lf description',
    ONESENTENCE: 'one-sentence description',
    MOREINFOLB: 'more info label',
    MOREINFOTXT: 'more info text',
    PLATFORMCOMPATIBILITY: 'platform compatibility',
    PLATFORMCOMPATIBILITY_FR: 'french platform compatibility',
    SPECIALMSG: 'special message',
    TEACHES: 'teaches',
    TEACHES_FR: 'french teaches',
    LEGALTOP: 'legal top',
    LEGALBOTTOM: 'legal bottom',
    LICENSED: 'licensed',
    LICENSORS: 'licensors',
    LANGUAGE: 'language',
    PRICETIER: 'price tier',
    CONTENTTYPE: 'content type',
    TRAILER: 'trailer available',
    US: 'en_us',
    CA: 'en_ca',
    UK: 'en_gb',
    IE: 'en_ie',
    AU: 'en_au',
    ROW: 'en_row',
    FRANCE: 'france',
    FRENCH_CANADA: 'french canada',
    FRENCH_ROW: 'french row',
    LFSHOPPINGCARTNAME: 'lf shopping cart name',
    FORMAT: 'format',
    FILESIZE: 'file size',
    LFCHAR: 'characters',
    PUBLISHER: 'publisher',
    LENGTH: 'length (minutes)',
    HIGHLIGHTS: 'highlights',
    LEARNINGDIFFERENCE: 'the learning difference',
    BASEASSETNAME: 'base asset name',
    DETAIL1TITLE: 'details 1 - title',
    DETAIL1TEXT: 'details 1 - text',
    DETAIL2TITLE: 'details 2 - title',
    DETAIL2TEXT: 'details 2 - text',
    DETAIL3TITLE: 'details 3 - title',
    DETAIL3TEXT: 'details 3 - text',
    DETAIL4TITLE: 'details 4 - title',
    DETAIL4TEXT: 'details 4 - text',
    DETAIL5TITLE: 'details 5 - title',
    DETAIL5TEXT: 'details 5 - text',
    DETAIL6TITLE: 'details 6 - title',
    DETAIL6TEXT: 'details 6 - text',
    DETAIL7TITLE: 'details 7 - title',
    DETAIL7TEXT: 'details 7 - text',
    DETAIL8TITLE: 'details 8 - title',
    DETAIL8TEXT: 'details 8 - text',
    DETAIL9TITLE: 'details 9 - title',
    DETAIL9TEXT: 'details 9 - text',
    DETAIL10TITLE: 'details 10 - title',
    DETAIL10TEXT: 'details 10 - text',
    MISCNOTES: 'misc notes'
  }

  # declare header for Moas French
  MOAS_HEADERS_FRENCH = { PLATFORMCOMPATIBILITY: 'french platform compatibility', TEACHES: 'french teaches' }

  # make sure header in MOAS excel file is design
  def self.verify_header(header, language)
    headers_const = MOAS_HEADERS.values
    failed_headers = headers_const - header

    if language == ENGLISH
      failed_headers.delete_if { |h| h == MOAS_HEADERS[:PLATFORMCOMPATIBILITY_FR] || h == MOAS_HEADERS[:TEACHES_FR] || h == MOAS_HEADERS[:FRANCE] || h == MOAS_HEADERS[:FRENCH_CANADA] || h == MOAS_HEADERS[:FRENCH_ROW] }
    else
      failed_headers.delete_if { |h| h == MOAS_HEADERS[:PLATFORMCOMPATIBILITY] || h == MOAS_HEADERS[:TEACHES] || h == MOAS_HEADERS[:US] || h == MOAS_HEADERS[:CA] || h == MOAS_HEADERS[:UK] || h == MOAS_HEADERS[:AU] || h == MOAS_HEADERS[:IE] || h == MOAS_HEADERS[:ROW] }
    end

    failed_headers.empty? ? '' : failed_headers
  end

  def self.get_required_header_row(spreadsheet, required_header_row = [])
    return -1 if spreadsheet.nil? || spreadsheet.count < 1

    required_header_row = ModelCommon.downcase_array_key required_header_row

    (1..spreadsheet.last_row).each do |i|
      row = ModelCommon.downcase_array_key spreadsheet.row(i)
      return { index: i, headers: row } if (required_header_row - row).empty?
    end

    -1
  end
end
