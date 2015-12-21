#--------------------------
class ExcelHeader
  CHECKSUM_HEADERS = Hash[
  'title'=>'Title',
  'package_id'=>'Package Id',
  'url'=>'URL',
  'checksum'=>'Checksum']
  
  #
  # verify checksum header
  #
  def self.verify_checksum_header header
    headers_const = []

    CHECKSUM_HEADERS.each_value do |v|
      headers_const.push(v)
    end

    failed_hearders = headers_const.map{|i| i.downcase} - header.map{|i| i.downcase if !i.nil?}

    if failed_hearders.to_s == '[]'
      return true
    else
      return failed_hearders
    end
  end
end