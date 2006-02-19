require 'erb'
require 'syntax'
require 'syntax/convertors/html'

module Insurance
  class Formatter
    include ERB::Util
    
    def self.run(filelist)
      files = filelist.keys.sort

      project_name    = File.basename Dir.pwd

      File.open("insurance/index.html", 'w') do |f|
        f.write ERB.new(File.read("#{File.dirname(__FILE__)}/templates/index.rhtml")).result(binding)
        puts "Wrote insurance/index.html"
      end

      filelist.each do |file, sf|
        sf.post_analyze!

        file_under_test = sf.name
        percentage      = sf.coverage_percent

        File.open("insurance/#{sf.name.gsub('/', '-')}.html", 'w') do |f|
          contents = File.open(sf.name, 'r').readlines
          body = "<pre class=\"ruby\">\n"
          contents.each_with_index do |line, num|
            unless sf.lines.include?(num + 1)
              body << "#{'%3s' % (num + 1).to_s}  <span class=\"unhit\">#{Syntax::Convertors::HTML.for_syntax('ruby').convert(line.chomp, false)}</span>\n"
            else
              body << "#{'%3s' % (num + 1).to_s}  #{Syntax::Convertors::HTML.for_syntax('ruby').convert(line, false)}"
            end
          end
          body << "</pre>"
          f.write ERB.new(File.read("#{File.dirname(__FILE__)}/templates/code-page.rhtml")).result(binding)
          puts "Wrote insurance/#{sf.name.gsub('/', '-')}.html"
        end
      end
    end
  end
end
