#!/usr/bin/env ruby
#----------------------
#File: lookup_events.rb
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

def show_event(event)
  puts 'Event name:   ' + event.event_name.to_s
  puts 'Event ID:     ' + event.event_id.to_s
  puts "Event time:   "+event.event_time.to_s
  puts "User name:    "+event.username.to_s

  puts 'Resources:'
  MyLog.log.info 'Event name:   ' + event.event_name.to_s
  MyLog.log.info 'Event ID:     ' + event.event_id.to_s
  MyLog.log.info "Event time:   "+event.event_time.to_s
  MyLog.log.info 'User name:    ' + event.username.to_s
  MyLog.log.info 'Resources:'

  event.resources.each do |r|
    puts '  Name:       ' + r.resource_name
    puts '  Type:       ' + r.resource_type
    puts ''
    MyLog.log.info '  Name:       ' + r.resource_name
    MyLog.log.info '  Type:       ' + r.resource_type
  end
end

# Create client in us-west-2
client = Aws::CloudTrail::Client.new(region: 'us-east-1')

resp = client.lookup_events()

ap resp
MyLog.log.info resp

puts
puts "Found #{resp.events.count} events in us-east-1:"
puts

MyLog.log.info "Found #{resp.events.count} events in us-east-1:"

resp.events.each do |e|
  show_event(e)
end

#Upload work for credit
file=File.new("mylab.log")
assignment_turn_in(file,lab)