class Station < ActiveRecord::Base
  self.primary_key = 'network_name'
  MACHINE_FILE = ENV['MACHINE_FILE']

  def init_server_on_db
    xml_content = Nokogiri::XML(File.read(MACHINE_FILE))
    station_name = xml_content.search('//machineSettings/stationName').text
    network_name = xml_content.search('//machineSettings/networkName').text
    ip_address = xml_content.search('//machineSettings/ip').text
    port = xml_content.search('//machineSettings/port').text.to_i

    stations = Station.where(network_name: network_name)
    if stations.size == 0
      stations = Station.new(network_name: network_name, station_name: station_name, ip: ip_address, port: port)
      Rails.logger.info "Inserted station: #{network_name} into DB successful" if stations.save
    else
      Rails.application.config.server_role = false unless stations[0].network_name == network_name && stations[0].station_name == station_name && stations[0].ip == ip_address && stations[0].port == port
    end
  end

  def self.update_machine_config(station_name, network_name, ip_address, port)
    stations = Station.where(station_name: station_name, ip: ip_address, port: port)
    unless stations.size == 0
      stations.each do |station|
        return ModelCommon.success_message 'Successfully updated' if station.network_name == network_name
      end

      return ModelCommon.error_message "The station information is duplicated with another Station: #{network_name}"
    end

    outposts = Outpost.find_by(name: station_name)
    return ModelCommon.error_message "The station name is duplicated with another Outpost: #{station_name}" if outposts

    # Update station table
    Station.where(network_name: network_name).update_all(station_name: station_name, ip: ip_address, port: port)

    # Update machine.xml
    machine_config_xml = Nokogiri::XML(File.read(MACHINE_FILE))
    machine_config_xml.search('//machineSettings/stationName')[0].inner_html = station_name
    machine_config_xml.search('//machineSettings/ip')[0].inner_html = ip_address
    machine_config_xml.search('//machineSettings/port')[0].inner_html = port
    File.open(MACHINE_FILE, 'w') { |f| f.print(machine_config_xml.to_xml) }

    # Restart schedule
    if station_name.blank?
      Rails.application.config.server_role = nil
    else
      Rails.application.config.server_role = station_name
    end

    Rails.application.start_schedules

    ModelCommon.success_message 'Successfully updated'
  rescue => e
    ModelCommon.error_message "An error occurred while updating: #{e.message}"
  end

  def self.station_list_html
    Station.all.reduce('') { |a, e| a + e.to_html }.html_safe
  end

  def self.location_list(page = 'new_run')
    stations = Station.select(:station_name, :network_name).order(:station_name)
    return stations.pluck(:network_name, :station_name) if page == 'new_run'
    stations.pluck(:station_name, :network_name)
  end

  def to_html
    <<-INTERPOLATED_HEREDOC.strip_heredoc
      <tr class=\"bout\">
        <td>#{network_name}</td>
        <td>#{station_name}</td>
        <td>#{ip}</td>
        <td>#{port}</td>
        <td style=\"width: 6%\";><a href='#{Rails.application.config.server_protocol}://#{ip}:#{port}/admin/stations' target='_blank'>Edit</a></td>
        <td style=\"width: 6%\";><a onclick=\"delete_station('#{network_name}')\">Delete</a></td>
      </tr>
    INTERPOLATED_HEREDOC
  end

  def self.station_name(network_name)
    station = Station.find_by(network_name: network_name)
    return '' if station.blank?
    station.station_name
  end

  def self.next_station(recent_station)
    station_arr = Station.select(:station_name, :network_name).order(:station_name).pluck(:network_name)
    return station_arr[0] if recent_station.blank?

    index = station_arr.find_index(recent_station)
    return station_arr[0] if index.nil? || index == station_arr.size - 1
    station_arr[index + 1]
  end

  def self.assign_station(selected_station)
    if selected_station == 'ANY'
      station = next_station $recent_station
    else
      station = selected_station
    end

    $recent_station = station
  end

  def self.delete_station(network_name)
    current_station = Rails.application.config.server_name
    return ModelCommon.error_message "Can not delete. The station is running: #{network_name}" if current_station == network_name

    station = Station.find_by(network_name: network_name)
    return ModelCommon.error_message "The station does not exist: #{network_name}" unless station

    station.destroy
    ModelCommon.success_message "Successfully deleted: #{network_name}"
  rescue => e
    ModelCommon.error_message "An error occurred while deleting: #{e.message}"
  end
end
