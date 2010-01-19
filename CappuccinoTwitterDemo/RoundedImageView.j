@import <Foundation/Foundation.j>

@implementation RoundedImageView : CPView
{
	CPImage image;
}

- (id)initWithFrame:(CPRect)frameRect
{
    return [super initWithFrame:frameRect];	
}

- (void)setImage:(CPImage)setImage
{
    image = setImage;

	var defaultCenter = [CPNotificationCenter defaultCenter];
    
    if ([image loadStatus] < 2)
    {
        [defaultCenter addObserver:self selector:@selector(imageDidLoad:) name:CPImageDidLoadNotification object:image];    
    }
    else
    {
        [self setNeedsLayout];
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(CPRect)rect
{				
	var context = [[CPGraphicsContext currentContext] graphicsPort];

	if ([image loadStatus] === 2)
	{
		var radius = 5.0;
		CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3.0 * Math.PI / 2.0, 0, 1);
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0.0, Math.PI / 2.0, 1);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, Math.PI / 2.0, Math.PI, 1);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, Math.PI, 3.0 * Math.PI / 2.0, 1);
		CGContextClosePath(context);
		CGContextClip(context);
		CGContextDrawImage(context, rect, image);
	}
}

- (void)imageDidLoad:(CPNotification)aNotification
{
    [self setNeedsLayout];
    [self setNeedsDisplay:YES];
}

@end
