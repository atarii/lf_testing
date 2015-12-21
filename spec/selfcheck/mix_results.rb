require 'rspec'

describe 'TS - TestCentral Self Check - Mix Results' do
  context 'TC01 - 2 passes' do
    it 'Check pass 1' do
      expect(1).to eq(1)
    end

    it 'Check pass 2' do
      expect(1).to eq(1)
    end
  end

  context 'TC02 - 2 fails' do
    it 'Check fail 1' do
      expect(1).to eq(2)
    end

    it 'Check fail 2' do
      expect(1).to eq(2)
    end
  end

  context 'TC03 - 2 pending' do
    it 'Check pending 1 by skip' do
      skip 'Check pending 1'
    end

    it 'Check pending 2' do
      pending 'Check pending 2 by pending - fail'
      fail
    end
  end

  context 'TC04 - 2 passes and 2 fail' do
    it 'Check pass 1' do
      expect(1).to eq(1)
    end

    it 'Check fail 1' do
      expect(1).to eq(2)
    end

    it 'Check pass 2' do
      expect(1).to eq(1)
    end

    it 'Check fail 2' do
      expect(1).to eq(2)
    end
  end

  context 'TC05 - 1 pass, 1 fail, 1 pending' do
    it 'Check pass 1' do
      expect(1).to eq(1)
    end

    it 'Check fail 1' do
      expect(1).to eq(2)
    end

    pending 'Check pending 1' do
      expect(1).to eq(2)
    end
  end
end
