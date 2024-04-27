class CreateFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :folders do |t|
      t.references :parent_folder, foreign_key: { to_table: :folders }
      t.string :name

      t.timestamps

      t.references :user
    end
  end
end
