require 'date'

class Version
  def self.tc_git_version
    time = DateTime.parse(`git log -1 --format=%ci`)
    short_hash = `git log -1 --format=%h`
    "#{time.year}.#{time.month}.#{time.day}-#{time.hour}.#{time.minute}.#{time.second}_#{short_hash}"
  rescue => error
    "Error: #{error.class.name}"
  end
end
