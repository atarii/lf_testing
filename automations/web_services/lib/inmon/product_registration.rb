class ProductRegistration
  @endpoint = LFSOAP::CONST_INMON_ENDPOINTS[:product_registration][:endpoint]
  @namespace = LFSOAP::CONST_INMON_ENDPOINTS[:product_registration][:namespace]

  def self.register_products(caller_id, customer_id, type, child_id, game_log_nbr)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :register_products,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <product-registration-type>#{type}</product-registration-type>
      <product-list>
        <child id='#{child_id}'/>
      </product-list>
      <product gameLogNbr='#{game_log_nbr}'/>"
    )
  end

  def self.list_registered_products(caller_id, customer_id, list_type)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :list_registered_products,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <list-type>#{list_type}</list-type>
      <process-customer>false</process-customer>
      <process-child>true</process-child>
      <game-type/>
      <registration-type/>"
    )
  end

  def self.deregister_products(caller_id, customer_id, child_id, game_log_nbr)
    LFCommon.soap_call(
      @endpoint,
      @namespace,
      :deregister_products,
      "<caller-id>#{caller_id}</caller-id>
      <username/>
      <customer-id>#{customer_id}</customer-id>
      <product-list>
        <child id='#{child_id}'/>
      </product-list>
      <product gameLogNbr='#{game_log_nbr}'/>"
    )
  end
end
