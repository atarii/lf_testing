class SearchController < ApplicationController
  def index
    @search_string = params[:q].to_s.strip
    return if @search_string.blank?
    @rs = search_result @search_string
  end

  def search_result(search_string)
    start_loop = Time.now.to_f
    condition = q_string_to_hash search_string

    if condition.blank?
      runs = Run.where('data like ? COLLATE utf8_general_ci', "%#{search_string}%").order(updated_at: :desc)
    else
      filter = []
      template = []
      args = []

      condition.each do |key, value|
        template << '(json_extract(data, ?)) = ? COLLATE utf8_general_ci'
        args << "$.#{key}" << "\"#{value}\""
      end

      filter << template.join(' and ')
      filter += args

      runs = Run.where(filter).order(id: :desc)
    end

    end_loop = Time.now.to_f
    duration = (end_loop - start_loop).round(2)

    { runs: runs, duration: duration }
  end

  def q_string_to_hash(q_string)
    return if q_string.blank?

    conditions = q_string.split(',')
    return if conditions.blank?

    q = {}
    conditions.each do |c|
      k_v = c.split(':')
      next if k_v.blank? || k_v.count < 2

      q["#{k_v[0].strip}"] = k_v[1].strip
    end

    q
  end
end
