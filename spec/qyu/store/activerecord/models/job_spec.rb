require 'spec_helper'

RSpec.describe Qyu::Store::ActiveRecord::Job, type: :model do
  describe '# relations' do
    it { should belong_to(:workflow) }
    it { should have_many(:tasks) }
  end
end
