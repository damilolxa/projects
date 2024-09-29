#!/usr/bin/env ruby
#----------------------
#File: describe_trails.rb
#Version: 1.3
#Date: 01/24/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-cloudtrail'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab2"

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

# Create client in us-east-1
client = Aws::CloudTrail::Client.new(region: 'us-east-1')

resp = client.describe_trails({})
ap resp
MyLog.log.info resp

puts
puts "Found #{resp.trail_list.count} trail(s) in us-east-1:"
MyLog.log.info "Found #{resp.trail_list.count} trail(s) in us-east-1:"
puts

resp.trail_list.each do |trail|
  puts 'Name:           ' + trail.name
  puts 'S3 bucket name: ' + trail.s3_bucket_name
  puts
  MyLog.log.info "Name:           #{trail.name}"
  MyLog.log.info "S3 bucket name: #{trail.s3_bucket_name}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)
