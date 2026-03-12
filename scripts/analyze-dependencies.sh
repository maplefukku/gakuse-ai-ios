#!/bin/bash

# コンポーネント依存関係分析スクリプト

COMPONENTS_DIR="GakuseAI/Views/Components"
OUTPUT_FILE="output/dependency-analysis.md"

# 出力ディレクトリ作成
mkdir -p output

# ヘッダー
cat > "$OUTPUT_FILE" << 'EOF'
# コンポーネント依存関係分析

## 生成日時
- 日時: $(date '+%Y-%m-%d %H:%M:%S')
- 分析対象: GakuseAI/Views/Components/*.swift

---

## 依存関係グラフ

```mermaid
graph TD
EOF

# 各コンポーネントの依存関係を分析
for comp in "$COMPONENTS_DIR"/*.swift; do
    comp_name=$(basename "$comp" .swift)
    echo "  $comp_name[$comp_name]" >> "$OUTPUT_FILE"

    # コンポーネント内で他のコンポーネントを使用しているかチェック
    grep -oE '[A-Z][a-zA-Z0-9]*View\(' "$comp" 2>/dev/null | \
        sed 's/View$//g' | \
        sort -u | \
        while read dep; do
            if [ -f "$COMPONENTS_DIR/${dep}View.swift" ]; then
                echo "  $comp_name --> ${dep}View" >> "$OUTPUT_FILE"
            fi
        done
done

# フッター
cat >> "$OUTPUT_FILE" << 'EOF'
```

---

## コンポーネント一覧

| コンポーネント | 依存先 | 再利用性 |
|--------------|--------|----------|
EOF

# 再利用性分析
for comp in "$COMPONENTS_DIR"/*.swift; do
    comp_name=$(basename "$comp" .swift)
    dep_count=$(grep -oE '[A-Z][a-zA-Z0-9]*View\(' "$comp" 2>/dev/null | sed 's/View$//g' | sort -u | wc -l)
    deps=$(grep -oE '[A-Z][a-zA-Z0-9]*View\(' "$comp" 2>/dev/null | sed 's/View$//g' | sort -u | tr '\n' ', ' | sed 's/,$//')

    # 再利用性スコア計算（依存が少ないほど高い再利用性）
    if [ $dep_count -eq 0 ]; then
        reuse="★★★★★"
    elif [ $dep_count -eq 1 ]; then
        reuse="★★★★☆"
    elif [ $dep_count -eq 2 ]; then
        reuse="★★★☆☆"
    elif [ $dep_count -eq 3 ]; then
        reuse="★★☆☆☆"
    else
        reuse="★☆☆☆☆"
    fi

    echo "| $comp_name | $deps | $reuse |" >> "$OUTPUT_FILE"
done

echo "依存関係分析完了: $OUTPUT_FILE"
