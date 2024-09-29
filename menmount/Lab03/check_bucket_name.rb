#!/usr/bin/env ruby
#----------------------
#File: check_bucket_name.rb
#Version: 1.2
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk-s3'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab3"

$f1_version="1.2"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"


#----------------------------------INPUTS
bucketname1='anikebucket'
bucketname2='oyinkansola'
#----------------------------------

def testname(testbucketname)
 return testbucketname.match(/(?=^.{3,63}$)(?!^(\d+\.)+\d+$)(^(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])$)/)
end

s3=Aws::S3::Resource.new(region: 'us-east-1')

bucket_exists1=s3.bucket(bucketname1).exists?
bucket_exists2=s3.bucket(bucketname2).exists?

puts "Checking if bucket name "+bucketname1+", exists:"
MyLog.log.info "Checking if bucket name "+bucketname1+", exists:"
if(bucket_exists1)
    puts "Bucket already exists, use a different bucket name for first bucket!"
    MyLog.log.info "Bucket already exists, use a different bucket name for first bucket!"
else
    puts "Bucket does not exist, first bucket name is available!"
    MyLog.log.info "Bucket does not exist, first bucket name is available!"
end

puts "Checking if bucket name "+bucketname1+" is DNS compatible:"
MyLog.log.info "Checking bucket name "+bucketname1+" is DNS compatible:"
if(testname(bucketname1))
    puts "First bucket name is DNS compatible!"   
    MyLog.log.info "First bucket name is DNS compatible!"   
else
   puts "First bucket name is not DNS compatible!"   
   MyLog.log.info "First bucket name is not DNS compatible!"   
end

puts "Checking if bucket name "+bucketname2+", exists:"
MyLog.log.info "Checking if bucket name "+bucketname2+", exists:"
if(bucket_exists2)
    puts "Bucket already exists, use a different bucket name for second bucket!"
    MyLog.log.info "Bucket already exists, use a different bucket name for second bucket!"
else
    puts "Bucket does not exist, second bucket name is available!"
    MyLog.log.info "Bucket does not exist, second bucket name is available!"
end
    
puts "Checking if bucket name "+bucketname2+" is DNS compatible:"
MyLog.log.info "Checking bucket name "+bucketname2+" is DNS compatible:"
if(testname(bucketname2))
    puts "Second bucket name is DNS compatible!"   
    MyLog.log.info "Second bucket name is DNS compatible!"   
else
   puts "Second bucket name is not DNS compatible!"   
   MyLog.log.info "Second bucket name is not DNS compatible!"   
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)