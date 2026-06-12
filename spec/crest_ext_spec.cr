require "./spec_helper"

describe Crest::Request do
  around_each do |example|
    saved = {
      "http_proxy"  => ENV["http_proxy"]?,
      "HTTP_PROXY"  => ENV["HTTP_PROXY"]?,
      "https_proxy" => ENV["https_proxy"]?,
      "HTTPS_PROXY" => ENV["HTTPS_PROXY"]?,
      "no_proxy"    => ENV["no_proxy"]?,
      "NO_PROXY"    => ENV["NO_PROXY"]?,
    }

    begin
      saved.each_key { |key| ENV.delete(key) }
      example.run
    ensure
      saved.each do |key, value|
        if value
          ENV[key] = value
        else
          ENV.delete(key)
        end
      end
    end
  end

  it "raises for an invalid proxy URL" do
    ENV["http_proxy"] = "http://"

    expect_raises(ArgumentError, "Invalid http_proxy URL") do
      Crest::Request.new(:get, "http://example.com")
    end
  end

  it "accepts a schemeless proxy host and port" do
    ENV["http_proxy"] = "localhost:3001"

    Crest::Request.new(:get, "http://example.com")
  end

  it "matches NO_PROXY entries with exact ports" do
    ENV["http_proxy"] = "localhost:3001"
    ENV["no_proxy"] = "example.com:80"

    Crest::Request.new(:get, "http://example.com").proxy.should be_nil
    Crest::Request.new(:get, "http://example.com:81").proxy.should_not be_nil
  end

  it "matches NO_PROXY suffix domains" do
    ENV["http_proxy"] = "localhost:3001"
    ENV["no_proxy"] = ".example.com"

    Crest::Request.new(:get, "http://api.example.com").proxy.should be_nil
    Crest::Request.new(:get, "http://example.net").proxy.should_not be_nil
  end

  it "matches NO_PROXY IPv4 CIDR ranges" do
    ENV["http_proxy"] = "localhost:3001"
    ENV["no_proxy"] = "10.0.0.0/8"

    Crest::Request.new(:get, "http://10.1.2.3").proxy.should be_nil
    Crest::Request.new(:get, "http://192.168.1.1").proxy.should_not be_nil
  end

  it "matches bracketed NO_PROXY IPv6 entries with ports" do
    ENV["http_proxy"] = "localhost:3001"
    ENV["no_proxy"] = "[::1]:80"

    Crest::Request.new(:get, "http://[::1]").proxy.should be_nil
    Crest::Request.new(:get, "http://[::1]:81").proxy.should_not be_nil
  end
end
