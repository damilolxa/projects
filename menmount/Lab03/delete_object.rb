#!/usr/bin/env ruby
#----------------------
#File: delete_object.rb
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
#----------------------------------

s3 = Aws::S3::Resource.new(region: 'us-east-1')

puts "Deleting #{myobject} in #{mybucket}"
MyLog.log.info "Deleting #{myobject} in #{mybucket}"

#List Objects before deletion
puts "Objects Before Deletion:"
MyLog.log.info "Objects Before Deletion:"

s3.bucket(mybucket).objects.each do |item|
  puts "Name:  #{item.key}"
  MyLog.log.info "Name:  #{item.key}"
end

# Create the object to retrieve
obj = s3.bucket(mybucket).object(myobject)

# Get the item's content and save it to a file
obj.delete

#List Objects after deletion

puts "Objects After Deletion:"
MyLog.log.info "Objects After Deletion:"
s3.bucket(mybucket).objects.each do |item|
  puts "Name:  #{item.key}"
  MyLog.log.info "Name:  #{item.key}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)