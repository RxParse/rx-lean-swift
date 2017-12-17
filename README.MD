# RxLeanCloudSwift
使用 Swift 语言重新编写的基于 Swift 的 SDK for iOS/macOS/tvOS/watchOS

## 开发进度

- [ ] AVObject - [AVObject doc issue](https://github.com/LeanCloud/-lean-swift/issues/8)
  - [x] save
  - [x] update
  - [x] delete
  - [x] fetch
  - [x] increase
  - [x] unset
  - [x] saveAll
- [ ] AVQuery - [AVQuery doc issue](https://github.com/LeanCloud/-lean-swift/issues/9)
  - [x] find
  - [ ] first
  - [ ] count
- [x] AVClient
  - [x] multiple AVApp
  - [x] request
- [ ] AVUser
  - [x] logIn
  - [x] signUp
  - [x] cache to local storage(use [UserDefaults.standard](https://developer.apple.com/documentation/foundation/userdefaults)).
- [ ] AVSMS
  - [x] send
  - [x] verify
  - [ ] captcha
- [ ] AVCloud
  - [x] callCloudFunction
  - [x] rpcCloudFunction
- [ ] AVRealtime - [AVRealtime doc issue](https://github.com/LeanCloud/-lean-swift/issues/5)
  - [x] connect
  - [x] connectWithUser
  - [x] createConversation
  - [x] send
  - [x] onMessage
  - [ ] onEvent
- [ ] AVLiveQuery
  - [ ] subscribe
  - [ ] on
- [ ] AVPush
  - [ ] registerDeviceToken

## 安装 - Installation

### Cocoapods

假设有一个 XCode 的 Project 叫做 `Sights`，请编写如下 Podfile 放在根目录下：

```ruby
platform :ios, '10.0'
use_frameworks!

target 'Sights' do
    pod 'LeanCloud','~> 0.1.0'
end

target 'SightsTests' do
    pod 'LeanCloud','~> 0.1.0'
    pod 'Blocking', '> 4.0'
    pod 'Test', '> 4.0'
end
```

## 测试
首先需要引用测试的时候必要的 module :

```swift
import LeanCloudSwift
import Swift
import Test
import Blocking
```

在单元测试项目里面需要在 setup 里面进行如下初始化：

```swift
  override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
      let app: AVApp =  AVApp(appId: "uay57kigwe0b6f5n0e1d4z4xhydsml3dor24bzwvzr57wdap", appKey: "kfgz7jjfsk55r5a8a3y4ttd3je1ko11bkibcikonk32oozww")
      let sdk = AVClient.initialize(app: app)
      sdk.toggleLog(enable: true)
  }
```

单元测试示例如下：

```swift
func testCreareNewAVObject() {
    let todo = AVObject(className: "SwiftTodo")
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

## 为什么要使用 Swift？ - Why Swift

首先要安利一下 [ReactiveX/Swift](https://github.com/ReactiveX/Swift) 上社区主页的几篇介绍文章请英文好的同学一定要去阅读

以下两篇是 [realm](https://realm.io/cn/) 公司出品的两篇文章，是由两位工程师做的公开分享里面的汇总，推荐阅读和仔细品读里面列举的代码示例

- [使用 Swift 进行响应式编程](https://news.realm.io/cn/news/altconf-scott-gardner-reactive-programming-with-swift/)
- [Swift 函数响应式编程](https://news.realm.io/cn/news/slug-max-alexander-functional-reactive-swift/)


## 我们如何选择？

目前 LeanCloud 官方 iOS/macOS sdk 依旧保持着高速的迭代以及稳定的性能和完整的功能，假设不是特别喜欢  风格的编码或者说，或者项目已经基于旧版的 iOS sdk 上线运行了很长时间了，那十分建议仅仅把 LeanCloudSwift 当做一个小玩具去研究或者加入我们一起完善

但是我依然十分推崇所有新的项目或者说是练手的 app 采用 LeanCloudSwift 作为您 LeanCloud 旅程的第一站：

- 长远得看 Swift 会比较容易让新手学习，毕竟这门语言是新时代的产品，它汲取了许多语言的优良特性
- Rx 风格的语言格外的，尤其的适合编写客户端，等业务逻辑繁琐起来，你会发现循环嵌套的 block 回调绝对是噩梦
- 在 LeanCloudSwift 成为官方钦定语言之前，它不受到任何商业角度的限制，坚持社区化


## 成为贡献者

[联系我们](mailto:jun.wu@leancloud.rocks)

