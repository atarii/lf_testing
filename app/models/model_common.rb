require 'csv'

class ModelCommon
  # check connection with info from database.yml file
  def self.check_db_connection
    config = Rails.configuration.database_configuration
    host = config[Rails.env]['host']
    port = config[Rails.env]['port']
    database = config[Rails.env]['database']
    username = config[Rails.env]['username']
    password = config[Rails.env]['password']
    con = Connection.new
    con.open_connection host, port, username, password, database
    con.close_connection
    return true
  rescue
    return false
  end

  # update file from client to server
  # if file_ext not given, uploading excel file type
  def self.upload_file(path, file, file_name = nil, file_ext = nil)
    file_name = "~#{Time.now.strftime('%Y%m%dT%H%M%S')}_#{file.original_filename}" if file_name.nil?
    ext = File.extname(file.original_filename)
    file_name = "#{file_name}#{ext}" if File.extname(file_name) == ''

    if file_ext.nil?
      return false unless ext == '.xls' || ext == '.xlsx' || ext == '.csv'
    else
      return false unless ext == file_ext
    end

    File.open(File.join(path, file_name), 'wb') { |f| f.write(file.read) }

    file_name
  end

  # open excel file
  def self.open_spreadsheet(file)
    begin
      case File.extname(File.basename(file))
      when '.xls'
        exl = Roo::Excel.new(file, { mode: 'r' }, :ignore)
      when '.xlsx'
        exl = Roo::Excelx.new(file, { mode: 'r' }, :ignore)
      when '.csv'
        exl = Roo::CSV.new(file, mode: 'r')
      end

      exl.sheet 0
      exl.row(1)
    rescue => e
      Rails.logger.error "Open spreadsheet error >>> #{e.message} >>> #{e.class.name}"
      return nil
    end
    exl
  end

  # E.g. '0,1,2,3,4,5,6' -> 'Sun, Mon, Tue, Wed, Thu, Fri, Sat'
  def self.to_day_of_week(dow_str)
    dow_str.split(',').map { |d| Date::DAYNAMES[d.to_i][0..2] }.join(', ')
  end

  # Update data_driven csv and return test data
  def self.upload_and_get_data_driven_csv(file)
    return '' if file.blank?

    file_name = "~#{Time.now.strftime('%Y%m%dT%H%M%S')}_#{file.original_filename}"
    ext = File.extname(file_name)

    return [] unless ext == '.csv'

    temp_file = Tempfile.new(file_name)
    file_path = temp_file.path
    Rails.logger.debug "Data driven file's path >>> #{file_path}"

    File.open(file_path, 'wb') { |f| f.write(file.read) }

    data = []
    CSV.foreach(file_path, headers: true) do |row|
      data.push(row.to_hash)
    end

    data
  end

  def self.downcase_array_key(array)
    array.map { |i| i.to_s.downcase unless i.nil? }
  end

  def self.replace_hash_value(hash, from, to)
    hash.map { |key, value| [key, value == from ? to : value] }.to_h
  end

  def self.error_message(message)
    "<p class = \"small-alert alert-error\">#{message}</p>"
  end

  def self.success_message(message)
    "<p class = \"small-alert alert-success\">#{message}</p>"
  end

  def self.full_exception_error(exception)
    "#{exception} \n" + exception.backtrace.join("\n")
  end
end
