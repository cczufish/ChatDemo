//
//  SWUIToolKit.h
//  Nurse
//
//  Created by Wu Stan on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#pragma mark -
#pragma mark Definations
#define kNavBGName      @""


#pragma mark -  UILabel Category
@interface UILabel(SWUIToolKit)

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font;
+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color;

@end


#pragma mark -
#pragma mark SWTextView 
/**
 UITextView subclass that adds placeholder support like UITextField has.
 */
@interface SWTextView : UITextView

/**
 The string that is displayed when there is no other text in the text view.
 
 The default value is `nil`.
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 The color of the placeholder.
 
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic, strong) UIColor *placeholderColor;

@end



#pragma mark -
#pragma mark SWImageView
/*
 *
 *  SWImageView
 *
 */
@class SWImageView;

@protocol SWImageViewDelegate

- (void)swImageViewLoadFinished:(SWImageView *)swImageView;

@end

@interface SWImageView : UIImageView{
    id<SWImageViewDelegate> __weak delegate;
}
@property (nonatomic,weak) id<SWImageViewDelegate> delegate;

- (void)loadURL:(NSString *)str;

@end


#pragma mark -
#pragma mark SWImageView
/*
 *
 *  SWButton
 *
 */
@class SWButton;

@protocol SWButtonDelegate

- (void)swButtonLoadFinished:(SWButton *)swButton;

@end

@interface SWButton : UIButton{
    id<SWButtonDelegate> __weak delegate;
}
@property (nonatomic,weak) id<SWButtonDelegate> delegate;

- (void)loadURL:(NSString *)str;

@end

#pragma mark -
#pragma mark UIImage Category
@interface UIImage(SWUIToolKit)
- (UIImage *)resizedImage:(CGSize)newSize;
- (UIImage *)croppedImage:(CGRect)area;
- (BOOL)hasFace;
@end


#pragma mark -
#pragma mark SWNavigationViewController

@interface SWNavigationViewController : UINavigationController<UINavigationControllerDelegate> {
    BOOL bShowTabBar;
}

@property BOOL bShowTabBar;

@end

@interface UINavigationBar (UINavigationBar_CustomBG)

@end


#pragma mark -
#pragma mark SWLabel
@interface SWLabel : UIView{
    NSString *strText;
    UIFont *fontLabel;
    UIColor *textColor;
    CGSize contentSize;
}
@property (nonatomic,copy) NSString *text;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic) float lineBreak;

- (void)sizeToFit;

@end




#pragma mark -  UIAlertView Extensions
@interface UIAlertView(SWExtensions)

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel;
+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate;
@end


#pragma mark - UIImage Extensions
@interface UIImage(SWExtensions)

- (UIImage *)normalizedImage;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end


#pragma mark - SWEmoticonsKeyboard

typedef enum {
    SWEmoticonsTypeQQ,
    SWEmoticonsTypeEmoji
}SWEmoticonsType;

@interface SWEmoticonsKeyboard:UIView<UIScrollViewDelegate>{
    UIScrollView *scvEmoticons;
    UIPageControl *pcEmoticons;
    
    SWEmoticonsType emoticonsType;
    NSDictionary *dicEmoticonsMap;
}
@property (nonatomic,weak) UITextField *inputTextField;
@property (nonatomic,weak) UITextView *inputTextView;
@property (nonatomic,strong) NSDictionary *dicEmoticonsMap;

@end

#pragma mark - Custom Corner Radius TableView Cell and TableView
typedef enum{
    SWCCCellTypeTop = 1,
    SWCCCellTypeMiddle,
    SWCCCellTypeBottom,
    SWCCCellTypeSingle
}SWCCCellType;

@interface SWCCTableViewCell:UITableViewCell{
    UIImageView *lineTop,*lineBottom;
    
    SWCCCellType cellType;
    float fTitlePadding;
    BOOL bAnimated;
    NSIndexPath *indexPath;
    UIColor *seperatorColor;
}
@property float fTitlePadding;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) UIColor *seperatorColor;
@end

@interface UIView(SWExtensions)

+ (UIView *)noDataTipsForTableView:(UITableView *)tableView target:(id)target;

@end
