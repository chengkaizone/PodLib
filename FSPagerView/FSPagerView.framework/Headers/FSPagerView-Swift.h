#if 0
#elif defined(__arm64__) && __arm64__
// Generated by Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
#ifndef FSPAGERVIEW_SWIFT_H
#define FSPAGERVIEW_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#if defined(__OBJC__)
#include <Foundation/Foundation.h>
#endif
#if defined(__cplusplus)
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#include <cstring>
#include <stdlib.h>
#include <new>
#include <type_traits>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>
#endif
#if defined(__cplusplus)
#if defined(__arm64e__) && __has_include(<ptrauth.h>)
# include <ptrauth.h>
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
# ifndef __ptrauth_swift_value_witness_function_pointer
#  define __ptrauth_swift_value_witness_function_pointer(x)
# endif
# ifndef __ptrauth_swift_class_method_pointer
#  define __ptrauth_swift_class_method_pointer(x)
# endif
#pragma clang diagnostic pop
#endif
#endif

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...) 
# endif
#endif
#if !defined(SWIFT_RUNTIME_NAME)
# if __has_attribute(objc_runtime_name)
#  define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
# else
#  define SWIFT_RUNTIME_NAME(X) 
# endif
#endif
#if !defined(SWIFT_COMPILE_NAME)
# if __has_attribute(swift_name)
#  define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
# else
#  define SWIFT_COMPILE_NAME(X) 
# endif
#endif
#if !defined(SWIFT_METHOD_FAMILY)
# if __has_attribute(objc_method_family)
#  define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
# else
#  define SWIFT_METHOD_FAMILY(X) 
# endif
#endif
#if !defined(SWIFT_NOESCAPE)
# if __has_attribute(noescape)
#  define SWIFT_NOESCAPE __attribute__((noescape))
# else
#  define SWIFT_NOESCAPE 
# endif
#endif
#if !defined(SWIFT_RELEASES_ARGUMENT)
# if __has_attribute(ns_consumed)
#  define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
# else
#  define SWIFT_RELEASES_ARGUMENT 
# endif
#endif
#if !defined(SWIFT_WARN_UNUSED_RESULT)
# if __has_attribute(warn_unused_result)
#  define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
# else
#  define SWIFT_WARN_UNUSED_RESULT 
# endif
#endif
#if !defined(SWIFT_NORETURN)
# if __has_attribute(noreturn)
#  define SWIFT_NORETURN __attribute__((noreturn))
# else
#  define SWIFT_NORETURN 
# endif
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA 
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA 
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA 
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif
#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif
#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER 
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility) 
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED_OBJC)
# if __has_feature(attribute_diagnose_if_objc)
#  define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
# else
#  define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
# endif
#endif
#if defined(__OBJC__)
#if !defined(IBSegueAction)
# define IBSegueAction 
#endif
#endif
#if !defined(SWIFT_EXTERN)
# if defined(__cplusplus)
#  define SWIFT_EXTERN extern "C"
# else
#  define SWIFT_EXTERN extern
# endif
#endif
#if !defined(SWIFT_CALL)
# define SWIFT_CALL __attribute__((swiftcall))
#endif
#if !defined(SWIFT_INDIRECT_RESULT)
# define SWIFT_INDIRECT_RESULT __attribute__((swift_indirect_result))
#endif
#if !defined(SWIFT_CONTEXT)
# define SWIFT_CONTEXT __attribute__((swift_context))
#endif
#if !defined(SWIFT_ERROR_RESULT)
# define SWIFT_ERROR_RESULT __attribute__((swift_error_result))
#endif
#if defined(__cplusplus)
# define SWIFT_NOEXCEPT noexcept
#else
# define SWIFT_NOEXCEPT 
#endif
#if !defined(SWIFT_C_INLINE_THUNK)
# if __has_attribute(always_inline)
# if __has_attribute(nodebug)
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline)) __attribute__((nodebug))
# else
#  define SWIFT_C_INLINE_THUNK inline __attribute__((always_inline))
# endif
# else
#  define SWIFT_C_INLINE_THUNK inline
# endif
#endif
#if defined(_WIN32)
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL __declspec(dllimport)
#endif
#else
#if !defined(SWIFT_IMPORT_STDLIB_SYMBOL)
# define SWIFT_IMPORT_STDLIB_SYMBOL 
#endif
#endif
#if defined(__OBJC__)
#if __has_feature(objc_modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import CoreFoundation;
@import ObjectiveC;
@import UIKit;
#endif

#endif
#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"
#pragma clang diagnostic ignored "-Wdollar-in-identifier-extension"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="FSPagerView",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)
@class NSCoder;
@class CALayer;
@class UIColor;
@class UIImage;
@class UIBezierPath;

IB_DESIGNABLE
SWIFT_CLASS("_TtC11FSPagerView13FSPageControl")
@interface FSPageControl : UIControl
/// The number of page indicators of the page control. Default is 0.
@property (nonatomic) IBInspectable NSInteger numberOfPages;
/// The current page, highlighted by the page control. Default is 0.
@property (nonatomic) IBInspectable NSInteger currentPage;
/// The spacing to use of page indicators in the page control.
@property (nonatomic) IBInspectable CGFloat itemSpacing;
/// The spacing to use between page indicators in the page control.
@property (nonatomic) IBInspectable CGFloat interitemSpacing;
/// The distance that the page indicators is inset from the enclosing page control.
@property (nonatomic) IBInspectable UIEdgeInsets contentInsets;
/// The horizontal alignment of content within the control’s bounds. Default is center.
@property (nonatomic) UIControlContentHorizontalAlignment contentHorizontalAlignment;
/// Hide the indicator if there is only one page. default is NO
@property (nonatomic) IBInspectable BOOL hidesForSinglePage;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)layoutSubviews;
- (void)layoutSublayersOfLayer:(CALayer * _Nonnull)layer;
/// Sets the stroke color for page indicators to use for the specified state. (selected/normal).
/// \param strokeColor The stroke color to use for the specified state.
///
/// \param state The state that uses the specified stroke color.
///
- (void)setStrokeColor:(UIColor * _Nullable)strokeColor forState:(UIControlState)state;
/// Sets the fill color for page indicators to use for the specified state. (selected/normal).
/// \param fillColor The fill color to use for the specified state.
///
/// \param state The state that uses the specified fill color.
///
- (void)setFillColor:(UIColor * _Nullable)fillColor forState:(UIControlState)state;
/// Sets the image for page indicators to use for the specified state. (selected/normal).
/// \param image The image to use for the specified state.
///
/// \param state The state that uses the specified image.
///
- (void)setImage:(UIImage * _Nullable)image forState:(UIControlState)state;
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state;
/// Sets the path for page indicators to use for the specified state. (selected/normal).
/// \param path The path to use for the specified state.
///
/// \param state The state that uses the specified path.
///
- (void)setPath:(UIBezierPath * _Nullable)path forState:(UIControlState)state;
@end

@protocol FSPagerViewDataSource;
@protocol FSPagerViewDelegate;
enum ScrollDirection : NSInteger;
@class FSPagerViewTransformer;
@class UIPanGestureRecognizer;
@class UIWindow;
@class UICollectionView;
@class NSIndexPath;
@class UICollectionViewCell;
@class UIScrollView;
@class NSString;
@class UINib;
@class FSPagerViewCell;

IB_DESIGNABLE
SWIFT_CLASS("_TtC11FSPagerView11FSPagerView")
@interface FSPagerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>
/// The object that acts as the data source of the pager view.
@property (nonatomic, weak) IBOutlet id <FSPagerViewDataSource> _Nullable dataSource;
/// The object that acts as the delegate of the pager view.
@property (nonatomic, weak) IBOutlet id <FSPagerViewDelegate> _Nullable delegate;
/// The scroll direction of the pager view. Default is horizontal.
@property (nonatomic) enum ScrollDirection scrollDirection;
/// The time interval of automatic sliding. 0 means disabling automatic sliding. Default is 0.
@property (nonatomic) IBInspectable CGFloat automaticSlidingInterval;
/// The spacing to use between items in the pager view. Default is 0.
@property (nonatomic) IBInspectable CGFloat interitemSpacing;
/// The item size of the pager view. When the value of this property is FSPagerView.automaticSize, the items fill the entire visible area of the pager view. Default is FSPagerView.automaticSize.
@property (nonatomic) IBInspectable CGSize itemSize;
/// A Boolean value indicates that whether the pager view has infinite items. Default is false.
@property (nonatomic) IBInspectable BOOL isInfinite;
/// An unsigned integer value that determines the deceleration distance of the pager view, which indicates the number of passing items during the deceleration. When the value of this property is FSPagerView.automaticDistance, the actual ‘distance’ is automatically calculated according to the scrolling speed of the pager view. Default is 1.
@property (nonatomic) IBInspectable NSUInteger decelerationDistance;
/// A Boolean value that determines whether scrolling is enabled.
@property (nonatomic) IBInspectable BOOL isScrollEnabled;
/// A Boolean value that controls whether the pager view bounces past the edge of content and back again.
@property (nonatomic) IBInspectable BOOL bounces;
/// A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
@property (nonatomic) IBInspectable BOOL alwaysBounceHorizontal;
/// A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content view.
@property (nonatomic) IBInspectable BOOL alwaysBounceVertical;
/// A Boolean value that controls whether the infinite loop is removed if there is only one item. Default is false.
@property (nonatomic) IBInspectable BOOL removesInfiniteLoopForSingleItem;
/// The background view of the pager view.
@property (nonatomic, strong) IBInspectable UIView * _Nullable backgroundView;
/// The transformer of the pager view.
@property (nonatomic, strong) FSPagerViewTransformer * _Nullable transformer;
/// Returns whether the user has touched the content to initiate scrolling.
@property (nonatomic, readonly) BOOL isTracking;
/// The percentage of x position at which the origin of the content view is offset from the origin of the pagerView view.
@property (nonatomic, readonly) CGFloat scrollOffset;
/// The underlying gesture recognizer for pan gestures.
@property (nonatomic, readonly, strong) UIPanGestureRecognizer * _Nonnull panGestureRecognizer;
@property (nonatomic, readonly) NSInteger currentIndex;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)layoutSubviews;
- (void)willMoveToWindow:(UIWindow * _Nullable)newWindow;
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView * _Nonnull)collectionView SWIFT_WARN_UNUSED_RESULT;
- (NSInteger)collectionView:(UICollectionView * _Nonnull)collectionView numberOfItemsInSection:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (UICollectionViewCell * _Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
- (BOOL)collectionView:(UICollectionView * _Nonnull)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
- (void)collectionView:(UICollectionView * _Nonnull)collectionView didHighlightItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (BOOL)collectionView:(UICollectionView * _Nonnull)collectionView shouldSelectItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
- (void)collectionView:(UICollectionView * _Nonnull)collectionView didSelectItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)collectionView:(UICollectionView * _Nonnull)collectionView willDisplayCell:(UICollectionViewCell * _Nonnull)cell forItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)collectionView:(UICollectionView * _Nonnull)collectionView didEndDisplayingCell:(UICollectionViewCell * _Nonnull)cell forItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;
- (void)scrollViewDidScroll:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewWillBeginDragging:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewWillEndDragging:(UIScrollView * _Nonnull)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint * _Nonnull)targetContentOffset;
- (void)scrollViewDidEndDecelerating:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView * _Nonnull)scrollView;
/// Register a class for use in creating new pager view cells.
/// \param cellClass The class of a cell that you want to use in the pager view.
///
/// \param identifier The reuse identifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
///
- (void)registerClass:(Class _Nullable)cellClass forCellWithReuseIdentifier:(NSString * _Nonnull)identifier;
/// Register a nib file for use in creating new pager view cells.
/// \param nib The nib object containing the cell object. The nib file must contain only one top-level object and that object must be of the type FSPagerViewCell.
///
/// \param identifier The reuse identifier to associate with the specified nib file. This parameter must not be nil and must not be an empty string.
///
- (void)registerNib:(UINib * _Nullable)nib forCellWithReuseIdentifier:(NSString * _Nonnull)identifier;
/// Returns a reusable cell object located by its identifier
/// \param identifier The reuse identifier for the specified cell. This parameter must not be nil.
///
/// \param index The index specifying the location of the cell.
///
///
/// returns:
/// A valid FSPagerViewCell object.
- (FSPagerViewCell * _Nonnull)dequeueReusableCellWithReuseIdentifier:(NSString * _Nonnull)identifier atIndex:(NSInteger)index SWIFT_WARN_UNUSED_RESULT;
/// Reloads all of the data for the collection view.
- (void)reloadData;
/// Selects the item at the specified index and optionally scrolls it into view.
/// \param index The index path of the item to select.
///
/// \param animated Specify true to animate the change in the selection or false to make the change without animating it.
///
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
/// Deselects the item at the specified index.
/// \param index The index of the item to deselect.
///
/// \param animated Specify true to animate the change in the selection or false to make the change without animating it.
///
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
/// Scrolls the pager view contents until the specified item is visible.
/// \param index The index of the item to scroll into view.
///
/// \param animated Specify true to animate the scrolling behavior or false to adjust the pager view’s visible content immediately.
///
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;
/// Returns the index of the specified cell.
/// \param cell The cell object whose index you want.
///
///
/// returns:
/// The index of the cell or NSNotFound if the specified cell is not in the pager view.
- (NSInteger)indexForCell:(FSPagerViewCell * _Nonnull)cell SWIFT_WARN_UNUSED_RESULT;
/// Returns the visible cell at the specified index.
/// \param index The index that specifies the position of the cell.
///
///
/// returns:
/// The cell object at the corresponding position or nil if the cell is not visible or index is out of range.
- (FSPagerViewCell * _Nullable)cellForItemAtIndex:(NSInteger)index SWIFT_WARN_UNUSED_RESULT;
@end


@interface FSPagerView (SWIFT_EXTENSION(FSPagerView))
@end

/// Constants indicating the direction of scrolling for the pager view.
typedef SWIFT_ENUM(NSInteger, ScrollDirection, closed) {
/// The pager view scrolls content horizontally
  ScrollDirectionHorizontal = 0,
/// The pager view scrolls content vertically
  ScrollDirectionVertical = 1,
};


SWIFT_CLASS("_TtC11FSPagerView15FSPagerViewCell")
@interface FSPagerViewCell : UICollectionViewCell
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)layoutSubviews;
@end


SWIFT_PROTOCOL("_TtP11FSPagerView21FSPagerViewDataSource_")
@protocol FSPagerViewDataSource <NSObject>
/// Asks your data source object for the number of items in the pager view.
- (NSInteger)numberOfItemsInPagerView:(FSPagerView * _Nonnull)pagerView SWIFT_WARN_UNUSED_RESULT;
/// Asks your data source object for the cell that corresponds to the specified item in the pager view.
- (FSPagerViewCell * _Nonnull)pagerView:(FSPagerView * _Nonnull)pagerView cellForItemAtIndex:(NSInteger)index SWIFT_WARN_UNUSED_RESULT;
@end


SWIFT_PROTOCOL("_TtP11FSPagerView19FSPagerViewDelegate_")
@protocol FSPagerViewDelegate <NSObject>
@optional
/// Asks the delegate if the item should be highlighted during tracking.
- (BOOL)pagerView:(FSPagerView * _Nonnull)pagerView shouldHighlightItemAtIndex:(NSInteger)index SWIFT_WARN_UNUSED_RESULT;
/// Tells the delegate that the item at the specified index was highlighted.
- (void)pagerView:(FSPagerView * _Nonnull)pagerView didHighlightItemAtIndex:(NSInteger)index;
/// Asks the delegate if the specified item should be selected.
- (BOOL)pagerView:(FSPagerView * _Nonnull)pagerView shouldSelectItemAtIndex:(NSInteger)index SWIFT_WARN_UNUSED_RESULT;
/// Tells the delegate that the item at the specified index was selected.
- (void)pagerView:(FSPagerView * _Nonnull)pagerView didSelectItemAtIndex:(NSInteger)index;
/// Tells the delegate that the specified cell is about to be displayed in the pager view.
- (void)pagerView:(FSPagerView * _Nonnull)pagerView willDisplayCell:(FSPagerViewCell * _Nonnull)cell forItemAtIndex:(NSInteger)index;
/// Tells the delegate that the specified cell was removed from the pager view.
- (void)pagerView:(FSPagerView * _Nonnull)pagerView didEndDisplayingCell:(FSPagerViewCell * _Nonnull)cell forItemAtIndex:(NSInteger)index;
/// Tells the delegate when the pager view is about to start scrolling the content.
- (void)pagerViewWillBeginDragging:(FSPagerView * _Nonnull)pagerView;
/// Tells the delegate when the user finishes scrolling the content.
- (void)pagerViewWillEndDragging:(FSPagerView * _Nonnull)pagerView targetIndex:(NSInteger)targetIndex;
/// Tells the delegate when the user scrolls the content view within the receiver.
- (void)pagerViewDidScroll:(FSPagerView * _Nonnull)pagerView;
/// Tells the delegate when a scrolling animation in the pager view concludes.
- (void)pagerViewDidEndScrollAnimation:(FSPagerView * _Nonnull)pagerView;
/// Tells the delegate that the pager view has ended decelerating the scrolling movement.
- (void)pagerViewDidEndDecelerating:(FSPagerView * _Nonnull)pagerView;
@end


SWIFT_CLASS("_TtC11FSPagerView27FSPagerViewLayoutAttributes")
@interface FSPagerViewLayoutAttributes : UICollectionViewLayoutAttributes
- (BOOL)isEqual:(id _Nullable)object SWIFT_WARN_UNUSED_RESULT;
- (id _Nonnull)copyWithZone:(struct _NSZone * _Nullable)zone SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

enum FSPagerViewTransformerType : NSInteger;

SWIFT_CLASS("_TtC11FSPagerView22FSPagerViewTransformer")
@interface FSPagerViewTransformer : NSObject
- (nonnull instancetype)initWithType:(enum FSPagerViewTransformerType)type OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end

typedef SWIFT_ENUM(NSInteger, FSPagerViewTransformerType, closed) {
  FSPagerViewTransformerTypeNone = 0,
  FSPagerViewTransformerTypeCrossFading = 1,
  FSPagerViewTransformerTypeZoomOut = 2,
  FSPagerViewTransformerTypeDepth = 3,
  FSPagerViewTransformerTypeOverlap = 4,
  FSPagerViewTransformerTypeLinear = 5,
  FSPagerViewTransformerTypeCoverFlow = 6,
  FSPagerViewTransformerTypeFerrisWheel = 7,
  FSPagerViewTransformerTypeInvertedFerrisWheel = 8,
  FSPagerViewTransformerTypeCubic = 9,
};

#endif
#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#if defined(__cplusplus)
#endif
#pragma clang diagnostic pop
#endif

#else
#error unsupported Swift architecture
#endif
