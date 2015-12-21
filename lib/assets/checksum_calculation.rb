require 'net/http'
require 'digest'
require 'uri'
require 'open-uri'

class ChecksumCalculation
  HTTP_0K_STATUS_CODE = '200'
  HTTP_INVALID_STATUS_CODE = '404'
  HTTP_INVALID_URI_ERROR = 'invalid url'
  HTTP_SOCKET_ERROR = 'SocketError'

  # get http status code
  # params: url
  # return: 200,404,invalid url,error message
  def self.get_http_code(url)
    uri = URI.parse(url)
    response = nil
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.head(url)
    end
    response.code
  rescue URI::InvalidURIError
    HTTP_INVALID_URI_ERROR
  rescue SocketError
    HTTP_SOCKET_ERROR
  rescue => e
    e.message
  end

  # get package size from URL
  def self.get_package_size(url)
    size_mb = 'URL not available'
    url_base = url.split('/')[2]
    url_path = '/' + url.split('/')[3..-1].join('/')

    Net::HTTP.start(url_base) do |http|
      response = http.request_head(URI.escape(url_path))
      if response.code.to_s == '200'
        file_size = response['content-length'].to_i
        if file_size < 1024 # convert to byte
          size_mb = file_size.to_s + 'byte'
        elsif (file_size >= 1024) && (file_size < 1024 * 1024) # convert to Kb
          size_mb = (file_size / 1024).to_s + 'KB'
        elsif (file_size >= 1024 * 1024) && (file_size < 1024 * 1024 * 1024) # convert to Mb
          size_mb = (file_size / 1024 / 1024).to_s + 'MB'
        elsif file_size < 1024 * 1024 * 1024 * 1024 # convert to Mb
          size_mb = (file_size / 1024 / 1024 / 1024).to_s + 'GB'
        end
      end
    end
  end

  # calculate SHA1 checksum
  def self.calculate_checksum(file_path)
    (File.size(file_path) > 0) ? Digest::SHA1.file(file_path).hexdigest : nil
  rescue
    nil
  end

  # download file
  def self.download_file(folder, filename, url)
    filename = get_url_filename(url) if filename.nil?

    # if url not ok, do not download file
    code = get_http_code url

    # download file
    if code == HTTP_0K_STATUS_CODE
      File.open(File.join(folder, filename), 'wb') do |saved_file|
        open(url, 'rb') do |read_file|
          while (buf = read_file.read(1_048_576)) # buffer 1MB
            saved_file.write buf
          end
        end
      end
    end
  end

  # get filename from URL
  def self.get_url_filename(url)
    uri = URI.parse(url)
    File.basename(uri.path)
  end

  # get folder name
  def self.get_folders_name(path)
    arr_folder = []
    Dir.entries(path).select do |entry|
      if File.directory?(File.join(path, entry)) && !(entry == '.' || entry == '..')
        arr_folder.push entry
      end
    end
    arr_folder
  end

  def self.get_excel_file(path)
    arr_file = []
    begin
      Dir.entries(path).select do |entry|
        if File.file?(File.join(path, entry)) && !(entry == '.' || entry == '..') && (File.extname(entry) == '.csv' || File.extname(entry) == '.xls' || File.extname(entry) == '.xlsx')
          arr_file.push entry
        end
      end
    rescue
      arr_file = []
    end
    arr_file
  end

  # return the first excel file
  def self.get_downloaded_files(path)
    arr_file = []
    Dir.entries(path).select do |entry|
      if File.file?(File.join(path, entry)) && !(entry == '.' || entry == '..') && (File.extname(entry) != '.csv' && File.extname(entry) != '.xls' && File.extname(entry) != '.xlsx')
        arr_file.push entry
      end
    end
    arr_file
  end
end
