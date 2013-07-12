iOS to Rails Images
===================

A quick project I threw together to figure out how to POST images from iOS to a Rails object and upload them via the Paperclip gem.

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


  
  
