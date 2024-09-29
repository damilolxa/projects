#!/usr/bin/env ruby
#----------------------
#File: megagreeter.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab1"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
#The inputs for this lab are at the bottom
#----------------------------------

#MegaGreeter Class Definition
class MegaGreeter
    attr_accessor :names
    # Create the object
    def initialize(names = "World")
        @names = names
        MyLog.log.info "New MegaGreeter created! Names: "+names
    end

    # Say hi to everybody
    def say_hi
        if @names.nil?
            puts "..."
            MyLog.log.info "..."
        elsif @names.respond_to?("each")
            # @names is a list of some kind, iterate!
            @names.each do |name|
                puts "Hello #{name}!"
                MyLog.log.info "Hello #{name}!"
            end
        else
            puts "Hello #{@names}!"
        end
    end

    # Say bye to everybody
    def say_bye
        if @names.nil?
            puts "..."
            MyLog.log.info "..."
        elsif @names.respond_to?("join")
            # Join the list elements with commas
            puts "Goodbye #{@names.join(", ")}. Come back soon!"
            MyLog.log.info "Goodbye #{@names.join(", ")}. Come back soon!"
        else
            puts "Goodbye #{@names}. Come back soon!"
            MyLog.log.info "Goodbye #{@names}. Come back soon!"
        end
    end
end

if __FILE__ == $0
    #Say Hi and Goodbye to the world
    puts "1)"
    mg1=MegaGreeter.new()
    mg1.say_hi
    mg1.say_bye
    #Say Hi and Goodbye to a person
    puts "2)"
    mg1.names="Morty"
    mg1.say_hi
    mg1.say_bye
    #Say Hi and Goodbye to a group of people
    puts "3)"
    mg1.names=["Squanchy","Unity","Gazorpian"]
    mg1.say_hi
    mg1.say_bye
    #Say Hi and Goodbye to a person
    puts "4)"
    mg2=MegaGreeter.new("Doofus Rick")
    mg2.say_hi
    mg2.say_bye
    #Say Hi and Goodbye to no one
    puts "5)"
    mg2.names= nil
    mg2.say_hi
    mg2.say_bye
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)
