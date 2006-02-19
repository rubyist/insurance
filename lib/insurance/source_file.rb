module Insurance
  class SourceFile
    attr_reader :name
    attr_reader :lines
    attr_reader :coverage_percent
    
    def initialize(name)
      @name             = name
      @lines            = []
      @coverage_percent = 0
    end
    
    def <<(line)
      @lines << line unless @lines.include?(line)
    end
    
    # This marks crufty crap that isn't important, like 'end', and whitespace.
    def post_analyze!
      contents = File.open(self.name, 'r').readlines
      contents.each_with_index do |line, num|
        sline = line.strip
        lines << num + 1 if sline.empty?
        lines << num + 1 if sline =~ /^#/
        lines << num + 1 if sline =~ /^\s*(?:end|\})\s*(?:#.*)?$/
        lines << num + 1 if sline =~ /^(public|private|protected)/
        lines << num + 1 if sline =~ /^(?:begin\s*(?:#.*)?|ensure\s*(?:#.*)?|else\s*(?:#.*)?)$/
        lines << num + 1 if sline =~ /^(?:rescue)/
        lines << num + 1 if sline =~ /^case\s*(?:#.*)?$/
        lines << num + 1 if sline =~ /^(\)|\]|\})(?:#.*)?$/
      end
      
      @coverage_percent = (@lines.size.to_f / contents.size.to_f) * 100.0
    end
  end
end