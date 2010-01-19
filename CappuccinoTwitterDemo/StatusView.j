@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "StatusBubbleView.j"
@import "RoundedImageView.j"
@import "AppController.j"

@implementation StatusView : CPView
{
	UpdateStatusView updateStatusView @accessors;
	RoundedImageView icon;	
	RoundedImageView retweetIcon;
	StatusBubbleView bubble @accessors (readonly);
	id status;
}
 
- (void)setRepresentedObject:(id)representedStatus
{	
	status = representedStatus;
	
	var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
    var screenName = [twitterRequestManager screenName];
    
	var width = CGRectGetWidth([self bounds]);
    var isMe = (status.user.screen_name === screenName) ? YES : NO;
    var mentionsMe = (status.text.toLowerCase().indexOf(screenName) >= 0) ? YES : NO;
	var bubbleX = 60; 
	if (isMe === YES)
	{
		bubbleX = 5; 
	}
	var bubbleRect = CGRectMake(bubbleX, 0.0, width - 60.0, 60.0);
	bubble = [[StatusBubbleView alloc] initWithFrame:bubbleRect isMe:isMe mentionsMe:mentionsMe withStatus:status];
	[self addSubview:bubble];
	bubbleRect = [bubble bounds];
	var bubbleHeight = CGRectGetHeight(bubbleRect);
	if (bubbleHeight < 60)
	{
		[bubble setFrameOrigin:CGPointMake(bubbleX, 60/2 - bubbleHeight/2)];
		bubbleRect = [bubble bounds];
	}

	var bubbleHeight = CGRectGetHeight(bubbleRect); 
	var height = bubbleHeight < 60 ? 60 : bubbleHeight;
	var frameSize = CGSizeMake(width, height);
	[self setFrameSize:frameSize];

    var iconX = 5;
	if (isMe === YES)
	{
		iconX = width - 55.0;
	}
	icon = [[RoundedImageView alloc] initWithFrame:CGRectMake(iconX, height/2 - 50/2, 50, 50)]; // TODO:	
	var image = [[CPImage alloc] initWithContentsOfFile:status.user.profile_image_url size:CGSizeMake(50, 50)];
	[icon setImage:image];
	[self addSubview:icon];	
	
/*	TODO: complete
	if (status.retweeted_status)
	{
		rtIcon = [[RoundedImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(bounds) - 60.0, 35, 25, 25)];
		[rtIcon setImage:[[CPImage alloc] initWithContentsOfFile:status.retweeted_status.user.profile_image_url size:CGSizeMake(25, 25)]];
		[self addSubview:rtIcon];
	}
*/
}

- (void)updateTimestamp
{
	[bubble updateTimestamp];
}

- (void)mouseDown:(CPEvent)anEvent
{
	[[updateStatusView text] setObjectValue:"@" + status.user.screen_name + " "];
	[updateStatusView controlTextDidChange:nil];
}

@end