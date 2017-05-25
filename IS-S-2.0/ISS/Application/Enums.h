//
//  Enums.h
//  ISS
//
//  Created by Anshuman Dahale on 5/26/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#ifndef Enums_h
#define Enums_h

//Classify the categories in following categories

typedef NS_ENUM (NSInteger, Key_Category) {
    
    Key_Category_Alphabet, // A, B ...Z
    Key_Category_Numeric, // 0, 1 ..9
    Key_Category_Arrow, // <-, ->, up arrow, down arrow
    Key_Category_KeyBoard_Functional, //Enter, Backspace, +/-, ., /
    Key_Category_Cockpit_Functional, // XPDR 1, ...VFR
    
    //HomeVC
    Key_Category_Cockpit_Special, //MAP, FMS ...PREV, NEXT, L PDF, R PDF
};


typedef NS_ENUM (NSInteger, Key_State) {
    
    Key_State_Default,      // Normal Background color
    Key_State_Highlighted    // Green background color
};


typedef NS_ENUM (NSInteger, Key_Theme) {
    
    Key_Theme_White,
    Key_Theme_LightGray,
    Key_Theme_DarkGray
};

typedef NS_ENUM (NSInteger, Frequency_Type) {
    
    Frequency_Type_COM1,
    Frequency_Type_COM2,
    Frequency_Type_NAV1,
    Frequency_Type_NAV2,
    Frequency_Type_ADF,
    Frequency_Type_TSP
};

typedef NS_ENUM (NSInteger, Encryption_Key_Type) {
    
    Encryption_Key_Type_AES,
    Encryption_Key_Type_IV
};

#endif /* Enums_h */
