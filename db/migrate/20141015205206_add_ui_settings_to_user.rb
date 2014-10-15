class AddUiSettingsToUser < ActiveRecord::Migration
  def up
    enable_extension :hstore
    add_column :users, :ui_settings, :hstore
  end

  def down
    remove_column :users, :ui_settings
    disable_extension :hstore
  end
end
