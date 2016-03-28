# 改變 Detective 的實作
# 讓它跟別的物件有互動
# 讓情況稍微複雜一點點
# 比較貼近真實情況
# 也才會面臨需要考慮使用
# stub, mock 或 spy 等技巧的狀況
#
# 初始化代入一個參數
# 這個物件要可以回應 prod 方法
class Detective
  def initialize(thingie)
    @thingie = thingie
  end

  # 因為這裡的實作是每次呼叫 investigate
  # 都會去呼叫 @thingie 的 prod
  # 所以第二個測項的次數預期會失敗
  #
  #
  #
  # 改變實做
  # 用 memoization 記住
  # 第一次呼叫 investigate 時的執行結果
  # 這樣第二次呼叫 investigate 時
  # 因為 @results 已經有值
  # 就不會去執行 ||= 右邊的運算式
  # 也就不會去呼叫到 @thingie 的 prod
  def investigate
    @results ||= "It went #{@thingie.prod}"
  end
end
