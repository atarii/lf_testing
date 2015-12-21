require 'error'

class Uploading < ActiveRecord::Base
  # upload excel file from client to server
  # return: sever file name
  #        -1: not excel file type
  #        -2: cannot update
  def self.upload_excel_file(path, file)
    msg = nil
    begin
      server_file_name = "~#{Time.new.month}#{Time.new.day}#{Time.new.year}#{Time.new.hour}#{Time.new.min}#{Time.new.sec}_#{file.original_filename}"
      ext = File.extname(file.original_filename)
      if ext == '.xls' || ext == '.xlsx' || ext == '.csv'
        File.open(File.join(path, server_file_name), 'wb') do |f|
          f.write(file.read)
        end
        msg = server_file_name
      else
        msg = ErrorNo::UploadFile::EXCEL_INVALID_FILE_TYPE # not excel file type
      end
    rescue Exception
      msg = ErrorNo::UploadFile::EXCEPTION # cannot upload
    end

    msg
  end

  # open excel file
  def self.open_spreadsheet(file)
    exl = nil
    begin
      case File.extname(File.basename(file))
      when '.csv'
        exl = Roo::CSV.new(file, { mode: 'r' })
      when '.xls'
        exl = Roo::Excel.new(file, { mode: 'r' }, :ignore)
      when '.xlsx'
        exl = Roo::Excelx.new(file, { mode: 'r' }, :error)
      end

      # handle case: <#to_s method raised exception: undefined method `text' for nil:NilClass>
      exl = nil if exl.to_s.include?('nil:NilClass')

    rescue Exception
      exl = nil
    end

    exl
  end

  #
  # validate header of excel file
  #
  def self.validate_excel_header(path, file)
    spreadsheet = Uploading::open_spreadsheet File.join(path, file)

    if !spreadsheet.nil? && spreadsheet.last_row > 1
      header = Checksum::downcase_array_key spreadsheet.row(1)

      # verify header, raise error if not map
      no_failed_hearders = ExcelHeader::verify_checksum_header header

      return (no_failed_hearders == true) ? spreadsheet : [ErrorNo::UploadFile::EXCEL_MISSING_HEADER, no_failed_hearders.to_s]
    end
  end
end
