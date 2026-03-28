# 714. Best Time to Buy and Sell Stock with Transaction Fee.py
# buy  = 手上持有股票時的最大利潤；cash = 手上沒有股票時的最大利潤
# 持有股票時：繼續持有 或 今天賣出；沒有股票時：繼續觀望 或 今天買入
class Solution:
    def maxProfit(self, prices: List[int], fee: int) -> int:
        buy = -prices[0]  # 第一天買入，花錢所以是負的
        cash = 0          # 第一天不買，利潤為 0

        for p in prices[1:]:                      # 從第二天開始逐天處理
            buy  = max(buy, cash - p)             # 繼續持有 或 今天買入（cash - p）
            cash = max(cash, buy + p - fee)       # 繼續不持有 或 今天賣出（扣手續費）

        return cash  # 最後手上不持有股票的最大利潤
