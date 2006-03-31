require 'erb'
require 'syntax'
require 'syntax/convertors/html'

module Insurance
  class Formatter
    include ERB::Util
    
    def self.svn_blame_for(file)
      if File.exist?(File.dirname(File.expand_path(file)) + '/.svn')
        `svn blame #{file}`.split("\n").map {|l| l.split[1]}.map { |l| l.split('@')[0] }
      else
        []
      end
    end
    
    def self.run(dbfile, outputdir)
      raw = Marshal.load(open(dbfile))

      unless File.exist?(outputdir)
        Dir.mkdir(outputdir)
      end
      
      asset_dir = File.dirname(__FILE__) + "/templates/assets"
      
      files = raw.keys.inject([]) { |arr, k| arr += raw[k].keys; arr }.uniq.sort

      project_name    = File.basename Dir.pwd

      File.open("#{outputdir}/index.html", 'w') do |f|
        f.write ERB.new(File.read("#{File.dirname(__FILE__)}/templates/index.rhtml")).result(binding)
        puts "Wrote #{outputdir}/index.html"
      end

      files.each do |file, lines|
        contents = File.open(file, 'r').readlines
        lines = []
        
        contents.each_with_index do |line, num|
          sline = line.strip
          #lines << num + 1 if sline.empty?
          #lines << num + 1 if sline =~ /^#/
          lines << num + 1 if sline =~ /^\s*(?:end|\})\s*(?:#.*)?$/
          lines << num + 1 if sline =~ /^(public|private|protected)/
          lines << num + 1 if sline =~ /^(?:begin\s*(?:#.*)?|ensure\s*(?:#.*)?|else\s*(?:#.*)?)$/
          lines << num + 1 if sline =~ /^(?:rescue)/
          lines << num + 1 if sline =~ /^case\s*(?:#.*)?$/
          lines << num + 1 if sline =~ /^(\)|\]|\})(?:#.*)?$/
        end
        [:unit, :functional, :integration].each do |suite|
          if raw[suite][file]
            raw[suite][file] += lines
          end
        end
      end

      # Create html output
      files.each do |file, lines|
        blame = svn_blame_for(file)

        File.open("#{outputdir}/#{file.gsub('/', '-')}.html", 'w') do |f|

          contents   = File.open(file, 'r').readlines
          executable_lines = []

          # Lines that were executed by the tests
          exelines   = [:unit, :functional, :integration].map { |k| raw[k][file] }.flatten.uniq.sort

          # Get all lines that aren't comments
          contents.each_with_index do |line, num|
            sline = line.strip
            executable_lines << num + 1 unless sline.empty? || sline =~ /^#/
          end

          puts "EXECUTED LINES: #{exelines.size}, EXECUTABLE LINES: #{executable_lines.size}"
          if executable_lines.size > 0
            percentage = (exelines.size.to_f / executable_lines.size) * 100
          else
            percentage = 0
          end
          puts "FUCKING PERCENTAGE IS #{percentage}"
          
          file_under_test = "#{file} - #{'%.2f' % percentage}%"

          body = "<table class=\"ruby\">\n"

          contents.each_with_index do |line, num|
            if line.strip.empty? || line.strip =~ /^#/
              classes = [:unit, :functional, :integration]
            else
              classes = []
              [:unit, :functional, :integration].each do |suite|
                if raw[suite][file] && raw[suite][file].include?(num+1)
                  classes << suite.to_s
                end
              end
            end
            lineno = (num + 1).to_s
            body << "<tr><td class=\"lineno\">"
            body << "<a href=\"txmt://open?url=file://#{File.expand_path(file)}&line=#{lineno}\">#{lineno}</a>"
            body << "</td>"
            unless blame.empty?
              body << "<td class=\"blame\">#{blame[num]}</td>"
            end
            body << "<td><pre>  <span class=\"codeline #{classes * ' '}\">#{Syntax::Convertors::HTML.for_syntax('ruby').convert(line, false)}</span>"
            body << "</td></tr>"
          end
          body << "</table>"
          f.write ERB.new(File.read("#{File.dirname(__FILE__)}/templates/code-page.rhtml")).result(binding)
          puts "Wrote #{outputdir}/#{file.gsub('/', '-')}.html"
        end
      end
    end
  end
end
