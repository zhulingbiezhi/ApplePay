# ApplePay

Apple payment backend attention：
1、CSR文件：
本地生成CSR文件分为RSA和ECC两种加密方式，有个勾选的选项可选择加密类型，这决定了backend解密token时的decryption type

2、EMV和3DS
a）中国的银联卡等在xcode代码中必须加入EMV支持，否则会无法支付
b）对于mastercard和visa卡等支持3DS，在xcode代码中只保留3DS支持，则出来的是3DS。若同时加入了EMV，默认是EMV

3、密钥：
a）导出p12文件：选中商户证书，同时下拉显示出key，同时选中key和证书，这样才可以导出P12文件
b）根据P12导出对应的私钥即可，即merchant private key——openssl pkcs12 -in YourPrivateKey.p12 -nodes -out YourPrivateKey.pem
