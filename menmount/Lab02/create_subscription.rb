#!/usr/bin/env ruby
#----------------------
#File: create_subscription.rb
#Version: 1.4
#Date: 01/25/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-sns'
require 'aws-sdk-resources'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab2"

$f1_version="1.4"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
accountnum='767398022705'
myemail="dami.oja05@gmail.com"
topicname="menmounttopic"
#----------------------------------
arnobj = Aws::ARN.new(partition: 'aws', service: 'sns', region: 'us-east-1', account_id: accountnum, resource: topicname)
topicarn = arnobj.to_s()
puts "Topic ARN: #{topicarn}"
MyLog.log.info"Topic ARN: #{topicarn}"

sns = Aws::SNS::Resource.new(region: 'us-east-1')
topic = sns.topic(topicarn)
MyLog.log.info "Creating Subscription to Topic ARN: #{topicarn}"
sub = topic.subscribe({
protocol: 'email',
endpoint: myemail
})

ap sub
MyLog.log.info sub

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)
