#!/usr/bin/env ruby
#----------------------
#File: delete_bucket.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk-s3'
require 'awesome_print'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab3"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
mybucket = "oyinkansola"
#----------------------------------

s3 = Aws::S3::Resource.new(region: 'us-east-1')

puts "Deleting #{mybucket}"
MyLog.log.info "Deleting #{mybucket}"

#List Buckets Before Deletion
puts "Buckets Before Deletion:"
MyLog.log.info "Buckets Before Deletion:"
s3.buckets.each do |item|
  puts "Name:  #{item.name}"
  MyLog.log.info "Name:  #{item.name}"
end

#Delete the Bucket
s3.bucket(mybucket).delete!

puts ""

#List Bucket After Deletion
puts "Buckets After Deletion:"
MyLog.log.info "Buckets After Deletion:"
s3.buckets.each do |item|
  puts "Name:  #{item.name}"
  MyLog.log.info "Name:  #{item.name}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)