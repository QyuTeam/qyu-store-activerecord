module Qyu
  module Store
    module ActiveRecord
      class Task < ::ActiveRecord::Base
        belongs_to :job
        belongs_to :parent_task, class_name: 'Task', foreign_key: :id
        has_many   :children_tasks, class_name: 'Task',
                                    foreign_key: 'parent_task_id',
                                    dependent: :destroy
      end
    end
  end
end
