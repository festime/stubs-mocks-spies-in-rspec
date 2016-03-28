require_relative '../detective'

# 為了使這個測試通過，需要改變什麼呢？
# Detective 初始化時代入一個可以回應 prod 的物件？
# 改變預期的回傳字串嗎？
RSpec.describe Detective do
  it "doesn't find much" do
    subject = Detective.new

    result = subject.investigate

    expect(result).to eq "Nothing to investigate :'("
  end
end
