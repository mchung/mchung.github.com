@import <Foundation/Foundation.j>
@import "AppController.j";

var twitterRequestManager = nil; 

@implementation TwitterRequestManager : CPObject
{
	CPArray requests;
	CPTimer requestsTimer;
	Boolean isPerformingRequest @accessors;

	id user @accessors;
	CPString screenName @accessors;
	CPString password @accessors;
	CPTimer friendsTimelineTimer;
	TimelineView friendsTimelineView @accessors;
	int lastId @accessors;
}

+ (TwitterRequestManager)twitterRequestManager 
{ 
    if (!twitterRequestManager) 
	{
        twitterRequestManager = [[TwitterRequestManager alloc] init]; 
	}
    return twitterRequestManager; 
}

- (id)init
{
    self = [super init]; 
    if (self) 
	{ 
		screenName = nil;
		password = nil;
		lastId = 0;
		requests = [];
		isPerformingRequest = NO;
		requestsTimer = [CPTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(performRequests:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void)performRequests:(CPTimer)timer
{
	if (isPerformingRequest === NO)
	{
		var requestHelper = [requests lastObject];
		if (requestHelper)
		{
			[requests removeLastObject];
			var connectionType = [requestHelper connectionType];
			if ([connectionType isEqualToString:@"CPJSONPConnection"])
			{
				[objj_getClass(connectionType) connectionWithRequest:[requestHelper request] callback:@"callback" delegate:requestHelper];
			}
			else 
			{
				[objj_getClass(connectionType) connectionWithRequest:[requestHelper request] delegate:requestHelper];
			}
		}
	}
}

- (void)showUser:(id)screenName withDelegate:(id)delegate andSelector:(SEL)selector
{
	var url = @"http://twitter.com/users/show/" + screenName + @".json";	
	var request = [CPURLRequest requestWithURL:url];
    var requestHelper = [[RequestHelper alloc] init];
	[requestHelper setRequest:request];
	[requestHelper setManager:self];
	[requestHelper setDelegate:delegate];
	[requestHelper setConnectionType:@"CPJSONPConnection"];
	[requestHelper setSelector:selector];
	[requests insertObject:requestHelper atIndex:0];	
}

- (void)setupFriendsTimeline:(TimelineView)timelineView
{
	friendsTimelineView = timelineView;
	friendsTimelineTimer = [CPTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateFriendsTimeline:) userInfo:nil repeats:YES];
	[self updateFriendsTimeline:nil];
} 

- (void)updateFriendsTimeline:(CPTimer)aTimer
{
	var url = @"http://" + screenName + @":" + password + @"@www.twitter.com/status/friends_timeline/" + screenName + @".json?";
    if (lastId === 0) 
	{
	    url += @"count=50";
	}
	else if (lastId > 0)
	{
		url += @"since_id=" + lastId;
	}
	var request = [CPURLRequest requestWithURL:url];
    var requestHelper = [[RequestHelper alloc] init];
	[requestHelper setRequest:request];
	[requestHelper setManager:self];
	[requestHelper setDelegate:requestHelper];
	[requestHelper setConnectionType:@"CPJSONPConnection"];
	[requestHelper setSelector:@selector(updateFriendsTimelineComplete:)]
	[requests insertObject:requestHelper atIndex:0];
}

- (void)updateStatus:(id)status withDelegate:(id)delegate
{
	var url = @"http://twitter.com/statuses/update.json";
	var request = [CPURLRequest requestWithURL:url];
	var body = @"status=" + status;
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self authorisationValue] forHTTPHeaderField:@"Authorization"];
	[request setValue:[body length] forHTTPHeaderField:@"Content-Length"];
 	[request setHTTPBody:body];

    var requestHelper = [[RequestHelper alloc] init];
	[requestHelper setManager:self];
	[requestHelper setRequest:request];
	[requestHelper setDelegate:delegate]
	[requestHelper setConnectionType:"CPURLConnection"];
	[requestHelper setSelector:@selector(updateStatusComplete:)]
	[requests insertObject:requestHelper atIndex:0];
}

- (void)retweet(id)status withDelegate:(id)delegate
{
	callback = andCallback;
	var url = @"http://api.twitter.com/1/statuses/retweet/" + status.id + @".json";
	var request = [CPURLRequest requestWithURL:url];
	var body = @"id=" + status.id;
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self authorisationValue] forHTTPHeaderField:@"Authorization"];
	[request setValue:[body length] forHTTPHeaderField:@"Content-Length"];
 	[request setHTTPBody:body];

    var requestHelper = [[RequestHelper alloc] init];
	[requestHelper setManager:self];
	[requestHelper setRequest:request];
	[requestHelper setDelegate:delegate];
	[requestHelper setConnectionType:@"CPURLConnection"];
	[requestHelper setSelector:@selector(retweetComplete:)]
	[requests insertObject:requestHelper atIndex:0];
}

- (CPString)authorisationValue
{
	return @"Basic " + base64_encode_string(screenName + @":" + password);
}

@end

@implementation RequestHelper : CPObject
{
	TwitterRequestManager manager @accessors;
	CPString connectionType @accessors;
	CPURLRequest request @accessors;
	id delegate @accessors;
	SEL selector @accessors;
}

- (void)connection:(id)aConnection didReceiveData:(id)response
{
	[manager setIsPerformingRequest:NO];
	[delegate performSelector:selector withObject:response];
}

- (void)connection:(id)aConnection didFailWithError:(CPString)error
{
	[manager setIsPerformingRequest:NO];
}

- (void)updateFriendsTimelineComplete:(id)response
{
	var lastId = [manager lastId];
	var data = [friendsTimelineView content];
	var object, enumerator = [response objectEnumerator];
	while ((object = [enumerator nextObject] ) !== nil)
    {		
		[data setObject:object forKey:object.id];
		if (lastId < object.id)
		{
			lastId = object.id;
		}
	}
	[manager setLastId:lastId];
	[[manager friendsTimelineView] reloadContent];
}

@end

/*
url = "http://api.twitter.com/1/statuses/retweeted_by_me.json";
if (lastId === 0) 
{
    url += "count=10";
}
else if (lastId > 0)
{
	url += "since_id=" + lastId;
}
//var request = [CPURLRequest requestWithURL:url];
//var connection = [CPJSONPConnection connectionWithRequest:request callback:"callback" delegate:self];

url = "http://api.twitter.com/1/statuses/retweeted_to_me.json";
if (lastId === 0) 
{
    url += "count=10";
}
else if (lastId > 0)
{
	url += "since_id=" + lastId;
}
var request = [CPURLRequest requestWithURL:url];
var connection = [CPJSONPConnection connectionWithRequest:request callback:"callback" delegate:self];

url = "http://api.twitter.com/1/statuses/retweets_of_me.json";
if (lastId === 0) 
{
    url += "count=10";
}
else if (lastId > 0)
{
	url += "since_id=" + lastId;
}
var request = [CPURLRequest requestWithURL:url];
var connection = [CPJSONPConnection connectionWithRequest:request callback:"callback" delegate:self];
*/