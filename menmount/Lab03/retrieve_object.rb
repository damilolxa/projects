#!/usr/bin/env ruby
#----------------------
#File: retrieve_object.rb
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
mybucket = "anikebucket"
myobject = "pink56.jpg"
savefile = "download.jpg"
#----------------------------------

s3 = Aws::S3::Resource.new(region: 'us-east-1')

# Create the object to retrieve
obj = s3.bucket(mybucket).object(myobject)

# Method1:
# Get the item's content and save it to a file
puts "Method 1:"
MyLog.log.info "Method 1:"
puts "Retrieving #{myobject} from #{mybucket} bucket!"
MyLog.log.info "Retrieving #{myobject} from #{mybucket} bucket!"
resp=obj.get(response_target: savefile)

puts "Response: #{resp}"
MyLog.log.info "Response: #{resp}"

puts "Object saved to #{savefile}"
MyLog.log.info "Object saved to #{savefile}"

# Method2:
# Create a presigned URL to give access to the object
puts "Method 2:"
MyLog.log.info "Method 2:"
puts "Generating URL for #{myobject} in #{mybucket} bucket!"
MyLog.log.info "Generating URL for #{myobject} in #{mybucket} bucket!"
url=obj.presigned_url(:get, expires_in: 604800)
puts "URL:   #{url}"
MyLog.log.info "URL:   #{url}"

puts "URL is good for 7 days!"
MyLog.log.info "URL is good for 7 days!"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)