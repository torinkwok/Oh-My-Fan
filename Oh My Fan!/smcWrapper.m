///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import "smcWrapper.h"
#import <CommonCrypto/CommonDigest.h>

//TODO: This is the smcFanControl 2.5ß checksum, it needs to be updated for the next release.
//NSString * const smc_checksum=@"03548c5634bd01315b19c46bf329cceb";
NSString * const smc_checksum=@"6e03b7c49e9b72e12cea0ff15fdb99e7";
static NSArray *allSensors = nil;


@implementation smcWrapper
	io_connect_t conn;

+(void)init{
	SMCOpen(&conn);
    allSensors = [[NSArray alloc] initWithObjects:@"TC0D",@"TC0H",@"TC0F",@"TCAH",@"TCBH",@"TC0P",nil];
}
+(void)cleanUp{
    SMCClose(conn);
}

+(float) get_maintemp{
	float c_temp;
    
    SMCVal_t      val;
    NSString *sensor = [[NSUserDefaults standardUserDefaults] objectForKey:@"TSensor"];
    SMCReadKey2((char*)[sensor UTF8String], &val,conn);
    c_temp= ((val.bytes[0] * 256 + val.bytes[1]) >> 2)/64;
    
    if (c_temp<=0) {
        for (NSString *sensor in allSensors) {
                SMCReadKey2((char*)[sensor UTF8String], &val,conn);
                c_temp= ((val.bytes[0] * 256 + val.bytes[1]) >> 2)/64;
                if (c_temp>0) {
                    [[NSUserDefaults standardUserDefaults] setObject:sensor forKey:@"TSensor"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    break;
                }
        }
    }


	return c_temp;
}


//temperature-readout for MacPro contributed by Victor Boyer
+(float) get_mptemp{
    UInt32Char_t  keyA;
    UInt32Char_t  keyB;
    SMCVal_t      valA;
    SMCVal_t      valB;
   // kern_return_t resultA;
   // kern_return_t resultB;
    sprintf(keyA, "TCAH");
	SMCReadKey2(keyA, &valA,conn);
    sprintf(keyB, "TCBH");
	SMCReadKey2(keyB, &valB,conn);
    float c_tempA= ((valA.bytes[0] * 256 + valA.bytes[1]) >> 2)/64.0;
    float c_tempB= ((valB.bytes[0] * 256 + valB.bytes[1]) >> 2)/64.0;
    int i_tempA, i_tempB;
    if (c_tempA < c_tempB)
    {
        i_tempB = round(c_tempB);
        return i_tempB;
    }
    else
    {
        i_tempA = round(c_tempA);
        return i_tempA;
    }
}

+(int) get_fan_rpm:(int)fan_number{
	UInt32Char_t  key;
	SMCVal_t      val;
	//kern_return_t result;
	sprintf(key, "F%dAc", fan_number);
	SMCReadKey2(key, &val,conn);
	int running= _strtof(val.bytes, val.dataSize, 2);
	return running;
}	

+(int) get_fan_num{
//	kern_return_t result;
    SMCVal_t      val;
    int           totalFans;
	SMCReadKey2("FNum", &val,conn);
    totalFans = _strtoul((char *)val.bytes, val.dataSize, 10);
	return totalFans;
}

+(NSString*) get_fan_descr:(int)fan_number{
	UInt32Char_t  key;
	char temp;
	SMCVal_t      val;
	//kern_return_t result;
	NSMutableString *desc;
//	desc=[[NSMutableString alloc] initWithFormat:@"Fan #%d: ",fan_number+1];
	desc=[[[NSMutableString alloc]init] autorelease];
	sprintf(key, "F%dID", fan_number);
	SMCReadKey2(key, &val,conn);
	int i;
	for (i = 0; i < val.dataSize; i++) {
		if ((int)val.bytes[i]>32) {
			temp=(unsigned char)val.bytes[i];
			[desc appendFormat:@"%c",temp];
		}
	}	
	return desc;
}	


+(int) get_min_speed:(int)fan_number{
	UInt32Char_t  key;
	SMCVal_t      val;
	//kern_return_t result;
	sprintf(key, "F%dMn", fan_number);
	SMCReadKey2(key, &val,conn);
	int min= _strtof(val.bytes, val.dataSize, 2);
	return min;
}	

+(int) get_max_speed:(int)fan_number{
	UInt32Char_t  key;
	SMCVal_t      val;
	//kern_return_t result;
	sprintf(key, "F%dMx", fan_number);
	SMCReadKey2(key, &val,conn);
	int max= _strtof(val.bytes, val.dataSize, 2);
	return max;
}	


+ (NSString*)createCheckSum:(NSString*)path {
    NSData *d=[NSData dataWithContentsOfMappedFile:path];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5((void *)[d bytes], [d length], result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    int i;
    for(i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

//call smc binary with setuid rights and apply
// The smc binary is given root permissions in FanControl.m with the setRights method.
+(void)setKey_external:(NSString *)key value:(NSString *)value{
	NSString *launchPath = [[NSBundle mainBundle]   pathForResource:@"smc" ofType:@""];
#if FUCKING_CODE
	NSString *checksum=[smcWrapper createCheckSum:launchPath];
    //first check if it's the right binary (security)
    // MW: Disabled smc binary checksum. This should be re-enabled in an official release.
	if (![checksum  isEqualToString:smc_checksum]) {
		NSLog(@"smcFanControl: Security Error: smc-binary is not the distributed one");
		return;
	}
#endif
    NSArray *argsArray = [NSArray arrayWithObjects: @"-k",key,@"-w",value,nil];
	NSTask *task;
    task = [[NSTask alloc] init];
	[task setLaunchPath: launchPath];
	[task setArguments: argsArray];
	[task launch];
	[task release];
}

+ ( float ) CPUTemperatureInCelsius
    {
    return [ self get_maintemp ];
    }

+ ( float ) CPUTemperatureInFahrenheit
    {
    return [ self get_maintemp ] * ( 9.f / 5.f ) + 32.f;
    }

@end

//////////////////////////////////////////////////////////////////////////////

/*****************************************************************************
 **                                                                         **
 **      _________                                      _______             **
 **     |___   ___|                                   / ______ \            **
 **         | |     _______   _______   _______      | /      |_|           **
 **         | |    ||     || ||     || ||     ||     | |    _ __            **
 **         | |    ||     || ||     || ||     ||     | |   |__  \           **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _        **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|       **
 **                                           ||                            **
 **                                    ||_____||                            **
 **                                                                         **
 ****************************************************************************/
///:~