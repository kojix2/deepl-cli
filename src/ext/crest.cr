require "crest"
require "socket"

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

      set_env_proxy!
    end

    private def set_env_proxy! : Nil
      # Respect Crest's explicit proxy options. Explicit arguments should win
      # over environment variables.
      return if explicit_proxy?

      request_uri = URI.parse(@url)
      scheme = env_proxy_scheme(request_uri)
      return unless scheme

      proxy_uri = proxy_uri_for_scheme(scheme)
      return unless proxy_uri

      set_proxy_from_uri!(proxy_uri)
    end

    private def explicit_proxy? : Bool
      !!(@p_addr || @p_port || @p_user || @p_pass)
    end

    private def env_proxy_scheme(request_uri : URI) : String?
      host = request_uri.host
      scheme = request_uri.scheme

      # Crest accepts relative URLs in some call paths. Environment proxies only
      # make sense once the request has both a host and a scheme.
      return unless host && scheme

      no_proxy = ENV["no_proxy"]? || ENV["NO_PROXY"]?
      request_port = request_uri.port || default_proxy_port(scheme)
      return if no_proxy && no_proxy_matches?(no_proxy, host, request_port)

      scheme
    end

    private def set_proxy_from_uri!(proxy_uri : URI) : Nil
      @p_addr = proxy_uri.host
      @p_port = proxy_uri.port || default_proxy_port(proxy_uri.scheme)
      @p_user = proxy_uri.user
      @p_pass = proxy_uri.password

      set_proxy!(@p_addr, @p_port, @p_user, @p_pass)
    end

    private def proxy_uri_for_scheme(scheme : String) : URI?
      proxy_env = ENV.has_key?("#{scheme.downcase}_proxy") ? "#{scheme.downcase}_proxy" : "#{scheme.upcase}_PROXY"
      proxy = ENV[proxy_env]?
      return unless proxy

      uri = URI.parse(proxy)

      # Be permissive for common values such as "proxy.example.com:8080".
      if blank?(uri.host) && !proxy.includes?("://")
        uri = URI.parse("http://#{proxy}")
      end

      return uri unless blank?(uri.host)

      raise ArgumentError.new("Invalid #{proxy_env} URL")
    rescue URI::Error
      raise ArgumentError.new("Invalid #{proxy_env} URL")
    end

    private def blank?(value : String?) : Bool
      value.nil? || value.empty?
    end

    private def no_proxy_matches?(no_proxy : String, host : String, port : Int32?) : Bool
      host = normalize_no_proxy_host(host)

      # Match common NO_PROXY forms: "*", exact hosts, suffix domains, IPv4
      # CIDR ranges, IPv6 literals, and optional ports such as example.com:443
      # or [::1]:443.
      no_proxy.split(',').any? do |entry|
        entry = entry.strip.downcase
        next false if entry.empty?
        next true if entry == "*"

        entry_host, entry_port = split_no_proxy_entry(entry)
        next false if entry_port && entry_port != port

        entry_host = normalize_no_proxy_host(entry_host)
        next ipv4_cidr_matches?(host, entry_host) if entry_host.includes?('/')

        host == entry_host || host.ends_with?(".#{entry_host}")
      end
    end

    private def split_no_proxy_entry(entry : String) : {String, Int32?}
      if entry.starts_with?('[')
        if bracket_end = entry.index(']')
          entry_host = entry[1...bracket_end]
          rest = entry[(bracket_end + 1)..]? || ""
          return {entry_host, parse_no_proxy_port(rest[1..]?)} if rest.starts_with?(':')
          return {entry_host, nil}
        end
      end

      if entry.count(':') == 1
        entry_host, entry_port = entry.split(':', 2)
        return {entry_host, parse_no_proxy_port(entry_port)}
      end

      {entry, nil}
    end

    private def parse_no_proxy_port(port : String?) : Int32?
      return unless port
      parsed = port.to_i?
      return parsed if parsed && 0 <= parsed <= 65535

      # Port part present but invalid (e.g. "example.com:" or ":abc"):
      # return a sentinel that can never equal a real request port.
      -1
    end

    private def normalize_no_proxy_host(host : String) : String
      host = host.downcase
      host = host[1...-1] if host.starts_with?('[') && host.ends_with?(']')
      host = host.chomp(".")
      host.lchop('.')
    end

    private def ipv4_cidr_matches?(host : String, cidr : String) : Bool
      network, prefix = cidr.split('/', 2)
      prefix_size = prefix.to_i?
      return false unless prefix_size && 0 <= prefix_size <= 32

      host_addr = ipv4_to_u32(host)
      network_addr = ipv4_to_u32(network)
      return false unless host_addr && network_addr

      mask = prefix_size == 0 ? 0_u32 : UInt32::MAX << (32 - prefix_size)
      (host_addr & mask) == (network_addr & mask)
    end

    private def ipv4_to_u32(host : String) : UInt32?
      fields = Socket::IPAddress.parse_v4_fields?(host)
      return unless fields

      fields.reduce(0_u32) { |acc, field| (acc << 8) | field.to_u32 }
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
