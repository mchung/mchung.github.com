@import <Foundation/Foundation.j>
@import "TimelineView.j"
@import "TimelineViewItem.j"
@import "UpdateStatusView.j"
@import "StatusView.j"
@import "LoginView.j"

@implementation AppController : CPObject
{
	CPView contentView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{	
	var applicationWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
	contentView = [applicationWindow contentView];
	var contentViewBounds = [contentView bounds];
	var contentViewWidth = CGRectGetWidth(contentViewBounds);
	
	var boxWidth = 400;
	if (contentViewWidth > boxWidth)
	{
		var contentViewHeight = CGRectGetHeight(contentViewBounds);
		var boxHeight = contentViewHeight - 30;
		var boxFrame = CGRectMake(contentViewWidth/2 - boxWidth/2, contentViewHeight/2 - boxHeight/2, boxWidth, boxHeight);
		var boxView = [[CPBox alloc] initWithFrame:boxFrame];
		[boxView setFillColor:[CPColor colorWithHexString:@"E6E6E6"]];
		[boxView setBorderColor:[CPColor lightGrayColor]];
		[boxView setBorderType:CPLineBorder];
		[boxView setCornerRadius:5.0];
		[boxView setContentViewMargins:CGSizeMake(5, 0)];
		[boxView setAutoresizingMask: CPViewHeightSizable]; 
		[contentView setBackgroundColor:[CPColor lightGrayColor]];
		[contentView addSubview:boxView];
		var boxContentView = [[CPView alloc] initWithFrame:boxFrame];
		[boxView setContentView:boxContentView];
		[boxView setAutoresizingMask: CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];						
		contentView = boxContentView; 
		contentViewBounds = [boxContentView bounds];
		contentViewWidth = CGRectGetWidth(contentViewBounds);
	}

	var loginViewHeight = 125;
	var loginViewWidth = contentViewWidth - 30;
	var loginView = [[LoginView alloc] initWithFrame:CGRectMake(contentViewWidth/2 - loginViewWidth/2, 
		16, loginViewWidth, loginViewHeight)];
	[loginView setAppController:self];
	[contentView addSubview:loginView];

    [applicationWindow orderFront:self];
}

- (void)loginComplete
{
	var contentViewBounds = [contentView bounds];
	var contentViewWidth = CGRectGetWidth(contentViewBounds);
	var contentViewHeight = CGRectGetHeight(contentViewBounds);

	var updateStatusViewHeight = 71;
	var updateStatusViewWidth = contentViewWidth - 30;
	var updateStatusView = [[UpdateStatusView alloc] initWithFrame:CGRectMake(contentViewWidth/2 - updateStatusViewWidth/2, 
		contentViewHeight - updateStatusViewHeight - 16, updateStatusViewWidth, updateStatusViewHeight)];
	
	var listItem = [[TimelineViewItem alloc] init];
 	friendsTimelineView = [[TimelineView alloc] initWithFrame: CGRectMake(0.0, 0.0, contentViewWidth, contentViewHeight)];
	[friendsTimelineView setVerticalMargin:0];
	[friendsTimelineView setItemPrototype:listItem];
	[friendsTimelineView setBackgroundColor:[CPColor colorWithHexString:@"E6E6E6"]];
	[friendsTimelineView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];  
	[friendsTimelineView setUpdateStatusView:updateStatusView];  	
	
	var scrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0.0, 0.0, contentViewWidth, contentViewHeight)];
	[scrollView setDocumentView:friendsTimelineView];
	[scrollView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
	[scrollView setAutohidesScrollers:YES];
	[scrollView setBackgroundColor:[CPColor whiteColor]];
	[scrollView setHasHorizontalScroller:NO];
	[scrollView setHasVerticalScroller:NO];	

	var statusView = [[StatusView alloc] initWithFrame:[friendsTimelineView bounds]];		
	[listItem setView:statusView];	

	var view = [scrollView contentView];
	[view setBackgroundColor:[CPColor colorWithHexString:@"E6E6E6"]];
	[view setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
	[contentView addSubview:scrollView];
	[contentView addSubview:updateStatusView];	
		
    var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
    [twitterRequestManager setupFriendsTimeline:friendsTimelineView];
}

@end
