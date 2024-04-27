class Document < ActiveRecord::Base
    belongs_to :user
    belongs_to :folder, optional: true
end
