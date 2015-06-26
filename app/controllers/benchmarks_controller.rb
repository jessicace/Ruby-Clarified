class BenchmarksController < ApplicationController

  def sort
    num_array = (1..10000).map { rand }
    char_array = (1..10000).map { rand.to_s }
    case params[:id]
    when 'sort_bang'
      @bms = Benchmark.bmbm do |bm|
        bm.report("num_array.sort!") { num_array.dup.sort! }
        bm.report("num_array.sort! { |x,y| x <=> y }") { num_array.dup.sort! { |x,y| x <=> y } }
        bm.report("num_array.sort!.reverse!") { num_array.dup.sort!.reverse! }
        bm.report("num_array.sort! { |x,y| y <=> x }") { num_array.dup.sort! { |x,y| y <=> x } }
      end
      @bms2 = Benchmark.bmbm do |bm|
        bm.report("char_array.sort!") { char_array.dup.sort! }
        bm.report("char_array.sort! { |x,y| x <=> y }") { char_array.dup.sort! { |x,y| x <=> y } }
      end
    when 'sort'
      @bms = Benchmark.bmbm do |bm|
        bm.report("num_array.dup.sort!") { @num_array.dup.sort! }
        bm.report("num_array.dup.sort! { |x,y| x <=> y }") { @num_array.dup.sort! { |x,y| x <=> y } }
        bm.report("num_array.dup.sort!.reverse!") { @num_array.dup.sort!.reverse! }
        bm.report("num_array.dup.sort! { |x,y| y <=> x }") { @num_array.dup.sort! { |x,y| y <=> x } }
      end
    when 'sort_by'
      @bms = Benchmark.bmbm do |bm|
        bm.report("num_array.dup.sort!") { @num_array.dup.sort! }
        bm.report("num_array.dup.sort! { |x,y| x <=> y }") { @num_array.dup.sort! { |x,y| x <=> y } }
        bm.report("num_array.dup.sort!.reverse!") { @num_array.dup.sort!.reverse! }
        bm.report("num_array.dup.sort! { |x,y| y <=> x }") { @num_array.dup.sort! { |x,y| y <=> x } }
      end
    end
    render layout: false
  end
  
end

