# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

root_dir = Folder.create!([{
    :name => "Root folder",
}])[0]

user = User.create!([
    {
        :email => "test",
        :password => "123123",
        :root_directory_id => root_dir.id,
    },
])[0]

5.times do |i|
    c = Folder.create!([{
        :name => "Child dir ##{i}",
        :parent_folder_id => root_dir.id,
    }])[0]

    Document.create!([
        {
            :name => "Doc inside 1",
            :data => "Lorem ipsum",
            :folder_id => c.id,
            :user_id => user.id,
        },
        {
            :name => "Doc inside 2",
            :data => "Timeo danaos et donna ferentes",
            :folder_id => c.id,
            :user_id => user.id,
        },
    ])
end

Document.create!([
    {
        :name => "Root doc 1",
        :data => "Lorem Ipsum - это текст-\"рыба\", часто используемый в печати и вэб-дизайне. Lorem Ipsum является стандартной \"рыбой\" для текстов на латинице с начала XVI века. В то время некий безымянный печатник создал большую коллекцию размеров и форм шрифтов, используя Lorem Ipsum для распечатки образцов. Lorem Ipsum не только успешно пережил без заметных изменений пять веков, но и перешагнул в электронный дизайн. Его популяризации в новое время послужили публикация листов Letraset с образцами Lorem Ipsum в 60-х годах и, в более недавнее время, программы электронной вёрстки типа Aldus PageMaker, в шаблонах которых используется Lorem Ipsum.",
        :folder_id => root_dir.id,
        :user_id => user.id,
    },
    {
        :name => "Root doc 2",
        :data => "Давно выяснено, что при оценке дизайна и композиции читаемый текст мешает сосредоточиться. Lorem Ipsum используют потому, что тот обеспечивает более или менее стандартное заполнение шаблона, а также реальное распределение букв и пробелов в абзацах, которое не получается при простой дубликации \"Здесь ваш текст.. Здесь ваш текст.. Здесь ваш текст..\" Многие программы электронной вёрстки и редакторы HTML используют Lorem Ipsum в качестве текста по умолчанию, так что поиск по ключевым словам \"lorem ipsum\" сразу показывает, как много веб-страниц всё ещё дожидаются своего настоящего рождения. За прошедшие годы текст Lorem Ipsum получил много версий. Некоторые версии появились по ошибке, некоторые - намеренно (например, юмористические варианты).",
        :folder_id => root_dir.id,
        :user_id => user.id,
    },
])
