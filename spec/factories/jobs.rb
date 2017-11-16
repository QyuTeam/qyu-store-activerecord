# frozen_string_literal: true

FactoryBot.define do
  factory :job, class: Qyu::Store::ActiveRecord::Job do
    workflow
    payload { { key: :value } }
  end
end
