module Qyu
  module Store
    module ActiveRecord
      class Job < ::ActiveRecord::Base
        belongs_to :workflow

        has_many :tasks
      end
    end
  end
end
