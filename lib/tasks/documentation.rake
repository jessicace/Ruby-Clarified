require 'rdoc/task'
require 'rails/api/task'

class RDocTaskWithoutDescriptions < RDoc::Task
    include ::Rake::DSL

    def define
      task rdoc_task_name

      task rerdoc_task_name => [clobber_task_name, rdoc_task_name]

      task clobber_task_name do
        rm_r rdoc_dir rescue nil
      end

      task :clobber => [clobber_task_name]

      directory @rdoc_dir
      task rdoc_task_name => [rdoc_target]
      file rdoc_target => @rdoc_files + [Rake.application.rakefile] do
        rm_r @rdoc_dir rescue nil
        @before_running_rdoc.call if @before_running_rdoc
        args = option_list + @rdoc_files
        if @external
          argstring = args.join(' ')
          sh %{ruby -Ivendor vendor/rd #{argstring}}
        else
          require 'rdoc/rdoc'
          RDoc::RDoc.new.document(args)
        end
      end
      self
    end
end

  namespace :doc do
    RDocTaskWithoutDescriptions.new(rdoc: 'source',
                                    clobber_rdoc: 'source:clean',
                                    rerdoc: 'source:force'
                                   ) do |rdoc|
      rdoc.rdoc_dir = 'app/views/sources'
      rdoc.generator = 'darkfish'
      rdoc.template = 'darkruby'
      rdoc.title    = ENV['title'] || "Rails Application Documentation"
      rdoc.options << '--line-numbers'
      rdoc.options << '--charset' << 'utf-8'
      rdoc.rdoc_files.include('README.rdoc')
      rdoc.rdoc_files.include('lib/source/*.c')
    end
    Rake::Task['doc:source'].comment = "Generate docs for the app -- also available doc:rails, doc:guides (options: TEMPLATE=/rdoc-template.rb, TITLE=\"Custom Title\")"

  end


