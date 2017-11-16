module Qyu
  module Store
    module ActiveRecord
      class Task < ::ActiveRecord::Base
        belongs_to :job
        belongs_to :parent_task, class_name: 'Task', foreign_key: :id
      end
    end
  end
end
