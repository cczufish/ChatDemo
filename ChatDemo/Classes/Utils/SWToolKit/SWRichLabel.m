//
//  SWRichTextView.m
//  AiBa
//
//  Created by Stan Wu on 8/6/13.
//
//

#import "SWRichLabel.h"

static NSDictionary *dicEmotionsMap = nil;

#define KFacialSizeWidth    24
#define KFacialSizeHeight   24
#define KImgInterval 5

@implementation SWRichLabel
@synthesize text = strText,textColor = colorText,font = fontText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textColor = [UIColor blackColor];
        self.font = kPMFont;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
+ (CGSize)sizeForContent:(NSString *)str font:(UIFont *)font{
    NSArray *components = [SWRichLabel componentsOfContent:str];
        
    
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat fH = 0;
    CGSize sizeReturn=CGSizeZero;
    if (components) {
        for (int i=0;i<[components count];i++) {
            NSString *str=[components objectAtIndex:i];
            
            if ([str hasPrefix:@"["]&&[str hasSuffix: @"]"])
            {
                //表情符号
                if (upX+KFacialSizeWidth > kPMCellContentWidth)
                {
                    sizeReturn.width=kPMCellContentWidth;
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                }
                
                NSString *path = [SWRichLabel imagePath:str];
                
                
                UIImageView *ivFace = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
                ivFace.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);

                
                upX += KFacialSizeWidth;
                upX += KImgInterval;
                fH = upY+KFacialSizeHeight;
            } else {
                //纯文字部分
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    
                    
                    CGSize sizeLetter=[temp sizeWithFont:font constrainedToSize:CGSizeMake(1000, 40)];
                    if (upX+sizeLetter.width > kPMCellContentWidth)
                    {
                        sizeReturn.width=kPMCellContentWidth;
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                    }
                    upX=upX+sizeLetter.width;
                    
                    fH = upY+5+sizeLetter.height;
                    
                    
                }
                
                upX += KImgInterval;
            }
        }
    }
    
    upX -= KImgInterval;

    return CGSizeMake(sizeReturn.width>upX?sizeReturn.width:upX, fH);
}

+ (NSArray *)componentsOfContent:(NSString *)content{
    if (!content)
        return nil;
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]"
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


- (void)showText:(NSString *)text{
    for (UIView *v in self.subviews)
        [v removeFromSuperview];
    
    if (!text) {
        self.frame = CGRectZero;
        return;
    }
    
    NSArray *array = [SWRichLabel componentsOfContent:text];
    
    NSArray *data = array;
    
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat fH = 0;
    CGSize sizeReturn=CGSizeZero;
    if (data) {
        for (int i=0;i<[data count];i++) {
            NSString *str=[data objectAtIndex:i];
            
            if ([str hasPrefix:@"["]&&[str hasSuffix: @"]"])
            {
                //表情符号
                if (upX+KFacialSizeWidth > kPMCellContentWidth)
                {
                    sizeReturn.width=kPMCellContentWidth;
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                }
                
                NSString *path = [SWRichLabel imagePath:str];
                
                
                UIImageView *ivFace = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
                ivFace.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [self addSubview:ivFace];
                
                upX += KFacialSizeWidth;
                upX += KImgInterval;
                fH = ivFace.frame.origin.y+ivFace.frame.size.height;
            } else {
                //纯文字部分
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    
                    
                    CGSize sizeLetter=[temp sizeWithFont:fontText constrainedToSize:CGSizeMake(1000, 40)];
                    if (upX+sizeLetter.width > kPMCellContentWidth)
                    {
                        sizeReturn.width=kPMCellContentWidth;
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                    }
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY+5,sizeLetter.width,sizeLetter.height)];
                    la.backgroundColor = [UIColor clearColor];
                    la.textColor = colorText;
                    la.font = fontText;
                    la.text = temp;
                    [self addSubview:la];
                    upX=upX+sizeLetter.width;
                    
                    fH = la.frame.origin.y+la.frame.size.height;
                    
                    
                }
                
                upX += KImgInterval;
            }
        }
    }
    
    upX -= KImgInterval;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeReturn.width>upX?sizeReturn.width:upX, fH); //需要将该view的尺寸记下，方便以后使用
}

- (void)setText:(NSString *)text{
    strText = text;
    
    [self showText:text];
}

- (NSString *)text{
    return strText;
}

- (void)setTextColor:(UIColor *)textColor{
    colorText = textColor;
    
    for (UILabel *lbl in self.subviews)
        if ([lbl isKindOfClass:[UILabel class]])
            lbl.textColor = colorText;
}

- (UIColor *)textColor{
    return colorText;
}

- (void)setFont:(UIFont *)font{
    fontText = font;
    
    for (UILabel *lbl in self.subviews)
        if ([lbl isKindOfClass:[UILabel class]])
            lbl.font = fontText;
}

- (UIFont *)font{
    return fontText;
}

+ (NSString *)imagePath:(NSString *)str{
    if (!dicEmotionsMap)
        dicEmotionsMap = [NSDictionary dictionaryWithContentsOfFile:[@"SWToolKit.bundle/Emoticons/EmoticonsMap.plist" bundlePath]];
    
    NSString *path = [[NSString stringWithFormat:@"SWToolKit.bundle/Emoticons/images/%@.png",[[dicEmotionsMap objectForKey:@"name"] objectForKey:str]] bundlePath];
    
    return path;
}

@end
