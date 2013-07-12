iOS to Rails Images
===================

A quick project I threw together to figure out how to POST images from iOS to a Rails object and upload them via the Paperclip gem.  My solution was largely inspired by [this post](http://code4j.blogspot.com/2012/12/image-upload-from-ios-to-rails-part-3.html).

This repository contains the iOS (Image Tester) and Ruby on Rails (project_gallery) apps that I used to test the code.  The important parts of each one are:

iOS
-------------------
Using the Base64 library, images are encoded and then sent as JSON, along with the other regular model fields that rails expects for the given object.  The iOS part is actually fairly straightforward NSURLConnection networking.

Encoding using Base64:
```objectivec
  // Convert our image to Base64 encoding.
  NSData *imageData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage]);
  [Base64 initialize];
  NSString *imageDataEncodedString = [Base64 encode:imageData];
    
  // Add the encoded image to our storage array.
  [selectedImages addObject:[NSDictionary dictionaryWithObject:imageDataEncodedString forKey:@"image_data"]];
```

Sending using NSURLConnection:
``` objectivec
  // Create the URL Request and set it's method and content type.
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPMethod:@"POST"];
    
  // Create an dictionary of the info for our new project, including the selected images.
  NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"Office", @"iOS", selectedImages, nil] forKeys:[NSArray arrayWithObjects:@"name", @"framework", @"images_attributes", nil]];
    
  // Convert our dictionary to JSON and NSData
  NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:newProject options:NSJSONReadingMutableContainers error:nil];
    
  // Assign the request body
  [request setHTTPBody:newProjectJSONData];
    
  // Initialize our request and send it away.
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
```
In this case, it's important that the array containing the images is stored under the JSON key "image_data," which is what the Rails app will check when the data's received.

Ruby on Rails
---------------
The Rails setup has a bit more going on than iOS.  First, we're going to use the [Paperclip](https://github.com/thoughtbot/paperclip) gem, so add it to the gemfile:

```ruby
  gem 'paperclip', '~>3.0'
```

In my case, I wanted to use a one-to-many relationship between projects and project images, with each project image model storing data of one image.  I also wanted to be able to create both objects through HTML and JSON, and handle the image uploading with Paperclip.  

The Project model:
```ruby
class Project < ActiveRecord::Base
  attr_accessible :framework, :name, :images_attributes

  has_many :images, class_name: 'ProjectImage', dependent: :destroy

  accepts_nested_attributes_for :images
end
```
There's nothing overly special here, we set up the one-to-many relationship for project images using the "images" alias, and enable nested attributes for it.  

The Project Images model:
```ruby
class ProjectImage < ActiveRecord::Base
  # We need to create a virtual property that won't be saved to the database, in 
  # this case I've used 'image_data'.
  attr_accessible :project, :image_data, :image
  attr_accessor :image_data

  has_attached_file :image, styles: {medium: ["300x300>", :png], thumb: ["100x100>", :png]}
  belongs_to :project
  before_save :decode_image_data

  def decode_image_data
    # If image_data is present, it means that we were sent an image over
  	# JSON and it needs to be decoded.  After decoding, the image is processed
  	# normally via Paperclip.
  	if self.image_data.present?
  		data = StringIO.new(Base64.decode64(self.image_data))
  		data.class.class_eval {attr_accessor :original_filename, :content_type}
  		data.original_filename = self.id.to_s + ".png"
  		data.content_type = "image/png"

  		self.image = data
  	end
  end
end
```
The first point of interest is:
```ruby 
  attr_accessible :project, :image_data, :image
  attr_accessor :image_data
```
We need to set up a virtual property that we can use to send the encoded image from iOS, but that won't be used to create the object from a form or saved to the database.

The following three lines set up the paperclip attachment under the "image" property, the relationship to the Project model, and a method called "decode_image_data" that's called before the project image is saved.  This method is the key to the Rails side of getting this working.  It checks to see if the image_data property has been provided, and then decodes the image and assigns it to the "image" property.  After this is done, Paperclip uploads the image normally.  

  
  
