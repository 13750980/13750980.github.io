# week01-h2.py
# LeetCode 75: Array / String Q5
# 345. Reverse Vowels of a String
class Solution:
    def reverseVowels(self, s: str) -> str:
        vowels = "aeiouAEIOU"
        s = list(s)

        left = 0
        right = len(s) - 1

        while left < right:
            # 左邊不是母音就往右移
            while left < right and s[left] not in vowels: left += 1
            # 右邊不是母音就往左移
            while left < right and s[right] not in vowels: right -= 1

            # 交換母音
            s[left], s[right] = s[right], s[left]
            left += 1
            right -= 1

        return "".join(s)
