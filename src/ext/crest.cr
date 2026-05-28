require "crest"

# Add *_proxy / NO_PROXY environment variable support to Crest.
#
# Crest already has an official proxy API via p_addr, p_port, p_user, and
# p_pass. This extension only fills those fields from the environment when the
# caller did not explicitly pass proxy settings.
module Crest
  class Request
    # Keep this signature aligned with Crest::Request#initialize.
    # If Crest changes the signature, this local extension needs to follow.
    def initialize(
      method : Symbol,
      url : String,
      form = {} of String => String,
      **args,
    )
      previous_def

      # Respect Crest's explicit proxy options. Explicit arguments should win
      # over environment variables.
      return if @p_addr || @p_port || @p_user || @p_pass

      request_uri = URI.parse(@url)
      host = request_uri.host
      scheme = request_uri.scheme

      # Crest accepts relative URLs in some call paths. Environment proxies only
      # make sense once the request has both a host and a scheme.
      return unless host && scheme

      no_proxy = ENV["no_proxy"]? || ENV["NO_PROXY"]?
      return if no_proxy && no_proxy_matches?(no_proxy, host)

      proxy_uri = proxy_uri_for_scheme(scheme)
      return unless proxy_uri

      @p_addr = proxy_uri.host
      @p_port = proxy_uri.port || default_proxy_port(proxy_uri.scheme)
      @p_user = proxy_uri.user
      @p_pass = proxy_uri.password

      set_proxy!(@p_addr, @p_port, @p_user, @p_pass)
    end

    private def proxy_uri_for_scheme(scheme : String) : URI?
      proxy = ENV["#{scheme.downcase}_proxy"]? || ENV["#{scheme.upcase}_PROXY"]?
      return unless proxy

      uri = URI.parse(proxy)

      # Be permissive for common values such as "proxy.example.com:8080".
      if uri.host.nil? && !proxy.includes?("://")
        uri = URI.parse("http://#{proxy}")
      end

      uri.host ? uri : nil
    rescue URI::Error
      nil
    end

    private def no_proxy_matches?(no_proxy : String, host : String) : Bool
      host = host.downcase

      # Match the common NO_PROXY forms: "*", exact hosts, suffix domains, and
      # optional ports such as "example.com:443".
      no_proxy.split(',').any? do |entry|
        entry = entry.strip.downcase
        next false if entry.empty?
        next true if entry == "*"

        entry_host = entry.includes?(':') ? entry.split(':', 2).first : entry
        entry_host = entry_host.lchop('.')

        host == entry_host || host.ends_with?(".#{entry_host}")
      end
    end

    private def default_proxy_port(scheme : String?) : Int32?
      case scheme.try(&.downcase)
      when "http"
        80
      when "https"
        443
      end
    end
  end
end
