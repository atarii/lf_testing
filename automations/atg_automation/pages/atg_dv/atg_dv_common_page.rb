require 'capybara'
require 'site_prism'

class AtgDvCommonPage < SitePrism::Page
  # Device elements
  element :btn_device_menu, :xpath, ".//div[contains(text(),'Menu')]/.."
  element :lnk_device_my_account, :xpath, ".//a[text()='My Account' or text()='Mon compte']"
  element :lnk_device_cart, '.icon-nav.icon-cart'
  element :lnk_device_shop_all_apps, :xpath, ".//a[text()='Shop All Apps' or text()='Voir toutes les apps']"
  element :btn_device_continue_login, :xpath, ".//button[text()='Continue' or text()='Connexion']"
  element :txt_device_login_password, '#atg_loginPassword'

  # LFC elements
  element :lnk_lfc_my_account, '#headerLogin'
  element :lnk_lfc_cart, '.nav-account__mini-cart-softgoods-link'
  element :btn_lfc_shop_now, :xpath, ".//a[text()='Shop Now' or text()='Voir le magasin']"

  def dv_go_to_my_account(device_store, password = '')
    if device_store.include? 'LFC'
      lnk_lfc_my_account.click
    else
      btn_device_menu.click
      lnk_device_my_account.click

      if has_txt_device_login_password?(TimeOut::WAIT_MID_CONST)
        txt_device_login_password.set password
        btn_device_continue_login.click
      end
    end

    sleep TimeOut::WAIT_MID_CONST
  end

  def dv_go_to_shop_all_apps(device_store)
    if device_store.include? 'LFC'
      lnk_lfc_cart.click
      btn_lfc_shop_now.click
    else
      btn_device_menu.click
      lnk_device_shop_all_apps.click
    end

    sleep TimeOut::WAIT_MID_CONST
  end

  def dv_go_to_check_out_page(device_store)
    if device_store.include? 'LFC'
      lnk_lfc_cart.click
    else
      lnk_device_cart.click
    end

    AtgDvCheckOutPage.new
  end
end
