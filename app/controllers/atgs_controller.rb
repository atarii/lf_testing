class AtgsController < ApplicationController

  # this process configuration database that used in atg test scripts
  # get default data in data.xml file
  def atgconfig
    # Set default value
    @empty_acc = @credit_acc = @balance_acc = @credit_balance_acc = @p_us_acc = @p_ca_acc = @p_uk_acc = @p_ie_acc = @p_au_acc = @p_row_acc = []
    @prod_id = @ce_sku = @ce_catalog_title = @ce_product_type = @ce_price = @ce_strike = @ce_sale = @ce_pdp_title = @ce_cart_title = @ce_pdp_type = @vin_username = @vin_password = ''

    # Get info from 'atg_configuration' table
    atg_data = AtgConfiguration.get_atg_data

    unless atg_data.blank?
      # Load App Center account info
      @empty_acc = atg_data[:ac_account][:empty_acc]
      @credit_acc = atg_data[:ac_account][:credit_acc]
      @balance_acc = atg_data[:ac_account][:balance_acc]
      @credit_balance_acc = atg_data[:ac_account][:credit_balance_acc]

      # Load PayPal account info
      @p_us_acc = atg_data[:paypal_account][:p_us_acc]
      @p_ca_acc = atg_data[:paypal_account][:p_ca_acc]
      @p_uk_acc = atg_data[:paypal_account][:p_uk_acc]
      @p_ie_acc = atg_data[:paypal_account][:p_ie_acc]
      @p_au_acc = atg_data[:paypal_account][:p_au_acc]
      @p_row_acc = atg_data[:paypal_account][:p_row_acc]

      # Load Catalog Entry info
      @prod_id = atg_data[:catalog_entry][:prod_id]
      @ce_sku = atg_data[:catalog_entry][:ce_sku]
      @ce_catalog_title = atg_data[:catalog_entry][:ce_catalog_title]
      @ce_product_type = atg_data[:catalog_entry][:ce_product_type]
      @ce_price = atg_data[:catalog_entry][:ce_price]
      @ce_strike = atg_data[:catalog_entry][:ce_strike]
      @ce_sale = atg_data[:catalog_entry][:ce_sale]
      @ce_pdp_title = atg_data[:catalog_entry][:ce_pdp_title]
      @ce_cart_title = atg_data[:catalog_entry][:ce_cart_title]
      @ce_pdp_type = atg_data[:catalog_entry][:ce_pdp_type]

      # Load Vindicia Account info
      @vin_username = atg_data[:vin_acc][:vin_username]
      @vin_password = atg_data[:vin_acc][:vin_password]
    end
  end

  def config_atg_data
    ac_account = {
      empty_acc: [params[:empty_email], params[:empty_pass]],
      credit_acc: [params[:credit_email], params[:credit_pass]],
      balance_acc: [params[:balance_email], params[:balance_pass]],
      credit_balance_acc: [params[:credit_balance_email], params[:credit_balance_pass]]
    }

    paypal_account = {
      p_us_acc: [params[:p_email_us], params[:p_password_us]],
      p_ca_acc: [params[:p_email_ca], params[:p_password_ca]],
      p_uk_acc: [params[:p_email_uk], params[:p_password_uk]],
      p_ie_acc: [params[:p_email_ie], params[:p_password_ie]],
      p_au_acc: [params[:p_email_au], params[:p_password_au]],
      p_row_acc: [params[:p_email_row], params[:p_password_row]]
    }

    catalog_entry = {
      prod_id: params[:prod_id],
      ce_sku: params[:ce_sku],
      ce_catalog_title: params[:ce_catalog_title],
      ce_product_type: params[:ce_product_type],
      ce_price: params[:ce_price],
      ce_strike: params[:ce_strike],
      ce_sale: params[:ce_sale],
      ce_pdp_title: params[:ce_pdp_title],
      ce_cart_title: params[:ce_cart_title],
      ce_pdp_type: params[:ce_pdp_type]
    }

    vin_acc = {
      vin_username: params[:vin_username],
      vin_password: params[:vin_password]
    }

    atg_data = {
      ac_account: ac_account,
      paypal_account: paypal_account,
      catalog_entry: catalog_entry,
      vin_acc: vin_acc
    }.to_json

    # update input to xml file
    msg = AtgConfiguration.update_atg_data atg_data

    if msg == true
      flash[:success] = 'Your ATG data is updated successfully!'
    else
      flash[:error] = msg
    end

    redirect_to action: 'atgconfig'
  end

  # get data and process then return to view using ajax
  def atg_tracking_data
    env = params[:env].downcase # uat or uat2
    loc = params[:loc].downcase # US or CA

    if env.blank? || loc.blank?
      render plain: ['']
    else
      render plain: AtgTracking.where("email like '%atg_#{env}_#{locale}%'").order(updated_at: :desc).pluck(:email, :address1)
    end
  end

  def show
    @atg = Atg.find(params[:id])
  end

  # create new test suite from dialog ajax call
  def create_ts
    tsname = params[:tsname] # Smoke test account management
    tcs = params[:tcs].chomp(',').split(',') # 'value1,value2,..,' => array
    parent_suite_id = params[:tsId]

    connection = ActiveRecord::Base.connection
    inserts = []
    ts_id = -1

    ActiveRecord::Base.transaction do
      # get silo id
      silo = Silo.find_by name: 'ATG'

      # get maximum order
      max_order_suite = Suite.maximum(:order) + 1
      max_order_suitecsm = CaseSuiteMap.maximum(:order) + 1

      # insert into suites
      suite = Suite.create(name: tsname, silo_id: silo.id, description: '', order: max_order_suite)
      suite.create_activity key: 'suite.create', owner: User.current_user
      ts_id = suite.id

      # insert into suite_maps
      SuiteMap.create(parent_suite_id: parent_suite_id, child_suite_id: ts_id)

      # insert into case_suite_maps
      tcs.each do |tc_id|
        inserts.push "(#{suite.id}, #{tc_id}, #{max_order_suitecsm})"
        max_order_suitecsm += 1
      end

      sql = "INSERT INTO case_suite_maps (`suite_id`, `case_id`, `order`) VALUES #{inserts.join(', ')}"
      connection.execute sql
    end

    render plain: [ts_id]
  end

  #
  # Load default info on Code Upload page: Code type, message
  #
  def upload_code
    @type = Atg.load_code_type
    @message = ''
  end

  #
  # Upload .xls/.xlsx code file to data folder
  #
  def process_upload_code
    pin_file = params[:code_file]
    env = params[:env]
    code_type = params[:file_name]

    if code_type.include?('Select a code type')
      @message = "<p class='alert alert-error'>Please select Code type.</p>"
    elsif pin_file.blank?
      @message = "<p class='alert alert-error'>Please select Code file.</p>"
    else
      # Upload file to public/upload folder
      path = Rails.root.join('public', 'upload')
      FileUtilsC.delete_files(path)
      pin_file_name = ModelCommon.upload_file(path, pin_file)

      if pin_file_name
        @message = Pin.upload_pin_file File.join(path, pin_file_name), env, code_type
      else
        @message = "<p class = 'alert alert-success'>Error while uploading Code file. Please try again!</p>"
      end
    end

    @type = Atg.load_code_type
    render 'upload_code'
  end

  def first_parent_level_tss
    render plain: Atg.new.get_test_suites(true)
  end

  def parent_suite_id
    render plain: Atg.new.get_test_suite_parent(params[:ts_id])
  end

  def load_release_date
    language = params[:language]
    html_str = ''

    release_opts = Atg.release_date(language)
    release_opts.each do |key, value|
      html_str += <<-INTERPOLATED_HEREDOC.html_safe
        <li><label>
          <input type="checkbox" value="#{key}">
          <span>#{key} - Total: #{value.to_s} app#{'s' if value.to_i > 1}</span>
        </label></li>
      INTERPOLATED_HEREDOC
    end

    render plain: html_str
  end

  private

  def atg_params
    params.permit(:env, :user_email, :testsuite, :release_date)
  end
end
