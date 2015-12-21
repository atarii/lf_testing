class PinsController < ApplicationController
  def redeem_pin
    unless params[:commit]
      flash.clear
      return
    end

    env = params[:env]
    type = params[:type_pin]
    customer_management = CustomerManagement.new(env)
    pin_management = PINManagement.new(env)

    # LOOKUP_CUSTOMER_BY_USERNAME:
    customer_id = customer_management.get_customer_id(params[:email])
    if customer_id[0] == 'error' || customer_id.blank?
      flash.clear
      flash.now[:error] = 'The email address is incorrect. Please try again.'
      render 'redeem_pin'
      return
    end

    # FETCH_CUSTOMER: display customer information after redemption
    doc = customer_management.fetch_customer(customer_id)
    customer = Hash.from_xml(doc.at_xpath('//customer').to_s)
    @customerid = customer['customer']['id']
    @email = customer['customer']['email']
    @cust_type = customer['customer']['type']
    @lf_alias = customer['customer']['first_name'] + ' ' + customer['customer']['last_name']
    @locale = customer['customer']['locale']

    # REDEEM PINS
    @pin_arr = []
    status = nil
    pin_input_arr = params[:lf_pin].strip.split("\n").reject(&:empty?)
    pin_input_arr.each do |p|
      params_info = { env: params[:env], type_pin: params[:type_pin], pin: p, email: params[:email], locale: params[:locale] }
      rd = PublicActivity::Activity.new(key: 'pin.redeem', owner: User.current_user, parameters: params_info)
      rd.save

      pin = p.gsub(/-|\r/, '')
      # fetch pin attributes to PIN locale + status
      pin_info = pin_management.get_pin_information pin

      # If has_error
      if pin_info[:has_error] == 'error'
        @pin_arr.push(pin: p, status: pin_info[:message])
        next
      end

      # Get PIN locale
      locale = pin_info[:locale]

      # If PIN locale does not match with selected locale
      unless locale.split(';').include?(params[:locale])
        @pin_arr.push(pin: p, status: "Invalid locale: (#{locale})")
        next
      end
      locale = params[:locale]

      # If PIN is not available
      unless pin_info[:status] == 'AVAILABLE'
        @pin_arr.push(pin: p, status: pin_info[:status])
        next
      end

      amount = pin_info[:amount] + ' ' + pin_info[:currency]
      pin_type = pin_info[:type]

      case type
      when 'redeemGiftPackages'
        status = pin_management.redeem_gift_packages(customer_id, pin, locale)
      when 'redeemGiftValue'
        status = pin_management.redeem_gift_value(customer_id, pin, locale)
      when 'redeemValueCard'
        status = pin_management.redeem_value_card(customer_id, pin, locale)
      end

      # Check PIN redemption's status and push into array
      if status[0] == 'error'
        @pin_arr.push(pin: p, status: status[1])
      else
        @pin_arr.push(pin: p, status: "Success - #{amount} - #{pin_type}")
      end
    end

    flash.clear
    render 'show'
  rescue => e
    flash.now[:error] = "Error: #{e.message}"
    render 'redeem_pin'
  end
end
