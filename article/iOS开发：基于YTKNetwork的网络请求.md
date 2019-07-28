##  前言
日常开发中笔者对于网络请求的处理，一般是对AFNetworking封装一个基类方法，然后在网络请求类中调用该基类方法，这种处理方法即为集约型。
而YTKNetwork则是将每个网络请求抽象成一个对象，每个对象都可以单独的管理，称为离散型。

## 基类封装
在基类中我们可以全局设置超时时间、消息请求头等基础信息。
```
//WJBaseRequest.h
#import <YTKNetwork/YTKNetwork.h>
NS_ASSUME_NONNULL_BEGIN
@interface WJBaseRequest : YTKRequest
@end
NS_ASSUME_NONNULL_END
```
```
#import "WJBaseRequest.h"

@implementation WJBaseRequest

- (YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType
{
    return YTKResponseSerializerTypeHTTP;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary
{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (self.requestMethod == YTKRequestMethodGET) {
        
        NSString *usString= [WJGlobalMethod getUserAgentString];
        
        NSString *token = [WJUserInfoManager getCMLoginToken];
        token = token == nil ?@"":token;
        
        NSString *userid = [WJUserInfoManager getCMLoginUserId];
        userid = userid == nil ?@"" :userid;
        
        if([token length])
        {
            [headerDic setValue:token forKey:@"X-API-TOKEN"];
        }
        
        if([userid length])
        {
            [headerDic setValue:userid forKey:@"X-API-USERID"];
        }
        
        [headerDic setValue:usString forKey:@"User-Agent"];
        NSString * userGa = [WJGlobalMethod getUserAgentString];
        [headerDic setValue:userGa forKey:@"X-API-UA"];
        
    } else if (self.requestMethod == YTKRequestMethodPOST) {

        [headerDic setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
        NSString *usString= [WJGlobalMethod getUserAgentString];
        [headerDic setValue:usString forKey:@"User-Agent"];
        NSString * userGa = [WJGlobalMethod getUserAgentString];
        [headerDic setValue:userGa forKey:@"X-API-UA"];
        
        NSString *token = [WJUserInfoManager getCMLoginToken];
        token = token == nil ?@"":token;
        
        NSString *userid = [WJUserInfoManager getCMLoginUserId];
        userid = userid == nil ?@"" :userid;
        
        if([token length])
        {
            [headerDic setValue:token forKey:@"X-API-TOKEN"];
        }
        
        if([userid length])
        {
            [headerDic setValue:userid forKey:@"X-API-USERID"];
        }
        
        [headerDic setValue:usString forKey:@"User-Agent"];
    }
    
    return headerDic;
}

//请求超时时间
- (NSTimeInterval)requestTimeoutInterval
{
    return 60;
}

- (void)requestFailedPreprocessor
{
    [super requestFailedPreprocessor];
    //可以在此方法内处理token失效的情况，所有http请求统一走此方法，即会统一调用
    NSError * error = self.error;    
    if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain])
    {
        //AFNetworking处理过的错误
        NSLog(@"AFURLResponseSerializationErrorDomain");        
    }else if ([error.domain isEqualToString:YTKRequestValidationErrorDomain])
    {
        //猿题库处理过的错误
        NSLog(@"YTKRequestValidationErrorDomain");
    }else{
        //系统级别的domain错误，无网络等[NSURLErrorDomain]
        //根据error的code去定义显示的信息，保证显示的内容可以便捷的控制
        NSLog(@"RequestValidationErrorDomain");
    }
]}
@end
```
## 创建网络请求
##### 创建网络请求对象
这里需要设置请求域名、参数等
```
#import "WJBaseRequest.h"
NS_ASSUME_NONNULL_BEGIN
@interface WJGetInfoApi : WJBaseRequest
- (id)initWithUserId:(NSString *)userid;
@end
NS_ASSUME_NONNULL_END
```
```
#import "WJGetInfoApi.h"
#import "WJLocationManager.h"

@implementation WJGetInfoApi{
    NSString *_userid;
}

- (id)initWithUserId:(NSString *)userid
{
    self = [super init];
    if (self) {
        _userid = userid;
    }
    return self;
}

- (NSString *)requestUrl {
   // 这里可以设置全局域名，如果设置了全局域名的话，就只需要写后缀如，return "/user";
    return "http://www. example.com/user/getinfo";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (id)requestArgument {    
    NSString *userid = _userid;
    userid = userid == nil ?@"":userid;  
    return @{
             @"userid":_userid,
             };
}
@end
```
##### 网络请求接口调用
```
    WJGetInfoApi *api = [[WJGetInfoApi alloc] initWithUserId:userId];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request){
        // 数据解析
        NSDictionary *requestDict = [NSJSONSerialization JSONObjectWithData:request.responseObject options:NSJSONReadingMutableContainers error:nil];
        
    } failure:^(YTKBaseRequest *request){
         // 错误处理
    }];
```
## 文件上传
不知道是不是我的使用方法不对，当用YTKNetwork上传图片的时候，YTKNetwork好像没有特定的方法或者类来处理，笔者这里是自定义了消息体。上传图片时需要设置请求头的“Content-Type”为@"multipart/form-data" ，并将图片data添加到HTTP body中。

```
// WJUploadImageApi.h
#import "WJBaseRequest.h"
NS_ASSUME_NONNULL_BEGIN
@interface WJUploadImageApi : WJBaseRequest
- (id)initWithImage:(UIImage *)image;
@end
NS_ASSUME_NONNULL_END
```
```
#import "CMUploadImageApi.h"

@implementation CMUploadImageApi{
    UIImage *_image;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl {
    return "http://www. example.com/user/upload";
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary
{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithCapacity:0];
// 上传图片时需要设置请求头的“Content-Type”为@"multipart/form-data" 
    [headerDic setValue:@"multipart/form-data" forKey:@"Content-Type"];
    NSString *usString= [CMGlobalMethod getUserAgentString];
    [headerDic setValue:usString forKey:@"User-Agent"];
    NSString * userGa = [CMGlobalMethod getUserAgentString];
    [headerDic setValue:userGa forKey:@"X-API-UA"];
    
    NSString *token = [CMUserInfoManager getCMLoginToken];
    token = token == nil ?@"":token;
    
    NSString *userid = [CMUserInfoManager getCMLoginUserId];
    userid = userid == nil ?@"" :userid;
    
    if([token length])
    {
        [headerDic setValue:token forKey:@"X-API-TOKEN"];
    }
    if([userid length])
    {
        [headerDic setValue:userid forKey:@"X-API-USERID"];
    }
    [headerDic setValue:usString forKey:@"User-Agent"];
    return headerDic;
}

// 设置HTTP body
- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"image";
        NSString *formKey = @"attachment";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

- (id)jsonValidator {
    return @{ @"url": [NSString class] };
}

@end
```
