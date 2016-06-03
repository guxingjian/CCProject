//
//  SouFunCheckBox.m
//  SouFun
//
//  Created by 何庆钊 on 15/5/5.
//
//

#import "CCCheckBox.h"

@implementation CCCheckBox

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        CGRect rectImage = CGRectMake(frame.size.width/4, frame.size.height/4, frame.size.width/2, frame.size.height/2);
        
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:rectImage];
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView.layer.borderWidth = 1.0f;
        
        self.imageSelected = [UIImage imageNamed:@"common_rectcheck_select_ios7.png"];
        self.imageNormal = [UIImage imageNamed:@"common_rectcheck_normal_ios7.png"];
        
        [self addSubview:imgView];
        self.imageView = imgView;
        
        UIButton* button = [[UIButton alloc] initWithFrame:self.bounds];
        button.backgroundColor = [UIColor clearColor];
        
        [button addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        self.checkButton = button;
    }
    
    return self;
}

- (void) touchDown:(UIButton *)btn
{
    [self.imageView setImage:nil];
    self.imageView.layer.borderColor = [UIColor greenColor].CGColor;
}

- (void) touchUp:(UIButton *)btn
{
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.selected = !self.selected;
}

- (void) setSelected:(BOOL)selected
{
    _selected = selected;
    
    if(_selected)
    {
        [self.imageView setImage:self.imageSelected];
    }
    else
    {
        [self.imageView setImage:self.imageNormal];
    }
    
    if([self.checkDelegate respondsToSelector:@selector(checkStatus:)])
    {
        [self.checkDelegate checkStatus:_selected];
    }
}

- (void) setCheckable:(BOOL)checkable
{
    _checkable = checkable;
    self.checkButton.userInteractionEnabled = _checkable;
}

@end
