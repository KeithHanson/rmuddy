Gem::Specification.new do |s|
  s.name = %q{RubyInline}
  s.version = "3.6.6"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Davis"]
  s.date = %q{2007-12-27}
  s.default_executable = %q{inline_package}
  s.description = %q{Ruby Inline is an analog to Perl's Inline::C. Out of the box, it allows you to embed C/++ external module code in your ruby script directly. By writing simple builder classes, you can teach how to cope with new languages (fortran, perl, whatever). The code is compiled and run on the fly when needed.}
  s.email = %q{ryand-ruby@zenspider.com}
  s.executables = ["inline_package"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/inline_package", "demo/fastmath.rb", "demo/hello.rb", "example.rb", "example2.rb", "lib/inline.rb", "test/test_inline.rb", "tutorial/example1.rb", "tutorial/example2.rb"]
  s.has_rdoc = true
  s.homepage = %q{    http://rubyforge.org/projects/rubyinline/
}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.requirements = ["A POSIX environment and a compiler for your language."]
  s.rubyforge_project = %q{rubyinline}
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{Ruby Inline is an analog to Perl's Inline::C. Out of the box, it allows you to embed C/++ external module code in your ruby script directly.}
  s.test_files = ["test/test_inline.rb"]

  s.add_dependency(%q<hoe>, [">= 1.4.0"])
end
