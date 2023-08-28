class ChangeDatatypeRateOfComments < ActiveRecord::Migration[6.1]
  def change
    change_column :comments, :rate, :integer
  end
end
