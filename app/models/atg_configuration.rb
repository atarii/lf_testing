class AtgConfiguration < ActiveRecord::Base
  include PublicActivity::Common
  cattr_accessor :current_user

  def self.get_atg_data
    atg_data = AtgConfiguration.order(updated_at: :desc).select(:data).first

    return {} if atg_data.nil?

    JSON.parse(atg_data['data'], symbolize_names: true)
  end

  def self.update_atg_data(data)
    AtgConfiguration.new.transaction do
      begin
        atg_config = AtgConfiguration.create!(data: data)
        atg_config.create_activity key: 'update.atg_configuration', owner: User.current_user
      rescue => e
        ActiveRecord::Rollback
        return "Error while uploading ATG data: <br>#{e}</p>"
      end
    end

    true
  end
end
