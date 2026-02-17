#  MS4 Data Wrangling 

## 1）less（看大输出）

~~~md
### 常用启动
```bash
less file
less -N file                 # 行号
less +/PATTERN file          # 打开即定位到首次匹配
less -N +/PATTERN file       # 常用组合
### less 内操作
- 搜索：`/PATTERN` 回车；下/上：`n` / `N`
- 翻页：`Space` / `b`
- 头尾：`g` / `G`
- 退出：`q`
~~~

------

## 2) grep / rg（过滤）

```bash
grep 'PATTERN' file
grep -E 'REGEX' file                 # ERE
grep -n 'PATTERN' file               # 行号
rg -n 'PATTERN' file                 # 推荐：更快更友好
rg -n 'WARN|ERROR' file              # 多分支
```

------

## 3) sed（提取/替换/清洗）

- `-E`：扩展正则（直接用 `()` `?` `|` `+`）
- `-n`：关闭默认输出
- `p`：只打印匹配成功（用于“提取”）

### 替换

```bash
sed 's/REGEX/SUB/'            # 每行只替换第1次匹配
sed 's/REGEX/SUB/g'           # 每行全局替换
sed -E 's/(...)/\1/'          # 扩展正则 + 捕获组引用
```

### 提取

```bash
sed -nE 's/WHOLE_LINE_REGEX/\2/p' file
# 只输出匹配成功行；不匹配行不会混进来
```

### 常用定位/截取

```bash
sed -n '10p' file
sed -n '10,30p' file
sed '/PATTERN/d' file
```

 ***必备外部工具（正则）

- regex debugger: https://regex101.com/r/qqbZqh/2
- short interactive regex tutorial: https://regexone.com/

### sshd Disconnected：删前缀（先观察结构）

```bash
cat ssh.log | sed 's/.*Disconnected from //'
```

### sshd Disconnected：提取 username（稳健）

> **用 `([^ ]+)`，不要用 `(.\*)`**太宽泛maybe

```bash
sed -nE 's/.*Disconnected from (authenticating |invalid )?user ([^ ]+) [0-9.]+ port [0-9]+( \[preauth\])?/\2/p' ssh.log
```

------

## 4) sort / uniq / head / tail（TopN 聚合）

### TopN 模板

```bash
... | sort | uniq -c | sort -nr | head -n 10
# uniq -c 前必须 sort（否则只统计相邻重复）
```

### 数值排序

```bash
sort -n -k1,1        # 按第1列数值升序
sort -nr -k1,1       # 按第1列数值降序
```

### ssh 用户 TopN

```bash
cat ssh.log \
| sed -nE 's/.*Disconnected from (authenticating |invalid )?user ([^ ]+) [0-9.]+ port [0-9]+( \[preauth\])?/\2/p' \
| sort | uniq -c | sort -nr | head -n 10
```

------

## 5) awk（列/条件/统计）

### 列

```bash
awk '{print $1}' file
awk '{print $1, $2}' file
```

### 条件 + 正则

```bash
awk '$1==1 {print $2}' file
awk '$2 ~ /^f[^ ]*$/ {print $2}' file
awk '$1==1 && $2 ~ /^f[^ ]*$/ {print $2}' file
```

### BEGIN/END 累加

```bash
awk 'BEGIN{sum=0} {sum+=$1} END{print sum}' file
```

------

## 6) paste + bc（把多行数字求和）

```bash
... | awk '{print $1}' | paste -sd+ | bc
# paste -s 合并多行；-d+ 用 + 连接；bc 计算表达式
```

------

## 7) perl -pe（非贪婪 *?）

### sed 贪婪示例

```bash
echo '... Disconnected from A Disconnected from B ...' | sed 's/.*Disconnected from //'
# 输出 B...
```

### perl 非贪婪（*?）

```bash
echo '... Disconnected from A Disconnected from B ...' | perl -pe 's/.*?Disconnected from //'
# 输出 A...
```

------

## 8) tee（边看边存）

```bash
... | tee work/out.txt
... | tee work/out.txt >/dev/null     # 只存不在屏幕刷
```

------

## 9) xargs（批处理）

```bash
cat list.txt | xargs -I{} echo {}
cat list.txt | xargs -I{} sh -c 'echo --- {}; rg -n "{}" ssh.log'
```

------

## 10) wc / find（规模统计）

```bash
wc -l file
find . -type f -name '*md' | xargs wc -l
find . -type f -name '*md' -print0 | xargs -0 wc -l   # 文件名含空格用 -0
```

------

## 11) ssh 远程执行模板

```bash
ssh hk 'journalctl | grep sshd | grep "Disconnected from"' | less
```

------

## 12) 高频错误清单

- `user ([^ ]+)`：**user 后要有空格**；`[^ ]+` 才是字段
- `preauth` 拼错（你写过 `preath`）→ 整行不匹配，输出为空
- 可选组写法：`( \[preauth\])?`（括号闭合，`?` 在括号外）
- 想只输出匹配行：用 `sed -nE ... p`（否则不匹配行会原样输出）
- 续行 `\` 必须在**行尾**
- 命令不要粘连：`chmod ...` 与 `less ...` 分行或用 `&&`

------

# 实践

从 `data/ssh.log` 自动生成：

- `work/task03_users.out`（用户名列表）
- `work/task04_top_users.out`（TopN）
- `work/task05_sum_top_counts.out`（TopN 计数求和）
- `work/task06_{greedy,nongreedy}.out`（贪婪 vs 非贪婪）

## 目录约定

```
ms-04-data-wrangling/
  data/ssh.log
  scripts/task03_extract_user.sh
  scripts/task04_top_users.sh
  scripts/task05_sum_top_counts.sh
  scripts/task06_nongreedy_demo.sh
  work/
```

## 4 个脚本（task03~06）

### task03：提取用户名

```
cat > ms-04-data-wrangling/scripts/task03_extract_user.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

sed -nE 's/.*Disconnected from (authenticating |invalid )?user ([^ ]+) [0-9.]+ port [0-9]+( \[preauth\])?/\2/p' \
  ms-04-data-wrangling/data/ssh.log \
  > ms-04-data-wrangling/work/task03_users.out

echo "OK -> work/task03_users.out"
EOF
```

### task04：TopN 用户

```
cat > ms-04-data-wrangling/scripts/task04_top_users.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

sed -nE 's/.*Disconnected from (authenticating |invalid )?user ([^ ]+) [0-9.]+ port [0-9]+( \[preauth\])?/\2/p' \
  ms-04-data-wrangling/data/ssh.log \
| sort | uniq -c | sort -nr | head -n 10 \
> ms-04-data-wrangling/work/task04_top_users.out

echo "OK -> work/task04_top_users.out"
EOF
```

### task05：TopN 计数求和（awk + paste + bc）

```
cat > ms-04-data-wrangling/scripts/task05_sum_top_counts.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

bash ms-04-data-wrangling/scripts/task04_top_users.sh >/dev/null

awk '{print $1}' ms-04-data-wrangling/work/task04_top_users.out \
  | paste -sd+ \
  | bc \
  > ms-04-data-wrangling/work/task05_sum_top_counts.out

echo "OK -> work/task05_sum_top_counts.out"
EOF
```

### task06：贪婪 vs 非贪婪（sed vs perl）

```
cat > ms-04-data-wrangling/scripts/task06_nongreedy_demo.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo 'something Disconnected from A Disconnected from B. OK finish string' \
  | sed 's/.*Disconnected from //' \
  > ms-04-data-wrangling/work/task06_greedy.out

echo 'something Disconnected from A Disconnected from B. OK finish string' \
  | perl -pe 's/.*?Disconnected from //' \
  > ms-04-data-wrangling/work/task06_nongreedy.out

echo "OK -> work/task06_greedy.out + work/task06_nongreedy.out"
EOF
```

## 一键跑？

```
ms-04-data-wrangling/run.sh
#!/usr/bin/env bash
set -euo pipefail
mkdir -p ms-04-data-wrangling/work
for f in ms-04-data-wrangling/scripts/task*.sh; do
  bash "$f"
done
```

运行：

```bash
chmod +x ms-04-data-wrangling/run.sh
bash ms-04-data-wrangling/run.sh
```

## Git 记录（最小动作）

```bash
git status
git add ms-04-data-wrangling/scripts ms-04-data-wrangling/notes
git commit -m "MS4: scripts + cheatsheet"

```


> 核心套路：**filter → extract → aggregate → inspect**  
> 统一习惯：输入进 `data/`，脚本进 `scripts/`，输出进 `work/`（可重建）。



