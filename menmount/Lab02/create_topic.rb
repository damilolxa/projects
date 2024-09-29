#!/usr/bin/env ruby
#----------------------
#File: create_topic.rb
#Version: 1.3
#Date: 01/24/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-sns'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab2"

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
topicname="menmounttopic"
#----------------------------------

sns = Aws::SNS::Resource.new(region: 'us-east-1')

topic = sns.create_topic(name: topicname)
ap topic
MyLog.log.info topic

puts
puts "Topic ARN: #{topic.arn}"

MyLog.log.info "Topic ARN: #{topic.arn}"

#Upload work for credit
file=File.new("mylab.log")
assignment_turn_in(file,lab)