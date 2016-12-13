FactoryGirl.define do
  factory :book, aliases: [:agile_rails] do
    title 'Ruby on Rails Tutorial'
    subtitle 'Agile Web Development with Ruby on Rails 5'
    isbn_10 '1235548799'
    isbn_13 '9875439654415'
    description 'Learn Rails 5 basic'
    released_on '2016-08-01'
    publisher
    author
  end

  factory :practical_ruby, class: Book do
    title 'Practical Ruby Projects'
    subtitle 'Ideas for the Eclectic Programmer'
    isbn_10 '5564126688'
    isbn_13 '9776887654415'
    description 'Learn advanced programming techniques'
    released_on '2008-10-15'
    publisher_id  nil
    association :author, factory: :topher_cyll
  end

  factory :eccomerce_rails, class: Book do
    title 'Beginning Ruby on Rails E-Commerce'
    subtitle 'Online shops using Ruby on Rails'
    isbn_10 '5774367891'
    isbn_13 '9654378654761'
    description 'Develop next-generation online shops using Ruby on Rails'
    released_on '2008-10-15'
    publisher
    association :author, factory: :jarkko_laine
  end
end
