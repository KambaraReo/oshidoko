class CreateUsersMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :users_members do |t|
      t.integer :user_id, null: false, foreign_key: true
      t.integer :member_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
