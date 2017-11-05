task :default => :transform

task :html => %W[index.html]

task :transform do
  sh "pandoc -s -t revealjs -o index.html Basis.md -V theme=serif --slide-level 2"
end

