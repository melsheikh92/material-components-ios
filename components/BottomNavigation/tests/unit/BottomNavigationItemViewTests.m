// Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <XCTest/XCTest.h>

#import "../../src/private/MDCBottomNavigationItemBadge.h"
#import "../../src/private/MDCBottomNavigationItemView.h"

#import "MaterialInk.h"

static UIImage *fakeImage(void) {
  CGSize imageSize = CGSizeMake(24, 24);
  UIGraphicsBeginImageContext(imageSize);
  [UIColor.whiteColor setFill];
  UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@interface MDCBottomNavigationItemView (Testing)
@property(nonatomic, strong) UIImageView *iconImageView;
@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) MDCBottomNavigationItemBadge *badge;
- (CGPoint)badgeCenterFromIconFrame:(CGRect)iconFrame isRTL:(BOOL)isRTL;
@end

@interface BottomNavigationItemViewTests : XCTestCase

@end

@implementation BottomNavigationItemViewTests

- (void)testVerticalMarginLayout {
  // Given
  MDCBottomNavigationItemView *view = [[MDCBottomNavigationItemView alloc] init];
  view.title = @"Test Content";
  view.image = fakeImage();
  view.bounds = CGRectMake(0, 0, 100, 100);
  view.contentVerticalMargin = 20;
  view.contentHorizontalMargin = 20;
  view.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;

  // When
  view.titleBelowIcon = YES;
  [view layoutSubviews];

  // Then
  CGFloat contentHeight =
      CGRectGetHeight(view.label.bounds) + CGRectGetHeight(view.iconImageView.bounds);
  CGFloat expectedDistance = contentHeight / 2 + view.contentVerticalMargin;
  XCTAssertEqualWithAccuracy(view.label.center.y - view.iconImageView.center.y, expectedDistance,
                             (CGFloat)0.001);
}

- (void)testHorizontalMarginLayout {
  // Given
  MDCBottomNavigationItemView *view = [[MDCBottomNavigationItemView alloc] init];
  view.title = @"Test Content";
  view.image = fakeImage();
  view.bounds = CGRectMake(0, 0, 100, 100);
  view.contentVerticalMargin = 20;
  view.contentHorizontalMargin = 20;
  view.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;

  // When
  view.titleBelowIcon = NO;
  [view layoutSubviews];

  // Then
  CGFloat contentWidth =
      CGRectGetWidth(view.label.bounds) + CGRectGetWidth(view.iconImageView.bounds);
  CGFloat expectedDistance = contentWidth / 2 + view.contentHorizontalMargin;
  XCTAssertEqualWithAccuracy(view.label.center.x - view.iconImageView.center.x, expectedDistance,
                             (CGFloat)0.001);
}

- (void)testContentInsetLayout {
  // Given
  MDCBottomNavigationItemView *view = [[MDCBottomNavigationItemView alloc] init];
  view.title = @"Test Content";
  view.image = fakeImage();
  view.bounds = CGRectMake(0, 0, 100, 100);
  view.contentVerticalMargin = 20;
  view.contentHorizontalMargin = 20;
  view.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;

  // When
  view.titleBelowIcon = YES;
  view.contentInsets = UIEdgeInsetsMake(10, 10, 5, 5);
  [view layoutSubviews];

  // Then
  CGRect contentRect = UIEdgeInsetsInsetRect(view.bounds, view.contentInsets);
  XCTAssert(view.label.center.x == CGRectGetMidX(contentRect));
  XCTAssert(view.iconImageView.center.x == CGRectGetMidX(contentRect));
  CGFloat contentSpan = CGRectGetMaxY(view.label.frame) - CGRectGetMinY(view.iconImageView.frame);
  XCTAssertEqualWithAccuracy(CGRectGetMinY(view.iconImageView.frame) + contentSpan / 2,
                             CGRectGetMidY(contentRect), (CGFloat)0.001);
}

- (void)testSetSelectedItemTintColorUpdatesInkColor {
  // Given
  MDCBottomNavigationItemView *item1 = [[MDCBottomNavigationItemView alloc] init];
  MDCBottomNavigationItemView *item2 = [[MDCBottomNavigationItemView alloc] init];
  item1.selected = YES;
  UIColor *item1DefaultInkColor = item1.inkView.inkColor;
  UIColor *item2DefaultInkColor = item2.inkView.inkColor;

  // When
  item1.selectedItemTintColor = UIColor.cyanColor;
  item2.selectedItemTintColor = UIColor.cyanColor;

  // Then
  XCTAssertNotEqualObjects(item1.inkView.inkColor, item1DefaultInkColor);
  XCTAssertNotEqualObjects(item2.inkView.inkColor, item2DefaultInkColor);
  XCTAssertEqualObjects(item1.inkView.inkColor, item2.inkView.inkColor);
}

- (void)testSetTitleVisibilityUpdatesLayout {
  // Given
  MDCBottomNavigationItemView *view = [[MDCBottomNavigationItemView alloc] init];
  view.title = @"Test Content";
  view.image = fakeImage();
  view.bounds = CGRectMake(0, 0, 100, 100);
  view.contentVerticalMargin = 20;
  view.contentHorizontalMargin = 20;
  view.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  [view layoutIfNeeded];
  CGFloat imageMidYWithTitle = CGRectGetMidY(view.iconImageView.frame);

  // When
  view.titleVisibility = MDCBottomNavigationBarTitleVisibilityNever;
  [view layoutIfNeeded];

  // Then
  CGFloat imageMidYWithoutTitle = CGRectGetMidY(view.iconImageView.frame);
  // To check that the image has moved down, we assert imageMidYWithoutTitle is greater than
  // imageMidYWithTitle + 1. The + 1 makes sure the change in position is greater than a rounding
  // error. Practically, the difference is likely to be greater than 10.
  XCTAssertGreaterThan(imageMidYWithoutTitle, imageMidYWithTitle + 1);
}

- (void)testBadgeCenterIsCorrectWithoutRTL {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.iconImageView.frame = CGRectMake(8, 8, 24, 24);
  CGPoint expectedCenter = CGPointMake(32, 12);

  // When
  CGPoint badgePoint =
      [itemView badgeCenterFromIconFrame:CGRectStandardize(itemView.iconImageView.frame) isRTL:NO];
  // Then
  XCTAssertEqualWithAccuracy(badgePoint.x, expectedCenter.x, 0.001);
  XCTAssertEqualWithAccuracy(badgePoint.y, expectedCenter.y, 0.001);
}

- (void)testBadgeCenterIsCorrectWithRTL {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.iconImageView.frame = CGRectMake(8, 8, 24, 24);
  CGPoint expectedCenter = CGPointMake(8, 12);

  // When
  CGPoint badgePoint =
      [itemView badgeCenterFromIconFrame:CGRectStandardize(itemView.iconImageView.frame) isRTL:YES];

  // Then
  XCTAssertEqualWithAccuracy(badgePoint.x, expectedCenter.x, 0.001);
  XCTAssertEqualWithAccuracy(badgePoint.y, expectedCenter.y, 0.001);
}

#pragma mark - sizeThatFits

- (void)testSizeThatFitsSmallSizeStackedLayout {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.image = fakeImage();
  itemView.title = @"A very long title that takes much space to fit.";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = YES;
  CGSize desiredSize = CGSizeMake(24, 8);

  // When
  CGSize fitSize = [itemView sizeThatFits:desiredSize];

  // Then
  XCTAssertGreaterThanOrEqual(fitSize.width, desiredSize.width);
  XCTAssertGreaterThanOrEqual(fitSize.height, desiredSize.height);
}

- (void)testSizeThatFitsSmallSizeAdjacentLayout {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.image = fakeImage();
  itemView.title = @"A very long title that takes much space to fit.";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = NO;
  CGSize desiredSize = CGSizeMake(24, 8);

  // When
  CGSize fitSize = [itemView sizeThatFits:desiredSize];

  // Then
  XCTAssertGreaterThanOrEqual(fitSize.width, desiredSize.width);
  XCTAssertGreaterThanOrEqual(fitSize.height, desiredSize.height);
}

- (void)testSizeThatFitsLargerThanTooSmallBoundsStackedLayout {
  // Given
  CGRect originalFrame = CGRectMake(0, 0, 1, 3);
  MDCBottomNavigationItemView *itemView =
      [[MDCBottomNavigationItemView alloc] initWithFrame:originalFrame];
  itemView.title = @"A very long title that takes much space to fit.";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = YES;

  // When
  CGSize fitSize = [itemView sizeThatFits:CGSizeMake(10000, 10000)];

  // Then
  XCTAssertGreaterThan(fitSize.width, originalFrame.size.width);
  XCTAssertGreaterThan(fitSize.height, originalFrame.size.height);
}

- (void)testSizeThatFitsLargerThanTooSmallBoundsAdjacentLayout {
  // Given
  CGRect originalFrame = CGRectMake(0, 0, 1, 3);
  MDCBottomNavigationItemView *itemView =
      [[MDCBottomNavigationItemView alloc] initWithFrame:originalFrame];
  itemView.title = @"A very long title that takes much space to fit.";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = NO;

  // When
  CGSize fitSize = [itemView sizeThatFits:CGSizeMake(10000, 10000)];

  // Then
  XCTAssertGreaterThan(fitSize.width, originalFrame.size.width);
  XCTAssertGreaterThan(fitSize.height, originalFrame.size.height);
}

- (void)testSizeThatFitsSmallerThanTooLargeBoundsStackedLayout {
  // Given
  CGRect originalFrame = CGRectMake(0, 0, 1202, 1301);
  MDCBottomNavigationItemView *itemView =
      [[MDCBottomNavigationItemView alloc] initWithFrame:originalFrame];
  itemView.title = @"1";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = YES;

  // When
  CGSize fitSize = [itemView sizeThatFits:CGSizeMake(10000, 10000)];

  // Then
  XCTAssertLessThan(fitSize.width, originalFrame.size.width);
  XCTAssertLessThan(fitSize.height, originalFrame.size.height);
}

- (void)testSizeThatFitsSmallerThanTooLargeBoundsAdjacentLayout {
  // Given
  CGRect originalFrame = CGRectMake(0, 0, 1202, 1301);
  MDCBottomNavigationItemView *itemView =
      [[MDCBottomNavigationItemView alloc] initWithFrame:originalFrame];
  itemView.title = @"1";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = NO;

  // When
  CGSize fitSize = [itemView sizeThatFits:CGSizeMake(10000, 10000)];

  // Then
  XCTAssertLessThan(fitSize.width, originalFrame.size.width);
  XCTAssertLessThan(fitSize.height, originalFrame.size.height);
}

- (void)testSizeThatFitWithCGSizeZeroStackedLayout {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.title = @"Favorites";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = YES;

  // When
  CGSize fitSize = [itemView sizeThatFits:CGSizeZero];

  // Then
  XCTAssertGreaterThan(fitSize.width, 0);
  XCTAssertGreaterThan(fitSize.height, 0);
}

- (void)testSizeThatFitWithCGSizeZeroAdjacentLayout {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.title = @"Favorites";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = NO;

  // When
  CGSize fitSize = [itemView sizeThatFits:CGSizeZero];

  // Then
  XCTAssertGreaterThan(fitSize.width, 0);
  XCTAssertGreaterThan(fitSize.height, 0);
}

- (void)testSizeThatFitsMatchesSizeToFitUnboundedStackedLayout {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.title = @"Favorites";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = YES;
  CGSize fitSize = [itemView sizeThatFits:CGSizeMake(10000, 10000)];

  // When
  [itemView sizeToFit];

  // Then
  CGRect fitBounds = CGRectStandardize(itemView.bounds);
  XCTAssertFalse(CGRectEqualToRect(fitBounds, CGRectZero),
                 @"sizeToFit should never set a CGRectZero bounds when content is present.");
  XCTAssertEqualWithAccuracy(fitBounds.size.width, fitSize.width, 0.001);
  XCTAssertEqualWithAccuracy(fitBounds.size.height, fitSize.height, 0.001);
}

- (void)testSizeThatFitsMatchesSizeToFitUnboundedAdjacentLayout {
  // Given
  MDCBottomNavigationItemView *itemView = [[MDCBottomNavigationItemView alloc] init];
  itemView.title = @"Favorites";
  itemView.titleVisibility = MDCBottomNavigationBarTitleVisibilityAlways;
  itemView.titleBelowIcon = NO;
  CGSize fitSize = [itemView sizeThatFits:CGSizeMake(10000, 10000)];

  // When
  [itemView sizeToFit];

  // Then
  CGRect fitBounds = CGRectStandardize(itemView.bounds);
  XCTAssertFalse(CGRectEqualToRect(fitBounds, CGRectZero),
                 @"sizeToFit should never set a CGRectZero bounds when content is present.");
  XCTAssertEqualWithAccuracy(fitBounds.size.width, fitSize.width, 0.001);
  XCTAssertEqualWithAccuracy(fitBounds.size.height, fitSize.height, 0.001);
}

@end
