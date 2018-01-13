class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :number
      t.text :text
      t.references :book, index: true
      t.string :tags

      t.timestamps
    end
  end
end
