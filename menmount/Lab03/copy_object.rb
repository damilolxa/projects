#!/usr/bin/env ruby
#----------------------
#File: copy_object.rb
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
from_bucket = 'anikebucket'
to_bucket = 'oyinkansola'
obj_key = 'pink56.jpg'
#----------------------------------

s3 = Aws::S3::Client.new(region: 'us-east-1')
resp=s3.copy_object(bucket: to_bucket,copy_source: "#{from_bucket}/#{obj_key}",key: obj_key)

puts "Copying #{obj_key} from #{from_bucket} bucket to #{to_bucket} bucket!"
MyLog.log.info "Copying #{obj_key} from #{from_bucket} bucket to #{to_bucket} bucket!"

puts "Response: #{resp}"
MyLog.log.info "Response: #{resp}"


puts "Objects in To Bucket (#{to_bucket}):"
MyLog.log.info "Objects in To Bucket (#{to_bucket}):"
s3.list_objects({bucket: to_bucket,}).contents.each do |item|
  puts "  Name:  #{item.key}"
  MyLog.log.info "  Name:  #{item.key}"
end
puts ""
puts "Objects in From Bucket (#{from_bucket}):"
MyLog.log.info "Objects in From Bucket (#{from_bucket}):"
s3.list_objects({bucket: from_bucket,}).contents.each do |item|
  puts "  Name:  #{item.key}"
  MyLog.log.info "  Name:  #{item.key}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)