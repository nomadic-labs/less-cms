class AddEnvironmentVariablesToWebsite < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :environment_variables, :text
  end
end
