require 'rake/testtask'


module Rake
  REDUCE_COMPAT = true
end


task :app do
  require './lib/inports'
end


Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
end


namespace :render do
  task :content do
    Rake::Task['app'].invoke
    SanityCheck.render_as_list './output/xml/techlink-content-only.xml'
  end

  task :all do
    Rake::Task['app'].invoke
    SanityCheck.render_as_list './output/xml/techlink-content.xml'
  end
end


namespace :process do
  task :static do
    system("bundle exec ruby bin/static.rb")
  end


  task :all do
    system("bundle exec ruby bin/all.rb")
  end


  task :content do
    system("bundle exec ruby bin/content.rb")
  end


  task :split_static do
    system("bundle exec ruby bin/split_static.rb")
  end
end


task :inspect, :path, :field, :type do |t, args|
  path = args[:path]
  field = args[:field]
  field_type = args[:type] || 'string'
  system("bundle exec ruby bin/parse_test.rb #{path} #{field} #{field_type}")
end


namespace :lock do
  task :media do
    Rake::Task['app'].invoke

    $r.lock_keys(/^media/) {|k| puts $term.color("Locking #{k}", :green)}
  end
end


namespace :list do
  task :locked do
    Rake::Task['app'].invoke

    $r.lrange('locked-keys', 0, -1).each {|k| puts $term.color("#{k}", :green)}
  end
end


namespace :delete do
  task :lock do
    Rake::Task['app'].invoke

    $r.lrange('locked-keys', 0, -1).each do |k|
      puts $term.color("Removing #{k}", :green)
      $r.del k
    end

    $r.del 'locked-keys'
  end


  namespace :helpers do
    task :output, :section, :silent do |t, args|
      section = args[:section]
      silent = args[:silent] || nil

      Rake::Task['app'].invoke

      unless silent
        $term.agree($term.color("Wipe existing #{section} output?", :red))
      end

      dir = CONFIG['directories']['output'][section]

      puts $term.color("Removing #{dir}", :green)
      FileUtils.remove_dir(dir, true)

      puts $term.color("Recreating fresh #{dir}", :green)
      FileUtils.mkdir(dir)
      FileUtils.touch(dir + '/.gitkeep')
    end
  end


  task :logs, :silent do |t, args|
    Rake::Task['app'].invoke

    silent = args[:silent] || nil

    unless silent
      $term.agree($term.color('Wipe all logs?', :red))
    end

    puts $term.color("Deleting logs", :green)

    FileUtils.rm Dir.glob('./log/*.log')
  end


  task :keys, :silent do |t, args|
    Rake::Task['app'].invoke

    silent = args[:silent] || nil

    unless silent
      $term.agree($term.color('Delete all redis keys?', :red))
    end

    $r.kill_keys { |k| puts $term.color("Deleting #{k}", :yellow) }
  end


  namespace :output do
    task :files, :silent do |t, args|
      Rake::Task['delete:helpers:output'].reenable
      Rake::Task['delete:helpers:output'].invoke('files', args[:silent])
    end

    task :images, :silent do |t, args|
      Rake::Task['delete:helpers:output'].reenable
      Rake::Task['delete:helpers:output'].invoke('images', args[:silent])
    end

    task :static, :silent do |t, args|
      Rake::Task['delete:output:files'].invoke(args[:silent])
      Rake::Task['delete:output:images'].invoke(args[:silent])
    end

    task :xml, :silent do |t, args|
      Rake::Task['delete:helpers:output'].reenable
      Rake::Task['delete:helpers:output'].invoke('xml', args[:silent])
    end

    task :all, :silent do |t, args|
      Rake::Task['delete:output:files'].invoke(args[:silent])
      Rake::Task['delete:output:images'].invoke(args[:silent])
      Rake::Task['delete:output:xml'].invoke(args[:silent])
    end
  end
end


task :flush do
  Rake::Task['delete:keys'].invoke('shh')
  Rake::Task['delete:output:all'].invoke('shh')
  Rake::Task['delete:logs'].invoke('shh')
end


task :scratch, :v do |t, args|
    # $ rake scratch[v]

    Rake::Task['app'].invoke
    args.with_defaults(:v => nil)
    $verbose = args[:v]
    require './scratch'
end
