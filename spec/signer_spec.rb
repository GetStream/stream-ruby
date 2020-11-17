require 'spec_helper'

describe Stream::Signer do
  it 'tests a token' do
    Stream::Signer.new('123')
  end
end
