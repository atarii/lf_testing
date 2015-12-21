require 'pages/atg_dv/atg_dv_common_page'
require 'pages/atg_dv/atg_dv_check_out_page'
require 'pages/atg/atg_app_center_page'

class AtgDvAppCenterPage < AtgDvCommonPage
  element :catalog_div_css, '.container.no-pad.ng-scope'
  elements :product_div_css, '.container.no-pad.ng-scope>.row.row-results .col-xs-12.col-sm-4>div'

  def load
    visit url
    visit url unless has_catalog_div_css?(wait: TimeOut::WAIT_CONTROL_CONST)
    TestDriverManager.session_id
  end

  def dv_get_random_product_info(device_store)
    return AppCenterCatalogATG.new.sg_get_random_product_info if device_store.include? 'LFC'

    return {} if product_div_css.size < 1

    product_id = product_div_css.at(0)['id']
    product_html = Nokogiri::HTML(page.evaluate_script("$('.container.no-pad.ng-scope>.row.row-results').parent().html();").to_s)
    product_el = product_html.css(".col-xs-12.col-sm-4>##{product_id.downcase}")

    return {} if product_el.empty?

    title = product_el.css('.col-xs-12>h2').text.delete("\n")
    sku = product_el.css('div>@data-ga-prod-childskus').to_s
    strike = product_el.css('.price.strike').text.delete("\n")
    sale = product_el.css('.price.sale').text.delete("\n")
    price = strike.blank? ? product_el.css('.price').text.delete("\n") : ''

    {
      id: product_id,
      sku: sku,
      title: title,
      price: price,
      strike: strike,
      sale: sale
    }
  end

  def dv_add_to_cart_from_catalog(product_id, device_store)
    if device_store.include? 'LFC'
      page.execute_script("$('##{product_id} .btn.btn-add-to-cart.btn-block.ng-isolate-scope').click();")
    else
      page.execute_script("$('##{product_id} .btn.btn-block.btn-primary.ng-isolate-scope').click();")
    end

    sleep TimeOut::WAIT_MID_CONST
  end
end
