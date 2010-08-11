#!/usr/bin/env ruby
require 'rubygems'
require 'bio'

ff = Bio::FlatFile.new(Bio::FastaFormat, ARGF)
 
# Iterates over each entry. the variable "entry" is a 
# Bio::FastaFormat object:
lens=[]
total_len=0

ff.each do |entry|
  #puts entry.methods.join("\n")
  x = entry.seq.length
  lens << x
  total_len = total_len + x
end

sorted = lens.sort

puts sorted

n50_len = total_len / 2

acc = 0
n50 = 0
sorted.each do |x| 
  acc = acc + x
  if acc > n50_len then
    n50 = x
    break
  end
end

puts "Total len = #{total_len}"
puts "N50 = #{n50}"

