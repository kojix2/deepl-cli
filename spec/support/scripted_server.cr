require "http/server"

class ScriptedServer
  record Response,
    status_code : Int32,
    body : String = "",
    headers : Hash(String, String) = {} of String => String

  record Request, method : String, resource : String, body : String

  getter requests : Array(Request)
  getter url : String

  def initialize(@responses : Array(Response))
    @requests = [] of Request
    @server = HTTP::Server.new do |context|
      body = context.request.body.try(&.gets_to_end) || ""
      @requests << Request.new(context.request.method, context.request.resource, body)

      response = @responses.shift? || Response.new(500, "No scripted response")
      context.response.status_code = response.status_code
      response.headers.each do |name, value|
        context.response.headers[name] = value
      end
      context.response.content_length = response.body.bytesize
      context.response.print(response.body) unless response.body.empty?
      context.response.close
    end

    address = @server.bind_tcp("127.0.0.1", 0)
    @url = "http://127.0.0.1:#{address.port}"
    spawn { @server.listen }
  end

  def close : Nil
    @server.close unless @server.closed?
  end
end
