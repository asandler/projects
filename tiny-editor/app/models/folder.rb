class Folder < ActiveRecord::Base
    has_many :documents, dependent: :destroy
    has_many :child_folders, class_name: "Folder", foreign_key: "parent_folder", dependent: :destroy
    belongs_to :parent_folder, class_name: "Folder", optional: true
    belongs_to :user
end
