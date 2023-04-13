# https://github.com/getmango/Mango/blob/master/src/util/proxy.cr

# The MIT License (MIT)

# Copyright (c) 2020 Alex Ling

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "http_proxy"

# Monkey-patch `HTTP::Client` to make it respect the `*_PROXY`
#   environment variables
module HTTP
  class Client
    private def self.exec(uri : URI, tls : TLSContext = nil)
      Logger.debug "Setting proxy"
      previous_def uri, tls do |client, path|
        client.set_proxy get_proxy uri
        yield client, path
      end
    end
  end
end

private def get_proxy(uri : URI) : HTTP::Proxy::Client?
  no_proxy = ENV["no_proxy"]? || ENV["NO_PROXY"]?
  return if no_proxy &&
            no_proxy.split(",").any? &.== uri.hostname

  case uri.scheme
  when "http"
    env_to_proxy "http_proxy"
  when "https"
    env_to_proxy "https_proxy"
  else
    nil
  end
end

private def env_to_proxy(key : String) : HTTP::Proxy::Client?
  val = ENV[key.downcase]? || ENV[key.upcase]?
  return if val.nil?

  begin
    uri = URI.parse val
    HTTP::Proxy::Client.new uri.hostname.not_nil!, uri.port.not_nil!,
      username: uri.user, password: uri.password
  rescue
    nil
  end
end
