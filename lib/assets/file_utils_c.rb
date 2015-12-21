require 'find'

class FileUtilsC
  #
  # Delete all files in folder
  #
  def self.delete_files path
    Dir.foreach(path) do |fname|
      begin
        # do something with fname
        next if fname == '.' or fname == '..'
        File.delete(File.join(path, fname))
      rescue Exception => e
        puts e.message
      end
    end
  end

  #
  # return array folders's name
  #
  def self.get_folders_name_in directory
    arr = []
    begin
      Dir.entries(directory).select { |f|
        if File.directory? File.join(directory, f)
          next if f == '.' or f == '..'
          arr.push f
        end
      }
    rescue
    end
    return arr
  end

  #
  #Check if has sub folder in directory
  #
  def self.check_sub_folder_exist directory
    begin
      Dir.entries(directory).select { |f|
        if File.directory? File.join(directory, f)
          next if f == '.' or f == '..'
          return true
        end
      }
    rescue Exception => e
    end
    return false
  end

  #
  # return array files's name
  #
  def self.get_files_name_in directory
    arr = []
    begin
      Dir.entries(directory).select { |f|
        if File.file? File.join(directory, f)
          next if f == '.' or f == '..'
          arr.push f
        end
      }
    rescue Exception => e
    end
    return arr
  end

  # return all files in directory an it sub-folders
  def self.get_filesname_recursively directory
    arr = []
    Find.find(directory) do |e|
      if File.file?(e)
        arr.push(e)
      end
    end

    return arr
  end

  # get datetime for folder or file
  # return: m-d-y h:M:s
  def self.get_modified_time directory

    if File.exists?(directory)
      time = File.mtime(directory)
      return "%s-%s-%s %s:%s:%s" % [time.mon, time.day, time.year, time.hour, time.min, time.sec]
    else
      return ''
    end
  end

  # delete specific file types
  def self.delete_files_by_types path, arr_type
    begin
      allowed_types = ['.zip']
      valid_files = Dir.entries(path).select do |f|
        allowed_types.any? { |suffix| f.end_with? suffix }
      end

      if !valid_files.nil?
        valid_files.each do |fname|
          begin
            File.delete(File.join(path, fname))
          rescue Exception => e
          end
        end
      end
    rescue Exception => e
    end
  end

  # get file size
  def self.get_file_size file_path
    file_size = File.size(file_path)
    if file_size < 1024 # convert to byte
      size_mb = file_size.to_s << ' byte'
    elsif (file_size >=1024) and (file_size < 1024*1024) # convert to Kb
      size_mb = (file_size/1024).to_s << ' KB'
    elsif (file_size >= 1024*1024) and (file_size < 1024*1024*1024) # convert to Mb
      size_mb = (file_size/1024/1024).to_s << ' MB'
    elsif file_size < 1024*1024*1024*1024 # convert to Mb
      size_mb = (file_size/1024/1024/1024).to_s << ' GB'
    end
    return size_mb
  end

end

