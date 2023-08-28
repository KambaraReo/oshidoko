class AddUniqueIndexToComments < ActiveRecord::Migration[6.1]
  def change
    add_index :comments, [:user_id, :post_id], unique: true
  end
end
