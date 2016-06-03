

#import <UIKit/UIKit.h>

@protocol CCCheckBoxDelegate <NSObject>

- (void) checkStatus:(BOOL) checked;

@end

@interface CCCheckBox : UIView

@property(nonatomic, assign) BOOL checkable;
@property(nonatomic, weak) UIImageView* imageView;
@property(nonatomic, strong) UIImage* imageNormal;
@property(nonatomic, strong) UIImage* imageSelected;
@property(nonatomic, weak) UIButton* checkButton;

@property(nonatomic, assign) BOOL selected;
@property(nonatomic, weak) id<CCCheckBoxDelegate> checkDelegate;


@end
