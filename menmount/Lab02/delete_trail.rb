#!/usr/bin/env ruby
#----------------------
#File: delete_trail.rb
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
name="menmounttrail"
#----------------------------------

# Create client in us-east-1
client = Aws::CloudTrail::Client.new(region: 'us-east-1')

begin
  resp = client.delete_trail({
    name: name, # required
  })
  ap resp
  MyLog.log.info resp


  puts 'Successfully deleted CloudTrail ' + name + ' in us-east-1'
  MyLog.log.info 'Successfully deleted CloudTrail ' + name + ' in us-east-1'
  MyLog.log.info resp
rescue StandardError => err
  puts 'Got error trying to delete trail ' + name + ':'
  puts err
  exit 1
end

#Upload work for credit
file=File.new("mylab.log")
assignment_turn_in(file,lab)