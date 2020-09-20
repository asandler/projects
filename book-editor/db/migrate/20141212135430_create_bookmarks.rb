class CreateBookmarks < ActiveRecord::Migration[4.2]
  def change
    create_table :bookmarks do |t|
      t.references :user
      t.references :book
      t.integer :page
      t.integer :par
      t.integer :pos
      t.integer :forward

      t.timestamps
    end
    add_index :bookmarks, [:user_id, :book_id]
  end
end
