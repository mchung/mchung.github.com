@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation BubbleView : CPView
{
	CPColor fillColor @accessors;
	float fillOpacity @accessors;
	CPColor borderColor @accessors;
	Boolean isLeftFacing @accessors (readonly);
	Boolean hasShadow @accessors; 
}

- (id)initWithFrame:(CPRect)frameRect isLeftFacing:(Boolean)initIsLeftFacing
{
    self = [super initWithFrame:frameRect];
	if (self)
	{
		isLeftFacing = initIsLeftFacing;
		fillOpacity = 1.0;
		borderColor = nil;
		hasShadow = YES;
		drawBackground = YES;
	}
	return self;
}

- (void)drawRect:(CPRect)rect
{
    var bounds = [self bounds];
    var context = [[CPGraphicsContext currentContext] graphicsPort];                           
	var radius = 5.0;
	
    CGContextSetLineWidth(context, 1.0);
	CGContextSetFillColor(context, fillColor);
	
	var red = [fillColor redComponent], blue = [fillColor blueComponent], green = [fillColor greenComponent], alpha = [fillColor alphaComponent];
	var strokeColor = borderColor;
	if (strokeColor === nil) 
	{
		strokeColor = [CPColor colorWithRed:[self darkenComponent:red] green:[self darkenComponent:green] blue:[self darkenComponent:blue] alpha:1];
	}
	CGContextSetStrokeColor(context, strokeColor);
				
	CGContextSaveGState(context);
	if (hasShadow === YES)
	{
		CGContextSetShadowWithColor(context, CGSizeMake(1,1), 2.0, strokeColor);
	}
	CGContextBeginPath(context);
	
	if (isLeftFacing === YES)
	{
    	var rect = CGRectMake(CGRectGetMinX(bounds) + 9, CGRectGetMinY(bounds) + 5,
			CGRectGetWidth(bounds) - 14, CGRectGetHeight(bounds) - 10);
		CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3.0 * Math.PI / 2.0, 0, 1);
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0.0, Math.PI / 2.0, 1);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, Math.PI / 2.0, Math.PI, 1);					
		CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - (CGRectGetHeight(rect) / 2.0) + 5);				
		CGContextAddLineToPoint(context, CGRectGetMinX(rect) - 9, CGRectGetMaxY(rect) - (CGRectGetHeight(rect) / 2.0));
		CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect) - (CGRectGetHeight(rect) / 2.0) - 5);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, Math.PI, 3.0 * Math.PI / 2.0, 1);				
	}
	else {
    	var rect = CGRectMake(CGRectGetMinX(bounds) + 1, CGRectGetMinY(bounds) + 5,
			CGRectGetWidth(bounds) - 14, CGRectGetHeight(bounds) - 10);
		CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3.0 * Math.PI / 2.0, 0, 1);
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - (CGRectGetHeight(rect) / 2.0) - 5);				
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect) + 9, CGRectGetMaxY(rect) - (CGRectGetHeight(rect) / 2.0));
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - (CGRectGetHeight(rect) / 2.0) + 5);
		CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0.0, Math.PI / 2.0, 1);
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, Math.PI / 2.0, Math.PI, 1);					
		CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, Math.PI, 3.0 * Math.PI / 2.0, 1);				
	}			

	CGContextClosePath(context);
	CGContextSetAlpha(context, fillOpacity);
	CGContextFillPath(context);	
	CGContextRestoreGState(context);	
	CGContextStrokePath(context);
}

- (float)darkenComponent:(float)component
{
	var darker = component - 0.20;
	if (darker <= 0)
	{
		return 0;
	}
	else {
		return darker;
	}
}

@end
