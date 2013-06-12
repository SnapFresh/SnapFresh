/*
 * Copyright 2013 Marco Abundo, Ysiad Ferreiras, Aaron Bannert, Jeremy Canfield and Michelle Koeth
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ABUtils.h"

@implementation ABUtils

#pragma mark - Map view utility methods

+ (ABRecordRef)abRecordRefFromRetailer:(SnapRetailer *)retailer
{
    CFErrorRef error = NULL;
    ABRecordRef newPerson = ABPersonCreate();
    
    ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (__bridge CFTypeRef)(retailer.name), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(retailer.name), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)(retailer.name), &error);
    
    [self setImageForContact:newPerson];
    
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    ABMultiValueAddValueAndLabel(address, (__bridge CFDictionaryRef)retailer.addressDictionary, kABWorkLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonAddressProperty, address, &error);
    
    return newPerson;
}

+ (void)setImageForContact:(ABRecordRef)contact
{
    CFErrorRef error = NULL;
    UIImage *image = [UIImage imageNamed:@"snap"];
    NSData *imageData = UIImagePNGRepresentation(image);
    CFDataRef imgDataRef = (__bridge CFDataRef)imageData;
    ABPersonSetImageData(contact, imgDataRef, &error);
}

@end
