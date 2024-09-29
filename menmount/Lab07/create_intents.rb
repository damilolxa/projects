#!/usr/bin/env ruby
#----------------------
#File: create_intents.rb
#Version: 1.4
#Date: 11/11/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-lambda'
require 'aws-sdk-lexmodelbuildingservice'
require 'aws-sdk-resources'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab7"

$f1_version="1.4"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
accountnum="767398022705"
#----------------------------------
lambdaarnobj = Aws::ARN.new(partition: 'aws', service: 'lambda', region: 'us-east-1', account_id: accountnum, resource: 'function:PizzaOrderProcessor' )
lexarnobj = Aws::ARN.new(partition: 'aws', service: 'lex', region: 'us-east-1', account_id: accountnum, resource: 'intent:OrderPizzas:*' )

arn_lex = lexarnobj.to_s()
arn_lambda = lambdaarnobj.to_s()


lambdaClient = Aws::Lambda::Client.new(region: 'us-east-1')
client = Aws::LexModelBuildingService::Client.new(region: 'us-east-1')



#Initial Creation of Intent
resp = client.put_intent({
  name: "OrderPizzas", # required
  slots: [
    {
      name: "pizzaKind", # required
      slot_constraint: "Required", # required, accepts Required, Optional
      slot_type: "PizzaKind",
      slot_type_version: "$LATEST",
      value_elicitation_prompt: {
        messages: [ # required
          {
            content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
            content: "Do you want a veggie, pepperoni, or cheese pizza?", # required
          },
        ],
        max_attempts: 2, # required
      },
      priority: 3,
    },
    {
      name: "size", # required
      slot_constraint: "Required", # required, accepts Required, Optional
      slot_type: "Sizes",
      slot_type_version: "$LATEST",
      value_elicitation_prompt: {
        messages: [ # required
          {
            content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
            content: "What size pizza?", # required
          },
        ],
        max_attempts: 2, # required
      },
      priority: 2,
    },
    {
      name: "crust", # required
      slot_constraint: "Required", # required, accepts Required, Optional
      slot_type: "Crusts",
      slot_type_version: "$LATEST",
      value_elicitation_prompt: {
        messages: [ # required
          {
            content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
            content: "What kind of crust would you like?", # required
          },
        ],
        max_attempts: 2, # required
      },
      priority: 1,
    },
  ],
  sample_utterances: ["I want to order pizza please",
    "I want to order a pizza",
    "I want to order a {pizzaKind} pizza",
    "I want to order a {size} {pizzaKind} pizza",
    "I want a {size} {crust} crust {pizzaKind} pizza",
    "Can I get a pizza please",
    "Can I get a {pizzaKind} pizza",
    "Can I get a {size} {pizzaKind} pizza"],
})

  ap resp
 
#Save the checksum for later use
checksum = resp[:checksum]
ap checksum
MyLog.log.info "Checksum: #{checksum}"

#Add permission for Lex to invoke Lambda function
resp=lambdaClient.add_permission({
  action: "lambda:InvokeFunction", 
  function_name: "PizzaOrderProcessor", #This must match the name of your lambda function from lab 6!
  principal: "lex.amazonaws.com", 
  source_arn: arn_lex, 
  statement_id: "OrderPizzas", 
})


ap resp
MyLog.log.info "Resp: #{resp}"

#Give the system time to register the permission
sleep(10)

#Update the Intent with Lambda Code Hook
resp = client.put_intent({
  name: "OrderPizzas", # required
  slots: [
    {
      name: "pizzaKind", # required
      slot_constraint: "Required", # required, accepts Required, Optional
      slot_type: "PizzaKind",
      slot_type_version: "$LATEST",
      value_elicitation_prompt: {
        messages: [ # required
          {
            content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
            content: "Do you want a veg or cheese pizza?", # required
          },
        ],
        max_attempts: 2, # required
      },
      priority: 3,
    },
    {
      name: "size", # required
      slot_constraint: "Required", # required, accepts Required, Optional
      slot_type: "Sizes",
      slot_type_version: "$LATEST",
      value_elicitation_prompt: {
        messages: [ # required
          {
            content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
            content: "What size pizza?", # required
          },
        ],
        max_attempts: 2, # required
      },
      priority: 2,
    },
    {
      name: "crust", # required
      slot_constraint: "Required", # required, accepts Required, Optional
      slot_type: "Crusts",
      slot_type_version: "$LATEST",
      value_elicitation_prompt: {
        messages: [ # required
          {
            content_type: "PlainText", # required, accepts PlainText, SSML, CustomPayload
            content: "What kind of crust would you like?", # required
          },
        ],
        max_attempts: 2, # required
      },
      priority: 1,
    },
  ],
  sample_utterances: ["I want to order pizza please",
    "I want to order a pizza",
    "I want to order a {pizzaKind} pizza",
    "I want to order a {size} {pizzaKind} pizza",
    "I want a {size} {crust} crust {pizzaKind} pizza",
    "Can I get a pizza please",
    "Can I get a {pizzaKind} pizza",
    "Can I get a {size} {pizzaKind} pizza"],
  fulfillment_activity: {
    type: "CodeHook", # required, accepts ReturnIntent, CodeHook
    code_hook: {
      uri: arn_lambda, # required
      message_version: "1.0", # required
    },
  },
  checksum: "#{checksum}",
})

ap resp
MyLog.log.info "Resp: #{resp}"

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)