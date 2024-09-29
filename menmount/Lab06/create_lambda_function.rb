#!/usr/bin/env ruby
#----------------------
#File: create_lambda_function.rb
#Version: 1.4
#Date: 11/11/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-lambda'
require 'aws-sdk-resources'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab6"

$f1_version="1.4"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
accountnum="767398022705"
#----------------------------------
iamarnobj = Aws::ARN.new(partition: 'aws', service: 'iam', region: '', account_id: accountnum, resource: 'role/PizzaOrderProcessorRole' )
#iamarnobj = Aws::ARN.new(partition: 'aws', service: 'iam', region: '', account_id: accountnum, resource: 'service-role/PizzaOrderProcessorRole') #Old type of role ARN

arn = iamarnobj.to_s()

client = Aws::Lambda::Client.new(region: 'us-east-1')

# This example creates a Lambda function.
args = {}
args[:role] = arn

args[:function_name] = 'PizzaOrderProcessor'
args[:handler] = 'PizzaOrderProcessor.handler'

# Also accepts nodejs, nodejs4.3, and python2.7
args[:runtime] = 'nodejs18.x'

code = {}
code[:zip_file] = File.open('PizzaOrderProcessor.zip','rb').read

args[:code] = code

MyLog.log.info "Lambda Function Args: #{args}"

resp=client.create_function(args)

ap resp
MyLog.log.info resp

client.list_functions.functions.each do |function|
  puts 'Name: ' + function.function_name
  puts 'ARN:  ' + function.function_arn
  puts 'Role: ' + function.role
  puts
  MyLog.log.info 'Name: ' + function.function_name
  MyLog.log.info 'ARN:  ' + function.function_arn
  MyLog.log.info 'Role: ' + function.role
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)