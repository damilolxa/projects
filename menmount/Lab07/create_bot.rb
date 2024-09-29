#!/usr/bin/env ruby
#----------------------
#File: create_bot.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-lexmodelbuildingservice'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab7"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

client = Aws::LexModelBuildingService::Client.new(region: 'us-east-1')

#Create Bot
resp=client.put_bot({
  name: "PizzaOrderingBot", # required
  intents: [
    {
      intent_name: "OrderPizzas", # required
      intent_version: "$LATEST", # required
    },
  ],
  clarification_prompt: {
    messages: [ # required
      {
        content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
        content: "Sorry, can you please repeat that?", # required
      },
    ],
    max_attempts: 5, # required
  },
  abort_statement: {
    messages: [ # required
      {
        content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
        content: "Sorry, I could not understand. Goodbye.", # required
      },
    ],
  },
  idle_session_ttl_in_seconds: 300,
  voice_id: "Salli",
  process_behavior: "BUILD", # accepts SAVE, BUILD
  locale: "en-US", # required, accepts en-US, en-GB, de-DE
  child_directed: false, # required
})

ap resp
MyLog.log.info "Resp: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)