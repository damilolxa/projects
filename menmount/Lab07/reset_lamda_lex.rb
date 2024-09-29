#!/usr/bin/env ruby
#----------------------
#File: reset_lambda_lex.rb
#Version: 1.1
#Date: 11/11/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'awesome_print'
require 'aws-sdk-lambda'
require 'aws-sdk-lexmodelbuildingservice'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab7"

$f1_version="1.1"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS

#----------------------------------

lambdaclient = Aws::Lambda::Client.new(region: 'us-east-1')
lexclient = Aws::LexModelBuildingService::Client.new(region: 'us-east-1')

#Delete Bot if it exists
begin  
    resp = lexclient.get_bot({
        name: "PizzaOrderingBot", 
        version_or_alias: "$LATEST", 
    })
    puts("PizzaOrderingBot bot exists!")
    MyLog.log.info("PizzaOrderingBot bot exists!")
    sleep(2)
    resp = lexclient.delete_bot({
        name: "PizzaOrderingBot", # required
    })
    puts("PizzaOrderingBot bot deleted!")
    MyLog.log.info("PizzaOrderingBot bot deleted!")
rescue => e
    #ap(e)
    puts("Bot does not exist, skipping deletion of bot!")
    MyLog.log.info("Bot does not exist, skipping deletion of bot!")
end

#Delete Intent if it exists
begin  
    resp = lexclient.get_intent({
        version: "$LATEST", 
        name: "OrderPizzas", 
    })
    puts("OrderPizzas intent exists!")
    MyLog.log.info("OrderPizzas intent exists!")
    sleep(2)
    resp = lexclient.delete_intent({
        name: "OrderPizzas", # required
    })
    puts("OrderPizzas intent deleted!")
    MyLog.log.info("OrderPizzas intent deleted!")
rescue => e
    #ap(e)
    puts("Intent does not exist, skipping deletion of intent!")
    MyLog.log.info("Intent does not exist, skipping deletion of intent!")
end

#Delete all Slots if they exist
#-Crusts
begin  
    resp = lexclient.get_slot_type({
        version: "$LATEST", 
        name: "Crusts", 
    })
    puts("Crusts slot exists!")
    MyLog.log.info("Crusts slot exists!")
    sleep(2)
    resp = lexclient.delete_slot_type({
        name: "Crusts", # required
    })
    puts("Crusts slot deleted!")
    MyLog.log.info("Crusts slot deleted!")
rescue => e
    #ap(e)
    puts("Crusts slot does not exist, skipping deletion of Crusts slot!")
    MyLog.log.info("Crusts slot does not exist, skipping deletion of Crusts slot!")
end

#-Sizes
begin  
    resp = lexclient.get_slot_type({
        version: "$LATEST", 
        name: "Sizes", 
    })
    puts("Sizes slot exists!")
    MyLog.log.info("Sizes slot exists!")
    sleep(2)
    resp = lexclient.delete_slot_type({
        name: "Sizes", # required
    })
    puts("Sizes slot deleted!")
    MyLog.log.info("Sizes slot deleted!")
rescue => e
    #ap(e)
    puts("Sizes slot does not exist, skipping deletion of Sizes slot!")
    MyLog.log.info("Sizes slot does not exist, skipping deletion of Sizes slot!")
end

#-PizzaKind
begin  
    resp = lexclient.get_slot_type({
        version: "$LATEST", 
        name: "PizzaKind", 
    })
    puts("PizzaKind slot exists!")
    MyLog.log.info("PizzaKind slot exists!")
    sleep(2)
    resp = lexclient.delete_slot_type({
        name: "PizzaKind", # required
    })
    puts("PizzaKind slot deleted!")
    MyLog.log.info("PizzaKind slot deleted!")
rescue => e
    #ap(e)
    puts("PizzaKind slot does not exist, skipping deletion of PizzaKind slot!")
    MyLog.log.info("PizzaKind slot does not exist, skipping deletion of PizzaKind slot!")
end

#Delete Lambda Function
begin  
    resp = lambdaclient.get_function({
        function_name: "PizzaOrderProcessor"
    })
    puts("PizzaOrderProcessor function exists!")
    MyLog.log.info("PizzaOrderProcessor function exists!")
    sleep(2)
    resp = lambdaclient.delete_function({
        function_name: "PizzaOrderProcessor", # required
    })
    puts("PizzaOrderProcessor function deleted!")
    MyLog.log.info("PizzaOrderProcessor function deleted!")
rescue => e
    #ap(e) 
    puts("PizzaOrderProcessor function does not exist, skipping deletion of PizzaOrderProcessor function!")
    MyLog.log.info("PizzaOrderProcessor function does not exist, skipping deletion of PizzaOrderProcessor function!")
end

#Instructions
puts("")
puts("Everything has been reset for Lab7!")
puts("You now need to rerun Lab6's create_lambda_function.rb script!")
puts("After that rerun Lab7's create_slots.rb script!")
puts("Then rerun Lab7's create_intents.rb script!")
puts("Finally rerun Lab7's create_bot.rb script!")

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)