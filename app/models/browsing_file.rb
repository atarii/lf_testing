require 'zip'

class BrowsingFile
  # List all folders in a folder
  def self.bind_folder(folder)
    arr_folders = FileUtilsC.get_folders_name_in folder
    html = ''
    if !arr_folders.nil? && arr_folders.size > 0
      arr_folders.sort_by! { |f| f.downcase }.reverse!
      index = 1
      arr_folders.each do |f|
        sub_folder = folder + '/' + f
        html += "<tr class='bout'>
                            <td style='padding-left: 15px' align='left'><a href='/browsing_files/results?fold=#{sub_folder}'>#{f}</a></td>
                            <td align='center' width='7%'><a href='/browsing_files/download_folder?fold=#{sub_folder}'><img src='/assets/download_folder.png' height='20' width='20' title='Download this folder'></a></td>
                            <td align='center' width='7%'><a onclick='return confirm_delete();' href='/browsing_files/delete?fold=#{sub_folder}&t=folder'><img src='/assets/delete_folder.png' height='20' width='20' title='Delete this folder'></a></td>
                        </tr>"
        index += 1
      end
    end
    html
  end

  # List all files in a folder
  def self.bind_files(folder)
    arr_files = FileUtilsC.get_files_name_in folder
    html = ''
    if !arr_files.nil? && arr_files.size > 0
      arr_files.sort_by! { |f| f.downcase }
      index = 1
      arr_files.each do |f|
        sub_file = folder + '/' + f
        html += "<tr class='bout'>
                          <td style='padding-left: 15px' align='left'><a href='/browsing_files/view_result?fold=#{sub_file}'>#{f}</a></td>
                          <td align='center'>#{FileUtilsC.get_file_size(sub_file)}</td>
                      </tr>"
        index += 1
      end
    end
    html
  end

  # Read file content
  def self.read_file(file)
    file_name =  File.join(Rails.root, file).gsub('/', '\\')
    File.read(file_name)
  end

  # Delete a file or folder
  def self.delete_file_folder(path, type)
    FileUtils.rm_rf path if !path.blank?
    if type == 'file' # If delete file -> return 1
      return 1
    else # If delete folder -> return 2
      return 2
    end
  end

  # Zip folder and return zip file
  def self.zip_folder(folder)
    zipfile_name = File.join(Rails.root, folder + '.zip').gsub('/', '\\')
    directory = File.join(Rails.root, folder).gsub('/', '\\')

    # Setting
    Zip.setup do |c|
      c.continue_on_exists_proc = true # overwrite existing zip file
      c.unicode_names = true # for zip file name is unicode
    end

    # Zip folder
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Find.find(directory) do |file|
        if File.file?(file)
          file = file.gsub('/', '\\')
          zipfile.add(file.sub(directory, ''), file)
        end
      end
    end

    # Return zip file
    zipfile_name
  end

  #
  # Generate path string from path array
  #
  def self.get_path_from_array(path_arr)
    path = ''
    path_arr.each do |e|
      path += e + ' >> '
    end
    path
  end

  #
  # This method is to check if a path already exist in path array
  # If path is exist -> return 'false'
  # Else: Handle for pressing on BackSpace key: remove last path if user selects another folder
  #
  def self.check_if_path_exist(path_arr, path)
    if path_arr.include?(path)
      return false
    else
      last_path = path_arr[path_arr.length - 1]
      arr_last_path = last_path.split('/')
      arr_path = path.split('/')
      if (arr_path[0..arr_path.length - 3] - arr_last_path[0..arr_last_path.length - 3] == [])
        return path_arr[0..path_arr.length - 2]
      else
        return path_arr
      end
    end
  end
end
