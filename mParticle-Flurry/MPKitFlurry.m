#import "MPKitFlurry.h"
#import <CoreLocation/CoreLocation.h>
#import "MPIHasher.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import <Flurry_iOS_SDK/Flurry_iOS_SDK.h>
#import "MPEnums.h"

@implementation MPKitFlurry

+ (NSNumber *)kitCode {
    return @83;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Flurry" className:@"MPKitFlurry"];
    [MParticle registerExtension:kitRegister];
}

#pragma mark MPKitInstanceProtocol methods
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    
    if (!configuration[@"apiKey"]) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }
    
    _configuration = configuration;
    _started = NO;
    
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[[self class] kitCode] returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (void)start {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Boolean crashReporting = NO;
        if ([self.configuration[@"captureExceptions"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
            crashReporting = YES;
        }
        
        FlurrySessionBuilder* builder = [[[FlurrySessionBuilder new]
        withLogLevel:FlurryLogLevelCriticalOnly]
        withCrashReporting:crashReporting];

        [Flurry startSession:self.configuration[@"apiKey"] withSessionBuilder:builder];
        
    });
    
    self->_started = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

- (MPKitExecStatus *)beginTimedEvent:(MPEvent *)event {
    FlurryEventRecordStatus flurryRecordStatus = FlurryEventFailed;
    
    if (event.customAttributes) {
        flurryRecordStatus = [Flurry logEvent:event.name withParameters:event.customAttributes timed:YES];
    } else {
        flurryRecordStatus = [Flurry logEvent:event.name timed:YES];
    }
    
    MPKitReturnCode kitReturnCode = flurryRecordStatus != FlurryEventFailed ? MPKitReturnCodeSuccess : MPKitReturnCodeFail;
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:kitReturnCode];
    
    return execStatus;
}

- (MPKitExecStatus *)endTimedEvent:(MPEvent *)event {
    [Flurry endTimedEvent:event.name withParameters:event.customAttributes];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)logBaseEvent:(nonnull MPBaseEvent *)event {
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else {
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceAppboy) returnCode:MPKitReturnCodeUnavailable];
    }
}

- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    FlurryEventRecordStatus flurryRecordStatus = FlurryEventFailed;
    
    if (event.customAttributes) {
        flurryRecordStatus = [Flurry logEvent:event.name withParameters:event.customAttributes];
    } else {
        flurryRecordStatus = [Flurry logEvent:event.name];
    }
    
    MPKitReturnCode kitReturnCode = flurryRecordStatus != FlurryEventFailed ? MPKitReturnCodeSuccess : MPKitReturnCodeFail;
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:kitReturnCode];
    
    return execStatus;
}

- (MPKitExecStatus *)logError:(NSString *)message eventInfo:(NSDictionary *)eventInfo {
    NSError *error = [NSError errorWithDomain:message code:1 userInfo:eventInfo];
    [Flurry logError:message message:message error:error];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logException:(NSException *)exception {
    [Flurry logError:[exception name] message:[exception reason] exception:exception];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    FlurryEventRecordStatus flurryRecordStatus = FlurryEventFailed;

    if (event.customAttributes) {
        flurryRecordStatus = [Flurry logEvent:event.name withParameters:event.customAttributes];
    } else {
        flurryRecordStatus = [Flurry logEvent:event.name];
    }
    
    MPKitReturnCode kitReturnCode = flurryRecordStatus != FlurryEventFailed ? MPKitReturnCodeSuccess : MPKitReturnCodeFail;
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:kitReturnCode];
    return execStatus;
}

- (MPKitExecStatus *)setDebugMode:(BOOL)debugMode {
    if (debugMode) {
        [Flurry setLogLevel:FlurryLogLevelAll];
    } else {
        [Flurry setLogLevel:FlurryLogLevelNone];
    }
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options API_AVAILABLE(ios(9.0)){
    [Flurry addSessionOrigin:options[UIApplicationOpenURLOptionsSourceApplicationKey] withDeepLink:[url absoluteString]];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [Flurry addSessionOrigin:sourceApplication withDeepLink:[url absoluteString]];
    
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    MPKitExecStatus *execStatus;
    
    if ([key isEqualToString:mParticleUserAttributeAge]) {
        [Flurry setAge:(int)[value integerValue]];
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    } else if ([key isEqualToString:mParticleUserAttributeGender]) {
        [Flurry setGender:value];
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
    } else {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeUnavailable];
    }
    
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    MPKitExecStatus *execStatus;
    
    if (identityType == MPUserIdentityCustomerId && identityString.length > 0) {
        NSString *idString = nil;
        if ([self.configuration[@"hashCustomerId"] caseInsensitiveCompare:@"true"]) {
            NSData *identityData = [identityString dataUsingEncoding:NSUTF8StringEncoding];
            
            uint64_t identityHash = [MPIHasher hashFNV1a:identityData];
            idString = [@(identityHash) stringValue];
        } else {
            idString = identityString;
        }
        
        if (idString) {
            [Flurry setUserID:idString];
            execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeSuccess];
        } else {
            execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeFail];
        }
    } else {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceFlurry) returnCode:MPKitReturnCodeUnavailable];
    }
    
    return execStatus;
}

@end
