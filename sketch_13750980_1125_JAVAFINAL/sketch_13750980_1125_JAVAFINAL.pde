// 簡易 Tetris – Processing 版（Java Mode）
// 操作：← → 移動，↓ 加速落下，↑ 旋轉，p 暫停
// 一開始會先選難度：1=EASY, 2=NORMAL, 3=HARD
// Game Over：若破紀錄會先輸入名字，否則按任意鍵回到難度選單

// ====== 顏色與棋盤參數 ======
color[] brickColor = {
color(239, 32, 41), // I
color(49, 199, 239), // T
color(239, 121, 33), // L
color(90, 101, 173), // J
color(173, 77, 156), // S
color(66, 182, 66), // Z
color(247, 211, 8) // O
};

int W = 12; // 欄數（含邊界）
int H = 22; // 列數（含邊界）
int B = 30; // 每一格像素大小

// 右邊側欄的「格數寬度」
int SIDE_COLS = 6;

// 掉落速度相關
int T = 60; // 自動下落倒數
int baseFall = 60; // 依難度調整：EASY 60, NORMAL 40, HARD 20

// 難度選擇
int difficulty = 1; // 1=EASY, 2=NORMAL, 3=HARD
boolean choosingDifficulty = true; // 一開始在選難度畫面

int brickNow = 4 + W; // 目前方塊中心位置（用一維 index 表示）
int rot = 0; // 旋轉狀態 0~3
int type = 0; // 目前方塊種類 0~6
int nextType = 0; // 下一個方塊種類 0~6

// 分數與消行數
int score = 0;
int lines = 0;

// grid：-1 = 邊界，0 = 空白，>0 = 已固定的方塊（代表顏色）
int[] grid = new int[H * W];

// 方塊抽卡袋（每包 28 塊，每種 4 個）
int[] bag = new int[28];
int bagIndex = 0;

// High Score 資料
String highName = "NONE";
int highScore = 0;
boolean enteringName = false; // 是否正在輸入名字
String tempName = ""; // 正在輸入中的名字

// 方塊形狀：brick[種類][旋轉][第幾格(0~3)]，每一格是相對偏移量 offset
int[][][] brick = {
{ // type I
{0, 1, 2, 3},
{2 - 2*W, 2 - W, 2, 2 + W},
{0, 1, 2, 3},
{1 - 2*W, 1 - W, 1, 1 + W}
},
{ // type T
{0, 1, 2, 1 + W},
{1 - W, 0, 1, 1 + W},
{1, W, W + 1, W + 2},
{1 - W, 1, 2, 1 + W}
},
{ // type L
{0, 1, 2, W},
{-W, 1 - W, 1, 1 + W},
{2, W, W + 1, W + 2},
{1 - W, 1, 1 + W, 2 + W}
},
{ // type J
{0, 1, 2, 2 + W},
{1 - W, 1, W, W + 1},
{0, W, W + 1, W + 2},
{1 - W, 2 - W, 1, 1 + W}
},
{ // type S
{1, 2, W, W + 1},
{1 - W, 1, 2, 2 + W},
{1, 2, W, W + 1},
{-W, 0, 1, 1 + W}
},
{ // type Z
{0, 1, 1 + W, 2 + W},
{2 - W, 1, 2, 1 + W},
{0, 1, 1 + W, 2 + W},
{1 - W, 0, 1, W}
},
{ // type O (square)
{0, 1, W, W + 1},
{0, 1, W, W + 1},
{0, 1, W, W + 1},
{0, 1, W, W + 1}
}
};

boolean bGameOver = false;
boolean bFalling = false;
boolean bPause = false;

// ====== 視窗設定：用 settings() 才能在 size() 用變數 ======
void settings() {
size(W * B + SIDE_COLS * B, H * B); // 左邊遊戲區 + 右側資訊欄
}

void setup() {
noStroke();
loadHighScore();
refillBag(); // 準備抽卡袋
// 不立刻 restart，等選完難度後才開始遊戲
}

void draw() {
background(0);

// 如果還在選難度，畫選單後就結束 draw
if (choosingDifficulty) {
drawDifficultyMenu();
return;
}

// 右側欄背景
fill(30);
rect(W * B, 0, SIDE_COLS * B, H * B);

// 畫遊戲區
drawGrid();
showBrick();

// 畫 NEXT、SCORE、LINES、HIGH SCORE
showNextBrickPanel();
showScorePanel();

// 暫停畫面
if (bPause && !bGameOver) {
fill(0, 180);
rect(0, 0, width, height);
fill(255);
textAlign(CENTER, CENTER);
textSize(32);
text("PAUSE", width/2, height/2);
return;
}

// Game Over 畫面
if (bGameOver) {
fill(0, 200);
rect(0, 0, width, height);
fill(255);
textAlign(CENTER, CENTER);

if (enteringName) {
textSize(32);
text("NEW HIGH SCORE!", width/2, height/2 - 60);

textSize(18);
text("Enter your name:", width/2, height/2 - 20);

// 顯示正在輸入中的名字 + 閃爍游標
String displayName = tempName;
if ((frameCount / 30) % 2 == 0) {
displayName += "_";
}
textSize(24);
text(displayName, width/2, height/2 + 20);

textSize(14);
text("ENTER 確認 / ESC 放棄 / Backspace 刪除", width/2, height/2 + 60);
} else {
textSize(32);
text("GAME OVER", width/2, height/2 - 20);
textSize(16);
text("Press any key to select difficulty", width/2, height/2 + 15);
}
return;
}

// 自動下落
if ((--T) <= 0) {
T = baseFall;
if (!testSafeBrick(brickNow + W)) {
brickFrozen();
} else {
brickNow += W;
}
}

// 手動加速下落（按住 ↓）
if (bFalling) {
if (testSafeBrick(brickNow + W)) {
brickNow += W;
}
}
}

// ====== 畫「選擇難度」畫面 ======
void drawDifficultyMenu() {
background(0);
fill(255);
textAlign(CENTER, CENTER);

textSize(32);
text("SELECT DIFFICULTY", width/2, height/2 - 80);

textSize(22);
text("1 - EASY (慢速)", width/2, height/2 - 20);
text("2 - NORMAL (中速)", width/2, height/2 + 20);
text("3 - HARD (快速)", width/2, height/2 + 60);

textSize(14);
text("按 1 / 2 / 3 選擇", width/2, height/2 + 110);
}

// ====== 根據難度設定掉落速度 ======
void setDifficulty(int d) {
difficulty = d;
if (difficulty == 1) { // EASY
baseFall = 60;
} else if (difficulty == 2) { // NORMAL
baseFall = 40;
} else if (difficulty == 3) { // HARD
baseFall = 20;
} else {
baseFall = 60;
}
}

// ====== 畫主棋盤（包含已固定方塊） ======
void drawGrid() {
for (int i = 0; i < H * W; i++) {
int gx = i % W;
int gy = i / W;

if (grid[i] == -1) {
// 邊界
fill(80);
rect(gx * B, gy * B, B, B);
} else if (grid[i] != 0) {
// 已固定的方塊 → 用立體方塊畫法
color c = brickColor[grid[i] - 1];
drawBlock(gx, gy, c);
} else {
// 空白
fill(0);
rect(gx * B, gy * B, B, B);
}
}
}

// ====== 重置遊戲 ======
void restart() {
for (int i = 0; i < H * W; i++) {
// 外圍一圈設為邊界 -1
if (i % W == 0 || i % W == W - 1 || i >= H*W - W || i < W) {
grid[i] = -1;
} else {
grid[i] = 0;
}
}

T = baseFall;
brickNow = 4 + W;
rot = 0;

score = 0;
lines = 0;

type = drawTypeFromBag();
nextType = drawTypeFromBag();

bGameOver = false;
bFalling = false;
bPause = false;
enteringName = false;
tempName = "";
}

// ====== 畫目前正在掉落的方塊（立體） ======
void showBrick() {
for (int k = 0; k < 4; k++) {
int idx = brick[type][rot][k] + brickNow;
int x = idx % W;
int y = idx / W;
drawBlock(x, y, brickColor[type]);
}
}

// ====== 右側：NEXT 預覽（立體小方塊版） ======
void showNextBrickPanel() {
int panelX = W * B;
int panelY = 0;

// 面板底
fill(20);
rect(panelX, panelY, SIDE_COLS * B, 6 * B);

// NEXT 標題
fill(255);
textAlign(CENTER, CENTER);
textSize(20);
text("NEXT", panelX + SIDE_COLS * B / 2, panelY + B);

// 預覽用的小方塊尺寸
float miniB = 20;
float offsetX = panelX + SIDE_COLS * B / 2;
float offsetY = panelY + 3 * B;

color c = brickColor[nextType];

// 使用 nextType 的第 0 種旋轉狀態
for (int k = 0; k < 4; k++) {
int off = brick[nextType][0][k];
int cx = off % W;
int cy = off / W;

// 做一個小小的中心對齊偏移
float gx = cx - 1;
float gy = cy - 1;

float px = offsetX + gx * miniB;
float py = offsetY + gy * miniB;

drawMiniBlock(px, py, miniB, c);
}
}

// ====== 右側：分數／行數／最高分（名字與分數距離≥10字元） ======
void showScorePanel() {
int panelX = W * B;
int panelY = 6 * B;

fill(25);
rect(panelX, panelY, SIDE_COLS * B, 6 * B);

fill(255);
textAlign(LEFT, TOP);

// 當前分數
textSize(16);
text("SCORE", panelX + B * 0.5, panelY + B * 0.5);
textSize(20);
text(score, panelX + B * 0.5, panelY + B * 1.5);

// 消除行數
textSize(16);
text("LINES", panelX + B * 0.5, panelY + B * 3.0);
textSize(20);
text(lines, panelX + B * 0.5, panelY + B * 4.0);

// High Score
textSize(14);
text("HIGH SCORE", panelX + B * 0.5, panelY + B * 5.2);

// 顯示格式：名字 + 至少 10 字元的間距 + 分數
String name = highName;
String scoreText = str(highScore);

while (name.length() < 10) {
name += " ";
}

textSize(15);
text(name + scoreText, panelX + B * 0.5, panelY + B * 5.8);
}

// ====== 安全檢查：某個位置 now 放方塊是否會撞到東西 ======
boolean testSafeBrick(int now) {
for (int k = 0; k < 4; k++) {
if (grid[brick[type][rot][k] + now] != 0) {
return false;
}
}
return true;
}

// ====== 方塊落地 → 固定＆消行＆計分 ======
void brickFrozen() {
// 固定到 grid
for (int k = 0; k < 4; k++) {
grid[brickNow + brick[type][rot][k]] = type + 1;
}

boolean[] checkedRow = new boolean[H];
int linesCleared = 0;

// 檢查可能被填滿的那些列
for (int k = 0; k < 4; k++) {
int row = (brickNow + brick[type][rot][k]) / W;
if (checkedRow[row]) continue;
checkedRow[row] = true;

boolean filled = true;
for (int i = 0; i < W; i++) {
if (grid[i + row * W] == 0) {
filled = false;
break;
}
}

if (filled) {
linesCleared++;
// 把 row 以上全部往下搬一行
for (int i = row * W + W - 1; i >= W; i--) {
grid[i] = grid[i - W];
}
// 第二列（最上面一行內框）清為 0
for (int i = W + 1; i < W + W - 1; i++) {
grid[i] = 0;
}
}
}

// 更新行數
lines += linesCleared;

// 計分（1/2/3/4 行）
int addScore = 0;
if (linesCleared == 1) addScore = 100;
else if (linesCleared == 2) addScore = 300;
else if (linesCleared == 3) addScore = 500;
else if (linesCleared == 4) addScore = 800;
score += addScore;

// 產生新方塊
brickNow = 4 + W;
rot = 0;
type = nextType;
nextType = drawTypeFromBag();

// 剛生出來就撞到 → Game Over
if (!testSafeBrick(brickNow)) {
bGameOver = true;

// 若破紀錄則進入名字輸入模式
if (score > highScore) {
enteringName = true;
tempName = "";
}
}
}

// ====== 鍵盤控制 ======
void keyPressed() {

// 1. 選難度模式
if (choosingDifficulty) {
if (key == '1') {
setDifficulty(1);
choosingDifficulty = false;
restart();
} else if (key == '2') {
setDifficulty(2);
choosingDifficulty = false;
restart();
} else if (key == '3') {
setDifficulty(3);
choosingDifficulty = false;
restart();
}
return;
}

// 2. 若正在輸入名字，就只處理文字輸入
if (enteringName) {
handleNameInput();
return;
}

// 3. Game Over（但沒在輸入名字）：按任意鍵 → 回到難度選單
if (bGameOver) {
bGameOver = false;
choosingDifficulty = true;
return;
}

// 4. 一般遊戲中控制
if (keyCode == LEFT) {
if (testSafeBrick(brickNow - 1)) brickNow--;
}

if (keyCode == RIGHT) {
if (testSafeBrick(brickNow + 1)) brickNow++;
}

if (keyCode == DOWN) {
bFalling = true;
}

if (keyCode == UP) {
int oldRot = rot;
int oldPos = brickNow;

rot = (rot + 1) % 4;

// I 型在最上面時稍微往下挪，避免旋轉撞到
while (type == 0 && (brickNow / W) <= 2) {
brickNow += W;
}

// 簡單 wall kick 嘗試
if (testSafeBrick(brickNow)) {
// OK
} else if (testSafeBrick(brickNow + 1)) {
brickNow++;
} else if (testSafeBrick(brickNow - 1)) {
brickNow--;
} else if (testSafeBrick(brickNow + W)) {
brickNow += W;
} else if (testSafeBrick(brickNow + W + 1)) {
brickNow += W + 1;
} else if (testSafeBrick(brickNow + W - 1)) {
brickNow += W - 1;
} else {
// 不行就還原
rot = oldRot;
brickNow = oldPos;
}
}

if (key == 'p' || key == 'P') {
bPause = !bPause;
}
}

void keyReleased() {
if (keyCode == DOWN) {
bFalling = false;
}
}

// ====== 處理名字輸入模式 ======
void handleNameInput() {
if (key == ENTER || key == RETURN) {
if (tempName.length() == 0) {
tempName = "PLAYER";
}
highName = tempName;
highScore = score;
saveHighScore();
enteringName = false;
} else if (key == BACKSPACE) {
if (tempName.length() > 0) {
tempName = tempName.substring(0, tempName.length() - 1);
}
} else if (key == ESC) {
// 防止 ESC 直接關閉視窗
key = 0;
enteringName = false;
} else if (key >= 32 && key <= 126) {
// 一般可見字元
if (tempName.length() < 12) {
tempName += key;
}
}
}

// ====== 立體小積木畫法（主遊戲用） ======
void drawBlock(int gx, int gy, color base) {
float px = gx * B;
float py = gy * B;

color light = lerpColor(base, color(255), 0.4);
color dark = lerpColor(base, color(0), 0.4);

float s = 3; // 邊緣厚度

noStroke();

// 底色
fill(base);
rect(px, py, B, B);

// 上方高光
fill(light);
quad(px, py,
px + B, py,
px + B - s, py + s,
px + s, py + s);

// 左側高光
quad(px, py,
px + s, py + s,
px + s, py + B - s,
px, py + B);

// 下方陰影
fill(dark);
quad(px, py + B,
px + s, py + B - s,
px + B - s, py + B - s,
px + B, py + B);

// 右側陰影
quad(px + B, py,
px + B, py + B,
px + B - s, py + B - s,
px + B - s, py + s);
}

// ====== 縮小版立體方塊（NEXT 預覽用） ======
void drawMiniBlock(float px, float py, float size, color base) {
color light = lerpColor(base, color(255), 0.4);
color dark = lerpColor(base, color(0), 0.4);

float e = size * 0.18; // 邊緣厚度比例

noStroke();

// 底色
fill(base);
rect(px, py, size, size);

// 上方高光
fill(light);
quad(px, py,
px + size, py,
px + size - e, py + e,
px + e, py + e);

// 左側高光
quad(px, py,
px + e, py + e,
px + e, py + size - e,
px, py + size);

// 下方陰影
fill(dark);
quad(px, py + size,
px + e, py + size - e,
px + size - e, py + size - e,
px + size, py + size);

// 右側陰影
quad(px + size, py,
px + size, py + size,
px + size - e, py + size - e,
px + size - e, py + e);
}

// ====== 抽卡袋：填滿一包 28 塊（每種 4 個）並洗牌 ======
void refillBag() {
int idx = 0;
for (int t = 0; t < 7; t++) { // 7 種方塊
for (int c = 0; c < 4; c++) { // 每種 4 個
bag[idx++] = t;
}
}

// Fisher-Yates shuffle
for (int i = bag.length - 1; i > 0; i--) {
int j = int(random(i + 1));
int tmp = bag[i];
bag[i] = bag[j];
bag[j] = tmp;
}

bagIndex = 0;
}

// ====== 從袋子裡抽一個方塊種類 ======
int drawTypeFromBag() {
if (bagIndex >= bag.length) {
refillBag(); // 這一包用完，再做一包新的
}
int t = bag[bagIndex];
bagIndex++;
return t;
}

// ====== 讀取 High Score 檔案 ======
void loadHighScore() {
try {
String[] lines = loadStrings("highscore.txt");
if (lines != null && lines.length >= 2) {
highName = lines[0];
highScore = int(lines[1]);
}
}
catch (Exception e) {
highName = "NONE";
highScore = 0;
}
}

// ====== 存檔 High Score 到檔案 ======
void saveHighScore() {
String[] lines = { highName, str(highScore) };
saveStrings("highscore.txt", lines);
}
