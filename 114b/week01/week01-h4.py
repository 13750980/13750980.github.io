# week01-h4.py
# #LeetCode 75: Array / String Q9
# 443. String Compression

class Solution:
    def compress(self, chars: List[str]) -> int:
        write = 0   # 寫入位置
        read = 0    # 讀取位置

        while read < len(chars):

            current_char = chars[read]
            count = 0

            # 計算有幾個相同字元
            while read < len(chars) and chars[read] == current_char:
                read += 1
                count += 1

            # 先寫入字母
            chars[write] = current_char
            write += 1

            # 如果出現超過 1 次，寫入數字
            if count > 1:
                for digit in str(count):
                    chars[write] = digit
                    write += 1

        return write
