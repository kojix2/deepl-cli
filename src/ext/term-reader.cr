module Term
  # Get input in unbuffered mode.
  class Reader
    def unbuffered(& : ->)
      buffering = begin
        # @output.as(IO::FileDescriptor).sync?
        (@output.as(IO::FileDescriptor).sync? || false)
      rescue
        false
      end
      # Immidiately flush output
      begin
        @output.as(IO::FileDescriptor).sync = true
      rescue
      end
      yield
    ensure
      begin
        # @output.as(IO::FileDescriptor).sync = buffering
        @output.as(IO::FileDescriptor).sync = (buffering || false)
      rescue
      end
    end
  end
end
