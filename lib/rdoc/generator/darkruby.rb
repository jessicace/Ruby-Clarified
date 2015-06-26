# -*- mode: ruby; ruby-indent-level: 2; tab-width: 2 -*-

require 'erb'
require 'fileutils'
require 'pathname'
require 'rdoc/generator/markup'

class RDoc::Generator::Darkruby
  RDoc::RDoc.add_generator self
  include ERB::Util

  ##
  # Path to this file's parent directory. Used to find templates and other
  # resources.

  GENERATOR_DIR = File.join 'rdoc', 'generator'

  ##
  # The path to generate files into, combined with <tt>--op</tt> from the
  # options for a full path.

  attr_reader :base_dir

  ##
  # Classes and modules to be used by this generator, not necessarily
  # displayed.  See also #modsort

  attr_reader :classes

  ##
  # No files will be written when dry_run is true.

  attr_accessor :dry_run

  ##
  # When false the generate methods return a String instead of writing to a
  # file.  The default is true.

  attr_accessor :file_output

  ##
  # Files to be displayed by this generator

  attr_reader :files

  ##
  # The JSON index generator for this Darkfish generator

  attr_reader :json_index

  ##
  # Stores current class directory, for generating nested method files.
  attr_reader :klass_dir
  
  ##
  # Methods to be displayed by this generator
  attr_reader :methods

  ##
  # Sorted list of classes and modules to be displayed by this generator
  attr_reader :modsort

  ##
  # The RDoc::Store that is the source of the generated content

  attr_reader :store

  ##
  # The directory where the template files live

  attr_reader :template_dir # :nodoc:

  ##
  # The output directory
  attr_reader :outputdir

  ##
  # Initialize a few instance variables before we start

  def initialize store, options
    @store   = store
    @options = options

    @base_dir       = Pathname.pwd.expand_path
    @dry_run        = @options.dry_run
    @file_output    = true
    @template_dir   = Pathname.new options.template_dir
    @template_cache = {}

    @classes = nil
    @context = nil
    @modsort = nil

    @json_index = RDoc::Generator::JsonIndex.new self, options
  end

  ##
  # Output progress information if debugging is enabled

  def debug_msg *msg
    return unless $DEBUG_RDOC
    $stderr.puts(*msg)
  end


  ##
  # Directory where generated class HTML files live relative to the output
  # dir.

  def class_dir
    nil
  end

  ##
  # Directory where generated class HTML files live relative to the output
  # dir.

  def file_dir
    nil
  end

  ##
  # Create the directories the generated docs will live in if they don't
  # already exist.

  def gen_sub_directories
    @outputdir.mkpath
  end

  ##
  # Build the initial indices and output objects based on an array of TopLevel
  # objects containing the extracted information.

  def generate
    setup

    generate_class_files
    @json_index.generate
    @json_index.generate_gzipped

  rescue => e
    debug_msg "%s: %s\n  %s" % [
      e.class.name, e.message, e.backtrace.join("\n  ")
    ]

    raise
  end
  
  ##
  # Return a list of the documented modules sorted by salience first, then
  # by name.

  def get_sorted_module_list classes
    classes.select do |klass|
      klass.display?
    end.sort
  end
  
  ##
  # Generates a class file for +klass+

  def generate_class klass, template_file = nil
    setup

    # The class template file is retrieved from the template directory.
    # Extract to method?
    template_file ||= @template_dir + 'class.html.erb'

    # Debug output.
    debug_msg "  working on %s (%s)" % [klass.full_name, klass.path]

    # Output file.
    @klass_dir = Pathname.new(klass.full_name).expand_path @outputdir
    
    @klass_dir.mkpath
    out_file   = @klass_dir + klass.path

    @title = "#{klass.type} #{klass.full_name} - #{@options.title}"

    debug_msg "  rendering #{out_file}"
    render_template template_file, out_file do |io| binding end
  end

  def generate_method method, template_file = nil
    setup

    template_file ||= @template_dir + 'method.html.erb'

    path = "_" + method.aref.gsub('-', '_') + ".html"
    out_file = @klass_dir + path
    
    @title = method.full_name

    debug_msg "  rendering #{out_file}"
    render_template template_file, out_file do |io| binding end
    
  end
  
  def generate_method_files klass
    setup

    template_file = @template_dir + 'method.html.erb'
    template_file = @template_dir + 'methodpage.html.erb' unless
      template_file.exist?
    return unless template_file.exist?

    current = nil

    klass.method_list.each do |method|
      current = method
      generate_method method, template_file
    end

  rescue => e
    error = RDoc::Error.new \
      "error generating #{current.path}: #{e.message} (#{e.class})"  
    error.set_backtrace e.backtrace
    raise error    
  end
  
  ##
  # Generate a documentation file for each class and module
  
  def generate_class_files
    setup

    template_file = @template_dir + 'class.html.erb'
    template_file = @template_dir + 'classpage.html.erb' unless
      template_file.exist?
    return unless template_file.exist?

    debug_msg "Generating class documentation in #{@outputdir}"

    current = nil

    @classes.each do |klass|
      current = klass
      generate_class klass, template_file
      generate_method_files klass
    end
    
  rescue => e
    error = RDoc::Error.new \
      "error generating #{current.path}: #{e.message} (#{e.class})"
    error.set_backtrace e.backtrace

    raise error
  end

  ##
  # Prepares for generation of output from the current directory

  def setup
    return if instance_variable_defined? :@outputdir

    @outputdir = Pathname.new(@options.op_dir).expand_path @base_dir

    return unless @store

    @classes = @store.all_classes_and_modules.sort
    @modsort = get_sorted_module_list @classes
  end

  
  ##
  # Creates a template from its components and the +body_file+.

  def assemble_template body_file
    body_file.read
  end

  
  ##
  # Load and render the erb template in the given +template_file+ and write
  # it out to +out_file+.
  #
  # Both +template_file+ and +out_file+ should be Pathname-like objects.
  #
  # An io will be yielded which must be captured by binding in the caller.

  def render_template template_file, out_file = nil # :yield: io
    io_output = out_file && !@dry_run && @file_output
    erb_klass = io_output ? RDoc::ERBIO : ERB

    template = template_for template_file, true, erb_klass

    if io_output then
      debug_msg "Outputting to %s" % [out_file.expand_path]

      out_file.dirname.mkpath
      out_file.open 'w', 0644 do |io|
        io.set_encoding @options.encoding if Object.const_defined? :Encoding

        @context = yield io

        template_result template, @context, template_file
      end
    else
      @context = yield nil

      output = template_result template, @context, template_file

      debug_msg "  would have written %d characters to %s" % [
        output.length, out_file.expand_path
      ] if @dry_run

      output
    end
  end

  ##
  # Creates the result for +template+ with +context+.  If an error is raised a
  # Pathname +template_file+ will indicate the file where the error occurred.

  def template_result template, context, template_file
    template.filename = template_file.to_s
    template.result context
  rescue NoMethodError => e
    raise RDoc::Error, "Error while evaluating %s: %s" % [
      template_file.expand_path,
      e.message,
    ], e.backtrace
  end

  ##
  # Retrieves a cache template for +file+, if present, or fills the cache.

  def template_for file, page = true, klass = ERB
    template = @template_cache[file]

    return template if template

    if page then
      template = assemble_template file
      erbout = 'io'
    else
      template = file.read
      template = template.encode @options.encoding if
        Object.const_defined? :Encoding

      file_var = File.basename(file).sub(/\..*/, '')

      erbout = "_erbout_#{file_var}"
    end

    template = klass.new template, nil, '<>', erbout
    @template_cache[file] = template
    template
  end

end

