class Pin < ActiveRecord::Base
  VALID_PIN_REGEX = /^[0-9]{4}\-{0,1}[0-9]{4}\-{0,1}[0-9]{4}\-{0,1}[0-9]{4}\-{0,1}$/
  validates :pin_number, presence: true, format: { with: VALID_PIN_REGEX, multiline: true }

  def self.upload_pin_file(pin_file, env, code_type)
    spreadsheet = ModelCommon.open_spreadsheet pin_file
    return '<p class = "alert alert-error">Please make sure PINs file is saved to Excel format</p>' if spreadsheet.nil?

    header = ModelCommon.downcase_array_key spreadsheet.row(1)
    unless header.include?('id') && header.include?('status')
      return <<-ERROR.strip_heredoc
        <p class = "alert alert-error">
          Make sure that: <br/>
            1. PINs file in the first sheet. <br/>
            2. \'ID\', \'Status\' headers in the first row.
        </p>
      ERROR
    end

    Pin.new.transaction do
      row = 0
      begin
        (2..spreadsheet.last_row).each do |i|
          row = i
          row_header = Hash[[header, spreadsheet.row(i)].transpose]

          # If PIN exist -> update PIN status to PIN excel file, else -> add new PIN record
          pin_exist = Pin.where(env: env, code_type: code_type, pin_number: row_header['id'])
          if pin_exist.empty?
            Pin.create!(env: env, code_type: code_type, pin_number: row_header['id'], platform: row_header['platform'], location: row_header['location'], amount: row_header['amount'], currency: row_header['currency'], status: row_header['status'])
          else
            pin_exist.update_all(status: row_header['status'])
          end
        end
      rescue => e
        ActiveRecord::Rollback
        return "<p class = \"alert alert-error\">Error while uploading data at row #{row}: <br>#{e}</p>"
      end
    end

    "<p class = 'alert alert-success'>PINs are uploaded successfully.</p>"
  end
end
