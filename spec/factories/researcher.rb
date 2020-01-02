# frozen_string_literal: true

FactoryBot.define do
  factory :researcher do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password 'password'
    role :researcher

    factory :director do
      role :director
    end

    factory :esie_postdoc do
      role :esie_postdoc
    end

    factory :superadmin do
      role :superadmin
    end
  end
end
