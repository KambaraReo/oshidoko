class CreatePostsMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :posts_members do |t|
      t.integer :post_id, null: false, foreign_key: true
      t.integer :member_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
