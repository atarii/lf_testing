require 'pages/atg_dv/atg_dv_common_page'
require 'pages/atg_dv/atg_dv_check_out_confirmation_page'

class AtgDvCheckOutReviewPage < AtgDvCommonPage
  element :btn_device_place_order, :xpath, "(.//button[text()='Place Order' or text()='Commander'])[1]"
  element :lbl_device_sub_total, '#orderSubtotal'
  element :lbl_device_account_balance, '.orderAccountBalanceApplied .col-xs-4.col-sm-2.text-right'
  element :lbl_device_tax, '#orderTax'
  element :lbl_device_order_total, '.col-xs-4.col-sm-2.text-right .orderTotalCart'

  element :btn_lfc_place_order, '#commitOrderSubmitButton'
  element :lbl_lfc_account_balance, :xpath, "//*[@id='orderSummary']//div[@class='price-type text-success']/div[@class='cartRight']"
  element :lbl_lfc_sub_total, '.cartRight>strong'
  element :lbl_lfc_tax, :xpath, ".//div[contains(text(), 'Sales Tax')]/../div[@class='cartRight']"
  element :lbl_lfc_order_total, :xpath, ".//h2[contains(text(), 'Order Total') or contains(text(), 'Total')]"

  def play_order_displayed?(device_store)
    return has_btn_lfc_place_order?(wait: TimeOut::WAIT_BIG_CONST / 2) if device_store.include? 'LFC'
    has_btn_device_place_order?(wait: TimeOut::WAIT_BIG_CONST / 2)
  end

  def dv_place_order(device_store)
    if device_store.include? 'LFC'
      btn_lfc_place_order.click
    else
      btn_device_place_order.click
    end

    sleep TimeOut::WAIT_MID_CONST * 2
    AtgDvCheckOutConfirmationPage.new
  end

  def dv_order_review_info(device_store)
    if device_store.include? 'LFC'
      sub_total = lbl_lfc_sub_total.text
      tax = has_lbl_lfc_tax?(TimeOut::WAIT_SMALL_CONST) ? lbl_lfc_tax.text : ''
      account_balance = has_lbl_lfc_account_balance?(TimeOut::WAIT_SMALL_CONST) ? lbl_lfc_account_balance.text : ''
      order_total = lbl_lfc_order_total.text.gsub('Order Total:', '').gsub('Total :', '').strip
    else
      sub_total = lbl_device_sub_total.text
      tax = has_lbl_device_tax?(TimeOut::WAIT_SMALL_CONST) ? lbl_device_tax.text : ''
      account_balance = has_lbl_device_account_balance?(TimeOut::WAIT_SMALL_CONST) ? lbl_device_account_balance.text.gsub('-', '– ') : ''
      order_total = lbl_device_order_total.text
    end

    {
      sub_total: sub_total,
      tax: tax,
      account_balance: account_balance,
      order_total: order_total
    }
  end
end
