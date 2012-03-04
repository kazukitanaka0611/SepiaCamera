//
//  ViewController.h
//  SepiaCamera
//
//  Created by 和樹 田中 on 11/12/08.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/TWTweetComposeViewController.h>
#import "Facebook.h"

@interface ViewController : UIViewController
    <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, 
    MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, FBSessionDelegate>
{
    IBOutlet UIImageView *imageView;
    IBOutlet UIActivityIndicatorView *avtivity;
    
    CGPoint touchPoint;
}

- (IBAction)showActionSheetCamera;
- (IBAction)showActionSheetPost;

@end
