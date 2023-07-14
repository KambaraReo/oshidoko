class AddIsGraduatedToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :is_graduated, :boolean, null: false
  end
end
