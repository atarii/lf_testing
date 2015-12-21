class Checksum
  #
  # sequentially download file
  # params: 1. path: use to save files
  #         2. file: csv file
  #
  def self.dowload_files(path, file)
    return ErrorNo::FileFolder::F_EXIST if !path.nil? && File.directory?(path)
    FileUtils.mkdir_p path

    # 1. upload csv file
    exl_file = Uploading.upload_excel_file path, file

    # 2. read csv file
    if exl_file == ErrorNo::UploadFile::EXCEL_INVALID_FILE_TYPE || exl_file == ErrorNo::UploadFile::EXCEPTION
      FileUtils.rm_rf path
      return exl_file
    end

    # 2.1 validate header
    spreadsheet = Uploading.validate_excel_header path, exl_file
    if spreadsheet.nil?
      FileUtils.rm_rf path
      return ErrorNo::UploadFile::EXCEL_CANNOT_OPEN
    elsif spreadsheet.is_a?(Array)
      FileUtils.rm_rf path
      return spreadsheet
    end

    # 2. download file
    if spreadsheet.last_row > 1
      header = downcase_array_key spreadsheet.row(1)
      Thread.new do
        (2..spreadsheet.last_row).each do |i|
          begin
            row = Hash[[header, spreadsheet.row(i)].transpose]
            ChecksumCalculation.download_file(path, nil, row[ExcelHeader::CHECKSUM_HEADERS['url'].downcase])
          rescue => e
            File.open(Rails.root.join('log', 'download_file.log'), 'a') { |f| f.write("\n******#{Time.now}*********************\n" << e.message) }
          end
        end
      end
    end
  end

  # roo lib is case sensitive
  def self.downcase_array_key(arr)
    arr.map { |i| i.to_s.downcase if !i.nil? }
  end

  #
  #
  #
  def self.get_checksum_info(path, file)
    content = ''
    spreadsheet = Uploading.open_spreadsheet File.join(path, file)
    if !spreadsheet.nil?
      index = 0
      if spreadsheet.last_row > 1
        header = downcase_array_key spreadsheet.row(1)
        downloaded_files = ChecksumCalculation.get_downloaded_files(path)
        (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          url = row[ExcelHeader::CHECKSUM_HEADERS['url'].downcase]
          next if url.nil?

          content += '<tr>'
          # #
          content += "<td>#{index += 1}</td>"
          # Package
          content += '<td>' + row["#{ExcelHeader::CHECKSUM_HEADERS['package_id'].downcase}"] + '</td>'
          # URL
          content += '<td>' + url + '</td>'
          # Begin downloading
          content += '<td>' + format_begin_downloading_time(path, downloaded_files, ChecksumCalculation.get_url_filename(url)) + '</td>'
          # End downloading
          content += '<td>' + format_end_downloading_time(path, downloaded_files, ChecksumCalculation.get_url_filename(url)) + '</td>'
          # Package size
          content += '<td>' + get_file_size(path, downloaded_files, ChecksumCalculation.get_url_filename(url)) + '</td>'
          # Expected checksum
          content += '<td>' + row["#{ExcelHeader::CHECKSUM_HEADERS['checksum'].downcase}"] + '</td>'
          # Actual checksum
          actual_checksum = get_checksum(path, downloaded_files, ChecksumCalculation.get_url_filename(url))
          content += '<td>' + actual_checksum + '</td>'
          # Result
          content += '<td>' + format_result(row["#{ExcelHeader::CHECKSUM_HEADERS['checksum'].downcase}"], actual_checksum) + '</td>'
          content += '</tr>'
        end
      end
    end
    content
  end

  #
  #
  #
  def self.get_header_info(file)
    re_msg = nil
    path = Rails.root.join('public', 'upload')
    # delete files
    FileUtilsC.delete_files(path)

    # 1. upload csv file
    exl_file = Uploading.upload_excel_file path, file

    # 2. read csv file
    return exl_file if exl_file == ErrorNo::UploadFile::EXCEL_INVALID_FILE_TYPE || exl_file == ErrorNo::UploadFile::EXCEPTION

    # 2.1 validate header
    spreadsheet = Uploading.validate_excel_header path, exl_file
    if spreadsheet.nil?
      return ErrorNo::UploadFile::EXCEL_CANNOT_OPEN
    elsif spreadsheet.is_a?(Array)
      return spreadsheet
    end

    # 2. download file
    if spreadsheet.last_row > 1
      content = ''
      index = 0
      header = downcase_array_key spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        url = row[ExcelHeader::CHECKSUM_HEADERS['url'].downcase]
        next if url.nil?
        content += '<tr>'
        # #
        content += "<td>#{index += 1}</td>"
        # URL
        content += '<td>' + url + '</td>'
        # Response
        content += '<td>' + format_response(ChecksumCalculation.get_http_code(url)) + '</td>'

        content += '</tr>'
      end
      re_msg = content
    end
    re_msg
  end

  def self.format_end_downloading_time(path, downloaded_files, filename)
    if downloaded_files.include?(filename)
      time = File.mtime(File.join(path, filename))
      '%s-%s-%s %s:%s:%s' % [time.mon, time.day, time.year, time.hour, time.min, time.sec]
    else
      ''
    end
  rescue
    'Error when formatting time'
  end

  def self.format_begin_downloading_time(path, downloaded_files, filename)
    if downloaded_files.include?(filename)
      time = File::Stat.new(File.join(path, filename)).ctime
      '%s-%s-%s %s:%s:%s' % [time.mon, time.day, time.year, time.hour, time.min, time.sec]
    else
      ''
    end
  rescue
    'Error when formatting time'
  end

  def self.get_checksum(path, downloaded_files, filename)
    if downloaded_files.include?(filename)
      checksum = ChecksumCalculation.calculate_checksum(File.join(path, filename))
      (checksum.nil?) ? 'downloading' : checksum
    else
      ''
    end
  end

  def self.get_file_size(path, downloaded_files, filename)
    downloaded_files.include?(filename) ? FileUtilsC.get_file_size(File.join(path, filename)) : ''
  end

  def self.format_result(expected_checksum, actual_checksum)
    if actual_checksum == '' || actual_checksum == 'downloading'
      '&nbsp;'
    elsif expected_checksum == actual_checksum
      "<label class='pass'>Pass</label>"
    elsif expected_checksum != actual_checksum
      '<label class=\'fail\'>Fail</label>'
    else
      actual_checksum
    end
  end

  def self.format_response(code)
    output = code
    case code
    when ChecksumCalculation::HTTP_0K_STATUS_CODE
      output = ChecksumCalculation::HTTP_0K_STATUS_CODE + ' - ' + '<lable class=\'pass\'>PASS</lable>'
    when ChecksumCalculation::HTTP_INVALID_STATUS_CODE
      output = ChecksumCalculation::HTTP_INVALID_STATUS_CODE + ' - ' + '<lable class=\'fail\'>FAIL</lable>'
    when ChecksumCalculation::HTTP_INVALID_URI_ERROR
      output = "<lable class='error'>#{ChecksumCalculation::HTTP_INVALID_URI_ERROR}</lable>"
    when ChecksumCalculation::HTTP_SOCKET_ERROR
      output = '<lable class=\'socket_error\'>getaddrinfo: No such host is known. </lable>'
    end
    output
  end
end
