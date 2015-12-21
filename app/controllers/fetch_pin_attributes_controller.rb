class FetchPinAttributesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    flash.clear
  end

  def get_pins_status
    response_text = ''
    env = params[:pin_env]
    pins = params[:lf_pin]
    pin_management = PINManagement.new env

    return response_text if pins.to_s.length <= 0

    arr_pin = pins.delete("\r").split("\n")

    return response_text if arr_pin.count < 0

    arr_pin.each do |pin|
      pin_san = pin.to_s.strip.delete('-')
      next if pin_san.blank?
      status = pin_management.get_pin_status pin_san
      response_text << "<p>#{pin} = <span class=\"#{status.to_s.downcase}\">#{status}</span></p>"
    end

    render plain: response_text
  end
end
