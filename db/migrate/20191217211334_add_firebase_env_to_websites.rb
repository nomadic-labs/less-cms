class AddFirebaseEnvToWebsites < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :gatsby_env, :string
  end
end
