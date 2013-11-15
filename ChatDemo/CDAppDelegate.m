//
//  CDAppDelegate.m
//  ChatDemo
//
//  Created by Stan Wu on 13-10-30.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "CDAppDelegate.h"
#import "SWDataProvider.h"
#import "SWMessagesViewController.h"

@implementation CDAppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SWMessagesViewController *vcMessages = [[SWMessagesViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vcMessages];
    
    window.rootViewController = nav;
    [window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAccount) name:@"ReloadAccount" object:nil];
        
    return YES;
}

- (void)reloadAccount{
    [XMPPWorker disconnect];
    
    managedObjectContext = nil;
    managedObjectModel = nil;
    persistentStoreCoordinator = nil;
    
    SWMessagesViewController *vcMessages = [[SWMessagesViewController alloc] init];
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    nav.viewControllers = @[vcMessages];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Core Data stack
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 **/
- (NSManagedObjectModel *)managedObjectModel
{
	if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 **/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	NSString *username = [[SWDataProvider myInfo] objectForKey:@"username"];
	NSString *storeName = [NSString stringWithFormat:@"SWXMPP%@.sqlite",username];
	NSString *storePath = [storeName temporaryPath];
    
    
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSDictionary *sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                            error:nil];
    NSManagedObjectModel *destinationModel = [self managedObjectModel];
    BOOL isCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetaData];
    if (!isCompatibile){
        if ([[NSFileManager defaultManager] fileExistsAtPath:storePath])
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
    }
    
	NSManagedObjectModel *mom = [self managedObjectModel];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
	
	NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
	                                                                              configuration:nil
	                                                                                        URL:storeUrl
	                                                                                    options:nil
	                                                                                      error:&error];
    if (persistentStore == nil)
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
    return persistentStoreCoordinator;
}

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and
 * bound to the persistent store coordinator for the application.
 **/
- (NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        NSUndoManager *anUndoManager = [[NSUndoManager	alloc] init];
    	[managedObjectContext setUndoManager:anUndoManager];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

@end
