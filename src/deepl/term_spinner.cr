# A minimal implementation of the Term::Spinner class
# https://github.com/crystal-term/spinner by Chris Watson
# Provides only the API used by deepl-cli: Term::Spinner.new(clear: true).run { ... }

module Term
  class Spinner
    DEFAULT_FRAMES = ["|", "/", "-", "\\"] of String

    @running : Bool = false
    @clear : Bool
    @frames : Array(String)
    @interval : Float64

    def initialize(@clear : Bool = false, @frames = DEFAULT_FRAMES, @interval = 0.1)
      @frames = @frames.to_a
    end

    def run(&block)
      return yield unless tty?

      @running = true
      spawn do
        i = 0
        while @running
          frame = @frames[i % @frames.size]
          write("\r#{frame}")
          i += 1
          sleep @interval.seconds
        end
      end

      begin
        yield
      ensure
        @running = false
        clear_line if @clear
      end
    end

    private def clear_line
      # Clear current line and move cursor to column 1
      write("\r\e[2K")
    end

    private def write(text : String)
      STDERR.print(text)
      STDERR.flush
    end

    private def tty?
      STDERR.tty?
    end
  end
end
