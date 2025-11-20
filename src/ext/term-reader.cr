# ISSUE https://github.com/crystal-term/prompt/issues/12
# UPSTREAM ISSUE https://github.com/crystal-term/reader/issues/6
# PR https://github.com/crystal-term/reader/pull/7

# This is a workaround for Term::Reader
# Please remove this file when the upstream PR is merged and released.
# src/deepl/cli.cr requires this file.

module Term
  class Reader
    # Get input in unbuffered mode.
    def unbuffered(& : ->)
      buffering = begin
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
        @output.as(IO::FileDescriptor).sync = (buffering || false)
      rescue
      end
    end
  end
end
