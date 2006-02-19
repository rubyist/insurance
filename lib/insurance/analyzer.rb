require 'yaml'
module Insurance
  FILELIST = {}
  
  END {
    Insurance.set_trace_func nil
    
    Dir.mkdir('insurance') unless File.exist?('insurance')
    
    Insurance::Formatter.run(Insurance::FILELIST)    
  }
  
  class Analyzer
    def self.line_trace_func(event, file, line)     
#       case event
#       when 'c-call', 'c-return'
#         return
#       end
      
      if (full_path = self.filter(file))
        FILELIST[full_path] ||= SourceFile.new(full_path)
        FILELIST[full_path] << line
      end
    end
    
    def self.filter(file)
      file
    end
    
    def self.run(files)
      Insurance.set_trace_func self.method(:line_trace_func).to_proc
      files.each { |f| load f }
    end
  end
  
  class RailsAnalyzer < Analyzer
    @@dir_regexp  = Regexp.new("^#{Dir.pwd}/(?:lib|app/(?:models|controllers))/")
    @@_path_cache = {}
    
    def self.filter(file)
      begin
        full_path =  @@_path_cache[file] || (@@_path_cache[file] = File.expand_path(file))
        if @@dir_regexp =~ full_path
          pwd = Dir.pwd
          return full_path[(full_path.index(pwd)+pwd.length+1)..-1]
        else
          return false
        end
      rescue
        return false
      end
    end
    
    def self.run(files)
      # The rails analyzer does not need to set the trace func, because that is
      # done in the perversion of Test::Unit::TestCase.
      
      # Since we flip tracing on only right before a test is executed, to avoid
      # tracing the entire framework at all times (very slow), we need to pre-load
      # all of the application's models and controllers so that we can trace things
      # at the class level.  This is just easier to do than to try and figure out
      # what should really be marked as hit in the output stage.
      
      pipe = IO.popen('-', 'w+')
      if pipe
        Insurance::FILELIST.merge!(YAML::load(pipe.read))
        files.each { |f| load f }
      else
        at_exit {
          Insurance.set_trace_func nil
          puts Insurance::FILELIST.to_yaml
          exit!
        }
        
        require 'config/environment'
        Insurance.set_trace_func self.method(:line_trace_func).to_proc
        require 'application'
        (Dir['app/models/*.rb'] + Dir['app/controllers/*.rb']).each { |f| load f }
     end
    end
  end  
end