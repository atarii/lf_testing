require 'rspec'

describe 'TS - TestCentral Self Check - PassFast' do
  context 'TC01 - 2 passes' do
    it 'Check pass 1' do
      expect(1).to eq(1)
    end

    it 'Check pass 2' do
      expect('a').to eq('a')
    end
  end

  context 'TC02 - 5 passes' do
    it 'Check pass 1' do
      expect(1 + 1).to eq(2)
    end

    it 'Check pass 2' do
      expect(1 + 1).to eq(2)
    end

    it 'Check pass 3' do
      expect(1 + 1).to eq(2)
    end

    it 'Check pass 4' do
      expect(1 + 1).to eq(2)
    end

    it 'Check pass 5' do
      expect(1 + 1).to eq(2)
    end
  end
end
