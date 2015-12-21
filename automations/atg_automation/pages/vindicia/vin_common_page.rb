require 'site_prism'

class CommonVIN < SitePrism::Page
  #
  # PROPERTIES
  #
  element :search_transactions_lnk, :xpath, "//*[@id='topnav']//a[text()='Transactions']"
  element :search_lnk, :xpath, "//*[@id='topnav']//*[text()='Search']"

  # for health check
  element :contact_us_link, :xpath, ".//*[@id='searchBar']/a[1]"
  element :log_out_link, :xpath, ".//*[@id='searchBar']/a[2]"

  #
  # METHODS
  #
  def go_to_search_transactions_page
    search_lnk.click
    search_transactions_lnk.click
    SearchTransactionsVIN.new
  end
end
