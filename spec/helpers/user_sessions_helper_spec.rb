require 'spec_helper'

describe UserSessionsHelper do
  describe 'generate_oauth_hmac' do
    let (:salt) { 'a' }
    let (:salt2) { 'b' }
    let (:return_to) { 'b' }

    it 'should return null if return_to is also null' do
      expect(generate_oauth_hmac(salt, nil)).to be_nil
    end

    it 'should return not null if return_to is also not null' do
      expect(generate_oauth_hmac(salt, return_to)).not_to be_nil
    end

    it 'should return different hmacs for different salts' do
      secret1 = generate_oauth_hmac(salt, return_to)
      secret2 = generate_oauth_hmac(salt2, return_to)
      expect(secret1).not_to eq(secret2)
    end
  end

  describe 'generate_oauth_state' do
    let (:return_to) { 'b' }

    it 'should return null if return_to is also null' do
      expect(generate_oauth_state(nil)).to be_nil
    end

    it 'should return two different states for same return_to' do
      state1 = generate_oauth_state(return_to)
      state2 = generate_oauth_state(return_to)
      expect(state1).not_to eq(state2)
    end
  end

  describe 'get_ouath_state_return_to' do
    let (:return_to) { 'a' }
    let (:state) { generate_oauth_state(return_to) }

    it 'should return return_to' do
      expect(get_ouath_state_return_to(state)).to eq(return_to)
    end
  end

  describe 'is_oauth_state_valid?' do
    let (:return_to) { 'a' }
    let (:state) { generate_oauth_state(return_to) }
    let (:forged) { "forged#{state}" }
    let (:invalid) { 'aa' }
    let (:invalid2) { 'aa:bb' }
    let (:invalid3) { 'aa:bb:' }

    it 'should validate oauth state' do
      expect(is_oauth_state_valid?(state)).to be_truthy
    end

    it 'should not validate forged state' do
      expect(is_oauth_state_valid?(forged)).to be_falsey
    end

    it 'should not validate invalid state' do
      expect(is_oauth_state_valid?(invalid)).to be_falsey
      expect(is_oauth_state_valid?(invalid2)).to be_falsey
      expect(is_oauth_state_valid?(invalid3)).to be_falsey
    end
  end
end
