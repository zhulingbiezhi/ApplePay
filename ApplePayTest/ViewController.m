//
//  ViewController.m
//  ApplePayTest
//
//  Created by tiger on 16/4/19.
//  Copyright © 2016年 韩山虎. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>
#import <AFNetworking.h>


@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController
NSString *serverIP=@"http://192.168.22.26:9090/applePay";
UIButton *button;
UITextView *showTextView;
-(void)clickServer{
    __block UITextField *toptextField;
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:@"输入传输的服务器地址" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        toptextField=textField;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              //响应事件
        serverIP=toptextField.text;
        
        [button setTitle:[NSString stringWithFormat:@"服务器地址:%@",serverIP] forState:UIControlStateNormal];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    }];
    
    [alertController addAction:defaultAction];
    [alertController addAction:cancelAction];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 0, self.view.frame.size.width,75);
    button.backgroundColor=[UIColor lightGrayColor];
    [button setTitle:[NSString stringWithFormat:@"设置服务器地址:%@",serverIP] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(clickServer) forControlEvents:UIControlEventTouchUpInside];
   
    
    showTextView=[[UITextView alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height-120)];
    
    [self.view addSubview:showTextView];
    showTextView.textColor=[UIColor blackColor];
    showTextView.text=@"传输的结果";
//    Type : 类型
//    PKPaymentButtonTypePlain
//    PKPaymentButtonTypeBuy
//    PKPaymentButtonTypeSetUp
    
//    style : 样式
//    PKPaymentButtonStyleWhite
//    PKPaymentButtonStyleWhiteOutline
//    PKPaymentButtonStyleBlack
    
    //以上的样式和类型，大家可以更换下，运行后可以直接查看到效果。在这里就不在解释。
    PKPaymentButton * payButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleWhiteOutline];
    payButton.frame = CGRectMake(0, 75, self.view.frame.size.width, 45);
    
    [payButton addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payButton];
    
    
    

}

-(void)payAction:(PKPaymentButton *)button
{
    //系统提供了API来判断当前设备是否支持Apple Pay支付的功能。
    if([PKPaymentAuthorizationViewController canMakePayments]){
        //设备支持支付
        //PKPayment类来创建支付请求
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        //国家 //HK 香港   CN :  中国大陆
        request.countryCode = @"HK";
        //人民币 // HKD  港币  CNY : 人民币    USD : 美元
        request.currencyCode = @"HKD";// 其他国家以及币种的缩写自行百度
        ///由商家支持的支付网络 所支持的卡类型
        //此属性限制支付卡，可以支付。
        //        PKPaymentNetworkAmex : 美国运通
        //        PKPaymentNetworkChinaUnionPay : 中国银联
        //        PKPaymentNetworkVisa  : Visa卡
        //        PKPaymentNetworkMasterCard : 万事达信用卡

        //        PKPaymentNetworkDiscover
        //        PKPaymentNetworkInterac
        //        PKPaymentNetworkPrivateLabel
        //        PKEncryptionSchemeECC_V2
        request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkChinaUnionPay, PKPaymentNetworkDiscover, PKPaymentNetworkInterac, PKPaymentNetworkMasterCard, PKPaymentNetworkPrivateLabel, PKPaymentNetworkVisa, PKEncryptionSchemeECC_V2];
        
        //        PKMerchantCapability3DS // 美国的一个卡 必须支持
        //        PKMerchantCapabilityEMV // 欧洲的卡
        //        PKMerchantCapabilityCredit //信用卡
        //        PKMerchantCapabilityDebit //借记卡
        
        //商家的支付处理能力
        //PKMerchantCapabilityEMV : 他的旗下有三大银行 ： 中国银联 Visa卡 万事达信用卡
        //也就是说merchantCapabilities指的支付的银行卡的范围。
        //request.merchantCapabilities =    PKMerchantCapabilityEMV;
        
        request.merchantCapabilities =  PKMerchantCapability3DS;
        
        //merchantIdentifier 要和你在开发者中心生成的id保持一致
        request.merchantIdentifier = @"merchant.com.bindo.lhtestapplepay";
        
        
        //需要的配送信息和账单信息
        request.requiredBillingAddressFields = PKAddressFieldAll;
        request.requiredShippingAddressFields = PKAddressFieldAll;

        //运输方式
        NSDecimalNumber * shippingPrice = [NSDecimalNumber decimalNumberWithString:@"0.01"];
        PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"快递公司" amount:shippingPrice];
        method.detail = @"24小时送到！";
        method.identifier = @"kuaidi";
        request.shippingMethods = @[method];
        request.shippingType = PKShippingTypeServicePickup;
        
        
        // 2.9 存储额外信息
        // 使用applicationData属性来存储一些在你的应用中关于这次支付请求的唯一标识信息，比如一个购物车的标识符。在用户授权支付之后，这个属性的哈希值会出现在这次支付的token中。
        request.applicationData = [@"商品ID:123456" dataUsingEncoding:NSUTF8StringEncoding];
        
        
        //添加物品到支付页
        //创建物品并显示，这个对象描述了一个物品和它的价格，数组最后的对象必须是总价格。
        //使用PKPaymentSummaryItem来创建商品信息
        
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"Bindo测试" amount:[NSDecimalNumber decimalNumberWithString:@"0.1"]];
        
        
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Bindo测试Total" amount:[NSDecimalNumber decimalNumberWithString:@"0.1"]];
        
        request.paymentSummaryItems = @[widget1, total];
        //        request.paymentSummaryItems = @[widget1];
        
        //显示认证视图
        PKPaymentAuthorizationViewController * paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        paymentPane.delegate = self;
        
        
        [self presentViewController:paymentPane animated:TRUE completion:nil];
        
    }else{
        //设备不支持支付
        NSLog(@"设备不支持支付");
    }
}


#pragma mark -PKPaymentAuthorizationViewControllerDelegate
//这个代理方法指的是支付过程中会进行调用
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
  
    
    NSDictionary *finalDict=@{
                              @"token":[self returnTokenDictBy:payment.token],
                              @"billing":[self returnContactDictBy:payment.billingContact],
                              @"shipping":[self returnContactDictBy:payment.shippingContact],
                              @"shippingMethod":@{
                                      @"identifier":[self dealString:payment.shippingMethod.identifier],
                                      @"detail":[self dealString:payment.shippingMethod.detail]
                                      }
                              };
    
    
    
    [ViewController POST_Connect:serverIP parameters:finalDict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"成功");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"出现错误");
        NSLog(@"%@",error);
    }];
    showTextView.text=[self dictionaryToJson:finalDict];
    
    
    
    BOOL isSuccess = YES;
    
    if (isSuccess) {
        
        
        completion(PKPaymentAuthorizationStatusSuccess);
    }else
    {
        completion(PKPaymentAuthorizationStatusFailure);
    }
}
// 当授权成功之后或者取消授权之后会调用这个代理方法
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    
    NSLog(@"取消或者交易完成");
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -other
-(NSDictionary *)returnContactDictBy:(PKContact *)contact{
    return @{
             @"name":@{
                     @"namePrefix":[self dealString:contact.name.namePrefix],
                     @"givenName":[self dealString:contact.name.givenName],
                     @"middleName":[self dealString:contact.name.middleName],
                     @"familyName":[self dealString:contact.name.familyName],
                     @"nameSuffix":[self dealString:contact.name.nameSuffix],
                     @"nickname":[self dealString:contact.name.nickname],
                     },
//             @"postalAddress":@{
//                     @"street":[self dealString:contact.postalAddress.street],
////                     @"subLocality":[self dealString:contact.postalAddress.subLocality],
//                     @"city":[self dealString:contact.postalAddress.city],
//                     @"subAdministrativeArea":[self dealString:contact.postalAddress.subAdministrativeArea],
//                     @"postalCode":[self dealString:contact.postalAddress.postalCode],
//                     @"country":[self dealString:contact.postalAddress.country],
//                     @"ISOCountryCode":[self dealString:contact.postalAddress.ISOCountryCode],
//                     },
             @"phoneNumber":[self dealString:contact.phoneNumber.stringValue],
             @"emailAddress":[self dealString:contact.emailAddress]
             };
}



-(NSDictionary *)returnTokenDictBy:(PKPaymentToken *)token{
    NSDictionary *methodDict=[self returnMethodDict:token.paymentMethod];
    NSString *transactionIdentifier=token.transactionIdentifier;
    NSString* paymentDataString;
    if (token.paymentData.bytes) {
        paymentDataString = [NSString stringWithUTF8String:token.paymentData.bytes];
    }
    
    
    return @{
             @"methodDict":methodDict,
             @"transactionIdentifier":[self dealString:transactionIdentifier],
             @"paymentDataString":[self dealString:paymentDataString],
             };
}



-(NSDictionary *)returnMethodDict:(PKPaymentMethod *) method{
    NSString *displayName=method.displayName;
    NSString * network=(NSString *)method.network;
    
    NSString *methodType=@"Unknown";
    switch (method.type) {
        case PKPaymentMethodTypeUnknown:
            methodType=@"Unknown";
            break;
        case PKPaymentMethodTypeDebit:
            methodType=@"Debit";
            break;
        case PKPaymentMethodTypeCredit:
            methodType=@"Credit";
            break;
        case PKPaymentMethodTypePrepaid:
            methodType=@"Prepaid";
            break;
        case PKPaymentMethodTypeStore:
            methodType=@"Store";
            break;
        default:
            break;
    }
    
    
    NSDictionary *paymentPassDict=@{
                                    @"primaryAccountIdentifier":[self dealString:method.paymentPass.primaryAccountIdentifier],
                                    @"primaryAccountNumberSuffix":[self dealString:method.paymentPass.primaryAccountNumberSuffix],
                                    @"deviceAccountIdentifier":[self dealString:method.paymentPass.deviceAccountIdentifier],
                                    @"deviceAccountNumberSuffix":[self dealString:method.paymentPass.deviceAccountNumberSuffix],
                                    };
    NSDictionary *methodDict=@{
                               @"displayName":displayName,
                               @"network":network,
                               @"type":methodType,
                               @"paymentPass":paymentPassDict
                               };
    return methodDict;
}





#pragma mark -utilty
-(NSString *)dealString:(NSString *)str{
    if (str) {
        return str;
    }
    return @"";
}
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark 获取AFNetWorking的单例
#pragma mark -
+ (AFHTTPSessionManager *)returnHTTPSessionManager {
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    
    return manager;
}


#pragma mark -
#pragma mark HTTPSession Get POST方法封装
#pragma mark URLSession 下载方法封装
#pragma mark -
+(void)Get_Connect:(NSString *)URLString
        parameters:(id)parameters
          progress:(void (^)(NSProgress *downloadProgress))downloadProgress
           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
           failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure{
    [[self returnHTTPSessionManager]GET:URLString parameters:parameters progress:downloadProgress success:success failure:failure];
}
+(void)POST_Connect:(NSString *)URLString
         parameters:(id)parameters
           progress:(void (^)(NSProgress *uploadProgress))uploadProgress
            success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
            failure:(void (^)(NSURLSessionDataTask * task, NSError *error))failure{
    
    [[self returnHTTPSessionManager]POST:URLString parameters:parameters progress:uploadProgress success:success failure:failure];
}
@end
