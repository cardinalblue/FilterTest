//
//  ResultViewController.m
//  WhiteBoardGrab
//
//  Created by Chris Greening on 08/03/2009.
//

#import "ResultViewController.h"
#import "Image.h"

@implementation ResultViewController

@synthesize originalImage;
@synthesize resultImage;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void) setImage:(UIImage *) srcImage {
	originalImage.image=srcImage;
	// convert to grey scale and shrink the image by 4 - this makes processing a lot faster!
	ImageWrapper *greyScale=Image::createImage(srcImage, srcImage.size.width, srcImage.size.height);
	// you can play around with the numbers to see how it effects the edge extraction
	// typical numbers are  tlow 0.20-0.50, thigh 0.60-0.90
	//ImageWrapper *edges=greyScale.image->gaussianBlur().image->cannyEdgeExtract(0.3,0.7);
	// show the results
    
    ImageWrapper *thresh =  greyScale.image->autoLocalThreshold();
	resultImage.image = thresh.image->toUIImage();
    
    CGImageRef inImage =[resultImage.image CGImage];   //Input image cgi
    CGContextRef ctx;
    
    CFDataRef m_ori_DataRef;
	m_ori_DataRef = CGDataProviderCopyData(CGImageGetDataProvider([srcImage CGImage]));
	UInt8 * m_ori_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_ori_DataRef);
    
	
	CFDataRef m_DataRef;
	m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
	UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    
	int length = CFDataGetLength(m_DataRef);
    CGImageGetBitsPerComponent(inImage);
    CGImageGetBitsPerPixel(inImage);
    CGImageGetBytesPerRow(inImage);
	
    
	for (int index = 0; index < length; index += 4)
	{
		Byte tempR = m_ori_PixelBuf[index + 1];
		Byte tempG = m_ori_PixelBuf[index + 2];
		Byte tempB = m_ori_PixelBuf[index + 3];
		
        //		int outputRed = level + tempR;
        //		int outputGreen = level + tempG;
        //		int outputBlue = level + tempB;
		
        int outputRed = tempR;
		int outputGreen = tempG;
		int outputBlue =  tempB;
        
		if (outputRed>255) outputRed=255;
		if (outputGreen>255) outputGreen=255;
		if (outputBlue>255) outputBlue=255;
		
		if (outputRed<0) outputRed=0;
		if (outputGreen<0) outputGreen=0;
		if (outputBlue<0) outputBlue=0;
		
    
		m_ori_PixelBuf[index + 1] = outputRed; 
		m_ori_PixelBuf[index + 2] = outputGreen; 
		m_ori_PixelBuf[index + 3] = outputBlue;
		
	}
	
	ctx = CGBitmapContextCreate(m_ori_PixelBuf,
								CGImageGetWidth( inImage ),
								CGImageGetHeight( inImage ),
								8,
								CGImageGetBytesPerRow( inImage ),
								CGImageGetColorSpace(inImage),
								kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    
	CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
	UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
    
	CGContextRelease(ctx);
	CGImageRelease(imageRef); 
	
	CFRelease(m_DataRef);

    resultImage.image = rawImage;
    
}


- (void)dealloc {
	[originalImage release];
	[resultImage release];
    [super dealloc];
}


@end
