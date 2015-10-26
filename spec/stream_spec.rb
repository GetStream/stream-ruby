require 'stream'

describe Stream do
  it "connects returns a client instance" do
    client = Stream.connect('key', 'secret')
    expect(client).to be_instance_of Stream::Client
  end
end