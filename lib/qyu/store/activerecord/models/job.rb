module Qyu
  module Store
    module ActiveRecord
      class Job < ::ActiveRecord::Base
        belongs_to :workflow

        has_many :tasks, dependent: :destroy
      end
    end
  end
end
