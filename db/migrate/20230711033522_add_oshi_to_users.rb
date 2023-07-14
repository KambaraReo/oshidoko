class AddOshiToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :oshi_1, :string
    add_column :users, :oshi_2, :string
    add_column :users, :oshi_3, :string
  end
end
