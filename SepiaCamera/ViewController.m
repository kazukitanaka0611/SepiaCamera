//
//  ViewController.m
//  SepiaCamera
//
//  Created by 和樹 田中 on 11/12/08.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

enum ACTION_SHEET {
     ACTION_SHEET_CAMERA
    ,ACTION_SHEET_POST
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma actionSheet
- (IBAction)showActionSheetCamera
{
    UIActionSheet *sheet = [[UIActionSheet alloc] 
             initWithTitle:@"Select" 
             delegate:self 
             cancelButtonTitle:@"Cancel" 
             destructiveButtonTitle:nil 
             otherButtonTitles:@"Camera", @"Photo Library", nil];

    sheet.tag = ACTION_SHEET_CAMERA;
    [sheet showInView:self.view];
    
    [sheet release];
}

- (IBAction)showActionSheetPost
{
    UIActionSheet *sheet = [[UIActionSheet alloc] 
                            initWithTitle:@"Select" 
                            delegate:self 
                            cancelButtonTitle:@"Cancel" 
                            destructiveButtonTitle:nil 
                            otherButtonTitles:@"Save to Photo Library", 
                                @"E-mail", @"Twitter", @"Print", nil];
    
    sheet.tag = ACTION_SHEET_POST;
    [sheet showInView:self.view];
    
    [sheet release];
}

- (void)doActionSheetCamera:(NSInteger)buttonIndex
{
    if(buttonIndex >= 2) return;
    
    UIImagePickerControllerSourceType soureceType = 0;
    
    switch (buttonIndex) {
        case 0:{
            soureceType = UIImagePickerControllerSourceTypeCamera;
            break;
        } 
        case 1:{
            soureceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        default:
            break;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:soureceType]) {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = soureceType;
    imagePicker.delegate = self;
    
    [self presentModalViewController:imagePicker animated:YES];
    
    [imagePicker release];
}

- (void)showAlertInfomation:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" 
                                                    message:message 
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    
    [alert show];
    [alert release];

}

# pragma UIImagePickerControllerDelegate
- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
   
    [self showAlertInfomation:@"Save done."];
    [avtivity stopAnimating];
    imageView.image = nil;
}

- (void)savePhotoLibrary
{
    [avtivity startAnimating];
    UIImageWriteToSavedPhotosAlbum(imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
}

# pragma mail
- (void)sendMail
{
    if (![MFMailComposeViewController canSendMail]) {
       
        [self showAlertInfomation:@"Cannnot Send Mail."];
        return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    [controller setMessageBody:nil isHTML:NO];
    
    if (imageView.image != nil) {
        NSData *data = UIImagePNGRepresentation(imageView.image);
        [controller addAttachmentData:data mimeType:@"image/png" fileName:@""];
    }
    
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller 
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result){
        case MFMailComposeResultCancelled:
             [self showAlertInfomation:@"Cancelled."];
            //キャンセルした場合
            break;
        case MFMailComposeResultSaved:
            //保存した場合
            [self showAlertInfomation:@"Saved."];
            break;
        case MFMailComposeResultSent:
            //送信した場合
            [self showAlertInfomation:@"send Mail Done."];
            break;
        case MFMailComposeResultFailed:
            [self showAlertInfomation:@"Cannnot send Mail."];
            break;
        default:
            break;
    }    
    [self dismissModalViewControllerAnimated:YES];
}

# pragma twitter
- (void)sendTwitter
{
    TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc]init];
    [controller addImage:imageView.image];
    
    [controller setCompletionHandler:^(TWTweetComposeViewControllerResult result){
    
        NSString *output;
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                output = @"Tweet cancelled.";
                break;
            case TWTweetComposeViewControllerResultDone:
                output = @"Tweet done.";
            default:
                break;
        }
        
        [self performSelectorOnMainThread:@selector(showAlertInfomation:) withObject:output waitUntilDone:NO];
        
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

# pragma printer
- (void)sendPrinter
{
    if (![UIPrintInteractionController isPrintingAvailable]) {
        
        [self showAlertInfomation:@"Cannnot Print Out"];
    }
    
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(completed && error) {
            [self showAlertInfomation:@"Cannnot Print Out"];
        }
    };
    
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    controller.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputPhoto;
    printInfo.jobName = @"Sepia Camera Print Photo";
    controller.printInfo = printInfo;
    controller.printingItem = imageView.image;
    controller.showsPageRange = YES;
    
    [controller presentAnimated:YES completionHandler:completionHandler];
    [controller release];
}

- (void)printInteractionControllerDidFinishJob:
    (UIPrintInteractionController *)printInteractionController
{
     [self showAlertInfomation:@"Print Out done"];
}

# pragma action sheet deletage
- (void)doActionSheetPost:(NSInteger)buttonIndex
{
    if(buttonIndex >= 6) return;
    
    switch (buttonIndex) {
        case 0:{
            [self savePhotoLibrary];
            break;
        } 
        case 1:{
            [self sendMail];
            break;
        }
        case 2:{
            [self sendTwitter];
            break;
        }
        case 3:{
            [self sendPrinter];
            break;
        }
        default:
        break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (ACTION_SHEET_CAMERA == actionSheet.tag) {
        [self doActionSheetCamera:buttonIndex];
    }else{
        [self doActionSheetPost:buttonIndex];
    }
}

# pragma filter
- (void)setFilterImage:(UIImage *)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setDefaults];
    [filter setValue:ciImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat: 0.9f] forKey:@"inputIntensity"];
    CIImage *outputImage = filter.outputImage;
    
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgImage = [context createCGImage: outputImage fromRect: outputImage.extent];
    UIImage *resultUIImage = [UIImage imageWithCGImage: cgImage];
    CGImageRelease(cgImage);
    [ciImage release];
    
    imageView.image = resultUIImage;
}

# pragma resize
- (void)resizeImage:(UIImage *)originalImage
{   
    float aspect = originalImage.size.height / originalImage.size.width;

    float canvasRectWidth = imageView.bounds.size.width;
    float canvasRectHeight = (canvasRectWidth * aspect);
    
    if (canvasRectHeight > [[UIScreen mainScreen] bounds].size.height) {
        canvasRectHeight = [[UIScreen mainScreen] bounds].size.height;
        canvasRectWidth = canvasRectHeight / aspect;
    }
    
    CGRect canvasRect = CGRectMake(0.0f, 0.0f, canvasRectWidth, canvasRectHeight);
    imageView.bounds = canvasRect;

    UIGraphicsBeginImageContext(canvasRect.size);

    [originalImage drawInRect:canvasRect];
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setFilterImage:imageView.image];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self performSelector:@selector(resizeImage:) withObject:originalImage afterDelay:0.01f];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

# pragma touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    touchPoint = [touch locationInView:imageView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:imageView];
    
    NSLog(@" imageView.frame.size = %f", imageView.frame.size.height);
    UIGraphicsBeginImageContext(imageView.frame.size);
    
    [imageView.image drawInRect:
    CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchPoint.x, touchPoint.y);
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    touchPoint = currentPoint;
}

# pragma dealloc
-(void)dealloc
{
    imageView = nil;
    [imageView release];
    
    avtivity = nil;
    [avtivity release];
    
    [super dealloc];
}

@end
