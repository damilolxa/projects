#!/usr/bin/env ruby
#----------------------
#File: polly_voices1.rb
#Version: 1.3
#Date: 02/25/2021
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

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

polly = Aws::Polly::Client.new

#An Array to Store the Available Languages
language_codes = Array.new

resp = polly.describe_voices()

puts "List of Polly Voices:"
puts "---------------------"
MyLog.log.info "List of Polly Voices:"
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
  #Add Language Code to List
  paired="#{item.language_name}: #{item.language_code}"
  language_codes.push(paired)
end

#Only Keep the Unique Language Codes
language_codes.uniq!

puts "List of Polly Languages:"
puts "---------------------"
MyLog.log.info "List of Polly Languages:"
MyLog.log.info "---------------------"

language_codes.each do |language|
  puts "#{language}"
  MyLog.log.info "#{language}"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

