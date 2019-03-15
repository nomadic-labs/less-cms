class CreateWebsites < ActiveRecord::Migration[5.2]
  def change
    create_table :websites do |t|
      t.string :project_name
      t.string :source_repo
      t.string :firebase_api_key
      t.string :firebase_auth_domain
      t.string :firebase_database_url
      t.string :firebase_project_id
      t.text :firebase_service_account_key

      t.timestamps
    end
  end
end
