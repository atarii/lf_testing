class SearchTransactionsVIN < CommonVIN
  #
  # PROPERTIES
  #
  element :merchant_transaction_id_input, :xpath, "//*[@id='tx_search_form']//input[@name='search_merchant_tx_identifier']"
  element :submit_btn, :xpath, "//*[@id='tx_search_form']//*[@name='submit']"
  #
  # METHODS
  #

  def search_transaction(merchant_transaction_id = nil)
    merchant_transaction_id_input.set merchant_transaction_id unless merchant_transaction_id.nil?
    submit_btn.click

    TransactionDetailVIN.new
  end
end
