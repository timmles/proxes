# frozen_string_literal: true
require 'proxes/models/user'
require 'proxes/models/user_role'

FactoryGirl.define do
  to_create(&:save)

  sequence(:email) { |n| "person-#{n}@example.com" }
  sequence(:name) { |n| "Name-#{n}" }

  factory :user, class: ProxES::User, aliases: [:'ProxES::User'] do
    email
    after(:create) do |user, _evaluator|
      user.add_user_role(role: 'user')
    end

    factory :admin_user do
      after(:create) do |user, _evaluator|
        user.add_user_role(role: 'admin')
      end
    end

    factory :super_admin_user do
      after(:create) do |user, _evaluator|
        user.add_user_role(role: 'super_admin')
      end
    end
  end

  factory :user_role, class: ProxES::UserRole, aliases: [:'ProxES::UserRole'] do
    role 'admin'
    user
  end

  factory :identity, class: ProxES::Identity, aliases: [:'ProxES::Identity'] do
    username { generate :email }
    crypted_password 'som3Password!'
  end
end
