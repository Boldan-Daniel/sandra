FactoryGirl.define do
  factory :access_token do
    token_digest nil
    accessed_at '2017-02-11 18:34:58'
    user
    api_key
  end
end
