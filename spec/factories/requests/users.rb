require 'factory_girl' 

FactoryGirl.define do
  factory :user, class: "User" do
    sequence(:username) { |n| "username#{srand}" }
    sequence(:email) { |n| "email-#{srand}@princeton.edu" }
    provider 'cas'
    password 'foobarfoo'
    uid do |user|
      user.username
    end

    # factory :valid_princeton_patron do
    #   provider 'cas'
    # end

    factory :valid_barcode_patron do
      provider 'barcode'
      sequence(:uid) { srand.to_s[2..15] }
      username 'Student'
    end

    factory :unauthenticated_patron do
      guest true
    end
  end
end
