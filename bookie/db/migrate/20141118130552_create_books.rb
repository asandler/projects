class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :description
      t.integer :depth
      t.string :contents

      t.timestamps
    end
  end
end
