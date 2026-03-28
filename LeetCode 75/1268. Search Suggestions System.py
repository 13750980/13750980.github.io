# 1268. Search Suggestions System.py
from bisect import bisect_left
class Solution:
    def suggestedProducts(self, products: List[str], searchWord: str) -> List[List[str]]:
        products.sort() # 排序
        result = []
        prefix = ""

        for c in searchWord:
            prefix += c

            i = bisect_left(products, prefix)

            suggections = []
            for j in range(i , min(i+3, len(products))):
                if products[j].startswith(prefix):   # 確認是否這個前序
                    suggections.append(products[j])
            result.append(suggections)

        return result

