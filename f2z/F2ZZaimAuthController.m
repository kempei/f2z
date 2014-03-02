//
//  F2ZZaimAuthController.m
//  f2z
//
//  Created by Kempei Igarashi on 2014/03/02.
//  Copyright (c) 2014年 Kempei Igarashi. All rights reserved.
//

#import "F2ZZaimAuthController.h"
#import "GTMOAuthAuthentication.h"

/*
 Request token URL
 
 https://api.zaim.net/v2/auth/request
 Authorize URL
 
 https://auth.zaim.net/users/auth
 Access token URL
 
 https://api.zaim.net/v2/auth/access
 */

@implementation F2ZZaimAuthController
{
    
}

- (GTMOAuthAuthentication *) auth
{
    NSString *myConsumerKey = @"a1ced87da17ef9dc6c60d943be9a4e93fafbabde";    // pre-registered with service
    NSString *myConsumerSecret = @"aa1120bc9993aa922c66fad7d5295801397eeb46"; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:myConsumerKey
                                                         privateKey:myConsumerSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"Custom Auth Service";
    
    return auth;
}

- (void)signInToCustomService {
    /*
    NSURL *requestURL = [NSURL URLWithString:@"http://example.com/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://example.com/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://example.com/oauth/authorize"];
    NSString *scope = @"http://example.com/scope";
    
    GTMOAuthAuthentication *auth = [self myCustomAuth];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:@"http://www.example.com/OAuthCallback"];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:requestURL
                                                       authorizeTokenURL:authorizeURL
                                                          accessTokenURL:accessURL
                                                          authentication:auth
                                                          appServiceName:@"My App: Custom Service"
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
     */
}

- (void) sendHistory
{
    /*
    NSMutableURLRequest *request
    = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"送信先URL"]];
    GTMMIMEDocument *doc = [GTMMIMEDocument MIMEDocument];
    
    // keywordはNSString
    NSMutableDictionary *headers
    = [NSMutableDictionary dictionaryWithObject:@"form-data; name=\"keyword\"" forKey:@"Content-Disposition"];
    [doc addPartWithHeaders:headers body:[keyword dataUsingEncoding:NSUTF8StringEncoding]];
    
    // entryTextはNSString
    headers = [NSMutableDictionary dictionaryWithObject:@"form-data; name=\"status\"" forKey:@"Content-Disposition"];
    [doc addPartWithHeaders:headers body:[entryText dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    // ::
    // いろいろ
    // ::
    //authはGTMOAuthAuthentication
    [auth authorizeRequest:request];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher setPostStream:stream];
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(送信したあと)];
     */
}

@end
