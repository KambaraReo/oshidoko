class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :address, null: false
      t.float :latitude
      t.float :longitude
      t.string :description

      t.timestamps
    end
  end
end
