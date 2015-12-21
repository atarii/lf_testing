class AtgContentPlatformChecker
  # 1. Get package info from MOAS file
  # 2. Get data from csv file
  # 3. Compare package platforms between csv and MOAS files
  def validate_content_platform(content_csv_file, language)
    # 1. Get package info from MOAS file
    if language.downcase == 'english'
      moas_titles = AtgMoas.select(:sku, :shortname, :platformcompatibility)
    else
      moas_titles = AtgMoasFr.select(:sku, :shortname, :platformcompatibility)
    end

    return error_message('The MOAS data is empty. Please import MOAS data into Database.') if moas_titles.blank?

    moas_titles_arr = []
    moas_titles.to_a.each do |a|
      platform_arr = []
      platforms = a[:platformcompatibility].gsub(',', ';').split(';')
      platforms.each do |p|
        platform_arr.push map_platform(p)
      end
      moas_titles_arr.push(sku: a[:sku], title: a[:shortname], platforms: platform_arr)
    end

    # 2. Get data from csv file
    spreadsheet = ModelCommon.open_spreadsheet(content_csv_file)
    return error_message('Error while opening the Content Package CSV file.') if spreadsheet.nil?

    headers = ModelCommon.downcase_array_key spreadsheet.row(1)
    return error_message(
      <<-INTERPOLATED_HEREDOC.strip_heredoc
        Make sure that: <br/>
          1. The Content Package data in the first sheet <br/>
          2. The 'Sku', 'Package Id', 'Platforms' headers in the first row. <br/>
          Headers got: #{headers}
    INTERPOLATED_HEREDOC
    ) unless (['sku', 'package id', 'platforms'] - headers).empty?

    csv_packages = []
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[headers, spreadsheet.row(i)].transpose]
      row['platforms'] = 'AND1;' + row['platforms'] if row['package id'].to_s.include? '.apk'
      csv_packages.push(sku: row['sku'], platforms: row['platforms']) unless row['sku'].nil? || row['platforms'].nil?
    end

    return error_message 'Content Package CSV file is empty. Please re-check!' if csv_packages.blank?

    csv_platform_arr = get_csv_platform csv_packages
    return csv_platform_arr unless csv_platform_arr.is_a?(Array)

    # 3. Compare package platforms between csv and MOAS files
    results = compare_platforms(csv_platform_arr, moas_titles_arr)

    tr = ''
    results.each do |r|
      tr += <<-INTERPOLATED_HEREDOC.strip_heredoc
        <tr>
          <td>#{r[:sku]}</td>
          <td>#{r[:title]}</td>
          <td>#{r[:moas_platform]}</td>
          <td>#{r[:csv_platform]}</td>
          <td class="#{r[:class_name]}">#{r[:status]}</td>
        </tr>
      INTERPOLATED_HEREDOC
    end

    <<-INTERPOLATED_HEREDOC.strip_heredoc
      <table class="table">
        <tbody>
          <tr>
            <th>SKU</th>
            <th>MOAS Title</th>
            <th>MOAS Platforms</th>
            <th>CSV Platforms</th>
            <th>Results</th>
          </tr>
          #{tr}
        </tbody>
      </table>
    INTERPOLATED_HEREDOC
  end

  def get_csv_platform(csv_packages)
    sku_arr = []
    csv_packages.map { |x| sku_arr.push x[:sku] }
    sku_arr.uniq!

    platform_arr = []
    sku_arr.each do |sku|
      platform = ''
      csv_packages.each do |p|
        platform << ';' << p[:platforms] if p[:sku] == sku
      end
      platform_arr.push(sku: sku, platforms: platform.gsub(',', ';').split(';').delete_if(&:empty?).uniq)
    end

    platform_arr
  rescue => e
    error_message 'Error while getting CSV platforms: ' + e.message
  end

  def map_platform(platform)
    case platform
    when /LeapPad1/
      'LPAD'
    when /LeapPad2/
      'PAD2'
    when /LeapPad3/
      'PAD3'
    when /LeapPad Ultra/
      'PHR1'
    when /LeapPad Platinum/
      'PHR2'
    when /Leapster Explorer/
      'LST3'
    when /LeapsterGS Explorer/
      'GAM2'
    when /LeapReader/
      'LPRD'
    when /LeapTV/
      'THD1'
    when /Epic/
      'AND1'
    else
      platform
    end
  end

  def compare_platforms(csv_platform_arr, moas_titles_arr)
    result = []
    csv_platform_arr.each do |c|
      m = moas_titles_arr.find { |x| x[:sku] == c[:sku] }
      if m.nil?
        csv_platform = c[:platforms].sort
        result.push(sku: c[:sku], title: '', moas_platform: '', csv_platform: csv_platform.join(';'), status: 'N/A', class_name: 'text-muted')
      else
        moas_platform = m[:platforms].sort.join(';')
        csv_platform = c[:platforms].sort.join(';')

        if moas_platform == csv_platform
          status = 'Passed'
          class_name = 'pass'
        else
          status = 'Failed'
          class_name = 'failed'
        end

        result.push(sku: c[:sku], title: m[:title], moas_platform: moas_platform, csv_platform: csv_platform, status: status, class_name: class_name)
      end
    end

    result
  end

  def error_message(message)
    <<-INTERPOLATED_HEREDOC.strip_heredoc
      <div class='col-xs-offset-3'>
        <p class = "small-alert alert-error">
          #{message}
        </p>
      </div>
    INTERPOLATED_HEREDOC
  end
end
