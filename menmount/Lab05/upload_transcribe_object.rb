#!/usr/bin/env ruby
#----------------------
#File: upload_transcribe_object.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-s3'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab5"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
filename = 'polly_text.mp3'
bucket = 'menmountbucket'
#----------------------------------

client = Aws::S3::Client.new(region: 'us-east-1')

file = File.new(filename)

MyLog.log.info "Uploading #{filename}"
puts "Uploading #{filename}"
#Create the first object to upload
resp=client.put_object({
  body: file, 
  bucket: bucket, 
  key: filename, 
})

print "Response: "
ap resp
MyLog.log.info "Response: #{resp}"

puts "Listing of the objects in #{bucket} bucket:"
MyLog.log.info "Listing of the objects in #{bucket} bucket:"

client.list_objects({bucket: bucket,}).contents.each do |item|
  puts "Name:  #{item.key}"
  MyLog.log.info "Name:  #{item.key}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)