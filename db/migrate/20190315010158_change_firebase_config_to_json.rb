class ChangeFirebaseConfigToJson < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :firebase_config, :json
  end
end
