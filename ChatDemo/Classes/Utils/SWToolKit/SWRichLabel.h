//
//  SWRichTextView.h
//  AiBa
//
//  Created by Stan Wu on 8/6/13.
//
//

#import <UIKit/UIKit.h>

@interface SWRichLabel : UIView{
    NSString *strText;
    UIColor *colorText;
    UIFont *fontText;
}
@property (nonatomic,copy) NSString *text;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIFont *font;

+ (CGSize)sizeForContent:(NSString *)str font:(UIFont *)font;

@end
