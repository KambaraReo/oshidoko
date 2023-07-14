class RemoveOshiFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :oshi_1, :string
    remove_column :users, :oshi_2, :string
    remove_column :users, :oshi_3, :string
  end
end
