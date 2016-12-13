FactoryGirl.define do
  factory :author do
    given_name "John"
    family_name "Doe"
  end

  factory :dave_thomas, class: Author do
    given_name 'Dave'
    family_name 'Thomas'
  end

  factory :michael_hartl, class: Author do
    given_name 'Michael'
    family_name 'Hartl'
  end
end
