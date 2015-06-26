class BenchmarksController < ApplicationController

  def sort_bang
    num_array = (1..10000).map { rand }
    char_array = (1..10000).map { rand.to_s }
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
    render layout: false
  end

  def sort
    a = [ "d", "a", "e", "c", "b" ]
    @bms = Benchmark.bmbm do |bm|
      bm.report("a.sort") { a.dup.sort }
      bm.report("a.sort { |x,y| x <=> y }") { a.dup.sort { |x,y| x <=> y } }
    end
    render layout: false
  end
end

