#!/usr/bin/env ruby
#----------------------
#File: polly_voices2.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk-polly'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab4"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
language='de-DE'
#----------------------------------

polly = Aws::Polly::Client.new

resp = polly.describe_voices({
  language_code: language, 
})

puts "List of Polly Voices Filtered by #{language} Language Code:"
puts "---------------------"
MyLog.log.info "List of Polly Voices Filtered by #{language} Language Code:"
MyLog.log.info "---------------------"

resp.voices.each do |item|
  puts "VoiceID:  #{item.id}"
  puts "Name:  #{item.name}"
  puts "Gender:  #{item.gender}"
  puts "Language Code:  #{item.language_code}"
  puts "Language Name:  #{item.language_name}"
  puts ""
  MyLog.log.info "VoiceID:  #{item.id}"
  MyLog.log.info "Name:  #{item.name}"
  MyLog.log.info "Gender:  #{item.gender}"
  MyLog.log.info "Language Code:  #{item.language_code}"
  MyLog.log.info "Language Name:  #{item.language_name}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

