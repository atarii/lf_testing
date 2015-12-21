class AtgContentPlatformCheckerController < ApplicationController
  def index
  end

  def validate_content_platform
    language = params[:language]
    content_platform_csv_file = params[:content_platform_csv_file]

    # temporary path of uploaded files
    path = File.join(Dir.tmpdir, "#{File.basename(Rails.root.to_s)}_#{Time.now.to_i}_#{rand(100)}")
    Dir.mkdir(path)

    # Upload file to server
    csv_file_name = content_platform_csv_file.blank? ? false : ModelCommon.upload_file(path, content_platform_csv_file)

    if csv_file_name
      csv_file_path = File.join(path, csv_file_name)
      @message = AtgContentPlatformChecker.new.validate_content_platform(csv_file_path, language)
    else
      @message = <<-INTERPOLATED_HEREDOC.strip_heredoc
        <div class='col-xs-offset-3'>
          <p class = "small-alert alert-error">
            Please select correct Excel/CSV file format
          </p>
        </div>
      INTERPOLATED_HEREDOC
    end

    FileUtils.rm_rf(path)

    render 'index'
  end
end
