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
      exelines = 0
      contents.each_with_index do |line, num|
        sline = line.strip
        
        case sline
        when '', /^#/
          lines << num + 1
        when /^\s*(?:end|\})\s*(?:#.*)?$/, /^(public|private|protected)/,
             /^(?:begin\s*(?:#.*)?|ensure\s*(?:#.*)?|else\s*(?:#.*)?)$/,
             /^(?:rescue)/, /^case\s*(?:#.*)?$/, /^(\)|\]|\})(?:#.*)?$/
          lines << num + 1
          exelines += 1
        else
          exelines += 1
        end
        
      end
      
      @coverage_percent = (exelines.to_f / contents.size) * 100.0
    end
  end
end