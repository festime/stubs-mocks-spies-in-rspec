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

  def investigate
    "It went #{@thingie.prod}"
  end
end
