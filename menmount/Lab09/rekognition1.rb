#!/usr/bin/env ruby
#----------------------
#File: rekognition1.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk'
require 'aws-sdk-rekognition'
require "awesome_print"
require 'fileutils'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab9"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
bucket = 'menmountbucket'
filename = 'cat.jpg'
#----------------------------------

#Upload Image to work on
s3 = Aws::S3::Client.new(region: 'us-east-1')

file = File.new(filename)

#Upload the image object
resp=s3.put_object({
  body: file, 
  bucket: bucket, 
  key: filename, 
})

ap resp
MyLog.log.info resp

client=Aws::Rekognition::Client.new()

resp = client.detect_labels({
  image: { # required
    s3_object: {
      bucket: bucket,
      name: filename
    },
  },
  max_labels: 123,
  min_confidence: 70,
})

ap resp
MyLog.log.info resp.awesome_inspect
MyLog.log.info "\n"
resp.labels.each do |label|
    MyLog.log.info "#{label.name}-#{label.confidence.to_i}\n"
    puts "#{label.name}-#{label.confidence.to_i}\n"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

newname="rekognition_img.jpg"
FileUtils.cp(filename,newname)
#Upload your image for me to see
assignment_turn_in(File.new(newname),lab,newname)
