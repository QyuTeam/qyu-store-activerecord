require 'spec_helper'

RSpec.describe Qyu::Store::ActiveRecord::Task, type: :model do
  describe '# relations' do
    it { should belong_to(:job) }
    it { should belong_to(:parent_task) }
  end
end
