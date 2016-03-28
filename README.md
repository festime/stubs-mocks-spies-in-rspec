## 了解 Stubs, Mocks, and Spies
參考文章：[Stubs, Mocks and Spies in RSpec](https://about.futurelearn.com/blog/stubs-mocks-spies-rspec)

code 完全是照文章內容打，只是額外加上中文註解和 README

## 關於一個測項的流程
通常，都會有這三個階段
1. 準備測試環境，載入需要的 Library 、塞資料進資料庫、產生物件...等等
2. 執行，可能是對物件做操作、呼叫方法...等等
3. 斷言或預期結果，在第二步之後，某些東西應該要改變或沒改變，去檢查它們

在絕大多數問題上，類別和物件之間會互動，所以要測試一個物件或類別的 instance method ，往往也需要額外準備除了「主角」之外的「配角物件」或「有互動關係的物件」，上述文章就是在探討有什麼技巧可以用在準備這些物件，使測試能運作又比較不容易壞的



## 第一種實作方式：建立真實物件

```ruby
RSpec.describe Detective do
  it "says what noise the thingie makes" do
    thingie = Thingie.new
    subject = Detective.new(thingie)

    result = subject.investigate

    expect(result).to match(/It went (erp|blop|ping|ribbit)!/)
  end
end
```

這個測項的問題在於，測試的主要目標 `Detective` 跟 `Thingie` 的細節混在一起了

為什麼預期 `Detective#investigate` 的回傳結果，需要知道 `Thingie#prod` 會回傳 (erp! or blop! or ping! or ribbit!) 呢？換句話說，就是可能還要去了解 `Thingie` 的實作，才會知道這裡為什麼這麼寫

之後如果 `Thingie#prod` 的實作有變動，這裡可能也必須改

小結：
雖然在測項套用真實物件很方便，但可能造成測項易壞、細節牽連太多...等問題

我們可以好好思考一下，為了通過 `Detective` 這個測項，所需要最少的準備是什麼？

=> 除了主角「一個 Detective 物件」之外，一個可以回應 `prod` 方法的物件，而且它的回傳值可以內嵌進字串

RSpec 有提供 test double 這個工具，讓我們可以很容易產生這樣的「假物件」



## 第二種實作方式：使用 stub 這個測試技巧

```ruby
RSpec.describe Detective do
  it "says what noise the thingie makes" do
    thingie = double(:thingie, prod: "oi")
    subject = Detective.new(thingie)

    result = subject.investigate

    expect(result).to eq "It went oi"
  end
end
```

跟第一種實作方式相比，如果之後改了 `Thingie#prod` 的實作方式， `Detective` 維持不變，這個測項也可以通過

相對之下較不易壞，比較不會跟別的類別的實作細節牽連，達到某種隔離效果



## 用 mock 測試參數物件在方法執行過程中接受訊息的次數
我們有時候只是想知道，當做參數的物件，在方法執行過程中，有沒有被呼叫到，有沒有收到預期中的參數

```ruby
RSpec.describe Detective do
  # 以下是要測另一個問題
  # 如果我們預期「傳進某個方法 m 」的參數物件 obj
  # 在 m 的執行過程
  # 只收到某個 message `m_of_obj` 一次
  # 換句話說， obj 會去執行一次 `m_of_obj`
  # 有時候
  # 因為那個方法 m_of_obj 會做好我們要的結果
  # 所以在測試裡就下這樣的預期
  #
  # 這次不指定假物件要回應什麼和對應的回傳值
  # 而是指定在收到 message `prod` 時
  # 去把這個測項的區域變數 prod_count + 1
  # 最後只要這個區域變數的值是 1
  # 就表示假物件只收到 `prod` 這個 message 一次
  it "prods the thingie at most once" do
    prod_count = 0
    thingie = double(:thingie)
    allow(thingie).to receive(:prod) { prod_count += 1 }
    subject = Detective.new(thingie)

    subject.investigate
    subject.investigate

    expect(prod_count).to eq 1
  end
end
```

測項這樣寫已經能夠達到我們的目的：預期一個參數物件在方法執行過程中，接受某個訊息的次數

小小缺點是我們在測項裡面還要自己建一個區域變數來記錄訊息的接收次數，還有在收到訊息時要增加它，其實 RSpec 有內建功能可以幫我們省去這個小麻煩

```ruby
RSpec.describe Detective do
  # 使用 RSpec 內建功能達到同樣的效果：
  # 預期某個 thingie 會在 Detective#investigate 中
  # 收到訊息 `prod` 一次
  # 省去我們自己設定用於計數的區域變數
  it "prods the thingie at most once" do
    thingie = double(:thingie) # arrange
    expect(thingie).to receive(:prod).once # assert
    subject = Detective.new(thingie) # arrange

    subject.investigate # action
    subject.investigate # action
  end
end
```

這個做法的問題在於，一般測項的流程是「準備，執行，斷言（或預期）」，但是它變成「準備、斷言、準備、執行」這樣交錯了，可讀性降低了， Spies 這個技巧可以解決這個問題

## 用 spies 改寫
```ruby
RSpec.describe Detective do
  # 以下是要測另一個問題
  # 如果我們預期「傳進某個方法 m 」的參數物件 obj
  # 在 m 的執行過程
  # 只收到某個 message `m_of_obj` 一次
  # 換句話說， obj 會去執行一次 `m_of_obj`
  # 有時候是因為那個方法 m_of_obj 會做我們要的結果
  # 所以在測項下這樣的預期
  #
  # 使用 RSpec 內建功能來達成 spies
  # 不會像用 mocks 時的「準備、斷言、準備、執行」
  # 順序交錯
  # 現在是正常的「準備、執行、斷言」
  it "prods the thingie at most once" do
    # Arrange
    thingie = double(:thingie, prod: "")
    subject = Detective.new(thingie)

    # Act
    subject.investigate
    subject.investigate

    # Assert
    expect(thingie).to have_received(:prod).once
  end
end
```

讓測項的程式碼順序變得更自然，符合「準備、執行、斷言」的流程，增加可讀性

## 總結

### stubs
製造假物件，指定這個假物件能回應哪些訊息，還有對應的回傳值，讓要測試的主角，在執行過程中一些地方，能獲得一致的結果

**斷言的對象依然是主角**

### mocks
一樣製造假物件，但是現在我們**改對這個假物件斷言**，在主角的執行過程中，應該要收到什麼訊息、收到的訊息應該夾帶什麼參數、訊息收到的次數...等等，但是會有程式碼的流程些微不自然的問題（準備、斷言、（準備）、執行）

### spies
**類似 mocks ，一樣製造假物件，一樣是對假物件斷言**，但是透過測試工具的功能，而改善了測試程式碼的可讀性，流程更自然（準備、執行、斷言）

以上是我讀這篇文章的...算是筆記吧，我對 mocks 和 spies 的差異有點不確定，可能不是這樣，需要再探究
