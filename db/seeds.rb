doe = Author.create!(given_name: 'John', family_name: 'Doe')
laine = Author.create!(given_name: 'Jarkko', family_name: 'Laine')
cyll = Author.create!(given_name: 'Topher', family_name: 'Cyll')
packtpub = Publisher.create!(name: 'Packtpub')

Book.create!(title: 'Ruby on Rails Tutorial',
             subtitle: 'Agile Web Development with Ruby on Rails 5',
             isbn_10: '1235548799',
             isbn_13: '9875439654415',
             description: 'Learn Rails 5 basic',
             released_on: '2016-08-01',
             publisher: packtpub,
             author: doe)

Book.create!(title: 'Practical Ruby Projects',
             subtitle: 'Ideas for the Eclectic Programmer',
             isbn_10: '5564126688',
             isbn_13: '9776887654415',
             description: 'Learn advanced programming techniques',
             released_on: '2008-10-15',
             publisher: nil,
             author: cyll)

Book.create!(title: 'Beginning Ruby on Rails E-Commerce',
             subtitle: 'Online shops using Ruby on Rails',
             isbn_10: '5774367891',
             isbn_13: '9654378654761',
             description: 'Develop next-generation online shops using Ruby on Rails',
             released_on: '2008-10-15',
             publisher: packtpub,
             author: laine)