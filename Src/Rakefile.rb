$LOAD_PATH.unshift File.join(File.dirname(__FILE__)) 
require 'rake/testtask'


Rake::TestTask.new do |t|
    t.libs << File.join(File.dirname(__FILE__)) 
    #t.verbose = true
    t.pattern = "unittest/tc_*.rb"
    #t.test_files = FileList['unittest/test*.rb']
    t.warning=true
end

