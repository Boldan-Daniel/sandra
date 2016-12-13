FactoryGirl.define do
  factory :author do
    given_name "John"
    family_name "Doe"
  end

  factory :jarkko_laine, class: Author do
    given_name 'Jarkko'
    family_name 'Laine'
  end

  factory :topher_cyll, class: Author do
    given_name 'Topher'
    family_name 'Cyll'
  end
end
