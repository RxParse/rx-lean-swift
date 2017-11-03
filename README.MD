# RxLeanCloudSwift
使用 Swift 语言重新编写的基于 RxSwift 的 SDK for iOS/macOS/tvOS/watchOS

## 开发进度

- [ ] RxAVObject - [RxAVObject doc issue](https://github.com/RxLeanCloud/rx-lean-swift/issues/8)
  - [x] save
  - [x] update
  - [ ] delete
  - [x] fetch
  - [x] increase
  - [x] unset
- [ ] RxAVQuery - [RxAVQuery doc issue](https://github.com/RxLeanCloud/rx-lean-swift/issues/9)
  - [x] find
  - [ ] first
  - [ ] count
- [x] RxAVClient
  - [x] multiple RxAVApp
  - [x] request
- [ ] RxAVUser
  - [x] logIn
  - [ ] signUp
  - [x] cache to local storage(use [UserDefaults.standard](https://developer.apple.com/documentation/foundation/userdefaults)).
- [ ] RxSMS
  - [ ] send
  - [ ] verify
  - [ ] captcha
- [ ] RxAVCloud
  - [x] callCloudFunction
  - [ ] rpcCloudFunction
- [ ] RxAVRealtime - [RxAVRealtime doc issue](https://github.com/RxLeanCloud/rx-lean-swift/issues/5)
  - [x] connect
  - [x] connectWithUser
  - [x] createConversation
  - [x] send
  - [x] onMessage
  - [ ] onEvent
- [ ] RxLiveQuery
  - [ ] subscribe
  - [ ] on
- [ ] RxAVPush
  - [ ] registerDeviceToken

## 安装 - Installation

### Cocoapods

假设有一个 XCode 的 Project 叫做 `Sights`，请编写如下 Podfile 放在根目录下：

```ruby
platform :ios, '10.0'
use_frameworks!

target 'Sights' do
    pod 'RxLeanCloud','~> 0.1.0'
end

target 'SightsTests' do
    pod 'RxLeanCloud','~> 0.1.0'
    pod 'RxBlocking', '> 4.0'
    pod 'RxTest', '> 4.0'
end
```

## 测试
首先需要引用测试的时候必要的 module :

```swift
import RxLeanCloudSwift
import RxSwift
import RxTest
import RxBlocking
```

在单元测试项目里面需要在 setup 里面进行如下初始化：

```swift
  override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
      let app: RxAVApp = RxAVApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
      let sdk = RxAVClient.initialize(app: app)
      sdk.toggleLog(enable: true)
  }
```

单元测试示例如下：

```swift
func testCreareNewAVObject() {
    let todo = RxAVObject(className: "RxSwiftTodo")
    todo["foo"] = "bar"
    let result = todo.save()
        .toBlocking()
        .materialize()

    switch result {
    case .completed(let elements):
        print(elements[0].createdAt)
        //XCTFail("Expected result to complete with error, but result was successful.")
    case .failed(let elements, let error):
        print(error.localizedDescription)
    }
}
```

## 为什么要使用 RxSwift？ - Why RxSwift

首先要安利一下 [ReactiveX/RxSwift](https://github.com/ReactiveX/RxSwift) 上社区主页的几篇介绍文章请英文好的同学一定要去阅读

以下两篇是 [realm](https://realm.io/cn/) 公司出品的两篇文章，是由两位工程师做的公开分享里面的汇总，推荐阅读和仔细品读里面列举的代码示例

- [使用 RxSwift 进行响应式编程](https://news.realm.io/cn/news/altconf-scott-gardner-reactive-programming-with-rxswift/)
- [RxSwift 函数响应式编程](https://news.realm.io/cn/news/slug-max-alexander-functional-reactive-rxswift/)


## 我们如何选择？

目前 LeanCloud 官方 iOS/macOS sdk 依旧保持着高速的迭代以及稳定的性能和完整的功能，假设不是特别喜欢 rx 风格的编码或者说，或者项目已经基于旧版的 iOS sdk 上线运行了很长时间了，那十分建议仅仅把 RxLeanCloudSwift 当做一个小玩具去研究或者加入我们一起完善

但是我依然十分推崇所有新的项目或者说是练手的 app 采用 RxLeanCloudSwift 作为您 LeanCloud 旅程的第一站：

- 长远得看 Swift 会比较容易让新手学习，毕竟这门语言是新时代的产品，它汲取了许多语言的优良特性
- Rx 风格的语言格外的，尤其的适合编写客户端，等业务逻辑繁琐起来，你会发现循环嵌套的 block 回调绝对是噩梦
- 在 RxLeanCloudSwift 成为官方钦定语言之前，它不受到任何商业角度的限制，坚持社区化


## 成为贡献者

[联系我们](mailto:jun.wu@leancloud.rocks)

