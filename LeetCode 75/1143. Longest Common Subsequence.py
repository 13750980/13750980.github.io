# 1143. Longest Common Subsequence.py
class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:
        m, n = len(text1), len(text2)
        dp = [[0] * (n + 1) for _ in range(m + 1)]  # 多一行一列當邊界

        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if text1[i-1] == text2[j-1]:        # 字元相同
                    dp[i][j] = dp[i-1][j-1] + 1     # 繼承左上角 +1
                else:                                # 字元不同
                    dp[i][j] = max(dp[i-1][j], dp[i][j-1])  # 取上或左的最大值

        return dp[m][n]
