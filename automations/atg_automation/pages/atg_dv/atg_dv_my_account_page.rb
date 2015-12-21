require 'pages/atg_dv/atg_dv_common_page'

class AtgDvMyAccountPage < AtgDvCommonPage
  elements :lbl_device_order_numbers, '.orderNumber>a'

  def dv_order_ids
    order_id_arr = []
    lbl_device_order_numbers.each do |order|
      order_id_arr.push(order.text.strip)
    end

    order_id_arr
  end
end
