module Term
  class Prompt
    def select(label : String, items : Array(String)) : String?
      return nil if items.empty?
      return items.first? unless STDIN.tty? && STDERR.tty?

      STDERR.puts label
      items.each_with_index do |item, index|
        STDERR.puts "#{index + 1}) #{item}"
      end

      loop do
        STDERR.print "Select [1-#{items.size}]> "
        input = STDIN.gets
        return nil if input.nil?
        value = input.strip
        next if value.empty?
        idx = value.to_i
        if idx >= 1 && idx <= items.size
          return items[idx - 1]
        end
        STDERR.puts "Invalid selection. Please enter a number between 1 and #{items.size}."
      end
    end

    # Overload for arrays of any type convertible to String
    def select(label : String, items : Array(T)) : String? forall T
      return nil if items.empty?
      self.select(label, items.map(&.to_s))
    end
  end
end
