#!/usr/bin/env ruby
#----------------------
#File: show_alarms.rb
#Version: 1.3
#Date: 01/24/2021
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-cloudwatch'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab2"

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

client = Aws::CloudWatch::Client.new(region: 'us-east-1')

# use  client.describe_alarms({alarm_names: ['Name1', 'Name2']})
# to get information about alarms Name1 and Name2
resp = client.describe_alarms
ap resp
MyLog.log.info resp

resp.metric_alarms.each do |alarm|
  puts 'Name:           ' + alarm.alarm_name
  puts 'State:          ' + alarm.state_value
  puts '  reason:       ' + alarm.state_reason
  puts 'Metric:         ' + alarm.metric_name
  puts 'Namespace:      ' + alarm.namespace
  puts 'Statistic:      ' + alarm.statistic
  puts 'Dimensions (' + alarm.dimensions.length.to_s + '):'
  
  MyLog.log.info 'Name:           ' + alarm.alarm_name
  MyLog.log.info 'State:          ' + alarm.state_value
  MyLog.log.info '  reason:       ' + alarm.state_reason
  MyLog.log.info 'Metric:         ' + alarm.metric_name
  MyLog.log.info 'Namespace:      ' + alarm.namespace
  MyLog.log.info 'Statistic:      ' + alarm.statistic
  MyLog.log.info 'Dimensions (' + alarm.dimensions.length.to_s + '):'
  
  alarm.dimensions.each do |d|
    puts '  Name:         ' + d.name
    puts '  Value:        ' + d.value
    MyLog.log.info '  Name:         ' + d.name
    MyLog.log.info '  Value:        ' + d.value
  end

  puts 'Period:         ' + alarm.period.to_s
  puts 'Unit:           ' + alarm.unit.to_s
  puts 'Eval periods:   ' + alarm.evaluation_periods.to_s
  puts 'Threshold:      ' + alarm.threshold.to_s
  puts 'Comp operator:  ' + alarm.comparison_operator
  puts
  MyLog.log.info 'Period:         ' + alarm.period.to_s
  MyLog.log.info 'Unit:           ' + alarm.unit.to_s
  MyLog.log.info 'Eval periods:   ' + alarm.evaluation_periods.to_s
  MyLog.log.info 'Threshold:      ' + alarm.threshold.to_s
  MyLog.log.info 'Comp operator:  ' + alarm.comparison_operator
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)