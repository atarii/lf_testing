class AtgMoasImportingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @message = ''
  end

  # import MOAS excel file to database for ATG content
  def excel2mysql
    moas_file_param = params[:excel_file]
    catalog_file_param = params[:excel_catalog_file]
    ymal_file_param = params[:excel_ymal_file]
    language = params[:language]
    table = language == 'english' ? 'atg_moas' : 'atg_moas_fr'

    # initial AtgMoasImporting
    atg_import = AtgMoasImporting.new table

    # get temporary path of uploaded files
    path = File.join(Dir.tmpdir, "#{File.basename(Rails.root.to_s)}_#{Time.now.to_i}_#{rand(100)}")
    Dir.mkdir(path)

    # upload file
    moas_file_name = moas_file_param.blank? ? false : ModelCommon.upload_file(path, moas_file_param)
    catalog_file_name = catalog_file_param.blank? ? false : ModelCommon.upload_file(path, catalog_file_param)
    ymal_file_name = ymal_file_param.blank? ? false : ModelCommon.upload_file(path, ymal_file_param)

    # import to mysql
    if moas_file_name || catalog_file_name || ymal_file_name
      moas_file = File.join(path, moas_file_name) if moas_file_name
      catalog_file = File.join(path, catalog_file_name) if catalog_file_name
      ymal_file = File.join(path, ymal_file_name) if ymal_file_name
      @message = atg_import.import_atg_data moas_file, catalog_file, ymal_file, language
    else
      @message = '<p class="alert alert-error">Please select correct .xls/.xlsx file</p>'
    end

    FileUtils.rm_rf(path)

    render 'index'
  end
end
