class ChangeCloumnsNotnullAddMembers < ActiveRecord::Migration[6.1]
  def change
    change_column :members, :name, :string, null: false
    change_column :members, :generation, :integer, null: false
  end
end
