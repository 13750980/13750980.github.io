# week01-h3.py
# LeetCode 75: Array / String Q8
# 334. Increasing Triplet Subsequence
# 記住目前最小 + 第二小
class Solution:
    def increasingTriplet(self, nums: List[int]) -> bool:
        # float('inf') 預設一個無限大的數字
        first = float('inf')   # 最小
        second = float('inf')  # 第二小

        for x in nums:
            if x <= first:
                first = x
            elif x <= second:
                second = x
            else:
                return True # x > second > first

        return False
