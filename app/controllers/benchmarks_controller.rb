class BenchmarksController < ApplicationController

  def show
    @num_array = (1..10000).map { rand }
    @char_array = (1..10000).map { rand.to_s }
    if params[:id] == '1'
      @bms = Benchmark.bmbm do |bm|
        bm.report("num_array.dup.sort!") { @num_array.dup.sort! }
        bm.report("num_array.dup.sort! { |x,y| x <=> y }") { @num_array.dup.sort! { |x,y| x <=> y } }
        bm.report("num_array.dup.sort!.reverse!") { @num_array.dup.sort!.reverse! }
        bm.report("num_array.dup.sort! { |x,y| y <=> x }") { @num_array.dup.sort! { |x,y| y <=> x } }
      end
    end
    render layout: false
  end

  def sort
    num_array = (1..1000000).map { rand } 
    @bms = Benchmark.bmbm do |bm|
      bm.report("num_array.sort!") { num_array.dup.sort! } 
      bm.report("num_array.sort! { |x, y| x <=> y }") { num_array.sort! { |x,y| x <=> y } }
      bm.report("num_array.sort!.reverse!") { num_array.sort!.reverse! }
      bm.report("num_array.sort! { |x, y| y <=> x }") { num_array.sort! { |x,y| y <=> x } }
      bm.report("num_array.sort_by! { |x| x }") { num_array.dup.sort_by! { |x| x } }
    end
    render layout: false
  end
  
end
