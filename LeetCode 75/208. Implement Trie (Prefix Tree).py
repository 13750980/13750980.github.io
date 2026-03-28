# 208. Implement Trie (Prefix Tree).py
class Trie:

    def __init__(self):
        self.root = {} # 用 dict 當根節點

    def insert(self, word: str) -> None:
        node = self.root # 從樹根開始

        for c in word: # 逐字元走
            if c not in node: # 若該字元不存在
                node[c] = {} # 建立新的子節點
            node = node[c]   # 代替到下一層
        node["#"] = True   # 標記這裏單字結束

    def search(self, word: str) -> bool:
        node = self.root # 從樹根開始

        for c in word:    # 逐字元走
            if c not in node:
                return False # 表示前序不存在
            node = node[c]   # 代替到下一層
        return "#" in node # 走到底後確認是否有結束標記

    def startsWith(self, prefix: str) -> bool:
        node = self.root # 從樹根開始

        for c in prefix:    # 逐字元走
            if c not in node:
                return False # 表示前序不存在
            node = node[c]   # 代替到下一層
        return True          # 能走完前綴就回傳 True，不需檢查結束標記

# Your Trie object will be instantiated and called as such:
# obj = Trie()
# obj.insert(word)
# param_2 = obj.search(word)
# param_3 = obj.startsWith(prefix)
