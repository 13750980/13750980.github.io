# 62. Unique Paths.py
# DP 壓縮空間
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        dp = [1] * n          # 只需要一行

        for i in range(1, m):
            for j in range(1, n):
                dp[j] += dp[j-1]  # dp[j] 本身是上面的值，dp[j-1] 是左邊的值

        return dp[n-1]

'''
class Solution:
    def uniquePaths(self, m: int, n: int) -> int:
        dp = [[1] * n for _ in range(m)]  # 建立 m×n 的表，全部初始化為 1
                                           # 第一行和第一列都只有一種走法

        for i in range(1, m):              # 從第二行開始（第一行已經是 1）
            for j in range(1, n):          # 從第二列開始（第一列已經是 1）
                dp[i][j] = dp[i-1][j] + dp[i][j-1]  # 從上面來 + 從左邊來

        return dp[m-1][n-1]                # 回傳右下角的路徑總數
'''
