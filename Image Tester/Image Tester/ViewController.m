//
//  ViewController.m
//  Image Tester
//
//  Created by DJ DeFiccio on 7/9/13.
//  Copyright (c) 2013 DJ DeFiccio. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Base64.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        selectedImages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (IBAction)sendPicture:(id)sender {
    //Set this url to the destination server
    NSURL *url = [NSURL URLWithString:@"http://10.1.10.24:3000/projects"];
    
    [self sendImagesToServer:url];
}

// Summon our camera picker.  Most fo this function was originally supplied by apple's documentation.
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate> ) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:UIModalPresentationFullScreen completion:nil];
    return YES;
}

// Package and send the image.
- (void)sendImagesToServer:(NSURL *)url
{
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
    
    if (connection) {
        // Initialize an object to hold response data
        _receivedData = [[NSMutableData alloc] init];
        // Remove all pictures, and reset the UI to the way we found it.
        [selectedImages removeAllObjects];
        self.imagePreview.image = nil;
        self.imageCountLabel.text = @"0";
    }
}

#pragma -
#pragma Image Picker Delegate Methds

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker {    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Set the image preview to the new image.
    self.imagePreview.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Convert our image to Base64 encoding.
    NSData *imageData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage]);
    [Base64 initialize];
    NSString *imageDataEncodedString = [Base64 encode:imageData];
    
    // Add the encoded image to our storage array.
    [selectedImages addObject:[NSDictionary dictionaryWithObject:imageDataEncodedString forKey:@"image_data"]];
    
    // Update the image count. 
    self.imageCountLabel.text = [NSString stringWithFormat:@"%d", [selectedImages count]];
    
    // And dismiss the image picker.
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
