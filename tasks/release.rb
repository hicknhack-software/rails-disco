FRAMEWORKS = %w( active_event active_domain active_projection drailties )

root    = File.expand_path('../../', __FILE__)
version = File.read("#{root}/RAILS-DISCO_VERSION").strip
tag     = "v#{version}"

directory "pkg"

(FRAMEWORKS + ['rails-disco']).each do |framework|
  namespace framework do
    gem     = "pkg/#{framework}-#{version}.gem"
    gemspec = "#{framework}.gemspec"

    task :clean do
      rm_f gem
    end

    task :update_version_rb do
      glob = root.dup
      glob << "/#{framework}/lib/*" unless framework == "rails-disco"
      glob << "/version.rb"

      file = Dir[glob].first
      ruby = File.read(file)

      if framework == "rails-disco" || framework == "drailties"
        major, minor, tiny, pre = version.split('.')
        pre = pre ? pre.inspect : "nil"

        ruby.gsub!(/^(\s*)MAJOR(\s*)= .*?$/, "\\1MAJOR = #{major}")
        raise "Could not insert MAJOR in #{file}" unless $1

        ruby.gsub!(/^(\s*)MINOR(\s*)= .*?$/, "\\1MINOR = #{minor}")
        raise "Could not insert MINOR in #{file}" unless $1

        ruby.gsub!(/^(\s*)TINY(\s*)= .*?$/, "\\1TINY  = #{tiny}")
        raise "Could not insert TINY in #{file}" unless $1

        ruby.gsub!(/^(\s*)PRE(\s*)= .*?$/, "\\1PRE   = #{pre}")
        raise "Could not insert PRE in #{file}" unless $1
      else
        ruby.gsub!(/^(\s*)Gem::Version\.new .*?$/, "\\1Gem::Version.new \'#{version}\'")
        raise "Could not insert Gem::Version in #{file}" unless $1
      end

      File.open(file, 'w') { |f| f.write ruby }
    end

    task gem => %w(update_version_rb pkg) do
      cmd = ""
      cmd << "cd #{framework} && " unless framework == "rails-disco"
      cmd << "gem build #{gemspec} && mv #{framework}-#{version}.gem #{root}/pkg/"
      sh cmd
    end

    task :build => [:clean, gem]
    task :install => :build do
      sh "gem install #{gem}"
    end

    task :prep_release => [:ensure_clean_state, :build]

    task :push => :build do
      sh "gem push #{gem}"
    end
  end
end

namespace :changelog do
  task :release_date do
    FRAMEWORKS.each do |fw|
      require 'date'
      replace = '\1(' + Date.today.strftime('%B %d, %Y') + ')'
      fname = File.join fw, 'CHANGELOG.md'

      contents = File.read(fname).sub(/^([^(]*)\(unreleased\)/, replace)
      File.open(fname, 'wb') { |f| f.write contents }
    end
  end

  task :release_summary do
    FRAMEWORKS.each do |fw|
      puts "## #{fw}"
      fname    = File.join fw, 'CHANGELOG.md'
      contents = File.readlines fname
      contents.shift
      changes = []
      changes << contents.shift until contents.first =~ /^\*Rails \d+\.\d+\.\d+/
      puts changes.reject { |change| change.strip.empty? }.join
      puts
    end
  end
end

namespace :all do
  task :build   => FRAMEWORKS.map { |f| "#{f}:build"   } + ['rails-disco:build']
  task :install => FRAMEWORKS.map { |f| "#{f}:install" } + ['rails-disco:install']
  task :push    => FRAMEWORKS.map { |f| "#{f}:push"    } + ['rails-disco:push']

  task :ensure_clean_state do
    unless `git status -s | grep -v RAILS-DISCO_VERSION`.strip.empty?
      abort "[ABORTING] `git status` reports a dirty tree. Make sure all changes are committed"
    end

    unless ENV['SKIP_TAG'] || `git tag | grep #{tag}`.strip.empty?
      abort "[ABORTING] `git tag` shows that #{tag} already exists. Has this version already\n"\
            "           been released? Git tagging can be skipped by setting SKIP_TAG=1"
    end
  end

  task :commit do
    File.open('pkg/commit_message.txt', 'w') do |f|
      f.puts "# Preparing for #{version} release\n"
      f.puts
      f.puts "# UNCOMMENT THE LINE ABOVE TO APPROVE THIS COMMIT"
    end

    sh "git add . && git commit --verbose --template=pkg/commit_message.txt"
    rm_f "pkg/commit_message.txt"
  end

  task :tag do
    sh "git tag #{tag}"
    sh "git push --tags"
  end

  task :release => %w(ensure_clean_state build commit tag push)
end
