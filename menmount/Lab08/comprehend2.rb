#!/usr/bin/env ruby
#----------------------
#File: comprehend2.rb
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

inputtxt=File.new("email.txt").read
resp = client.detect_entities({
    text: inputtxt, # required
    language_code: "en", # required, accepts en, es
})

ap resp
MyLog.log.info "Entities Response: #{resp}"

resp = client.detect_key_phrases({
    text: inputtxt, # required
    language_code: "en", # required, accepts en, es
})

ap resp
MyLog.log.info "Key Phrases Response: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)