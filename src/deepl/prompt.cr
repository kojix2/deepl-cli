module Term
  class Prompt
    def initialize(@input : IO = STDIN, @output : IO = STDERR)
    end

    def select(label : String, items : Array(String)) : String?
      return if items.empty?
      return select_non_interactive(items) unless interactive?
      return items.first? if items.size == 1

      prompt_for_selection(label, items)
    end

    private def interactive? : Bool
      @input.tty? && @output.tty?
    end

    private def select_non_interactive(items : Array(String)) : String?
      items.first? if items.size == 1
    end

    private def prompt_for_selection(label : String, items : Array(String)) : String?
      @output.puts label

      items.each_with_index do |item, index|
        @output.puts "#{index + 1}) #{item}"
      end

      loop do
        @output.print "Select [1-#{items.size}] (Enter=1, q=cancel)> "
        case selection = read_selection(items.size)
        when :cancel
          return
        when :default
          return items[0]
        when :invalid
          @output.puts "Invalid selection. Enter 1-#{items.size}, Enter for 1, or q to cancel."
        when Int32
          return items[selection - 1]
        end
      end
    end

    private def read_selection(item_count : Int32) : Int32 | Symbol
      input = @input.gets
      return :cancel if input.nil?

      value = input.strip
      return :default if value.empty?

      case value.downcase
      when "q", "quit", "exit"
        return :cancel
      end

      if value =~ /^\d+$/
        idx = value.to_i
        return idx if idx >= 1 && idx <= item_count
      end

      :invalid
    end

    # Overload for arrays of any type convertible to String
    def select(label : String, items : Array(T)) : String? forall T
      return if items.empty?
      self.select(label, items.map(&.to_s))
    end
  end
end
