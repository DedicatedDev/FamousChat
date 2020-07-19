//
//  Utility.h
//  Fisseha
//
//  Created by Po Cui on 01/04/17.
//  Copyright © 2017 Po Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+(UIColor*)colorWithHexString:(NSString*)hex;

+(void)setupButtonStyle:(UIButton*)btn;

+ (BOOL)validateEmailWithString:(NSString*)emailtext;

+(void)Alert:(NSString *)Message andTitle:(NSString *)Title andController:(UIViewController*)objController;

+(BOOL)checkInternetConnection;


+(NSString *)getTimeFromDate:(NSString*)strCreateDate;

+ (NSString*)base64forData:(NSData*)theData;

+(NSDate*)DateNumOfYearPrevisious:(int)year;

+(int)ageFromDOB:(NSString*)strDate;

+(NSString *)GetTimeStamp;
@end
