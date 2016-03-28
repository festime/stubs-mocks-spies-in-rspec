require_relative '../detective'

RSpec.describe Detective do
  it "doesn't find much" do
    subject = Detective.new

    result = subject.investigate

    expect(result).to eq "Nothing to investigate :'("
  end
end
