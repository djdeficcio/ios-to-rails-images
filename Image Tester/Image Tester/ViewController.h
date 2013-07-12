//
//  ViewController.h
//  Image Tester
//
//  Created by DJ DeFiccio on 7/9/13.
//  Copyright (c) 2013 DJ DeFiccio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLConnectionDelegate>
{
    NSData *_receivedData;
    NSMutableArray *selectedImages;
}

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
- (IBAction)takePicture:(id)sender;
- (IBAction)sendPicture:(id)sender;
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (UIViewController <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate> *) delegate;
- (void)sendImagesToServer:(NSURL *)url;

@end
