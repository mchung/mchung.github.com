@import <Foundation/Foundation.j>
@import "TimelineViewItem.j"

@implementation TimelineView : CPView
{
	UpdateStatusView updateStatusView @accessors;
	CPDictionary items @accessors (readonly);
	CPDictionary content @accessors;
    TimelineViewItem itemPrototype @accessors;
	int verticalMargin @accessors;
	int maxStatuses @accessors;
	CPData itemData;
}

- (id)initWithFrame:(CPRect)frameRect
{
    self = [super initWithFrame:frameRect];	

	if (self)
	{
		items = [[CPDictionary alloc] init];
		content = [[CPDictionary alloc] init];
		verticalMargin = 0;
		maxStatuses = 100;
	}
	
	return self;
}

- (void)tile
{
    var count = [items count];
	if (count === 0) 
	{
		// nothing to tile
		return;
	}
		
    var y = verticalMargin;    

	var sortedItems = [[items allValues] sortedArrayUsingFunction:sortItems];
	var object, enumerator = [sortedItems objectEnumerator];
	while ((object = [enumerator nextObject] ) !== nil)
	{
		var view = [object view];
        [view setFrameOrigin:CGPointMake(0, y)];
		y += verticalMargin + CGRectGetHeight([view bounds]);
	}

	[self setFrameSize:CGSizeMake(CGRectGetWidth([self bounds]), y + verticalMargin + 95)];
}

- (void)resizeSubviewsWithOldSize:(CGSize)aSize
{
    [self tile];
}

- (void)reloadContent
{   
    if (!itemPrototype || !content || !items)
	{
        return;
	}

	if (([content count] > maxStatuses))
	{
		if ([items count] > 0) 
		{
			var sortedItems = [[items allValues] sortedArrayUsingFunction:sortItems];
			while ([content count] > maxStatuses)
			{
				var item = [sortedItems lastObject];
				var data = [item representedObject];
				var view = [item view];
				[sortedItems removeLastObject];
				[content removeObjectForKey:data.id];
				[items removeObjectForKey:data.id];
				[view removeFromSuperview];
			}
		}
		else 
		{
			var sortedContent = [[content allValues] sortedArrayUsingFunction:sortContent];
			while ([content count] > maxStatuses)
			{
				var data = [sortedContent lastObject];
				[content removeObjectForKey:data.id];
				[sortedContent removeLastObject];
			}
		}
	}	
	
	var object, enumerator = [content objectEnumerator];
	while ((object = [enumerator nextObject] ) !== nil)
	{
		if ([items objectForKey:object.id] === nil)
		{
			var item = [self newItemForRepresentedObject:object];			
	        [items setObject:item forKey: object.id];			
			[self _insertSubview:[item view] atIndex:0];
		}		
	}
	
	var item, enumerator = [items objectEnumerator];
	while ((item = [enumerator nextObject]) !== nil)
	{
		[[item view] updateTimestamp];
	}
		
    [self tile];
}

- (TimelineViewItem)newItemForRepresentedObject:(id)object
{
    var item = nil;

    if (!itemData) 
	{
        if (itemPrototype)
		{
            itemData = [CPKeyedArchiver archivedDataWithRootObject:itemPrototype];
		}
	}
	
    item = [CPKeyedUnarchiver unarchiveObjectWithData:itemData];
	[[item view] setUpdateStatusView:updateStatusView];
    [item setRepresentedObject:object];

    return item;
}

@end

function sortContent(a, b)
{
	var aId = parseInt(a.id);
	var bId = parseInt(b.id);
	if (bId < aId) return -1;
	if (bId === aId) return 0;
	return 1;
}

function sortItems(a, b)
{
	var aData = [a representedObject];
	var bData = [b representedObject];	
	var aId = parseInt(aData.id);
	var bId = parseInt(bData.id);
	if (bId < aId) return -1;
	if (bId === aId) return 0;
	return 1;
}
