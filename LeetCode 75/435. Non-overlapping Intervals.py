# 435. Non-overlapping Intervals.py
# 最少要刪掉幾個，才能讓剩下的區間互不重疊
class Solution:
    def eraseOverlapIntervals(self, intervals: List[List[int]]) -> int:
        # 按結尾排序
        intervals.sort(key=lambda x: x[1])

        keep = 0
        end = float('-inf') # 上一個保留區間的結尾

        for begin, stop in intervals:
            if begin >= end: # 不重疊（包含只碰到一點）
                keep += 1    # 保留這個區間
                end = stop   # 更新結尾

        return len(intervals) - keep
