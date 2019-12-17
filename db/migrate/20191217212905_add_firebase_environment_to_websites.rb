class AddFirebaseEnvironmentToWebsites < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :firebase_env, :string
  end
end
