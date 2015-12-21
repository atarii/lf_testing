class ChecksumComparisonController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
  end

  #
  # upload excel file and then download files
  #
  def get_checksum
    msg = nil
    header_only = nil

    if params[:chk_header_only] == '1'
      # bind header only content
      header_only  = true
      msg = Checksum.get_header_info params[:excel_file]
    else
      # 2. sequentially download package in checksum file
      path = Rails.root.join('public', 'checksum_packages', params[:folder])
      msg = Checksum.dowload_files path, params['excel_file']
    end

    if msg == ErrorNo::UploadFile::EXCEL_INVALID_FILE_TYPE
      message = 'Please select correct excel file type: .csv/.xls/.xlsx'
    elsif msg == ErrorNo::UploadFile::EXCEPTION
      message = 'Error occurred when uploading file. Please contact administrator for more details.'
    elsif msg == ErrorNo::FileFolder::F_EXIST
      message = "'#{params[:folder]}' folder already exists. Please enter new name"
    elsif msg.is_a?(Array) && msg[0] == ErrorNo::UploadFile::EXCEL_MISSING_HEADER
      message = 'Below is the missing header titles list. Please update header title(s) of the excel file or contact your administrator<br/>' + msg[1]
    elsif msg == ErrorNo::UploadFile::EXCEL_CANNOT_OPEN
      message = 'Cannot open file! Please try again.'
    elsif header_only
      message = msg
    else
      message = '<p class=\'alert alert-success\'>Server is downloading packages sequentially. Please navigate to Checksum Comparison Result page for more details.</p>'
    end

    render plain: message
  end

  def view_result
    session['hid_selected_folder'] = nil
    session['folders'] = nil
    session['folders'] = ChecksumCalculation.get_folders_name(Rails.root.join('public', 'checksum_packages')).insert(0, '--select folder--')
    render 'view_result'
  end

  #
  # Show status of completed files
  #
  def load_content
    # read csv file
    path = Rails.root.join('public', 'checksum_packages', params[:folder])
    arr_file = ChecksumCalculation.get_excel_file(path)
    @content = Checksum.get_checksum_info path, arr_file[0] if !arr_file.nil? && arr_file.count > 0
    session['hid_selected_folder'] = params[:hid_selected_folder]
    render 'view_result'
  end
end
