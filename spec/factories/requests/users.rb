require 'factory_girl'

FactoryGirl.define do
  factory :user, class: "User" do
    sequence(:username) { |_n| "username#{srand}" }
    sequence(:email) { |_n| "email-#{srand}@princeton.edu" }
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
      username 'Barcode Patron'
    end

    factory :unauthenticated_patron do
      guest true
      provider nil
    end
  end
end
