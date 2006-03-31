namespace 'insurance' do
  
  task :banner do
    puts ''
    puts 'You might want to get a beverage.  This could take a while!'
    puts ''
  end
  
  desc 'Run Insurnace coverage analysis on unit tests'
  task :units => :banner do
    puts 'Analyzing unit suite'
    sh %{railscov test/unit}
  end
  
  desc 'Run Insurnace coverage analysis on functional tests'
  task :functionals => :banner do
    puts 'Analyzing functional suite'
    sh %{railscov test/functional}
  end
  
  desc 'Run Insurnace coverage analysis on integration tests'
  task :integration => :banner do
    puts 'Analyzing integration suite'
    sh %{railscov test/integration}
  end
  
  desc 'Clean up Insurance temporary database'
  task :clean do
    rm_f 'insurance.db'
  end
  
  desc 'Generate the Insurance report'
  task :report do
    sh %{railscov -r}
  end
end

desc 'Run Insurnace coverage analysis'
task :insurance => ['insurance:banner',      'insurance:clean', 
                    'insurance:units',       'insurance:functionals',
                    'insurance:integration', 'insurance:report']