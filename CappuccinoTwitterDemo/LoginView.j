@import <Foundation/Foundation.j>
@import "AppController.j"
@import "BubbleView.j"

var loginViewBackgroundColor = nil;
 
@implementation LoginView : CPView
{
	CPTextField screenNameField @accessors (readonly);
	CPTextField passwordField @accessors (readonly);
	CPImageView spinnerView;
	AppController appController @accessors;
}

+ (void)initialize
{
    var bundle = [CPBundle bundleForClass:CPWindow];    
    loginViewBackgroundColor = [CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:
        [        
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground0.png"] size:CPSizeMake(6.0, 78.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground1.png"] size:CPSizeMake(1.0, 78.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPWindow/HUD/CPWindowHUDBackground2.png"] size:CPSizeMake(6.0, 78.0)],

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
        [self setBackgroundColor:loginViewBackgroundColor];
		
		var width = CGRectGetWidth([self bounds]);
		var screenNameImageView = [[CPImageView alloc] initWithFrame:CGRectMake(width - 60.0, 10, 50, 50)];
		var screenNameImage = [[CPImage alloc] initWithContentsOfFile:@"Resources/frontpage-bird-left.png"];// size:CGSizeMake(50, 50)];
		[screenNameImageView setImage:screenNameImage];
		[self addSubview:screenNameImageView];	
		
		var bubbleRect = CGRectMake(10.0, 15.0, width - 70.0, 38.0);
		var screenNameBubbleView = [[BubbleView alloc] initWithFrame:bubbleRect isLeftFacing:NO];
		[screenNameBubbleView setBorderColor:[CPColor blackColor]];
		[screenNameBubbleView setHasShadow:NO];
		[screenNameBubbleView setFillColor:[CPColor whiteColor]];
		[screenNameBubbleView setFillOpacity:0.3];
		[self addSubview:screenNameBubbleView];
		
	    screenNameField = [[CPTextField alloc] initWithFrame:CGRectMake(5.0, 10.0, CGRectGetWidth(bubbleRect) - 20.0, 18.0)];
		[screenNameField setPlaceholderString:@"...first enter your screen name here"];
		[screenNameField setDrawsBackground:NO];
		[screenNameField setEditable:YES];
		[screenNameField setFont:[CPFont systemFontOfSize:12]];		
		[screenNameBubbleView addSubview:screenNameField];		

		var passwordImageView = [[CPImageView alloc] initWithFrame:CGRectMake(10.0, 65, 50, 50)];
		var passwordImage = [[CPImage alloc] initWithContentsOfFile:@"Resources/frontpage-bird.png" size:CGSizeMake(50, 50)];
		[passwordImageView setImage:passwordImage];
		[self addSubview:passwordImageView];	

		var passwordBubbleViewRect = CGRectMake(65.0, 70.0, width - 70.0, 38.0);
		var passwordBubbleView = [[BubbleView alloc] initWithFrame:passwordBubbleViewRect isLeftFacing:YES];
		[passwordBubbleView setBorderColor:[CPColor blackColor]];
		[passwordBubbleView setHasShadow:NO];
		[passwordBubbleView setFillColor:[CPColor whiteColor]];
		[passwordBubbleView setFillOpacity:0.3];
		[self addSubview:passwordBubbleView];
		
	    passwordField = [[CPTextField alloc] initWithFrame:CGRectMake(15.0, 10.0, CGRectGetWidth(passwordBubbleViewRect) - 20.0, 18.0)];
		[passwordField setPlaceholderString:@"...then enter your password here & hit enter"];
		[passwordField setDrawsBackground:NO];
		[passwordField setEditable:YES];
		[passwordField setSecure:YES];
		[passwordField setFont:[CPFont systemFontOfSize:12]];		
		[passwordBubbleView addSubview:passwordField];	
	    [passwordField setDelegate:self];
	    [passwordField setAction:@selector(login:)];	

      	var spinner = [[CPImage alloc] initWithContentsOfFile:@"Resources/ajax-loader.gif"]
  		spinnerView = [[CPImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bubbleRect) - 35, 11.0, 15.0, 15.0)];
		[spinnerView setImage:spinner];
		[spinnerView setHidden:YES];
		[passwordBubbleView addSubview:spinnerView];					
    }
    
    return self;
}

- (void)login:(CPTextField)textField
{	
	[screenNameField setEditable:NO];
	[passwordField setEditable:NO];
	[spinnerView setHidden:NO];
	
    var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
	var screenName = [screenNameField objectValue];
	[twitterRequestManager setScreenName:screenName];
	[twitterRequestManager setPassword:[passwordField objectValue]];
    [twitterRequestManager showUser:screenName withDelegate:self andSelector:@selector(loginComplete:)];	
}

- (void)loginComplete:(id)response
{
    var twitterRequestManager = [TwitterRequestManager twitterRequestManager];
	[twitterRequestManager setUser:response];	
	[appController loginComplete];
	[self removeFromSuperview];
}

@end

