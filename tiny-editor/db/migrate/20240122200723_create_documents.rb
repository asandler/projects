class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.text   :data

      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :folder, index: true, foreign_key: true
      t.timestamps
    end
  end
end
