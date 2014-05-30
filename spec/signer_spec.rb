require 'stream'

describe Stream::Signer do

    it "tests a signature" do
        signer = Stream::Signer.new('123')
        signer.signature(123).should eq 'U_B-Ll24uKGqPayl1Nm-iJMXjIQ'
    end

end