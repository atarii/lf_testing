module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = t('title')
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  class JSONWithIndifferentAccess
    def self.load(str)
      self.indifferent_access JSON.load(str)
    end

    def self.dump(obj)
      JSON.dump obj
    end

    private

      def self.indifferent_access(obj)
        if obj.is_a? Array
          obj.map!{|o| self.indifferent_access(o)}
        elsif obj.is_a? Hash
          obj.with_indifferent_access
        else
          obj
        end
      end
  end
end
