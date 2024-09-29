#!/usr/bin/env ruby
#----------------------
#File: create_slots.rb
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

#Slot for crusts
resp = client.put_slot_type({
  name: "Crusts", # required
  description: "Available crusts",
  enumeration_values: [
    {
      value: "stuffed", # required
    },
    {
      value: "thick", # required
      synonyms: ["pan"],
    },
    {
      value: "thin", # required
    },
  ],
})

ap resp
MyLog.log.info resp

#Slot for sizes
resp = client.put_slot_type({
  name: "Sizes", # required
  description: "Available sizes",
  enumeration_values: [
    {
      value: "small", # required
    },
    {
      value: "medium", # required
    },
    {
      value: "large", # required
    },
  ],
})

ap resp
MyLog.log.info resp

#Slot for kinds
resp = client.put_slot_type({
  name: "PizzaKind", # required
  description: "Available pizzas",
  enumeration_values: [
    {
      value: "veggie", # required
    },
    {
      value: "cheese", # required
    },
  ],
})

ap resp
MyLog.log.info resp

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)