RSpec.describe Qyu do
  context 'fake logger' do
    before { described_class.logger = nil }

    it { expect(described_class.logger.nil?).to be false }
  end
end
