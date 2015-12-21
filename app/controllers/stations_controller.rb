class StationsController < ApplicationController
  def index
    xml_content = Nokogiri::XML(File.read(ENV['MACHINE_FILE']))
    @station_name = xml_content.search('//machineSettings/stationName').text
    @network_name = xml_content.search('//machineSettings/networkName').text
    @ip_address = xml_content.search('//machineSettings/ip').text
    @port = xml_content.search('//machineSettings/port').text.to_i
    @station_list_html = Station.station_list_html
  end

  def update_machine_config
    msg = Station.update_machine_config params['station_name'], params['network_name'], params['ip_address'], params['port']
    render html: msg.html_safe
  end

  def delete_station
    msg = Station.delete_station params['network_name']
    render html: msg.html_safe
  end

  def station_list
    render html: Station.station_list_html
  end
end
