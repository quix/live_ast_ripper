require_relative 'devel/levitate'

Levitate.new "live_ast_ripper" do |s|
  s.developers << ["James M. Lawrence", "quixoticsycophant@gmail.com"]
  s.username = "quix"
  s.required_ruby_version = ">= 1.9.2"
  s.camel_name = "LiveASTRipper"
  s.description = s.summary
end

task :test do
  puts "Testing is done with LiveAST test suite."
end

task :default => :test
