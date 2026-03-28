# 1318. Minimum Flips to Make a OR b Equal to c.py
# 每個 bit 位要讓 a OR b == c,
# c == 1: a、b 至少一個為 1，若兩個都是 0 則翻 1 次
# c == 0: a、b 都必須為 0，有幾個 1 就翻幾次
class Solution:
    def minFlips(self, a: int, b: int, c: int) -> int:
        f = 0

        while a or b or c:  # 只要還有 bit 沒處理
            a1 = a & 1      # 取 a 的最低位
            b1 = b & 1      # 取 b 的最低位
            c1 = c & 1      # 取 c 的最低位

            if c1 == 1:
                if a1 == 0 and b1 == 0: f += 1 # 需要翻一個
            else: # bit_c == 0
                f += a1 + b1    # a、b 各有 1 就各翻一次

            a >>= 1 # 右移，處理下一個 bit
            b >>= 1
            c >>= 1

        return f
