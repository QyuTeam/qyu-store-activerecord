# frozen_string_literal: true

FactoryBot.define do
  factory :task, class: Qyu::Store::ActiveRecord::Task do
    job
    parent_task_id { nil }

    sequence(:name) { |n| "Task #{n}" }
    sequence(:queue_name) { |n| "queue#{n}" }
    sequence(:status) { |n| "queued" }
    payload { { key: :value } }
  end
end
