# week01-h1.py
# LeetCode 75: Array / String Q4
# 605. Can Place Flowers
class Solution:
    def canPlaceFlowers(self, flowerbed: List[int], n: int) -> bool:
        length = len(flowerbed)
        for i in range(length):
           # 這格如果是 0 才有機會種
            if flowerbed[i] == 0:
                # 檢查左邊
                if i == 0: left_ok = True
                else: left_ok = (flowerbed[i-1] == 0)

                # 檢查右邊
                if i == len(flowerbed) - 1: right_ok = True
                else: right_ok = (flowerbed[i+1] == 0)

                # 如果左右都沒花
                if left_ok and right_ok:
                    flowerbed[i] = 1
                    n -= 1

        # 最後看有沒有種夠
        if n <= 0: return True
        else: return False
s
