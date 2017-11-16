require 'spec_helper'

RSpec.describe Qyu::Store::ActiveRecord::Workflow, type: :model do
  describe '# relations' do
    it { should have_many(:jobs) }
  end
end
