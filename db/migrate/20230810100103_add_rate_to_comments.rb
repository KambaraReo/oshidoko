class AddRateToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :rate, :float
  end
end
