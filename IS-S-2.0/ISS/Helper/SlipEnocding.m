//
//  SlipEnocding.m
//  ISS
//
//  Created by Anshuman Dahale on 3/13/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//


#import "SlipEnocding.h"
#import "NSString+Conversion.h"

@implementation SlipEnocding

#pragma mark SLIP Encoding

#define MAX_SLIP_DEV_WRITE_SIZE 1024

#define SLIP_START   0xC0
#define SLIP_END     0xC0
#define SLIP_ESC     0xDB
#define SLIP_ESC_END 0xDC
#define SLIP_ESC_ESC 0xDD



// SLIP Working
/****************************************************************************************************
 SLIP modifies a standard TCP/IP datagram by

 1. appending a special "END" byte to it, which distinguishes datagram boundaries in the byte stream,
 2. if the END byte occurs in the data to be sent, the two byte sequence ESC, ESC_END is sent instead,
 3. if the ESC byte occurs in the data, the two byte sequence ESC, ESC_ESC is sent.
 4. variants of the protocol may begin, as well as end, packets with END.
 
****************************************************************************************************/

- (NSData *) SLIPEncodeData:(NSData *)data {
    
    unsigned char *dataArray = (unsigned char *)[data bytes];
    unsigned char packet[[data length]];
    
    NSMutableData *destinationData = [[NSMutableData alloc] init];
    
    //Append the "Start Bit" 0xC0 to destination packet
    //this marks as the begining of the packet
    UInt8 j= SLIP_START;
    NSData *endDataBit = [[NSData alloc] initWithBytes:&j length:sizeof(j)];
    [destinationData appendData:endDataBit];
    
    //Iterate through each bit in the recieved data packet
    for(int i = 0; i < [data length]; i++) {
        
        //get the bit at index i
        packet[i] = dataArray[i];
//        NSLog(@"%2x", packet[i]);
        
        //if the bit at index i is a end bit
        //check if its not the last bit in the packet
        if((packet[i] == SLIP_END) && i != [data length]-1) {
            
            UInt8 escapeBit = SLIP_ESC;
            NSData *escapeBitData = [[NSData alloc] initWithBytes:&escapeBit length:sizeof(escapeBit)];
            
            UInt8 escapeEndBit = SLIP_ESC_END;
            NSData *escapeEndBitData = [[NSData alloc] initWithBytes:&escapeEndBit length:sizeof(escapeEndBit)];
            
            [destinationData appendData:escapeBitData];
            [destinationData appendData:escapeEndBitData];
        }
        
        else if (packet[i] == SLIP_ESC) {
            
            UInt8 escapeBit = SLIP_ESC;
            NSData *escapeBitData = [[NSData alloc] initWithBytes:&escapeBit length:sizeof(escapeBit)];
            
            UInt8 doubleEscapeBit = SLIP_ESC_ESC;
            NSData *doubleEscapeBitData = [[NSData alloc] initWithBytes:&doubleEscapeBit length:sizeof(doubleEscapeBit)];
            
            [destinationData appendData:escapeBitData];
            [destinationData appendData:doubleEscapeBitData];
        }
        
        else {
            
            UInt8 aBit = packet[i];
            NSData *aBitData = [[NSData alloc] initWithBytes:&aBit length:sizeof(aBit)];
            [destinationData appendData:aBitData];
        }
    }
    [destinationData appendData:endDataBit];
//    NSLog(@"Destination Data: %@", destinationData);
    return destinationData;
}


- (NSData *) SLIPDecodeData:(NSData *)data {
    
    unsigned char *dataArray = (unsigned char *)[data bytes];
    NSMutableData *destinationData = [[NSMutableData alloc] init];
    
    //Iterate through the recieved packet
    for(int i = 0; i < [data length]; i++) {
        
        unsigned char bit = dataArray[i];
        
        //The packet will contain SLIP_END bit at first and last location
        //if its the last location, it marks the end of the packet
        //the below code to skip the SLIP_END bit can be written in many other ways
        if(bit == SLIP_END) {
        
            if(i == [data length]) {
                break;
            }
            if(i == 0) {
                continue;
            }
        }
        
        //If its a escap bit, the next bit will decide its fate
        if(bit == SLIP_ESC) {
            
            i++;
            unsigned char nextBit = dataArray[i];
            switch (nextBit) {
                case SLIP_ESC_ESC:
                    {
                        UInt8 escapeBit = SLIP_ESC;
                        NSData *escapeBitData = [[NSData alloc] initWithBytes:&escapeBit length:sizeof(escapeBit)];
                        [destinationData appendData:escapeBitData];
                    }
                    break;
                    
                case SLIP_ESC_END:
                    {
                        UInt8 endBit = SLIP_END;
                        NSData *escapeBitData = [[NSData alloc] initWithBytes:&endBit length:sizeof(endBit)];
                        [destinationData appendData:escapeBitData];
                    }
                    break;
                    
                default:
                    break;
            }
        }
        
        //Its a normal bit, add it directly to the destination data
        else {
            UInt8 aBit = dataArray[i];
            NSData *aBitData = [[NSData alloc] initWithBytes:&aBit length:sizeof(aBit)];
            [destinationData appendData:aBitData];
        }
    }
    
    NSLog(@"Encoded Data: %@", data);
    NSLog(@"Decoded Data: %@", destinationData);
    return destinationData;
}


//int SlipEncode(void *dstBuffer, unsigned int dstBytes, void *srcBuffer, unsigned int srcBytes)
//{
//   int numEncodedBytes = 0;
//   int i;
//   unsigned char *pDst = dstBuffer;
//   unsigned char *pSrc = srcBuffer;
//
//   if (pSrc && pDst && (srcBytes >= 1) && (srcBytes <= MAX_SLIP_DEV_WRITE_SIZE))
//   {
//      *pDst++ = SLIP_END; numEncodedBytes++;
//
//      for (i = 0; (i < srcBytes) && (numEncodedBytes < dstBytes); i++)
//      {
//         switch (pSrc[i])
//         {
//         case SLIP_END:
//            *pDst++ = SLIP_ESC; numEncodedBytes++;
//            *pDst++ = SLIP_ESC_END; numEncodedBytes++;
//            break;
//         case SLIP_ESC:
//            *pDst++ = SLIP_ESC; numEncodedBytes++;
//            *pDst++ = SLIP_ESC_ESC; numEncodedBytes++;
//            break;
//         default:
//            *pDst++ = pSrc[i]; numEncodedBytes++;
//            break;
//         }
//      }
//
//      *pDst++ = SLIP_END; numEncodedBytes++;
//   }
//
//   return numEncodedBytes;
//}



@end
