# frozen_string_literal: true

require 'benchmark/ips'

def test_array
  Array.new(100) { rand 1000 }
end

def insertsort!(ary)
  (1..(ary.length - 1)).each do |i|
    value = ary[i]
    j = i - 1
    while j >= 0 && ary[j] > value
      ary[j + 1] = ary[j]
      j -= 1
    end
    ary[j + 1] = value
  end
end

def insertsort(ary)
  sorted = ary.dup
  insertsort! sorted
  sorted
end

def quicksort!(ary)
  return [] if ary.empty?
  pivot = ary.delete_at(ary.size / 2)
  left, right = ary.partition(&pivot.method(:>))
  [*quicksort!(left), pivot, *quicksort!(right)]
end

def quicksort(ary)
  sorted = ary.dup
  quicksort! sorted
  sorted
end

# rubocop:disable Metrics/BlockLength
# this benchmarking block is supposed to be exceptionally long
Benchmark.ips do |bm|
  bm.report('Array#each_with_object') do
    ary = test_array.each_with_object([]) do |x, memo|
      next memo.push x if memo.empty?
      memo.first < x ? memo.unshift(x) : memo.push(x)
      memo
    end
    ary.first 4
  end
  bm.report('Array#delete#max') do
    ary = test_array
    (0...4).map { ary.delete ary.max }
  end
  bm.report('Array#sort#reverse#first') { test_array.sort.reverse.first 4 }
  bm.report('Array#sort!#reverse#first') do
    ary = test_array
    ary.sort!
    ary.reverse.first 4
  end
  bm.report('Array#sort#reverse#slice') { test_array.sort.reverse[0...4] }
  bm.report('Array#sort!#reverse#slice') do
    ary = test_array
    ary.sort!
    ary.reverse[0...4]
  end
  bm.report('Array#sort{block}') { test_array.sort { |a, b| b <=> a }.first 4 }
  bm.report('Array#sort!{block}') do
    ary = test_array
    ary.sort! { |a, b| b <=> a }
    ary.first 4
  end
  bm.report('#insertsort') { insertsort(test_array).reverse.first 4 }
  bm.report('#insertsort!') do
    ary = test_array
    insertsort! ary
    ary.reverse.first 4
  end
  bm.report('#quicksort') { quicksort(test_array).reverse.first 4 }
  bm.report('#quicksort!') do
    ary = test_array
    quicksort! ary
    ary.reverse.first 4
  end

  bm.compare!
end
