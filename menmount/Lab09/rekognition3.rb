#!/usr/bin/env ruby
#----------------------
#File: rekognition2.rb
#Version: 1.4
#Date: 02/02/2020
#Prepared for Towson University
#ITEC 427 - Cloud Computing
#By Dr. John R. Auten Sr.
#----------------------
$LOAD_PATH << "."
require 'aws-sdk'
require 'aws-sdk-rekognition'
require "awesome_print"
require 'mini_magick'

require '../lab_log'
require '../assignment_turn_in'

#This is used to set the path for where your work will be stored for grading!
lab="Lab9"

$f1_version="1.4"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
source_img = 'Davido-1.jpg'
source_bucket = 'menmountbucket'
#----------------------------------

s3 = Aws::S3::Client.new(region: 'us-east-1')

image=MiniMagick::Image.open(source_img)
image = image.auto_orient
image.write(source_img)

#Upload source image
  resp=s3.put_object({
  body: File.new(source_img), 
  bucket: source_bucket, 
  key: source_img, 
  })
  
  ap resp

MyLog.log.info resp.awesome_inspect

target_img="MarkedCelebrities.jpg" #Don't Change This Value!
#Make a copy of the image
FileUtils.cp(source_img, target_img)

#--------------------------------------------------
#This method is used to draw a rectangle onto an image
#--------------------------------------------------
def draw_bounding_box(srcfilename,left,top,width,height,rsltfilename)
	image=MiniMagick::Image.open(srcfilename)
	imgwidth = image.width
	imgheight = image.height
	x0=(left*imgwidth).round
	y0=(top*imgheight).round
	x1=(x0+width*imgwidth).round
	y1=(y0+height*imgheight).round

	result = image.combine_options do |c|
		c.fill('none')
		c.stroke('#FF0000')
		c.draw "rectangle #{x0},#{y0},#{x1},#{y1}"
	end

	result.write(rsltfilename)
end

#--------------------------------------------------
#This method is used to add text to an image
#--------------------------------------------------
def add_text(srcfilename,left,top,width,height,rsltfilename,text)
	image=MiniMagick::Image.open(srcfilename)
	puts image.width
	puts image.height
	#image = image.auto_orient

	imgwidth = image.width
	imgheight = image.height
	x0=(left*imgwidth).round
	y0=(top*imgheight).round
	x1=(x0+width*imgwidth).round
	y1=(y0+height*imgheight).round
	
	
	
	puts "imgwidth: #{imgwidth}"
	puts "imgheight: #{imgheight}"
	puts "left: #{left}"
	puts "top: #{top}"
	puts "x0: #{x0}"
	puts "x1: #{x1}"
	puts "y0: #{y0}"
	puts "y1: #{y1}"
	
	result = image.combine_options do |c|
    	c.font "Helvetica"
    	c.gravity "NorthWest"
    	c.pointsize 14
    	c.fill "white"
    	#c.annotate "+#{x0}+#{y0} #{text}"
    	c.draw "text #{x0},#{y0} '#{text}'"
	end

	result.write(rsltfilename)
end


#--------------------------------------------------
MiniMagick.configure do |config|
  config.cli = :imagemagick
  config.timeout = 5
end

client=Aws::Rekognition::Client.new()

resp = client.recognize_celebrities({
  image: { # required
    s3_object: {
      bucket: source_bucket,
      name: source_img,
    },
  },
})

ap resp
MyLog.log.info resp.awesome_inspect


resp.celebrity_faces.each do |match|
	puts "Celebrity: #{match.name}"
	puts "Similarity: #{match.match_confidence}"
	MyLog.log.info "Celebrity: #{match.name}"
	MyLog.log.info "Similarity: #{match.match_confidence}"
	boxheight=match.face.bounding_box.height
	boxleft=match.face.bounding_box.left
	boxtop=match.face.bounding_box.top
	boxwidth=match.face.bounding_box.width
	draw_bounding_box(target_img,boxleft,boxtop,boxwidth,boxheight,target_img)
	name = match.name.to_s
	puts name
	add_text(target_img,boxleft,boxtop,boxwidth,boxheight,target_img,name)
end

#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

FileUtils.cp(target_img, "MarkedCelebritiesCopy.jpg")

#Upload your images for me to see
assignment_turn_in(File.new(target_img),lab,target_img)



