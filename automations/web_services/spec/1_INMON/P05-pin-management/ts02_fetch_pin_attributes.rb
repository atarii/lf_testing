require File.expand_path('../../../spec_helper', __FILE__)
require 'pin_management'

=begin
Verify fetchPinAttributes service works correctly
=end

describe "TS02 - fetchPinAttributes - #{Misc::CONST_ENV}" do
  pin = '3360202853365815'
  res = nil

  context 'TC02.001 - fetchPinAttributes - Successful Response' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, pin)
    end

    it 'Verify pin-text' do
      expect(res.xpath('//pins/@pin').text).to eq(pin)
    end

    it 'Verify status is REDEEMED' do
      expect(res.xpath('//pins/@status').text).to eq('REDEEMED')
    end

    it 'Verify current is USD' do
      expect(res.xpath('//pins/@currency').text).to eq('USD')
    end

    it 'Verify amount is 20.0' do
      expect(res.xpath('//pins/@amount').text.to_s).to eq('20.0')
    end
  end

  context 'TC02.003 - fetchPinAttributes - Invalid CallerID' do
    before :all do
      res = PINManagement.fetch_pin_attributes('invalid', pin)
    end

    it 'Verify faultstring is returned: Error while checking caller id' do
      expect(res).to eq('Error while checking caller id')
    end
  end

  context 'TC02.004 - fetchPinAttributes - Invalid Request' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, '', '')
    end

    it 'Verify faultstring is returned: The given pin was invalid: unexistent' do
      expect(res).to eq('The given pin was invalid: unexistent')
    end
  end

  context 'TC02.005 - fetchPinAttributes - Invalid PIN Response' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, 'invalid pin')
    end

    it 'Verify faultstring is returned: The given pin was invalid: unexistent' do
      expect(res).to eq('The given pin was invalid: unexistent')
    end
  end

  context 'TC02.006 - fetchPinAttributes - Pin text is empty' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, '')
    end

    it 'Verify faultstring is returned: The given pin was invalid: unexistent' do
      expect(res).to eq('The given pin was invalid: unexistent')
    end
  end

  context 'TC02.007 - fetchPinAttributes - Pin text is so long' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, '11111111111111111111111111111111122')
    end

    it 'Verify faultstring is returned: The given pin was invalid: unexistent' do
      expect(res).to eq('The given pin was invalid: unexistent')
    end
  end

  context 'TC02.008 - fetchPinAttributes - Pin text is special characters' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, '@###$%')
    end

    it 'Verify faultstring is returned: The given pin was invalid: unexistent' do
      expect(res).to eq('The given pin was invalid: unexistent')
    end
  end

  context 'TC02.009 - fetchPinAttributes - Pin text is negative numbers' do
    before :all do
      res = PINManagement.fetch_pin_attributes(Misc::CONST_CALLER_ID, '-12345678978946532131313213')
    end

    it 'Verify faultstring is returned: The given pin was invalid: unexistent' do
      expect(res).to eq('The given pin was invalid: unexistent')
    end
  end
end
