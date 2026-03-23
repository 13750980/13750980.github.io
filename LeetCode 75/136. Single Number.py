# 136. Single Number.py
class Solution:
    def singleNumber(self, nums: List[int]) -> int:
        ans = 0         # 初始值為 0，因為 a ^ 0 = a
        for i in nums:
            ans ^= i    # 每個數字 XOR 進去，成對的會抵消變 0
        return ans      # 輸出剩下的就是單一數字

        # 方法二:
        # reduce 把 nums 裡所有數字依序 XOR 在一起
        return reduce(lambda a, b: a ^ b, nums)
