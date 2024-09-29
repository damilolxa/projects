#!/usr/bin/env ruby
#----------------------
#File: comprehend3.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-comprehend'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab8"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

client = Aws::Comprehend::Client.new(region: 'us-east-1')

inputtxt=File.new("review1.txt").read
resp = client.detect_sentiment({
    text: inputtxt, # required
    language_code: "en", # required, accepts en, es
})

puts "Review1:"
ap resp
MyLog.log.info "Review1 Response: #{resp}"

inputtxt=File.new("review2.txt").read
resp = client.detect_sentiment({
    text: inputtxt, # required
    language_code: "en", # required, accepts en, es
})

puts "Review2:"
ap resp
MyLog.log.info "Review2 Response: #{resp}"

inputtxt=File.new("review3.txt").read
resp = client.detect_sentiment({
    text: inputtxt, # required
    language_code: "en", # required, accepts en, es
})

puts "Review3:"
ap resp
MyLog.log.info "Review3 Response: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)