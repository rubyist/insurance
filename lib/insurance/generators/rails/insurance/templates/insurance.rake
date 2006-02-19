desc 'Run Insurnace coverage analysis'
task :insurance => [ :prepare_test_database ] do
  puts
  puts 'You may want to get a beverage while this runs.  It could take a while!'
  puts
  system 'railscov'
end
