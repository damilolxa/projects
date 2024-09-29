#!/usr/bin/env ruby
#----------------------
#File: test_lambda_function.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'json'
require 'aws-sdk-lambda'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab6"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

client = Aws::Lambda::Client.new(region: 'us-east-1')

reqpayload = File.open('input.json',"rb").read

puts "Payload: #{reqpayload}"
MyLog.log.info "Payload: #{reqpayload}"

resp = client.invoke({
  function_name: "PizzaOrderProcessor", 
  invocation_type: "RequestResponse", 
  log_type: "None", 
  payload: reqpayload, 
})

ap resp
puts

MyLog.log.info "Resp: #{resp}"

# If the status code is 200, the call succeeded
if resp["status_code"] == 200
    # If there is not function error then the funcion was run successfully
    if resp["function_error"] == nil
        resp_payload = JSON.parse(resp["payload"].string)
        # If the request was fulfilled we can print out the message content
        if resp_payload["dialogAction"]["fulfillmentState"]=="Fulfilled"
            puts "Lambda Function Message:"
            puts resp_payload["dialogAction"]["message"]["content"]
            MyLog.log.info "Lambda Function Message: #{resp_payload["dialogAction"]["message"]["content"]}"
        else
            puts "The request was not fulfilled!"
        end
    else
        puts "There was a function error!"
    end
else
    puts "There was an error with the request!"
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)