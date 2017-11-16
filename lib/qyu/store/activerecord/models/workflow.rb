module Qyu
  module Store
    module ActiveRecord
      class Workflow < ::ActiveRecord::Base
        has_many :jobs
      end
    end
  end
end

