@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "BubbleView.j"

@implementation StatusBubbleView : BubbleView
{
	Boolean isMe @accessors (readonly);
	Boolean mentionsMe @accessors (readonly);
	CPTextField nameField;
	CPTextField timestampField;
	CPTextField textField @accessors (readonly);
	id status @accessors (readonly);
}

- (id)initWithFrame:(CPRect)frameRect isMe:(Boolean)initIsMe mentionsMe:(Boolean)initMentionsMe withStatus:(id)initStatus
{
    self = [super initWithFrame:frameRect isLeftFacing:!initIsMe];
	if (self)
	{
		isMe = initIsMe;
		mentionsMe = initMentionsMe;
		status = initStatus;
		
		var backgroundColor = [CPColor whiteColor];
		if (isMe === YES)
		{
			backgroundColor = [CPColor colorWithHexString:@"FFFFCC"];
		}
		else if (mentionsMe === YES)
		{
			backgroundColor = [CPColor colorWithHexString:@"CCFFFF"];
		}
		[self setFillColor:backgroundColor];				
				
		var x = isMe === YES ? 6 : 15;
		var width = CGRectGetWidth(frameRect);
		var statusText = status.text;
		statusText = [statusText stringByTrimmingWhitespace];
		var textSize = [statusText sizeWithFont:[CPFont systemFontOfSize:12] inWidth:width - 25.0 - (x - 5)];
		textSize.height = textSize.height + 5;
		[self setFrameSize:CGSizeMake(width,  textSize.height + 35)];
										
	 	nameField = [[CPTextField alloc] initWithFrame:CGRectMake(x, 8.0, width - 30.0, 20.0)];
		[nameField setStringValue:status.user.name];
		[nameField setFont:[CPFont boldSystemFontOfSize:12]];
		[nameField setTextColor:[CPColor blackColor]];
		[self addSubview:nameField];

		textField = [[CPTextField alloc] initWithFrame:CGRectMake(x, 28.0, width - 25.0, textSize.height)];
		[textField setStringValue:status.text];
		[textField setFont:[CPFont systemFontOfSize:12]];
		[textField setLineBreakMode:1]; 
		[textField setTextColor:[CPColor blackColor]];
		[self addSubview:textField];

		var timestampX = isMe === YES ? 160 : 150;
		timestampField = [[CPTextField alloc] initWithFrame:CGRectMake(width - timestampX, 7.0, 140.0, 20.0)];
		[timestampField setAlignment:CPRightTextAlignment];
		var timestampStr = [self getTimestampAsString:status.created_at];
		[timestampField setStringValue:timestampStr];
		[timestampField setFont:[CPFont systemFontOfSize:11]];
		[timestampField setTextColor:[CPColor darkGrayColor]];
		[self addSubview:timestampField];
	}
	return self;
}

- (void)updateTimestamp
{
	var timestampValue = [self getTimestampAsString:status.created_at];
	if (![timestampValue isEqualToString:[timestampField stringValue]])
	{
		[timestampField setStringValue:timestampValue];	
	}
}

- (CPString)getTimestampAsString:(CPString)twitterTimestamp
{
	var format = /(\w{3}) (\w{3}) (\d{2}) (\d{2}):(\d{2}):(\d{2}) ([-+])(\d{4}) (\d{4})/;
    var match = twitterTimestamp.match(new RegExp(format));
    var date = new Date(match[2] + " " + match[3] + ", " + match[9] + " " + match[4] + ":" + match[5] + ":" + match[6]);

    var currentDate = new Date();
    var delta = parseInt((currentDate - date) / 1000);
    delta = delta + (currentDate.getTimezoneOffset() * 60);

	var timestampStr = @"";
    if (delta < 60) 
	{
      timestampStr = @"less than a minute ago";
    } 
	else if(delta < 120) 
	{
      timestampStr = @"about a minute ago";
    } 
	else if(delta < (60*60)) 
	{
      timestampStr = (parseInt(delta / 60)).toString() + @" minutes ago";
    } 
	else if(delta < (120*60)) 
	{
      timestampStr =  @"about an hour ago";
    } 
	else if(delta < (24*60*60)) 
	{
      timestampStr = @"about " + (parseInt(delta / 3600)).toString() + @" hours ago";
    } 
	else if(delta < (48*60*60)) 
	{
      timestampStr = @"1 day ago";
    } 
	else {
      timestampStr = (parseInt(delta / 86400)).toString() + @" days ago";
    }

	return timestampStr;
}

@end
