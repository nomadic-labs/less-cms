class AddCustomDeployCommandToWebsite < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :custom_deploy_command, :string
  end
end
