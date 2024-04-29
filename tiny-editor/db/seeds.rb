# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

$words = File.open("db/words", "r").readlines.map{|s| s.split}.flatten

def create_folder user_id, parent_folder_id, name
    Folder.create!([{
        :name => name || $words.shuffle[0..2].join(" "),
        :parent_folder_id => parent_folder_id,
        :user_id => user_id,
    }])[0]
end

def create_doc user_id, folder_id, name
    Document.create!([{
        :name => name || $words.shuffle[0..2].join(" "),
        :data => 15.times.map{ $words.shuffle[0..15].join(" ") }.join("\n"),
        :user_id => user_id,
        :folder_id => folder_id,
    }])[0]
end

def init_user username
    u = User.create!([
        {
            :email => username,
            :password => "123123",
        },
    ])[0]

    root_dir = Folder.create!([{
        :name => "Root folder",
        :user_id => u.id,
    }])[0]

    u.root_directory_id = root_dir.id
    u.save!(validate: false)

    5.times do |i|
        c = create_folder(u.id, root_dir.id, "Child dir ##{i}")
        create_doc(u.id, c.id, nil)
        create_doc(u.id, c.id, nil)
    end

    create_doc(u.id, root_dir.id, "Root doc 1")
    create_doc(u.id, root_dir.id, "Root doc 2")
end

init_user("user_1")
init_user("user_2")
