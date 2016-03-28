## 了解 Stubs, Mocks, and Spies
參考文章：[Stubs, Mocks and Spies in RSpec](https://about.futurelearn.com/blog/stubs-mocks-spies-rspec/?utm_source=rubyweekly&utm_medium=email)

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
