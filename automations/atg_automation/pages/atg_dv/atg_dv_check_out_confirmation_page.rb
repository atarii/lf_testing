require 'pages/atg_dv/atg_dv_common_page'

class AtgDvCheckOutConfirmationPage < AtgDvCommonPage
  element :lbl_device_order_id, '.panel-body>p>strong'
  element :lbl_device_order_complete_msg, '.dary-grey'
  element :lbl_device_sub_total, '#orderSubtotal'
  element :lbl_device_account_balance, '.orderAccountBalanceApplied .col-xs-4.col-sm-2.text-right'
  element :lbl_device_tax, '#orderTax'
  element :lbl_device_order_total, '.col-xs-4.col-sm-2.text-right .orderTotalCart'

  element :lbl_lfc_order_id, '.fontsize16>strong'
  element :lbl_lfc_order_complete_msg, '.span12>.sub'
  element :lbl_lfc_sub_total, '.orderSubTotalCart .cartRight'
  element :lbl_lfc_account_balance, '.price-type-bigger.text-success .cartRight'
  element :lbl_lfc_tax, :xpath, ".//div[contains(text(), 'Sales Tax')]/../div[@class='cartRight']"
  element :lbl_lfc_order_total, '#orderDetails .sub'

  def dv_order_confirmation_info(device_store)
    if device_store.include? 'LFC'
      order_id = lbl_lfc_order_id.text.strip
      message = lbl_lfc_order_complete_msg.text.strip
      sub_total = lbl_lfc_sub_total.text
      account_balance = has_lbl_lfc_account_balance?(TimeOut::WAIT_SMALL_CONST) ? lbl_lfc_account_balance.text.gsub('-', '– ') : ''
      tax = has_lbl_lfc_tax?(TimeOut::WAIT_SMALL_CONST) ? lbl_lfc_tax.text : ''
      order_total = lbl_lfc_order_total.text.gsub('Order Total:', '').gsub('Total :', '').strip
    else
      order_id = lbl_device_order_id.text.strip
      message = lbl_device_order_complete_msg.text.strip
      sub_total = lbl_device_sub_total.text
      account_balance = has_lbl_device_account_balance?(TimeOut::WAIT_SMALL_CONST) ? lbl_device_account_balance.text.gsub('-', '– ') : ''
      tax = has_lbl_device_tax?(TimeOut::WAIT_SMALL_CONST) ? lbl_device_tax.text : ''
      order_total = lbl_device_order_total.text
    end

    {
      order_id: order_id,
      message: message,
      order_detail: {
        sub_total: sub_total,
        account_balance: account_balance,
        tax: tax,
        order_total: order_total
      }
    }
  end
end
