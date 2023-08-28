class ChangeColumnsNotnullAddComments < ActiveRecord::Migration[6.1]
  def change
    change_column :comments, :comment, :string, null: false
  end
end
