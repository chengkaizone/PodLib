#if 0
#elif defined(__arm64__) && __arm64__
// Generated by Apple Swift version 5.9 (swiftlang-5.9.0.128.108 clang-1500.0.40.1)
#ifndef SGPAGINGVIEW_SWIFT_H
#define SGPAGINGVIEW_SWIFT_H
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
@import Foundation;
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
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="SGPagingView",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

#if defined(__OBJC__)
typedef SWIFT_ENUM(NSInteger, ImageLocation, closed) {
  ImageLocationLeft = 0,
  ImageLocationRight = 1,
  ImageLocationTop = 2,
  ImageLocationBottom = 3,
};

/// 指示器添加到父视图上的层级位置，（Default：标题之下，Top：标题之上）
typedef SWIFT_ENUM(NSInteger, IndicatorLocation, closed) {
  IndicatorLocationDefault = 0,
  IndicatorLocationTop = 1,
};

/// 指示器随内容子视图滚动而滚动的样式
typedef SWIFT_ENUM(NSInteger, IndicatorScrollStyle, closed) {
  IndicatorScrollStyleDefault = 0,
  IndicatorScrollStyleHalf = 1,
  IndicatorScrollStyleEnd = 2,
};

/// 指示器样式
typedef SWIFT_ENUM(NSInteger, IndicatorType, closed) {
  IndicatorTypeDefault = 0,
  IndicatorTypeCover = 1,
  IndicatorTypeFixed = 2,
  IndicatorTypeDynamic = 3,
};

@protocol SGPagingContentViewDelegate;
@class NSCoder;

SWIFT_CLASS("_TtC12SGPagingView19SGPagingContentView")
@interface SGPagingContentView : UIView
/// SGPagingContentView 的代理
@property (nonatomic, weak) id <SGPagingContentViewDelegate> _Nullable delegate;
/// 内容视图的子视图是否需要动画效果，默认为 false
/// 为 true 时，点击标题如果指示器出现异常跳动，设置 isBounces = true，即可避免这个问题
@property (nonatomic) BOOL isAnimated;
/// 内容视图的子视图是否可以左右滚动，默认为 true；为 false 时，不需要设置代理及其方法
@property (nonatomic) BOOL isScrollEnabled;
/// 当内容视图的子视图滚动到最左边或最右边时，是否需要回弹效果，默认为 false
@property (nonatomic) BOOL isBounces;
/// 根据外界提供的下标值设置内容视图对应的子视图
- (void)setPagingContentViewWithIndex:(NSInteger)index;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIViewController;

SWIFT_CLASS("_TtC12SGPagingView29SGPagingContentCollectionView")
@interface SGPagingContentCollectionView : SGPagingContentView
- (nonnull instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController * _Nonnull)parentVC childVCs:(NSArray<UIViewController *> * _Nonnull)childVCs OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder SWIFT_UNAVAILABLE;
@property (nonatomic) BOOL isScrollEnabled;
@property (nonatomic) BOOL isBounces;
- (void)setPagingContentViewWithIndex:(NSInteger)index;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
@end


@class UICollectionView;
@class NSIndexPath;
@class UICollectionViewCell;

@interface SGPagingContentCollectionView (SWIFT_EXTENSION(SGPagingView)) <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView * _Nonnull)collectionView numberOfItemsInSection:(NSInteger)section SWIFT_WARN_UNUSED_RESULT;
- (UICollectionViewCell * _Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath SWIFT_WARN_UNUSED_RESULT;
@end

@class UIScrollView;

@interface SGPagingContentCollectionView (SWIFT_EXTENSION(SGPagingView)) <UICollectionViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewDidScroll:(UIScrollView * _Nonnull)scrollView;
@end


SWIFT_CLASS("_TtC12SGPagingView25SGPagingContentScrollView")
@interface SGPagingContentScrollView : SGPagingContentView
- (nonnull instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController * _Nonnull)parentVC childVCs:(NSArray<UIViewController *> * _Nonnull)childVCs OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder SWIFT_UNAVAILABLE;
@property (nonatomic) BOOL isScrollEnabled;
@property (nonatomic) BOOL isBounces;
- (void)setPagingContentViewWithIndex:(NSInteger)index;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
@end



@interface SGPagingContentScrollView (SWIFT_EXTENSION(SGPagingView)) <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView * _Nonnull)scrollView;
- (void)scrollViewDidScroll:(UIScrollView * _Nonnull)scrollView;
@end



SWIFT_PROTOCOL("_TtP12SGPagingView27SGPagingContentViewDelegate_")
@protocol SGPagingContentViewDelegate <NSObject>
@optional
/// 滚动当前子视图时对应的相关数据
/// \param contentView 分页滚动内容视图
///
/// \param progress 滚动进度值
///
/// \param currentIndex 当前子视图的下标值
///
/// \param targetIndex 目标子视图的下标值
///
- (void)pagingContentViewWithContentView:(SGPagingContentView * _Nonnull)contentView progress:(CGFloat)progress currentIndex:(NSInteger)currentIndex targetIndex:(NSInteger)targetIndex;
/// 内容视图当前对应子视图的下标值
/// \param index 当前子视图的下标值
///
- (void)pagingContentViewWithIndex:(NSInteger)index;
/// 内容视图滚动的方法（仅 SGPagingContentScrollView 实现了该方法）
- (void)pagingContentViewDidScroll;
/// 内容视图开始拖拽的方法
- (void)pagingContentViewWillBeginDragging;
/// 内容视图结束拖拽的方法
- (void)pagingContentViewDidEndDecelerating;
@end

@class NSString;
@class SGPagingTitleViewConfigure;
@protocol SGPagingTitleViewDelegate;

SWIFT_CLASS("_TtC12SGPagingView17SGPagingTitleView")
@interface SGPagingTitleView : UIView
- (nonnull instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> * _Nonnull)titles configure:(SGPagingTitleViewConfigure * _Nonnull)configure OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)coder SWIFT_UNAVAILABLE;
/// SGPagingTitleView 的代理
@property (nonatomic, weak) id <SGPagingTitleViewDelegate> _Nullable delegate;
/// 选中标题的下标，默认为 0
@property (nonatomic) NSInteger index;
/// 重置选中标题的下标
- (void)resetWithIndex:(NSInteger)index;
- (void)layoutSubviews;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
@end











@class NSAttributedString;
@class UIColor;

@interface SGPagingTitleView (SWIFT_EXTENSION(SGPagingView))
/// 根据 SGPagingContentView 子视图的滚动而去修改标题选中样式
- (void)setPagingTitleViewWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex targetIndex:(NSInteger)targetIndex;
/// 根据标题下标值重置标题文字
- (void)resetTitleWithText:(NSString * _Nonnull)text index:(NSInteger)index;
/// 根据标题下标值设置标题的 attributed 属性
- (void)setTitleWithAttributed:(NSAttributedString * _Nonnull)attributed selectedAttributed:(NSAttributedString * _Nonnull)selectedAttributed index:(NSInteger)index;
/// 重置指示器颜色
- (void)resetIndicatorWithColor:(UIColor * _Nonnull)color;
/// 重置标题颜色(color：普通状态下标题颜色、selectedColor：选中状态下标题颜色)
- (void)resetTitleWithColor:(UIColor * _Nonnull)color selectedColor:(UIColor * _Nonnull)selectedColor;
/// 根据标题下标值添加对应的 badge
- (void)addBadgeWithIndex:(NSInteger)index;
/// 根据标题下标值添加对应的 badge 及其文字
- (void)addBadgeWithText:(NSString * _Nonnull)text index:(NSInteger)index;
/// 根据标题下标值移除对应的 badge
- (void)removeBadgeWithIndex:(NSInteger)index;
/// 设置标题图片及相对文字的位置（支持本地和网络图片）
- (void)setImageWithNames:(NSArray<NSString *> * _Nonnull)names location:(enum ImageLocation)location spacing:(CGFloat)spacing;
/// 根据标题下标值设置标题图片及相对文字的位置（支持本地和网络图片）
- (void)setImageWithName:(NSString * _Nonnull)name location:(enum ImageLocation)location spacing:(CGFloat)spacing index:(NSInteger)index;
/// 根据标题下标值设置标题背景图片（支持本地和网络图片）
- (void)setBackgroundImageWithName:(NSString * _Nonnull)name selectedName:(NSString * _Nullable)selectedName index:(NSInteger)index;
@end

@class UIFont;

SWIFT_CLASS("_TtC12SGPagingView26SGPagingTitleViewConfigure")
@interface SGPagingTitleViewConfigure : NSObject
/// SGPagingTitleView 固定样式下，是否需要回弹效果，默认为 false
@property (nonatomic) BOOL bounce;
/// SGPagingTitleView 滚动样式下，是否需要回弹效果，默认为 true
@property (nonatomic) BOOL bounces;
/// SGPagingTitleView 固定样式下标题是否均分布局，默认为 true
@property (nonatomic) BOOL equivalence;
/// SGPagingTitleView 是否显示底部分割线，默认为 true
@property (nonatomic) BOOL showBottomSeparator;
/// SGPagingTitleView 底部分割线颜色，默认为 lightGray
@property (nonatomic, strong) UIColor * _Nonnull bottomSeparatorColor;
/// 标题文字大小，默认为 .systemFont(ofSize: 15)
@property (nonatomic, strong) UIFont * _Nonnull font;
/// 标题文字选中时大小，默认为 .systemFont(ofSize: 15)，一旦设置此属性，textZoom 属性将不起作用
@property (nonatomic, strong) UIFont * _Nonnull selectedFont;
/// 普通状态下标题颜色，默认为 black
@property (nonatomic, strong) UIColor * _Nonnull color;
/// 选中状态下标题颜色，默认为 red
@property (nonatomic, strong) UIColor * _Nonnull selectedColor;
/// 标题文字是否具有渐变效果，默认为 false
@property (nonatomic) BOOL gradientEffect;
/// 标题文字是否具有缩放效果，默认为 false。为 true 时，请与 textZoomRatio 属性结合使用，否则不起作用。（特别需要注意的是：此属性为 true 时，与 indicatorScrollStyle 属性不兼容）
@property (nonatomic) BOOL textZoom;
/// 标题文字缩放比，默认为 0.0f，取值范围 0.0 ～ 1.0f。请与 textZoom = true 时结合使用，否则不起作用
@property (nonatomic) CGFloat textZoomRatio;
/// 标题额外需要增加的宽度，默认为 20.0（标题宽度 = 文字宽度 + additionalWidth)
@property (nonatomic) CGFloat additionalWidth;
/// 是否显示指示器，默认为 true
@property (nonatomic) BOOL showIndicator;
/// 指示器颜色，默认为 red
@property (nonatomic, strong) UIColor * _Nonnull indicatorColor;
/// 指示器高度，默认为 2.0f
@property (nonatomic) CGFloat indicatorHeight;
/// 指示器动画时间，默认为 0.1f，取值范围 0.0 ～ 0.3f
@property (nonatomic) NSTimeInterval indicatorAnimationTime;
/// 指示器圆角大小，默认为 0.0f
@property (nonatomic) CGFloat indicatorCornerRadius;
/// 指示器 Cover 样式下的边框宽度，默认为 0.0f
@property (nonatomic) CGFloat indicatorBorderWidth;
/// 指示器 Cover 样式下的边框颜色，默认为 clear
@property (nonatomic, strong) UIColor * _Nonnull indicatorBorderColor;
/// 指示器 Cover、Default 样式下额外增加的宽度，默认为 0.0f；指示器默认宽度等于标题文字宽度
@property (nonatomic) CGFloat indicatorAdditionalWidth;
/// 指示器 Fixed 样式下的宽度，默认为 20.0f；最大宽度并没有做限制，请根据实际情况妥善设置
@property (nonatomic) CGFloat indicatorFixedWidth;
/// 指示器 Dynamic 样式下的宽度，默认为 20.0f；最大宽度并没有做限制，请根据实际情况妥善设置
@property (nonatomic) CGFloat indicatorDynamicWidth;
/// 指示器距 SGPagingTitleView 底部间的距离，默认为 0.0f
@property (nonatomic) CGFloat indicatorToBottomDistance;
/// 指示器样式，默认为 Default
@property (nonatomic) enum IndicatorType indicatorType;
/// 滚动内容视图时，指示器切换样式，默认为 Default。（特别需要注意的是：此属性与 textZoom = true 时不兼容）
@property (nonatomic) enum IndicatorScrollStyle indicatorScrollStyle;
/// 指示器添加在父视图上的层级位置，默认为 Default
@property (nonatomic) enum IndicatorLocation indicatorLocation;
/// 是否显示标题间分割线，默认为 false
@property (nonatomic) BOOL showSeparator;
/// 标题间分割线颜色，默认为 red
@property (nonatomic, strong) UIColor * _Nonnull separatorColor;
/// 标题间分割线额外减少的长度，默认为 20.0f
@property (nonatomic) CGFloat separatorAdditionalReduceLength;
/// badge 颜色，默认为 red
@property (nonatomic, strong) UIColor * _Nonnull badgeColor;
/// badge 的高，默认为 7.0f
@property (nonatomic) CGFloat badgeHeight;
/// badge 的偏移量，默认为 zero
@property (nonatomic) CGPoint badgeOff;
/// badge 的文字颜色，默认为 white（只针对：addBadge(text:index:) 方法有效）
@property (nonatomic, strong) UIColor * _Nonnull badgeTextColor;
/// badge 的文字大小，默认为 .systemFont(ofSize: 10)（只针对：addBadge(text:index:) 方法有效）
@property (nonatomic, strong) UIFont * _Nonnull badgeTextFont;
/// badge 额外需要增加的宽度，默认为 10.0f（只针对：addBadge(text:index:) 方法有效）
@property (nonatomic) CGFloat badgeAdditionalWidth;
/// badge 边框的宽度，默认为 0（只针对：addBadge(text:index:) 方法有效）
@property (nonatomic) CGFloat badgeBorderWidth;
/// badge 边框的颜色，默认为 clear（只针对：addBadge(text:index:) 方法有效）
@property (nonatomic, strong) UIColor * _Nonnull badgeBorderColor;
/// badge 圆角大小，默认为 5.0f（只针对：addBadge(text:index:) 方法有效）
@property (nonatomic) CGFloat badgeCornerRadius;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_PROTOCOL("_TtP12SGPagingView25SGPagingTitleViewDelegate_")
@protocol SGPagingTitleViewDelegate <NSObject>
@optional
/// 获取当前选中标题下标值
- (void)pagingTitleViewWithTitleView:(SGPagingTitleView * _Nonnull)titleView index:(NSInteger)index;
@end


@interface UIButton (SWIFT_EXTENSION(SGPagingView))
/// Set image location
/// Image and title must be set before this method will work, It is recommended to set it inside the block
/// \param location location of image relative to title
///
/// \param space space between image and title
///
/// \param completion set image and title
///
- (void)setImageWithLocation:(enum ImageLocation)location space:(CGFloat)space completion:(SWIFT_NOESCAPE void (^ _Nonnull)(UIButton * _Nonnull))completion;
/// Set image location
/// Image and title must be set before this method will work
/// \param location Location of image relative to title
///
/// \param space Space between image and title
///
- (void)setImageWithLocation:(enum ImageLocation)location space:(CGFloat)space;
@end


@interface UIScreen (SWIFT_EXTENSION(SGPagingView))
/// Gets the size of the screen
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGSize size;)
+ (CGSize)size SWIFT_WARN_UNUSED_RESULT;
/// Gets the width of the screen
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGFloat width;)
+ (CGFloat)width SWIFT_WARN_UNUSED_RESULT;
/// Gets the height of the screen
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGFloat height;)
+ (CGFloat)height SWIFT_WARN_UNUSED_RESULT;
/// Gets status bar height
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGFloat statusBarHeight;)
+ (CGFloat)statusBarHeight SWIFT_WARN_UNUSED_RESULT;
/// Gets navigation bar height
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGFloat navBarHeight;)
+ (CGFloat)navBarHeight SWIFT_WARN_UNUSED_RESULT;
/// Gets tab bar height
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGFloat tabBarHeight;)
+ (CGFloat)tabBarHeight SWIFT_WARN_UNUSED_RESULT;
/// Gets bottom safeArea height
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) CGFloat safeAreaInsetBottom;)
+ (CGFloat)safeAreaInsetBottom SWIFT_WARN_UNUSED_RESULT;
@end

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
