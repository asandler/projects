class UsersBooksManyToMany < ActiveRecord::Migration
  def change
    create_table :books_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :book, index: true
      t.string :status
    end
  end
end
