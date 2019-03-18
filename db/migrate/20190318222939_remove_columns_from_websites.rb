class RemoveColumnsFromWebsites < ActiveRecord::Migration[5.2]
  def change
    remove_column :websites, :access_token
    remove_column :websites, :firebase_api_key
    remove_column :websites, :firebase_auth_domain
    remove_column :websites, :firebase_database_url
    remove_column :websites, :firebase_service_account_key
  end
end
