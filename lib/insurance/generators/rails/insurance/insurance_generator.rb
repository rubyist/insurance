class InsuranceGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options={})
    super
  end
  
  def manifest
    record do |m|
      m.directory 'lib/tasks'
      m.template 'insurance.rake', File.join('lib', 'tasks', 'insurance.rake')
    end
  end
end
