# frozen_string_literal: true

class CreateInitialModels < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs do |t|
      t.jsonb :payload

      t.references :workflow, foreign_key: true

      t.timestamps
    end

    create_table :tasks do |t|
      t.string :name
      t.string :queue_name
      t.string :status
      t.column :locked_until, 'timestamp with time zone'
      t.string :locked_by
      t.jsonb :payload

      t.references :job, foreign_key: true
      t.references :parent_task, table_name: 'tasks', foreign_key: { to_table: 'tasks' }

      t.timestamps
    end

    create_table :workflows do |t|
      t.string :name, null: false, unique: true
      t.jsonb :descriptor, null: false
    end
  end
end
