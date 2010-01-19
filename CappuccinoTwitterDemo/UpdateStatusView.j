@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "BubbleView.j"
@import "RoundedImageView.j"
@import "TwitterRequestManager.j"

var UpdateStatusViewBackgroundColor = nil;
 
@implementation UpdateStatusView : CPView
{
	CPTextField text @accessors (readonly);
	CPTextField sizeField;
	CPImageView spinnerView;
}

+ (void)initialize
{
    var bundle = [CPBundle bundleForClass:CPWindow];    
    UpdateStatusViewBackgroundColor = [CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:
        [        
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground0.png"] size:CPSizeMake(6.0, 60.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground1.png"] size:CPSizeMake(1.0, 60.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground2.png"] size:CPSizeMake(6.0, 60.0)],

            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground3.png"] size:CPSizeMake(6.0, 1.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground4.png"] size:CPSizeMake(1.0, 1.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground5.png"] size:CPSizeMake(6.0, 1.0)],

            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground6.png"] size:CPSizeMake(6.0, 6.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground7.png"] size:CPSizeMake(6.0, 6.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground8.png"] size:CPSizeMake(6.0, 6.0)]
        ]]];
}

- (id)initWithFrame:(CPRect)aFrame
{
    self = [super initWithFrame:aFrame];
    
    if (self)
    {
        [self setBackgroundColor:UpdateStatusViewBackgroundColor];

	    var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
		var user = [twitterRequestManager user];
			
		var width = CGRectGetWidth([self bounds]);
		var icon = [[RoundedImageView alloc] initWithFrame:CGRectMake(width - 60.0, 10, 50, 50)];
		var image = [[CPImage alloc] initWithContentsOfFile:user.profile_image_url size:CGSizeMake(50, 50)];
		[icon setImage:image];
		[self addSubview:icon];	
		
		var bubbleRect = CGRectMake(10.0, 15.0, width - 70.0, 38.0);
		var bubble = [[BubbleView alloc] initWithFrame:bubbleRect isLeftFacing:NO];
		[bubble setBorderColor:[CPColor blackColor]];
		[bubble setHasShadow:NO];
		[bubble setFillColor:[CPColor whiteColor]];
		[bubble setFillOpacity:0.3];
		[self addSubview:bubble];
		
		text = [[CPTextField alloc] initWithFrame:CGRectMake(5.0, 10.0, CGRectGetWidth(bubbleRect) - 60.0, 18.0)];
		[text setDrawsBackground:NO];
		[text setEditable:YES];
		[text setFont:[CPFont systemFontOfSize:12]];		
		[text setPlaceholderString:@"...enter status"];
		[bubble addSubview:text];		

		sizeField = [[CPTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bubbleRect) - 77, 5.0, 50, 25.0)];
		[sizeField setAlignment:CPRightTextAlignment];
		[sizeField setDrawsBackground:NO];
		[sizeField setEditable:NO];
		[sizeField setFont:[CPFont systemFontOfSize:21]];
		[sizeField setTextColor:[CPColor colorWithHexString:@"444444"]];
		[sizeField setObjectValue:"0"];
		[bubble addSubview:sizeField];		

      	var spinner = [[CPImage alloc] initWithContentsOfFile:@"Resources/ajax-loader.gif"]
  		spinnerView = [[CPImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bubbleRect) - 45, 11.0, 15.0, 15.0)];
		[spinnerView setImage:spinner];
		[spinnerView setHidden:YES];
		[bubble addSubview:spinnerView];
		
	    [text setDelegate:self];
	    [text setAction:@selector(updateStatus:)];	
    }
    
    return self;
}

- (void)updateStatus:(CPTextField)textField
{
	[textField setEditable:NO];
	[sizeField setHidden:YES];
	[spinnerView setHidden:NO];
	
	var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
	[twitterRequestManager updateStatus:[textField objectValue] withDelegate:self];
}

- (void)updateStatusComplete:(id)response
{
	debugger;
	
	[text setObjectValue:""];
	[text setEditable:YES];
	[self controlTextDidChange:text]; // shouldn't have to do this
	[spinnerView setHidden:YES];
	[sizeField setHidden:NO];
	
	var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
	[twitterRequestManager updateFriendsTimeline:nil];
}

- (void)controlTextDidChange:(CPTextField)ignore
{
	var size = [[text objectValue] length];
	[sizeField setObjectValue:size];
	if (size > 140)
	{
		[sizeField setTextColor:[CPColor colorWithHexString:@"990000"]];		
	}
	else
	{
		[sizeField setTextColor:[CPColor colorWithHexString:@"444444"]];
	}	
}

@end

