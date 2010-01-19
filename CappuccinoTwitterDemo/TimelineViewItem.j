@import <AppKit/AppKit.j>
@import "TimelineView.j"

@implementation TimelineViewItem : CPViewController
{
}

- (void)setRepresentedObject:(id)newRepresentsObject
{
    [super setRepresentedObject:newRepresentsObject];

    var view = [self view];

    if ([view respondsToSelector:@selector(setRepresentedObject:)])
	{
        [view setRepresentedObject:[self representedObject]];
	}
}

- (TimelineView)timelineView
{
    return [_view superview];
}

@end
