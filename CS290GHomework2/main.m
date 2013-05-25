//
//  main.m
//  CS290GHomework2
//
//  Created by Johan Henkens on 5/11/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CS290GECC/CS290GECC.h>
#import <openssl/bn.h>

void HW2Driver()
{
    
#ifdef DEBUG
    NSLog(@"Running in debug CS290GECC");
#endif
    PrimeCurve* curve = [ECC getD121Curve];
    
    BIGNUM* rand192 = BN_new();
    BIGNUM* rand144 = BN_new();
    BIGNUM* rand96 = BN_new();
    BigPoint* resAff = [[BigPoint alloc] init];
    BigPoint* resJab = [[BigPoint alloc] init];
    
    BN_rand(rand192, 192, 0, false);
    while(BN_cmp(rand192,[curve n]) >= 0)
    {
        BN_rand(rand192, 192, 0, false);
    }
    BN_rand(rand144, 144, 0, false);
    BN_rand(rand96, 96, 0, false);
    NSLog(@"N192: %s",BN_bn2dec(rand192));
    NSLog(@"N144: %s",BN_bn2dec(rand144));
    NSLog(@"N96: %s",BN_bn2dec(rand96));
    
    [curve multGByD:rand192 result:resAff];
    [curve multGByJacobianD:rand192 result:resJab];
    NSLog(@"Testing equality with 192 bit...");
    assert([resAff isEqual:resJab]);
    
    [curve multGByD:rand144 result:resAff];
    [curve multGByJacobianD:rand144 result:resJab];
    NSLog(@"Testing equality with 144 bit...");
    assert([resAff isEqual:resJab]);
    
    [curve multGByD:rand96 result:resAff];
    [curve multGByJacobianD:rand96 result:resJab];
    NSLog(@"Testing equality with 96 bit...");
    assert([resAff isEqual:resJab]);
    NSLog(@"Testing done! Beginning performance timings...");
    
    BIGNUM* curr;
    for(int i = 0; i <3; i++){
        int iterations = 0;
        int bits = 0;
        NSTimeInterval start, duration;
        switch(i){
            case 0:
                curr = rand192;
                bits = 192;
                iterations = 2000;
                break;
            case 1:
                curr = rand144;
                bits = 144;
                iterations = 3500;
                break;
            case 2:
                curr = rand96;
                bits = 96;
                iterations = 4500;
                break;
            default:
                exit(1);
        }
        
        if(TARGET_OS_IPHONE || TARGET_OS_EMBEDDED){
            iterations/=10;
        }
        
        start = [NSDate timeIntervalSinceReferenceDate];
        for(int i = 0; i < iterations;i++){
            [curve multGByD:curr result:resAff];
        }
        duration = [NSDate timeIntervalSinceReferenceDate] - start;
        NSLog(@"Finished affine testing for %d bits with %d iterations. Duration: %f, Average: %f",bits,iterations,duration,duration/iterations);
        
        start = [NSDate timeIntervalSinceReferenceDate];
        for(int i = 0; i < iterations;i++){
            [curve multGByJacobianD:curr result:resAff];
        }
        duration = [NSDate timeIntervalSinceReferenceDate] - start;
        NSLog(@"Finished projective testing for %d bits with %d iterations. Duration: %f, Average: %f",bits,iterations,duration,duration/iterations);
        
    }
    NSLog(@"Done with performance testing!");
}


int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        HW2Driver();
        // insert code here...
    }
    return 0;
}

