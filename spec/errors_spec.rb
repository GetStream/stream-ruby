require 'spec_helper'
require 'stream'

describe Stream::Error do
  it { expect(Stream::Error).to be < StandardError }
  it { expect(Stream::StreamApiResponseException).to be < Stream::Error }
  it { expect(Stream::StreamApiResponseDoesNotExistException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseApiKeyException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseSignatureException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseInputException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseCustomFieldException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseFeedConfigException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseSiteSuspendedException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseInvalidPaginationException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseRateLimitReached).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseMissingUserException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseMissingRankingException).to be < Stream::StreamApiResponseFeedConfigException }
  it { expect(Stream::StreamApiResponseRankingException).to be < Stream::StreamApiResponseFeedConfigException }
  it { expect(Stream::StreamApiResponseOldStorageBackendException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseJinjaRuntimeException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseBestPracticeException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseDoesNotExistException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseNotAllowedException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamApiResponseConflictException).to be < Stream::StreamApiResponseException }
  it { expect(Stream::StreamInputData).to be < Stream::Error }
end
