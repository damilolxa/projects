#!/usr/bin/env ruby
#----------------------
#File: create_alarm.rb
#Version: 1.4
#Date: 01/25/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk-cloudwatch'
require 'aws-sdk-resources'
require 'awesome_print'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab2"

$f1_version="1.4"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
accountnum="767398022705"
bucketname="menmountbucket"
topicname="menmounttopic"
#----------------------------------
arnobj = Aws::ARN.new(partition: 'aws', service: 'sns', region: 'us-east-1', account_id: accountnum, resource: topicname)
topicarn = arnobj.to_s()
puts "Topic ARN: #{topicarn}"
MyLog.log.info"Topic ARN: #{topicarn}"

cw = Aws::CloudWatch::Client.new(region: 'us-east-1')

alarm_name = "TooManyObjectsInBucket"

resp=cw.put_metric_alarm({
  alarm_name: alarm_name, 
  alarm_description: "Alarm whenever an average of more than one object exists in the specified Amazon S3 bucket for more than one day.",
  alarm_actions: [ topicarn ],
  actions_enabled: true, # Do not take any actions if the alarm's state changes.
  metric_name: "NumberOfObjects",  
  namespace: "AWS/S3",   
  statistic: "Average",  
  dimensions: [
    {
      name: "BucketName",
      value: bucketname
    },
    {
      name: "StorageType",
      value: "AllStorageTypes"
    }
  ], 
  period: 86400, # Daily (24 hours * 60 minutes * 60 seconds = 86400 seconds).
  unit: "Count", 
  evaluation_periods: 1, # More than one day.
  threshold: 1, # One object. 
  comparison_operator: "GreaterThanThreshold"
})

ap resp
MyLog.log.info "Response: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)