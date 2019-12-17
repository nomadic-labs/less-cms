class AddStagingFirebaseConfigToWebsite < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :firebase_config_staging, :json
  end
end
