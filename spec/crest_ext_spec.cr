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
end
