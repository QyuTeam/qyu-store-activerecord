# frozen_string_literal: true

FactoryBot.define do
  factory :workflow, class: Qyu::Store::ActiveRecord::Workflow do
    sequence(:name) { |n| "Workflow #{n}" }
    descriptor { { 'some' => 'description' } }
  end
end
