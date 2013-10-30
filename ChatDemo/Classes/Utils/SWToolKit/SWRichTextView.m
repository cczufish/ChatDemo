//
//  SWRichTextView.m
//  AiBa
//
//  Created by Stan Wu on 8/6/13.
//
//

#import "SWRichTextView.h"

static NSDictionary *dicEmotionsMap = nil;

@implementation SWRichTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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



//imageview + label 格式
#define BEGIN_FLAG @"["
#define END_FLAG @"]"


//把message分离成符号描述 纯文字等几个部分到array
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    
    //判断当前字符串是否有表情的标志。
    if (range.length && range1.length) {
        if (range.location>0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
    }else {
        if (message != nil) {
            [array addObject:message];
        }
    }
}

#define KFacialSizeWidth    24
#define KFacialSizeHeight   24
#define KImgInterval 5
//把文本转换成图文混排的一个view
-(UIView *)assembleMessageAtIndex : (NSString *) message
{
    if (message) {
        if (message.length > 0) {
            if ([message isEqualToString:@" "]) {
                UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
                return returnView;
            }
        }else{
            return nil;
        }
    }else{
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    returnView.backgroundColor = [UIColor clearColor];
    NSArray *data = array;
    UIFont *fon = kPMFont;
    
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat fH = 0;
    CGSize sizeReturn=CGSizeZero;
    if (data) {
        for (int i=0;i<[data count];i++) {
            NSString *str=[data objectAtIndex:i];
            
            if ([str hasPrefix: BEGIN_FLAG]&&[str hasSuffix: END_FLAG])
            {
                //表情符号
                if (upX+KFacialSizeWidth > kPMCellContentWidth)
                {
                    sizeReturn.width=kPMCellContentWidth;
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                }
                
                NSString *path = [SWRichTextView imagePath:str];
                
                
                UIImageView *ivFace = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
                ivFace.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:ivFace];

                upX += KFacialSizeWidth;
                upX += KImgInterval;
                fH = ivFace.frame.origin.y+ivFace.frame.size.height;
            } else {
                //纯文字部分
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    
                    
                    CGSize sizeLetter=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(1000, 40)];
                    if (upX+sizeLetter.width > kPMCellContentWidth)
                    {
                        sizeReturn.width=kPMCellContentWidth;
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                    }
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY+5,sizeLetter.width,sizeLetter.height)];
                    la.backgroundColor = [UIColor clearColor];
                    la.font = fon;
                    la.text = temp;
                    [returnView addSubview:la];
                    upX=upX+sizeLetter.width;
                    
                    fH = la.frame.origin.y+la.frame.size.height;
                    

                }
                
                upX += KImgInterval;
            }
        }
    }
    
    upX -= KImgInterval;
    returnView.frame = CGRectMake(0, 0, sizeReturn.width>upX?sizeReturn.width:upX, fH); //需要将该view的尺寸记下，方便以后使用
    return returnView;
}

+ (NSString *)imagePath:(NSString *)str{
    if (!dicEmotionsMap)
        dicEmotionsMap = [NSDictionary dictionaryWithContentsOfFile:[@"SWToolKit.bundle/Emoticons/EmoticonsMap.plist" bundlePath]];
    
    NSString *path = [[NSString stringWithFormat:@"SWToolKit.bundle/Emoticons/images/%@.png",[[dicEmotionsMap objectForKey:@"name"] objectForKey:str]] bundlePath];
    
    return path;
}

@end
