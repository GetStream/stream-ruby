require "stream"

describe Stream::Signer do
  it "tests a token" do
    signer = Stream::Signer.new("123")
    signer.sign(1, 23).should eq "U_B-Ll24uKGqPayl1Nm-iJMXjIQ"
  end
end
