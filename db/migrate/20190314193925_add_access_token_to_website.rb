class AddAccessTokenToWebsite < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :access_token, :string
  end
end
