//
//  ITTestUser.m
//  MatchedUp
//
//  Created by yousheng chang on 9/5/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITTestUser.h"

@implementation ITTestUser
+(void)saveTestUserToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            NSDictionary *profile = @{@"age":@28, @"birthday":@"11/27/1885",@"firstName":@"Julie", @"gender":@"female", @"location":@"Berlin, Germany", @"name":@"Julie Adams"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"profileImage.jpeg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        PFObject *photo = [PFObject objectWithClassName:kITPhotoClassKey];
                        [photo setObject:newUser forKey:kITPhotoUserKey];
                        [photo setObject:photoFile forKey:kITPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"photo saved successfully");
                        }];
                    }
                }];
            }];
            
        }
    }];
}
@end
