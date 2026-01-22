module Term
  class Prompt
    def initialize(@input : IO = STDIN, @output : IO = STDERR)
    end

    def select(label : String, items : Array(String)) : String?
      return nil if items.empty?
      return items.first? unless @input.tty? && @output.tty?

      @output.puts label

      if items.size == 1
        @output.puts items[0]
        return items[0]
      end

      items.each_with_index do |item, index|
        @output.puts "#{index + 1}) #{item}"
      end

      loop do
        @output.print "Select [1-#{items.size}] (Enter=1, q=cancel)> "
        input = @input.gets
        return nil if input.nil?
        value = input.strip
        return items[0] if value.empty?

        case value.downcase
        when "q", "quit", "exit"
          return nil
        end

        if value =~ /^\d+$/
          idx = value.to_i
          if idx >= 1 && idx <= items.size
            return items[idx - 1]
          end
        end

        @output.puts "Invalid selection. Enter 1-#{items.size}, Enter for 1, or q to cancel."
      end
    end

    # Overload for arrays of any type convertible to String
    def select(label : String, items : Array(T)) : String? forall T
      return nil if items.empty?
      self.select(label, items.map(&.to_s))
    end
  end
end
