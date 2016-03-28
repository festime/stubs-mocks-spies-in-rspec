require_relative '../detective'
require_relative '../thingie'

# 為了使這個測試通過，需要改變什麼呢？
# Detective 初始化時代入一個可以回應 prod 的物件？
# 改變預期的回傳字串嗎？
#
# 一個做法是如果我們有實作 Thingie 這個類別
# 而且 Thingie object 可以回應 prod 方法
# 而且 Thingie#prod 可以回傳我們要的結果
# 這樣實際產生一個 Thingie object
# 並把它當作 Detective 初始化所需的參數
# 那測項應該就可以 pass 了才對？
#
# 第二種做法使用 stub 這個測試技巧
# 用 RSpec 提供的 `double` 方法
# 產生「假物件」
# 而且可以指定它能回覆什麼方法和對應的回傳值
# 為了了解這個測項為什麼這麼寫
# 相對於使用真實物件時
# 可以不必去了解 Thingie 的實作細節
RSpec.describe Detective do
  it "says what noise the thingie makes" do
    thingie = double(:thingie, prod: "oi")
    subject = Detective.new(thingie)

    result = subject.investigate

    expect(result).to eq "It went oi"
  end
end
