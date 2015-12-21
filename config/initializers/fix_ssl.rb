require 'net/https'
require 'open-uri'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      self.ca_file = 'lib/assets/cacert.pem'
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end
