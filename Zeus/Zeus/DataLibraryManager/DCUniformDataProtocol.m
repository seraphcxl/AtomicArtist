//
//  DCUniformDataProtocol.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCUniformDataProtocol.h"

//@implementation DCUniformDataProtocol
//
//@end


#pragma mark - Notify
NSString * const NOTIFY_DATAITEM_ADDED = @"NOTIFY_DATAITEM_ADDED";
NSString * const NOTIFY_DATAITEM_ENUM_END = @"NOTIFY_DATAITEM_ENUM_END";
NSString * const NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END = @"NOTIFY_DATAITEM_ENUMFIRSTSCREEN_END";
NSString * const NOTIFY_DATAITEMFORPOSTERIMAGE_ADDED = @"NOTIFY_DATAITEMFORPOSTERIMAGE_ADDED";
NSString * const NOTIFY_DATAGROUP_ADDED = @"NOTIFY_DATAGROUP_ADDED";
NSString * const NOTIFY_DATAGROUP_ENUM_END = @"NOTIFY_DATAGROUP_ENUM_END";
NSString * const NOTIFY_DATAGROUP_EMPTY = @"NOTIFY_DATAGROUP_EMPTY";

#pragma mark - DCDataItem
NSString * const kDATAITEMPROPERTY_UID = @"DATAITEMPROPERTY_UID";
NSString * const kDATAITEMPROPERTY_FILENAME = @"DATAITEMPROPERTY_FILENAME";
NSString * const kDATAITEMPROPERTY_URL = @"DATAITEMPROPERTY_URL";
NSString * const kDATAITEMPROPERTY_TYPE = @"DATAITEMPROPERTY_TYP";
NSString * const kDATAITEMPROPERTY_DATE = @"DATAITEMPROPERTY_DATE";
NSString * const kDATAITEMPROPERTY_ORIENTATION = @"DATAITEMPROPERTY_ORIENTATION";
NSString * const kDATAITEMPROPERTY_THUMBNAIL = @"DATAITEMPROPERTY_THUMBNAIL";
NSString * const kDATAITEMPROPERTY_ORIGINIMAGE = @"DATAITEMPROPERTY_ORIGINIMAGE";
NSString * const kDATAITEMPROPERTY_FULLSCREENIMAGE = @"DATAITEMPROPERTY_FULLSCREENIMAGE";
NSString * const kDATAITEMPROPERTY_THUMBNAILURL = @"DATAITEMPROPERTY_THUMBNAILURL";

#pragma mark - DCDataGroup
NSString * const kDATAGROUPPROPERTY_UID = @"DATAGROUPPROPERTY_UID";
NSString * const kDATAGROUPPROPERTY_GROUPNAME = @"DATAGROUPPROPERTY_GROUPNAME";
NSString * const kDATAGROUPPROPERTY_URL = @"DATAGROUPPROPERTY_URL";
NSString * const kDATAGROUPPROPERTY_TYPE = @"DATAGROUPPROPERTY_TYPE";
NSString * const kDATAGROUPPROPERTY_POSTERIMAGE = @"DATAGROUPPROPERTY_POSTERIMAGE";
NSString * const kDATAGROUPPROPERTY_POSTERIMAGEURL = @"DATAGROUPPROPERTY_POSTERIMAGEURL";
