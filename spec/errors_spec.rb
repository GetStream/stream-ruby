require "spec_helper"
require "stream"

describe Stream::Error do
  it { expect(Stream::Error).to be < StandardError }
  it { expect(Stream::StreamApiResponseException).to be < Stream::Error }
  it { expect(Stream::StreamInputData).to be < Stream::Error }
end
