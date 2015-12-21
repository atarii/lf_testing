require 'rspec'

describe 'TS - TestCentral Self Check - FailFast' do
  context 'TC01 - 4 fails' do
    it 'Check fail 1' do
      expect(1).to eq(2)
    end

    it 'Check fail 2' do
      expect('a').to eq('b')
    end

    it 'Check fail 3' do
      expect(1.5).to eq(2.0)
    end

    it 'Check fail 4' do
      expect(false).to eq(true)
    end
  end

  context 'TC02 - 1 fail' do
    it 'Throw an exception' do
      raise 'Some exception'
    end
  end

  context 'TC03 - 1 fail, 4 pending' do
    it 'Should be fail since pending will continue to run test but test expected to fail' do
      pending 'This is pending but marked as fail since test passed'
      expect(true).to eq(true)
    end

    it 'Skipped will not run tests' do
      skip 'This is skipped'
      expect(true).to eq(true)
    end

    it 'Should be pending since it is marked pending and tests fail' do
      pending 'This is pending but marked as passed since test fail'
      fail 'Test should fail'
    end

    it 'Has a blocked status' do
      skip 'BLOCKED: This is blocked (used skip method)'
    end

    it 'Has a blocked status' do
      pending 'BLOCKED: This is blocked (used pending method)'
      fail 'Test should fail'
    end

    skip 'BLOCKED: This is blocked outside of an "it" test (used skip method)'

    pending 'BLOCKED: This is blocked outside of an "it" test (used pending method)'

  end
end
