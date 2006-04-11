require 'erb'
require 'syntax'
require 'syntax/convertors/html'
require 'fileutils'

module Insurance
  class Formatter
    include ERB::Util
    
    def self.run(dbfile, outputdir)
      raw = Marshal.load(open(dbfile))
      project_coverage = {}

      asset_dir = "assets"
      FileUtils.mkdir_p "#{outputdir}/assets"
      
      # Copy assets
      Dir["#{File.dirname(__FILE__)}/templates/assets/*"].each do |f|
        FileUtils.cp f, "#{outputdir}/assets"
      end
      
      files = raw.keys.inject([]) { |arr, k| arr += raw[k].keys; arr }.uniq.sort
      
      controller_files = []
      model_files      = []
      lib_files        = []
      
      files.each do |file|
        case file
        when /app\/controllers\//
          controller_files << file
        when /app\/models\//
          model_files << file
        when /lib\//
          lib_files << file
        end
      end

      project_name    = File.basename Dir.pwd


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

          if executable_lines.size > 0
            percentage = (exelines.size.to_f / executable_lines.size) * 100
          else
            percentage = 0
          end
          project_coverage[file] = percentage
          
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
            body << "<td><pre>  <span class=\"codeline #{classes * ' '}\">#{Syntax::Convertors::HTML.for_syntax('ruby').convert(line, false)}</span>"
            body << "</td></tr>"
          end
          body << "</table>"
          f.write ERB.new(File.read("#{File.dirname(__FILE__)}/templates/code-page.rhtml")).result(binding)
          puts "Wrote #{outputdir}/#{file.gsub('/', '-')}.html"
        end
      end
      
      
      average_coverage = project_coverage.values.inject(0) { |s, v| s + v } / project_coverage.values.size
      File.open("#{outputdir}/index.html", 'w') do |f|
        f.write ERB.new(File.read("#{File.dirname(__FILE__)}/templates/index.rhtml")).result(binding)
        puts "Wrote #{outputdir}/index.html"
      end
    end
  end
end
