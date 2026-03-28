# 72. Edit Distance.py
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        m, n = len(word1), len(word2)
        dp = list(range(n + 1))  # 初始化第一行 [0,1,2,...,n]

        for i in range(1, m + 1):
            prev = dp[0]          # 保存左上角的值
            dp[0] = i             # 每行第一個值
            for j in range(1, n + 1):
                temp = dp[j]      # 暫存，下一格會用到
                if word1[i-1] == word2[j-1]:
                    dp[j] = prev  # 字元相同，繼承左上角
                else:
                    dp[j] = 1 + min(dp[j], dp[j-1], prev)  # 刪除、插入、替換
                prev = temp       # 更新左上角

        return dp[n]
