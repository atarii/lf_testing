class BrowsingFilesController < ApplicationController
  @@temp_path = '' # Global parameter to save current path
  @@arr_path = [] # Global parameter to save all path

  def index
    # List all folders and files in project result directory
    case params[:type]
    when 'result'
      # Get data: folder, file, path
      @content = BrowsingFile.bind_folder "automations/#{params[:fold]}/reports"
      @file = BrowsingFile.bind_files "automations/#{params[:fold]}/reports"

      # Get paths and push to array
      path = "<a href='/browsing_files/files?fold=automations/%s/reports'>%s result</a>" % [params[:fold], params[:fold]]
      @@arr_path = [path]
      @path, @@temp_path = BrowsingFile.get_path_from_array @@arr_path
    when 'checksum_comparison'
      @content = BrowsingFile.bind_folder 'public/checksum_packages'
      @file = BrowsingFile.bind_files 'public/checksum_packages'

      # Get paths and push to array
      path = "<a href='/browsing_files/files?fold=public/checksum_packages'>checksum results</a>"
      @@arr_path = [path]
      @path, @@temp_path = BrowsingFile.get_path_from_array @@arr_path
    end
  end

  # Load result (folder, file, nav path) when selecting a folder on table
  def results
    # Get folder and file
    @content = BrowsingFile.bind_folder params[:fold]
    @file = BrowsingFile.bind_files params[:fold]

    if @delete_type == 0 || @delete_type == 1 || @delete_type.nil?
      # Get paths and push to array
      folder_name = File.basename(params[:fold])
      path = "<a href='/browsing_files/files?fold=#{params[:fold]}'>#{folder_name}</a>"

      # Check if path exist
      check_path_exist = BrowsingFile.check_if_path_exist(@@arr_path, path)
      if check_path_exist
        @@arr_path = check_path_exist
        @@arr_path.push("<a href='/browsing_files/files?fold=#{params[:fold]}'>#{folder_name}</a>")
      end # Path exist -> Set current path = old path
      @path, @@temp_path = BrowsingFile.get_path_from_array @@arr_path

    else # If delete folder: set current path = old path
      @path = @@temp_path
    end

    # Check if sub folder exist
    @@temp_path = @path if FileUtilsC.check_sub_folder_exist params[:fold]

    # Set default @@delete_type = 0
    @delete_type = 0
    render 'index'
  end

  # Load result (folder, file, nav path) when clicking on a folder on path
  def files
    i = 0
    @@arr_path.each do |path|
      if path.include?(params[:fold])
        # Remove path from current path
        @@arr_path = @@arr_path[0..i]
        @path = ''

        @@arr_path.each do |e| # Put path from array to @path
          @path = @path + e + ' >> '
        end
        @@temp_path = @path

        # Get content: folders, file, count
        @content = BrowsingFile.bind_folder params[:fold]
        @file = BrowsingFile.bind_files params[:fold]

        render 'index' # Reload index page
        return
      end
      i += 1
    end
  end

  # Delete file/folder
  def delete
    @delete_type = BrowsingFile.delete_file_folder params[:fold], params[:t]
    redirect_to request.referrer
  end

  # Download folder as zip file
  def download_folder
    folder = params[:fold]
    # Delete old .zip files
    FileUtilsC.delete_files_by_types(folder[0..folder.rindex('/') - 1], ['.zip'])

    if !folder.blank?
      # Zip folder and send zip file to client
      zipfile_name = BrowsingFile.zip_folder folder
      send_file zipfile_name, type: 'application/zip', x_sendfile: true
    end
  end

  # Download html file
  def download_file
    path = params[:fold]
    file_name = File.join(Rails.root, path).gsub('/', '\\')
    # Send file to client
    send_file file_name, type: 'application/html', x_sendfile: true
  end

  # View a html result file on browser
  def view_result
    file = params[:fold]
    @result_content = BrowsingFile.read_file file
    render layout: false
  end
end
