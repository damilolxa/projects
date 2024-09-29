#!/usr/bin/env ruby
#----------------------
#File: create_bucket.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk-s3'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab3"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
bucketname1='anikebucket'
bucketname2='oyinkansola'
#----------------------------------

s3 = Aws::S3::Resource.new(region: 'us-east-1')

puts "Creating new bucket: #{bucketname1}!"
MyLog.log.info "Creating new bucket: #{bucketname1}!"
resp1=s3.create_bucket(bucket: bucketname1)
puts "Response: #{resp1}!"
MyLog.log.info "Response: #{resp1}!"

puts "Creating new bucket: #{bucketname2}!"
MyLog.log.info "Creating new bucket: #{bucketname2}!"
resp2=s3.create_bucket(bucket: bucketname2)
puts "Response: #{resp2}!"
MyLog.log.info "Response: #{resp2}!"

puts "Buckets:"
MyLog.log.info "Buckets:"
s3.buckets.each do |b|
  puts "  #{b.name}"
  MyLog.log.info "  #{b.name}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)