module Stream
  class Error < StandardError; end

  class StreamApiResponseException < Error; end

  class StreamApiResponseApiKeyException < StreamApiResponseException; end

  class StreamApiResponseSignatureException < StreamApiResponseException; end

  class StreamApiResponseInputException < StreamApiResponseException; end

  class StreamApiResponseCustomFieldException < StreamApiResponseException; end

  class StreamApiResponseFeedConfigException < StreamApiResponseException; end

  class StreamApiResponseSiteSuspendedException < StreamApiResponseException; end

  class StreamApiResponseInvalidPaginationException < StreamApiResponseException; end

  class StreamApiResponseRateLimitReached < StreamApiResponseException; end

  class StreamApiResponseMissingRankingException < StreamApiResponseFeedConfigException; end

  class StreamApiResponseMissingUserException < StreamApiResponseException; end

  class StreamApiResponseRankingException < StreamApiResponseFeedConfigException; end

  class StreamApiResponseOldStorageBackendException < StreamApiResponseException; end

  class StreamApiResponseJinjaRuntimeException < StreamApiResponseException; end

  class StreamApiResponseBestPracticeException < StreamApiResponseException; end

  class StreamApiResponseDoesNotExistException < StreamApiResponseException; end

  class StreamApiResponseNotAllowedException < StreamApiResponseException; end

  class StreamApiResponseConflictException < StreamApiResponseException; end

  class StreamInputData < Error; end
end
