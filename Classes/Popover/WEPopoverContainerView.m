//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties

@synthesize bgImageName, upArrowImageName, downArrowImageName, leftArrowImageName, rightArrowImageName, topBgMargin, bottomBgMargin, leftBgMargin, rightBgMargin, topBgCapSize, leftBgCapSize;
@synthesize bgCapInsets;
@synthesize leftContentMargin, rightContentMargin, topContentMargin, bottomContentMargin, arrowMargin;

#define WEUIEdgeInsetsInvalid UIEdgeInsetsMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MAX)

- (id)init
{
    self = [super init];
    if (self) {
        self.bgCapInsets = WEUIEdgeInsetsInvalid;
    }
    return self;
}

- (void)dealloc {
	self.bgImageName = nil;
	self.upArrowImageName = nil;
	self.downArrowImageName = nil;
	self.leftArrowImageName = nil;
	self.rightArrowImageName = nil;
	[super dealloc];
}

@end

@interface WEPopoverContainerView(Private)

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)props;
- (void)initFrame;

@end

@implementation WEPopoverContainerView

@synthesize arrowDirection, contentView;

- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)theProperties {
	if ((self = [super initWithFrame:CGRectZero])) {
		
		[self setProperties:theProperties];
		correctedSize = CGSizeMake(theSize.width + properties.leftBgMargin + properties.rightBgMargin + properties.leftContentMargin + properties.rightContentMargin, 
								   theSize.height + properties.topBgMargin + properties.bottomBgMargin + properties.topContentMargin + properties.bottomContentMargin);	
		[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
		[self initFrame];
		self.backgroundColor = [UIColor clearColor];
		UIImage *theImage = [UIImage imageNamed:properties.bgImageName];

        // yyjim: calcuates background image cap insets
        UIEdgeInsets bgImageCapInsets;
        if (!UIEdgeInsetsEqualToEdgeInsets(WEUIEdgeInsetsInvalid, properties.bgCapInsets))
            bgImageCapInsets = properties.bgCapInsets;
        else {
            CGFloat topBottomInset = properties.topBgCapSize;
            CGFloat leftRightInset = properties.leftBgCapSize;
            bgImageCapInsets = UIEdgeInsetsMake(topBottomInset, leftRightInset,
                                                topBottomInset, leftRightInset);
        }
        
        // yyjim: stretchableImageWithLeftCapWidth:topCapHeight is deprecated.
        if ([theImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            bgImage = [[theImage resizableImageWithCapInsets:bgImageCapInsets] retain];
        } else {
            bgImage = [[theImage stretchableImageWithLeftCapWidth:bgImageCapInsets.left
                                                     topCapHeight:bgImageCapInsets.top] retain];
        }
		
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)dealloc {
	[properties release];
	[contentView release];
	[bgImage release];
	[arrowImage release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[bgImage drawInRect:bgRect blendMode:kCGBlendModeNormal alpha:1.0];
	[arrowImage drawInRect:arrowRect blendMode:kCGBlendModeNormal alpha:1.0]; 
}

- (void)updatePositionWithAnchorRect:(CGRect)anchorRect 
						 displayArea:(CGRect)displayArea
			permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
	[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
	[self initFrame];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return CGRectContainsPoint(self.contentRect, point);	
} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)setContentView:(UIView *)v {
	if (v != contentView) {
		[contentView release];
		contentView = [v retain];		
		contentView.frame = self.contentRect;		
		[self addSubview:contentView];
	}
}



@end

@implementation WEPopoverContainerView(Private)

- (void)initFrame {
	CGRect theFrame = CGRectOffset(CGRectUnion(bgRect, arrowRect), offset.x, offset.y);
	
	//If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
	arrowOffset = CGPointMake(MAX(0, -arrowRect.origin.x), MAX(0, -arrowRect.origin.y));
	bgRect = CGRectOffset(bgRect, arrowOffset.x, arrowOffset.y);
	arrowRect = CGRectOffset(arrowRect, arrowOffset.x, arrowOffset.y);
	
	self.frame = theFrame;	
}																		 

- (CGSize)contentSize {
	return self.contentRect.size;
}

- (CGRect)contentRect {
	CGRect rect = CGRectMake(properties.leftBgMargin + properties.leftContentMargin + arrowOffset.x, 
							 properties.topBgMargin + properties.topContentMargin + arrowOffset.y, 
							 bgRect.size.width - properties.leftBgMargin - properties.rightBgMargin - properties.leftContentMargin - properties.rightContentMargin,
							 bgRect.size.height - properties.topBgMargin - properties.bottomBgMargin - properties.topContentMargin - properties.bottomContentMargin);
	return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)props {
	if (properties != props) {
		[properties release];
		properties = [props retain];
	}
}

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	offset =  CGPointZero;
	bgRect = CGRectZero;
	arrowRect = CGRectZero;
	arrowDirection = UIPopoverArrowDirectionUnknown;
	
	CGFloat biggestSurface = 0.0f;
	CGFloat currentMinMargin = 0.0f;
	
	UIImage *upArrowImage = [UIImage imageNamed:properties.upArrowImageName];
	UIImage *downArrowImage = [UIImage imageNamed:properties.downArrowImageName];
	UIImage *leftArrowImage = [UIImage imageNamed:properties.leftArrowImageName];
	UIImage *rightArrowImage = [UIImage imageNamed:properties.rightArrowImageName];
    
    CGSize upArrowSize = upArrowImage ? upArrowImage.size : CGSizeZero;
    CGSize downArrowSize = downArrowImage ? downArrowImage.size : CGSizeZero;
    CGSize leftArrowSize = leftArrowImage ? leftArrowImage.size : CGSizeZero;
    CGSize rightArrowSize = rightArrowImage ? rightArrowImage.size : CGSizeZero;
	
	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if ((supportedArrowDirections & theArrowDirection)) {
			
			CGRect theBgRect = CGRectZero;
			CGRect theArrowRect = CGRectZero;
			CGPoint theOffset = CGPointZero;
			CGFloat xArrowOffset = 0.0;
			CGFloat yArrowOffset = 0.0;
			CGPoint anchorPoint = CGPointZero;
			
			switch (theArrowDirection) {
				case UIPopoverArrowDirectionUp:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMaxY(anchorRect));
					
					xArrowOffset = theSize.width / 2 - upArrowSize.width / 2;
					yArrowOffset = properties.topBgMargin - upArrowSize.height;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - upArrowSize.width / 2, anchorPoint.y  - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, properties.leftBgMargin + properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - properties.rightBgMargin - properties.arrowMargin - upArrowSize.width);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, upArrowSize.width, upArrowSize.height);
					
					break;
				case UIPopoverArrowDirectionDown:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
					
					xArrowOffset = theSize.width / 2 - downArrowSize.width / 2;
					yArrowOffset = theSize.height - properties.bottomBgMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - downArrowSize.width / 2, anchorPoint.y - yArrowOffset - downArrowSize.height);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, properties.leftBgMargin + properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - properties.rightBgMargin - properties.arrowMargin - downArrowSize.width);
					
					theArrowRect = CGRectMake(xArrowOffset , yArrowOffset, downArrowSize.width, downArrowSize.height);
					
					break;
				case UIPopoverArrowDirectionLeft:
					
					anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = properties.leftBgMargin - leftArrowSize.width;
					yArrowOffset = theSize.height / 2  - leftArrowSize.height / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset - leftArrowSize.height / 2);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, properties.topBgMargin + properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - properties.bottomBgMargin - properties.arrowMargin - leftArrowSize.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, leftArrowSize.width, leftArrowSize.height);
					
					break;
				case UIPopoverArrowDirectionRight:
					
					anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = theSize.width - properties.rightBgMargin;
					yArrowOffset = theSize.height / 2  - rightArrowSize.width / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - rightArrowSize.width, anchorPoint.y - yArrowOffset - rightArrowSize.height / 2);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, properties.topBgMargin + properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - properties.bottomBgMargin - properties.arrowMargin - rightArrowSize.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, rightArrowSize.width, rightArrowSize.height);
					
					break;
                default:
                    break;
			}
			
			CGRect bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
			
			CGFloat minMarginLeft = CGRectGetMinX(bgFrame) - CGRectGetMinX(displayArea);
			CGFloat minMarginRight = CGRectGetMaxX(displayArea) - CGRectGetMaxX(bgFrame); 
			CGFloat minMarginTop = CGRectGetMinY(bgFrame) - CGRectGetMinY(displayArea); 
			CGFloat minMarginBottom = CGRectGetMaxY(displayArea) - CGRectGetMaxY(bgFrame); 
			
			if (minMarginLeft < 0) {
			    // Popover is too wide and clipped on the left; decrease width
			    // and move it to the right
			    theOffset.x -= minMarginLeft;
			    theBgRect.size.width += minMarginLeft;
			    minMarginLeft = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionRight) {
			        theArrowRect.origin.x = CGRectGetMaxX(theBgRect) - properties.rightBgMargin;
			    }
			}
			if (minMarginRight < 0) {
			    // Popover is too wide and clipped on the right; decrease width.
			    theBgRect.size.width += minMarginRight;
			    minMarginRight = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionLeft) {
			        theArrowRect.origin.x = CGRectGetMinX(theBgRect) - leftArrowSize.width + properties.leftBgMargin;
			    }
			}
			if (minMarginTop < 0) {
			    // Popover is too high and clipped at the top; decrease height
			    // and move it down
			    theOffset.y -= minMarginTop;
			    theBgRect.size.height += minMarginTop;
			    minMarginTop = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionDown) {
			        theArrowRect.origin.y = CGRectGetMaxY(theBgRect) - properties.bottomBgMargin;
			    }
			}
			if (minMarginBottom < 0) {
			    // Popover is too high and clipped at the bottom; decrease height.
			    theBgRect.size.height += minMarginBottom;
			    minMarginBottom = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionUp) {
			        theArrowRect.origin.y = CGRectGetMinY(theBgRect) - upArrowSize.height + properties.topBgMargin;
			    }
			}
			bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
            
			CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
			minMargin = MIN(minMargin, minMarginTop);
			minMargin = MIN(minMargin, minMarginBottom);
			
			// Calculate intersection and surface
			CGRect intersection = CGRectIntersection(displayArea, bgFrame);
			CGFloat surface = intersection.size.width * intersection.size.height;
			
			if (surface >= biggestSurface && minMargin >= currentMinMargin) {
				biggestSurface = surface;
				offset = theOffset;
				arrowRect = theArrowRect;
				bgRect = theBgRect;
				arrowDirection = theArrowDirection;
				currentMinMargin = minMargin;
			}
		}
		
		theArrowDirection <<= 1;
	}
	
	switch (arrowDirection) {
		case UIPopoverArrowDirectionUp:
			arrowImage = [upArrowImage retain];
			break;
		case UIPopoverArrowDirectionDown:
			arrowImage = [downArrowImage retain];
			break;
		case UIPopoverArrowDirectionLeft:
			arrowImage = [leftArrowImage retain];
			break;
		case UIPopoverArrowDirectionRight:
			arrowImage = [rightArrowImage retain];
			break;
        default:
            break;
	}
}

@end