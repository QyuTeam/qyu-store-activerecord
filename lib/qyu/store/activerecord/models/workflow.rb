module Qyu
  module Store
    module ActiveRecord
      class Workflow < ::ActiveRecord::Base
        has_many :jobs, dependent: :destroy
      end
    end
  end
end
