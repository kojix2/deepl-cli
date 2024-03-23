require "crest"

# Extends the CREST::Request class to support the proxy environment variables.
# https://github.com/mamantoha/crest
# https://github.com/mamantoha/http_proxy
#
# Set proxies according to the *_PROXY environment variables #22
# https://github.com/mamantoha/http_proxy/issues/22

module Crest
  class Request
    # FIXME: The method signature of initialize must exactly match the signature
    # of the original CREST::Request. This means that if CREST changes the method
    # signature slightly in the future, there will be bugs that are hard to detect.
    #
    # 2024-03-23: Crest v1.3.13 CREST::Request#initialize signature:
    # https://github.com/mamantoha/crest/blob/v1.3.13/src/crest/request.cr#L163
    #
    # TODO: It would be better to make a pull request to Crest/http_proxy to add
    # the support for the proxy environment variables. This way, we can avoid
    # the need to monkey patch the Request class.

    def initialize(
      method : Symbol,
      url : String,
      form = {} of String => String,
      **args
    )
      previous_def
      url = URI.parse(@url)
      no_proxy = ENV["no_proxy"]? || ENV["NO_PROXY"]?
      return if no_proxy && no_proxy.split(",").includes?(url.host)
      key = "#{url.scheme}_proxy"
      proxy_ = ENV[key.downcase]? || ENV[key.upcase]?
      return if proxy_.nil?
      uri = URI.parse proxy_
      @p_addr = uri.host
      @p_port = uri.port
      @p_user = uri.user
      @p_pass = uri.password
      set_proxy!(@p_addr, @p_port, @p_user, @p_pass)
    end
  end
end
