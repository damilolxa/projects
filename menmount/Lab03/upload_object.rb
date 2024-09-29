#!/usr/bin/env ruby
#----------------------
#File: upload_object.rb
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

STDOUT.sync = true

#This is used to set the path for where your work will be stored for grading!
lab="Lab3"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
filename1 = 'green56.jfif'
filename2 = 'pink56.jpg'
bucket = 'anikebucket'

metadata_tag1="type" #The name of your metadata tag1. Example: "Type"
metadata1="image"         #The value of your metadata tag1 Example: "Image"
metadata_tag2="pink" #The name of your metadata tag2 Example: "Format"
metadata2="image"         #The value of your metadata tag2 Example: "PNG"
#----------------------------------

client = Aws::S3::Client.new(region: 'us-east-1')

file1 = File.new(filename1)
file2 = File.new(filename2)

#Create the first object to upload
puts "Creating new object #{filename1} in bucket #{bucket}!"
MyLog.log.info "Creating new object #{filename1} in bucket #{bucket}!"
resp=client.put_object({
  body: file1, 
  bucket: bucket, 
  key: filename1, 
})

puts "Response:"
ap resp
MyLog.log.info "Response: #{resp}!"

#Create the second object to upload
puts "Creating new object #{filename2}, with metadata, in bucket #{bucket}!"
MyLog.log.info "Creating new object #{filename2}, with metadata, in bucket #{bucket}!"
resp=client.put_object({
  body: file2, 
  bucket: bucket, 
  key: filename2, 
  metadata: {
    metadata_tag1 => metadata1, 
    metadata_tag2 => metadata2, 
  },
})
puts "Response:"
ap resp
MyLog.log.info "Response: #{resp}!"

MyLog.log.info "List of Objects:"
puts "List of Objects:"
client.list_objects({bucket: bucket,}).contents.each do |item|
  sleep 1
  puts "Name:  #{item.key}"
  MyLog.log.info "Name:  #{item.key}"
  
  puts "Metadata: #{client.head_object({bucket: bucket, key: item.key,}).metadata}"
  MyLog.log.info "Metadata: #{client.head_object({bucket: bucket, key: item.key,}).metadata}"
end


#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)