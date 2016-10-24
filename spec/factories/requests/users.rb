require 'factory_girl' 

FactoryGirl.define do
  factory :user, class: "User" do
    sequence(:username) { |n| "username#{srand}" }
    sequence(:email) { |n| "email-#{srand}@princeton.edu" }
    password 'foobarfoo'
    uid do |user|
      user.username
    end

    factory :valid_princeton_patron do
      provider 'cas'
    end


    # for patrons without a net ID
    factory :valid_access_patron do
      provider 'voyager'
    end

    factory :unauthenticated_patron do
      guest true
    end
  end
end
