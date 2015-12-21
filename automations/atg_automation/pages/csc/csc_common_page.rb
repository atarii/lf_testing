require 'site_prism'

class CommonCSC < SitePrism::Page
  #
  # properties
  #
  element :customer_nav_lnk, '#navContext_customerNavItem'
  # for log out
  element :option_lnk, '#navActionContainer_optionsNavItem'
  element :logout_lnk, :xpath, "//div[@id='navActionPopup_optionsNavItem']/ul/li[1]/a"

  # for select site
  element :change_site_opt, :xpath, "//a[@id='navActionContainer_siteNavItem']/div"
  element :change_another_site_lnk, '#navActionPopup_siteNavItem a'
  elements :site_select, :xpath, "//div[@id='atg_commerce_csr_multisiteSelectSite']//tr[@class='odd' or @class='even']"
  #
  # methods
  #
  def wait_for_ajax
    sleep 1
    return if has_xpath?(".//*[@id='opaqueBackground' and contains(@style, 'none')]", visible: false, wait: TimeOut::WAIT_BIG_CONST)
  end

  #
  # go to home_customer_info_page
  #
  def goto_customer_info
    customer_nav_lnk.click
    wait_for_ajax
    HomeCustomerInforCSC.new
  end

  #
  # log out administrator
  #
  def logout_administrator
    option_lnk.click
    logout_lnk.click
    find('#logoutYes').click if has_css?('#logoutYes', wait: TimeOut::WAIT_BIG_CONST / 2)
    find('#warningsOk').click if has_css?('#warningsOk', wait: TimeOut::WAIT_BIG_CONST / 2)
    sleep TimeOut::WAIT_MID_CONST
  end

  #
  # select site (US or Canada)
  #
  def select_site(site = 'US')
    wait_for_ajax
    change_site_opt.click
    change_another_site_lnk.click
    wait_for_ajax
    site_select.each do |tr|
      within tr do
        if has_xpath?("td[contains(text(),'#{site}')]", wait: 0)
          find('td.atg_commcerce_csr_multisiteSelect a').click
          break
        end
      end
    end
    wait_for_ajax
    HomeCheckOutCSC.new
  end

  #
  # record order id
  #
  def record_order_id(email, id)
    query = "select * from atg_tracking where email = '#{email}'"
    rs = Connection.my_sql_connection query

    if (rs.num_rows == 0)
      query = "insert into atg_tracking(firstname, lastname, email, country, order_id) values ('#{Data::FIRSTNAME_CONST}', '#{Data::LASTNAME_CONST}', '#{email}', '#{Data::COUNTRY_CONST}', '#{id}')"
    else
      query = "select order_id from atg_tracking where email = '#{email}'"
      rs = Connection.my_sql_connection query
      temp = ''
      rs.each_hash do |row|
        temp = row['order_id'] + ', ' + id
        break
      end
      query = "update atg_tracking set order_id = '#{temp}' where email = '#{email}'"
    end

    Connection.my_sql_connection query
  end
end
