## 了解 Stubs, Mocks, and Spies
參考文章：[Stubs, Mocks and Spies in RSpec](https://about.futurelearn.com/blog/stubs-mocks-spies-rspec/?utm_source=rubyweekly&utm_medium=email)

code 完全是照他文章內容的打，只是加上自己註解和 README 而已

## 測項的第一種實作方式：建立真實物件

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

一個可以回應 `prod` 方法的物件，而且它的回傳值可以內嵌進字串，而 RSpec 有提供 test double 這個工具，讓我們可以很容易產生這樣的「假物件」



## 測項的第二種實作方式：使用 stub 這個測試技巧

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



## 測試參數物件在方法執行過程中接受訊息的次數
```ruby
RSpec.describe Detective do
  # 以下是要測另一個問題
  # 如果我們預期「傳進某個方法 m 」的參數物件 obj
  # 在 m 的執行過程
  # 只收到某個 message `m_of_obj` 一次
  # 換句話說， obj 會去執行一次 `m_of_obj`
  # 有時候是因為那個方法 m_of_obj 會做我們要的結果
  # 所以在測試裡下這樣的預期
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
