#!/usr/bin/env ruby
#----------------------
#File: rekognition2.rb
#Version: 1.3
#Date: 11/21/2020
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

$f1_version="1.3"
puts "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"
MyLog.log.info "This is #{lab} for #{ENV["UNAME"]}! They are using version #{$f1_version} of #{File.basename(__FILE__)}"

#----------------------------------INPUTS
source_img = 'red.jpg'
target_img = 'dricki2.jpg'
bucket = 'menmountbucket'
#----------------------------------

#sudo apt-get install ImageMagick
#gem install mini_magick
#https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html

s3 = Aws::S3::Client.new(region: 'us-east-1')

#Upload source image
  resp=s3.put_object({
   body: File.new(source_img), 
   bucket: bucket, 
   key: source_img, 
  })
  
  ap resp
 MyLog.log.info resp

#Upload source image
  resp=s3.put_object({
   body: File.new(target_img), 
   bucket: bucket, 
   key: target_img, 
  })
  
  ap resp
MyLog.log.info resp

#--------------------------------------------------
#This method is used to draw a rectangle onto an image
#--------------------------------------------------
def draw_bounding_box(srcfilename,left,top,width,height,rsltfilename)
	image=MiniMagick::Image.open(srcfilename)
  image = image.auto_orient
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
MiniMagick.configure do |config|
  config.cli = :imagemagick
  config.timeout = 5
end

client=Aws::Rekognition::Client.new()

resp = client.compare_faces({
  similarity_threshold: 90, 
  source_image: {
    s3_object: {
      bucket: bucket, 
      name: source_img, 
    }, 
  }, 
  target_image: {
    s3_object: {
      bucket: bucket, 
      name: target_img, 
    }, 
  }, 
})


ap resp
MyLog.log.info resp.awesome_inspect

#resp.face_matches: Array of CompareFacesMatch
resp.face_matches.each do |match|
	puts "Similarity: #{match.similarity}"
	boxheight=match.face.bounding_box.height
	boxleft=match.face.bounding_box.left
	boxtop=match.face.bounding_box.top
	boxwidth=match.face.bounding_box.width

	draw_bounding_box(target_img,boxleft,boxtop,boxwidth,boxheight,"MatchResult.jpg")
end

#--------------------------------------------------
#resp.source_image_face: ComparedSourceImageFace
#--------------------------------------------------
boxheight=resp.source_image_face.bounding_box.height
boxleft=resp.source_image_face.bounding_box.left
boxtop=resp.source_image_face.bounding_box.top
boxwidth=resp.source_image_face.bounding_box.width

draw_bounding_box(source_img,boxleft,boxtop,boxwidth,boxheight,"SourceResult.jpg")


#Upload work for credit
file= File.new("mylab.log")
assignment_turn_in(file,lab)

#Create copies of files for you to see
FileUtils.cp("SourceResult.jpg", "SourceResultCopy.jpg")
FileUtils.cp("MatchResult.jpg", "MatchResultCopy.jpg")

#Upload your images for me to see
assignment_turn_in(File.new("SourceResult.jpg"),lab,"SourceResult.jpg")
assignment_turn_in(File.new("MatchResult.jpg"),lab,"MatchResult.jpg")
