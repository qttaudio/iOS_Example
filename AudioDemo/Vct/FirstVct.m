//
//  FirstVct.m
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import "FirstVct.h"
#import "DataManage.h"
#import "UIColor+Ext.h"

@interface FirstVct ()<UITextFieldDelegate>
//房间号
@property (weak, nonatomic) IBOutlet UITextField *tf_roomNum;
//进入房间按钮
@property (weak, nonatomic) IBOutlet UIButton *btn_enterRoom;

@end

@implementation FirstVct

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    NSString *roomNum = [DataManage getObjectFromKey:@"roomNum"];
    if (roomNum && [roomNum length] > 0) {
        self.tf_roomNum.text = roomNum;
        [self.btn_enterRoom setBackgroundColor:[UIColor colorWithHex:0x2B6AF9]];
        self.btn_enterRoom.userInteractionEnabled = YES;
    }else{
        self.btn_enterRoom.userInteractionEnabled = NO;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string

{
    BOOL mark = YES;
    
    NSInteger existedLength = textField.text.length;
    
    NSInteger selectedLength = range.length;
    
    NSInteger replaceLength = string.length;
    
    NSInteger realLength = existedLength - selectedLength + replaceLength;
    
    if((realLength == 1 && [string isEqualToString:@"0"]) || realLength > 8) {
        
        mark = NO;
        
    }else if(realLength > 0 && ![string isEqualToString:@""] && ![self checkTextIsNumber:string]){
        mark = NO;
    }
    
    if (mark) {
        //判断输入
        if (realLength == 0) {
            [self.btn_enterRoom setBackgroundColor:[UIColor colorWithHex:0xB0C9F9]];
            self.btn_enterRoom.userInteractionEnabled = NO;
        }else{
            [self.btn_enterRoom setBackgroundColor:[UIColor colorWithHex:0x2B6AF9]];
            self.btn_enterRoom.userInteractionEnabled = YES;
        }
    }
    
    return mark;
    
}
//检查是否全是数字
- (BOOL) checkTextIsNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (IBAction)enterRoomAction:(id)sender {
    [DataManage saveDataForObject:self.tf_roomNum.text AndKey:@"roomNum"];
    [self performSegueWithIdentifier:@"HomeVct" sender:nil];
}



@end
