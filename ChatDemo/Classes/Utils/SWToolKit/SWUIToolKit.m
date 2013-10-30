//
//  SWUIToolKit.m
//  Nurse
//
//  Created by Wu Stan on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWUIToolKit.h"
#import <CoreImage/CoreImage.h>

#pragma mark -
#pragma mark UILabel Catergory
@implementation UILabel(SWUIToolKit)

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font{
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.font = font;
    lbl.backgroundColor = [UIColor clearColor];
    
    return lbl;
}

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color{
    UILabel *lbl = [self createLabelWithFrame:frame font:font];
    lbl.textColor = color;
    
    return lbl;
}

@end


#pragma mark -
#pragma mark SWTextView
@interface SWTextView ()
- (void)_initialize;
- (void)_updateShouldDrawPlaceholder;
- (void)_textChanged:(NSNotification *)notification;
@end


@implementation SWTextView {
    BOOL _shouldDrawPlaceholder;
}


#pragma mark Accessors

@synthesize placeholder = _placeholder;
@synthesize placeholderColor = _placeholderColor;

- (void)setText:(NSString *)string {
    [super setText:string];
    [self _updateShouldDrawPlaceholder];
}


- (void)setPlaceholder:(NSString *)string {
    if ([string isEqual:_placeholder]) {
        return;
    }
    
    _placeholder = string;
    
    [self _updateShouldDrawPlaceholder];
}


#pragma mark NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    
}


#pragma mark UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_shouldDrawPlaceholder) {
        [_placeholderColor set];
        [_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withFont:self.font];
    }
}


#pragma mark Private

- (void)_initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textChanged:) name:UITextViewTextDidChangeNotification object:self];
    
    self.placeholderColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
    _shouldDrawPlaceholder = NO;
}


- (void)_updateShouldDrawPlaceholder {
    BOOL prev = _shouldDrawPlaceholder;
    _shouldDrawPlaceholder = self.placeholder && self.placeholderColor && self.text.length == 0;
    
    if (prev != _shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
}


- (void)_textChanged:(NSNotification *)notificaiton {
    [self _updateShouldDrawPlaceholder];    
}

@end


#pragma mark -
#pragma mark    SWImageView
@implementation SWImageView
@synthesize delegate;

- (void)loadURL:(NSString *)str{
    @autoreleasepool {
        if(str){
            NSArray *ary = [str componentsSeparatedByString:@"/"];
            NSMutableString *fileName = [NSMutableString string];
            
            for (int i=0;i<[ary count];i++)
                [fileName appendString:[ary objectAtIndex:i]];
            
            NSString *path = [fileName imageCachePath];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:path]){
                [self setImage:[UIImage imageWithContentsOfFile:path]];
                
                NSObject *obj = (NSObject *)delegate;
                if ([obj respondsToSelector:@selector(wImageViewLoadFinished:)])
                    [delegate swImageViewLoadFinished:self];
            }else{
                [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:str];
            }
            
        }
    
    }
}

- (void)loadImage:(NSString *)str{
    @autoreleasepool {
    
        NSURL *url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        [self setImage:img];
        
        
        //save image
        NSArray *ary = [str componentsSeparatedByString:@"/"];
        NSMutableString *fileName = [NSMutableString string];
        
        for (int i=0;i<[ary count];i++)
            [fileName appendString:[ary objectAtIndex:i]];
        
        NSString *path = [fileName imageCachePath];
        
        [data writeToFile:path atomically:NO];
        
        
        
        NSObject *obj = (NSObject *)delegate;
        if ([obj respondsToSelector:@selector(wImageViewLoadFinished:)])
            [delegate swImageViewLoadFinished:self];
    
    }
}

- (void)dealloc{
    self.delegate = nil;
    
}

@end


#pragma mark -
#pragma mark    SWButton
@implementation SWButton
@synthesize delegate;

- (void)loadURL:(NSString *)str{
    @autoreleasepool {
        if(str){
            NSArray *ary = [str componentsSeparatedByString:@"/"];
            NSMutableString *fileName = [NSMutableString string];
            
            for (int i=0;i<[ary count];i++)
                [fileName appendString:[ary objectAtIndex:i]];
            
            NSString *path = [fileName temporaryPath];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:path]){
                [self setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
                
                NSObject *obj = (NSObject *)delegate;
                if ([obj respondsToSelector:@selector(wImageViewLoadFinished:)])
                    [delegate swButtonLoadFinished:self];
            }else{
                [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:str];
            }
            
        }
        
    }
}

- (void)loadImage:(NSString *)str{
    @autoreleasepool {
        
        NSURL *url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        [self setImage:img forState:UIControlStateNormal];
        
        
        //save image
        NSArray *ary = [str componentsSeparatedByString:@"/"];
        NSMutableString *fileName = [NSMutableString string];
        
        for (int i=0;i<[ary count];i++)
            [fileName appendString:[ary objectAtIndex:i]];
        
        NSString *path = [fileName temporaryPath];
        
        [data writeToFile:path atomically:NO];
        
        
        
        NSObject *obj = (NSObject *)delegate;
        if ([obj respondsToSelector:@selector(wImageViewLoadFinished:)])
            [delegate swButtonLoadFinished:self];
        
    }
}

- (void)dealloc{
    self.delegate = nil;
    
}

@end

#pragma mark -
#pragma mark UIImage Category
@implementation UIImage(SWUIToolKit)
- (UIImage *)fixOrientation{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (UIImage *)resizedImage:(CGSize)newSize{
    UIImage *img = [self fixOrientation];
    if ((img.size.width-img.size.height)*(newSize.width-newSize.height)<0)
        newSize = CGSizeMake(newSize.height, newSize.width);
    
    CGSize mysize = img.size;
    
    float w = newSize.width;
    float h = newSize.height;
    float W = mysize.width;
    float H = mysize.height;
    
    float fw = w/W;
    float fh = h/H;
    
    if (w>=W && h>=H){
        return self;
    }else{
        if (fw>fh){
            w = h/H*W;
        }else{
            h = w/W*H;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h),YES,0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, h);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextDrawImage(ctx, CGRectMake(0, 0, w, h), img.CGImage);
    UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    return imgC;
}

- (UIImage *)croppedImage:(CGRect)area{
    CGSize size = self.size;
    
    if (area.origin.x<0)
        area.origin.x = 0;
    if (area.origin.y<0)
        area.origin.y = 0;
    if (area.origin.x+area.size.width>size.width)
        area.size.width = size.width-area.origin.x;
    if (area.origin.y+area.size.height>size.height)
        area.size.height = size.height-area.origin.y;
    

    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, area);
    UIImage *imgC = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return imgC;

}

- (BOOL)hasFace{
    CIImage *cimg = [CIImage imageWithCGImage:self.CGImage];
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    NSArray *features = [detector featuresInImage:cimg];

    return features.count>0;
}

@end


#pragma mark -
#pragma mark SWNavigationViewController

@implementation UINavigationBar (UINavigationBar_CustomBG)

- (void)drawRect:(CGRect)rect
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ABNavigationBarBG" ofType:@"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    [image drawInRect:rect];
}

@end

@implementation SWNavigationViewController
@synthesize bShowTabBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:kNavBGName] forBarMetrics:UIBarMetricsDefault];
    }
    
    
    
    
    bShowTabBar = YES;
//    self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    //    self.navigationBar.tintColor = [UIColor colorWithRed:233/255.0f green:133/255.0f blue:49 /255.0f alpha:1.0];
    self.delegate = self;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //    NSSet *setclass = [NSSet setWithObjects:NSStringFromClass([ABBlogDetailViewController class]),
    //                       NSStringFromClass([ABBindViewController class]),
    //                       NSStringFromClass([ABAboutViewController class]),
    //                       NSStringFromClass([ABAlbumViewController class]),
    //                       NSStringFromClass([ABWebViewController class]),
    //                       NSStringFromClass([ABStatusPictureViewController class]),
    //                       NSStringFromClass([ABPMViewController class]),
    //                       nil];
    //    
    //    if ([setclass containsObject:NSStringFromClass([viewController class])]){
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTabBar" object:nil];
    //        bShowTabBar = NO;
    //    }
    //    else{
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTabBar" object:nil];
    //        bShowTabBar = YES;
    //    }
}


@end



#pragma mark -
#pragma mark SWLabel
@implementation SWLabel
@synthesize lineBreak,font,textColor;

- (void)dealloc{
    self.text = nil;
    self.font = nil;
    
}

+ (NSArray *)componentsOfContent:(NSString *)content{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\{[^\\{\\}]+\\}"
                                                                      options:0
                                                                        error:nil];
    NSMutableArray *ranges = [NSMutableArray array];
    NSArray *chunks = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    for (int i=0;i<chunks.count;i++){
        NSTextCheckingResult *chunk = [chunks objectAtIndex:i];
        int total = chunk.numberOfRanges;
        
        for (int j=0;j<total;j++)
            [ranges addObject:[NSValue valueWithRange:[chunk rangeAtIndex:j]]];
        
    }
    
    NSMutableArray *components = [NSMutableArray array];
    
    int index = 0;
    int i = 0;
    while (index<content.length){
        if (i<ranges.count){
            NSRange range = [[ranges objectAtIndex:i] rangeValue];
            
            if (index<range.location)
                [components addObject:[content substringWithRange:NSMakeRange(index, range.location-index)]];
            
            [components addObject:[content substringWithRange:range]];
            
            index = range.location+range.length;
        }else{
            [components addObject:[content substringWithRange:NSMakeRange(index, content.length-index)]];
            index = content.length;
        }
        
        
        i++;
    }
    
    return components;
}

- (void)refreshContent{
    NSArray *components = [SWLabel componentsOfContent:self.text];
    
    for (UIView *v in self.subviews)
        [v removeFromSuperview];
    
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat fH = 0;
    CGSize sizeReturn = CGSizeZero;
    
    for (int i=0;i<components.count;i++){
        NSString *str = [components objectAtIndex:i];
        
        if ([str hasPrefix:@"{"] && [str hasSuffix:@"}"]){
            NSDictionary *dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (![dict isKindOfClass:[NSDictionary class]])
                dict = nil;
            
            NSString *strfont = [dict objectForKey:@"font"];
            NSString *strcolor = [dict objectForKey:@"color"];
            
            if (strfont){
                float fontsize = [strfont floatValue];
                BOOL isBold = [[strfont lowercaseString] hasSuffix:@"b"];
                if (fontsize>0)
                    self.font = isBold?[UIFont boldSystemFontOfSize:fontsize]:[UIFont systemFontOfSize:fontsize];
            }
            
            if (strcolor){
                NSArray *arycolor = [strcolor componentsSeparatedByString:@","];
                switch (arycolor.count) {
                    case 1:
                        self.textColor = [UIColor colorWithWhite:[[arycolor objectAtIndex:0] floatValue] alpha:1];
                        break;
                    case 2:
                        self.textColor = [UIColor colorWithWhite:[[arycolor objectAtIndex:0] floatValue] alpha:[[arycolor objectAtIndex:1] floatValue]];
                        break;
                    case 3:
                        self.textColor = [UIColor colorWithRed:[[arycolor objectAtIndex:0] floatValue] green:[[arycolor objectAtIndex:1] floatValue] blue:[[arycolor objectAtIndex:2] floatValue] alpha:1];
                        break;
                    case 4:
                        self.textColor = [UIColor colorWithRed:[[arycolor objectAtIndex:0] floatValue] green:[[arycolor objectAtIndex:1] floatValue] blue:[[arycolor objectAtIndex:2] floatValue] alpha:[[arycolor objectAtIndex:3] floatValue]];
                        break;
                    default:
                        break;
                }
            }
        }
        else{
            for (int j=0;j<str.length;j++){
                NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                
                
                CGSize sizeLetter=[temp sizeWithFont:self.font];
                if (upX+sizeLetter.width > self.frame.size.width)
                {
                    sizeReturn.width = self.frame.size.width;
                    upY = upY+sizeLetter.height+self.lineBreak;
                    upX = 0;
                }
                UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY+5,sizeLetter.width,sizeLetter.height)];
                la.backgroundColor = [UIColor clearColor];
                la.textColor = self.textColor;
                la.font = self.font;
                la.text = temp;
                [self addSubview:la];
                upX=upX+sizeLetter.width;
                
                fH = la.frame.origin.y+la.frame.size.height;
            }
        }
    }
    
    contentSize = CGSizeMake(0==sizeReturn.width?upX:self.frame.size.width, fH);
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:17];
        self.textColor = [UIColor blackColor];
        self.lineBreak = 2;
    }
    return self;
}

- (void)setText:(NSString *)text{
    if (strText!=text){
        strText = [text copy];
    }
    
    if (strText){
        [self refreshContent];
    }
}

- (NSString *)text{
    return strText;
}








- (void)sizeToFit{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentSize.width, contentSize.height);
}


@end


#pragma mark -  UIAlertView Extensions
@implementation UIAlertView(SWExtensions)

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel{
    [UIAlertView showAlertWithTitle:strtitle message:strmessage cancelButton:strcancel delegate:nil];
}

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate{
    if (!strcancel)
        strcancel = @"确定";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strtitle message:strmessage delegate:alertdelegate cancelButtonTitle:strcancel otherButtonTitles:nil];
    [alert show];
}

@end

#pragma mark - UIImage Extensions
@implementation UIImage(SWExtensions)

- (UIImage *)normalizedImage{
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CIColor *cicolor = [CIColor colorWithCGColor:color.CGColor];
    cicolor = [CIColor colorWithRed:cicolor.red green:cicolor.green blue:cicolor.blue alpha:cicolor.alpha];
    
    CIImage *ciimg = [CIImage imageWithColor:cicolor];
    CIContext *ctx = [CIContext contextWithOptions:nil];
    CGImageRef imgref = [ctx createCGImage:ciimg fromRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *img = [UIImage imageWithCGImage:imgref];
    CGImageRelease(imgref);
    
    return img;
}

@end


#pragma mark - SWEmoticonsKeyboard
@implementation SWEmoticonsKeyboard
@synthesize inputTextField,inputTextView,dicEmoticonsMap;


- (id)init{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 160)];
    if (self){
        self.dicEmoticonsMap = [NSDictionary dictionaryWithContentsOfFile:[@"SWToolKit.bundle/Emoticons/EmoticonsMap.plist" bundlePath]];
        
        self.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
        
        scvEmoticons = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        scvEmoticons.pagingEnabled = YES;
        scvEmoticons.showsHorizontalScrollIndicator = NO;
        scvEmoticons.delaysContentTouches = YES;
        scvEmoticons.delegate = self;
        [self addSubview:scvEmoticons];
        
        pcEmoticons = [[UIPageControl alloc] init];
        
        [self addSubview:pcEmoticons];
        [pcEmoticons addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        
        
        [self prepareKeyboard:emoticonsType];
    }
    
    return self;
}

- (void)switchEmoticonsType:(UIButton *)btn{
//    [self prepareKeyboard:emoticonsType];
}

- (void)delClicked{
    NSString *txt = self.inputTextView?self.inputTextView.text:self.inputTextField.text;
    
    int len = txt.length;
    if (len>0){
        NSString *last = [txt substringWithRange:NSMakeRange(len-1, 1)];
        if ([last isEqualToString:@"]"]){
            BOOL bRightFinded = NO;
            BOOL bLeftFinded = NO;
            for (int i=len-2;i>=0;i--){
                NSString *sub = [txt substringWithRange:NSMakeRange(i, 1)];
                if ([sub isEqualToString:@"["])
                    bLeftFinded = YES;
                else if ([sub isEqualToString:@"]"])
                    bRightFinded = YES;
                
                if (bLeftFinded && !bRightFinded){
                    NSString *newstr = [txt stringByReplacingCharactersInRange:NSMakeRange(i, len-i) withString:@""];
                    self.inputTextView.text = newstr;
                    break;
                }else if (bRightFinded && !bLeftFinded)
                    break;
            }
        }else{
            if ([self.inputTextView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
                NSString *newstr = [txt stringByReplacingCharactersInRange:NSMakeRange(len-1, 0) withString:@""];
                self.inputTextView.text = newstr;
            }
        }
    }
}



- (void)sendClicked{
    if (self.inputTextField){
        
    }else if (self.inputTextView){
        if ([self.inputTextView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
            [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:NSMakeRange(self.inputTextView.text.length, 0) replacementText:@"\n"];
        }
    }
}

- (void)prepareKeyboard:(SWEmoticonsType)type{
    NSDictionary *dict = dicEmoticonsMap;
    switch (type) {
        case SWEmoticonsTypeQQ:{
            NSArray *images = [[dict objectForKey:@"image"] allKeys];
            NSArray *emoticons = [dict objectForKey:@"order"];
            int totalPage = images.count/21+(images.count%21==0?0:1);
            pcEmoticons.numberOfPages = totalPage;
            pcEmoticons.currentPage = 0;
            [pcEmoticons sizeToFit];
            pcEmoticons.center = CGPointMake(160, 145);
            
            for (UIView *v in scvEmoticons.subviews){
                [v removeFromSuperview];
            }
            scvEmoticons.contentSize = CGSizeMake(scvEmoticons.frame.size.width*totalPage, scvEmoticons.frame.size.height);
            
            for (int i=0;i<emoticons.count;i++){
                int page = i/21;
                int row = i/7-page*3;
                int column = i%7;
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(12+column*45+page*scvEmoticons.frame.size.width, 16+row*45, 24, 24);
                [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"SWToolKit.bundle/Emoticons/images/%@.png",[[[emoticons objectAtIndex:i] allValues] lastObject]]] forState:UIControlStateNormal];
                [scvEmoticons addSubview:btn];
                [btn addTarget:self action:@selector(emoticonClicked:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = i;
            }
        }
            break;
        case SWEmoticonsTypeEmoji:{

        }
            break;
        default:
            break;
    }
}

- (void)changePage:(UIPageControl *)pc{
    [scvEmoticons setContentOffset:CGPointMake(pc.currentPage*scvEmoticons.frame.size.width, 0) animated:YES];
}

- (void)emoticonClicked:(UIButton *)btn{
    NSArray *order = [dicEmoticonsMap objectForKey:@"order"];
    if (SWEmoticonsTypeQQ==emoticonsType){
        if (inputTextView){
            if (inputTextView.text)
                inputTextView.text = [inputTextView.text stringByAppendingString:[[[order objectAtIndex:btn.tag] allKeys] lastObject]];
            else
                inputTextView.text = [[[order objectAtIndex:btn.tag] allKeys] lastObject];
            
            if (inputTextView.delegate && [inputTextView.delegate respondsToSelector:@selector(textViewDidChange:)]){
                [inputTextView.delegate textViewDidChange:inputTextView];
            }
        }else{
            
        }
    }
}
#pragma mark -  UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = scvEmoticons.contentOffset.x/scvEmoticons.frame.size.width;
    
    pcEmoticons.currentPage = page;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){
        int page = scvEmoticons.contentOffset.x/scvEmoticons.frame.size.width;
        
        pcEmoticons.currentPage = page;
    }
}

@end

#pragma mark - Custom Corner Radius TableView Cell
@implementation SWCCTableViewCell
@synthesize fTitlePadding,indexPath,seperatorColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self){
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        lineTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, .5f)];
        lineTop.backgroundColor = [UIColor colorWithWhite:.77 alpha:1];
        [self.contentView addSubview:lineTop];
        lineTop.hidden = YES;
        
        lineBottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, .5f)];
        lineBottom.backgroundColor = [UIColor colorWithWhite:.77 alpha:1];
        [self.contentView addSubview:lineBottom];
    }
    
    
    return self;
}

- (void)updateShape:(SWCCCellType)type{
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    float p = 0==self.fTitlePadding?41:self.fTitlePadding;
    
    BOOL isTop = NO,isBottom = NO;
    switch (type) {
        case SWCCCellTypeSingle:
        case SWCCCellTypeTop:
            isTop = YES;
            break;   
        default:
            break;
    }
    switch (type) {
        case SWCCCellTypeBottom:
        case SWCCCellTypeSingle:
            isBottom = YES;
            break;  
        default:
            break;
    }
    
    lineTop.hidden = !isTop;
    if (!isBottom)
        lineBottom.frame = CGRectMake(p, h-.5f, w-p, .5f);
    else
        lineBottom.frame = CGRectMake(0, h-.5f, w, .5f);
    
    if (seperatorColor){
        lineTop.backgroundColor = seperatorColor;
        lineBottom.backgroundColor = seperatorColor;
    }
}

- (void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
    
    [self updateShape:cellType];
}


- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    UIView *v = newSuperview;
    while (v && ![v isKindOfClass:[UITableView class]]) v = v.superview;
    UITableView *tv = (UITableView *)v;
    id<UITableViewDataSource> delegate = tv.dataSource;
    
    int last = [delegate tableView:tv numberOfRowsInSection:indexPath.section]-1;
    
    if (0==indexPath.row && last==indexPath.row)
        cellType = SWCCCellTypeSingle;
    else if (indexPath.row==0)
        cellType = SWCCCellTypeTop;
    else if (indexPath.row==last)
        cellType = SWCCCellTypeBottom;
    else
        cellType = SWCCCellTypeMiddle;
    
    [self updateShape:cellType];
}

- (void)setIndexPath:(NSIndexPath *)indexp{
    indexPath = indexp;

    UIView *v = self;
    while (v && ![v isKindOfClass:[UITableView class]]) v = v.superview;
    UITableView *tv = (UITableView *)v;
    id<UITableViewDataSource> delegate = tv.dataSource;
    
    int last = [delegate tableView:tv numberOfRowsInSection:indexPath.section]-1;
    
    if (0==indexPath.row && last==indexPath.row)
        cellType = SWCCCellTypeSingle;
    else if (indexPath.row==0)
        cellType = SWCCCellTypeTop;
    else if (indexPath.row==last)
        cellType = SWCCCellTypeBottom;
    else
        cellType = SWCCCellTypeMiddle;
            
    [self updateShape:cellType];
}

- (void)animateStroke{
    return;
    
    
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
//    if (highlighted){
//        [shapeLayer setFillColor:[[UIColor colorWithWhite:.86 alpha:1] CGColor]];
//    }else{
//        [shapeLayer setFillColor:[[UIColor colorWithWhite:.96 alpha:1] CGColor]];
//    }
//    
//    [shapeLayer setNeedsDisplay];
//}

@end

@implementation UIView(SWExtensions)

+ (UIView *)noDataTipsForTableView:(UITableView *)tableView target:(id)target{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ABWifiLogo.png"]];
    imgv.center = CGPointMake(160, imgv.frame.size.height/2);
    [v addSubview:imgv];
    
    UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(0, 72, 320, 15) font:[UIFont systemFontOfSize:15] textColor:[UIColor colorWithWhite:.64 alpha:1]];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = @"数据加载失败";
    [v addSubview:lbl];
    
    lbl = [UILabel createLabelWithFrame:CGRectMake(0, 100, 320, 15) font:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithWhite:.64 alpha:1]];
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.text = @"请检查您的设备是否已联网，点击重新加载";
    [v addSubview:lbl];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(-1, 135, 322, 53);
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor colorWithWhite:.78 alpha:1].CGColor;
    [btn setTitleColor:[UIColor colorWithRed:0 green:.48 blue:1 alpha:1] forState:UIControlStateNormal];
    [btn setTitle:@"重新加载" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [v addSubview:btn];
    [btn addTarget:target action:@selector(reloadClicked) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect rect = v.frame;
    rect.size.height = btn.frame.origin.y+btn.frame.size.height;
    v.frame = rect;
    
    UIView *fullv = [[UIView alloc] initWithFrame:tableView.bounds];
    v.center = CGPointMake(160, fullv.frame.size.height/2);
    [fullv addSubview:v];
    
    return fullv;
}

@end