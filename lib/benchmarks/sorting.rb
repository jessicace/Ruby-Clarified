##
# ==== Benchmark Data
# 
#     require 'benchmark'
#     num_array = (1..1000000).map { rand } 
#
#     Benchmark.bmbm do |bm|
#       bm.report("num_array.dup.sort!") { num_array.dup.sort! } 
#       bm.report("num_array.dup.sort!") { |x, y| x <=> y }") { num_array.sort! { |x,y| x <=> y } }
#       bm.report("num_array.dup.sort!.reverse!") { num_array.sort!.reverse! }
#       bm.report("num_array.dup.sort!") { |x, y| y <=> x } { num_array.sort! { |x,y| y <=> x } }
#     end

=begin
#   require 'benchmark'
#
#     a = (1..100000).map { rand(100000) }
#
Benchmark.bm(10) do |b|
 *       b.report("Sort")    { a.sort }
 *       b.report("Sort by") { a.sort_by { |a| a } }
 *     end
 *
 *  <em>produces:</em>
 *
 *     user     system      total        real
 *     Sort        0.180000   0.000000   0.180000 (  0.175469)
 *     Sort by     1.980000   0.040000   2.020000 (  2.013586)
=end
