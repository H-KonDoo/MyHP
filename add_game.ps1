$baseDir = $PSScriptRoot

# 1. Ask for input
$gameId = Read-Host "新しいゲームのファイル名を入力してください (例: game03)"
if ([string]::IsNullOrWhiteSpace($gameId)) {
    Write-Host "ファイル名が入力されませんでした。中止します。"
    Pause
    exit
}
# Add .html if missing
if (-not $gameId.EndsWith(".html")) {
    $gameId = "$gameId.html"
}

$gameTitle = Read-Host "ゲームのタイトルを入力してください"
if ([string]::IsNullOrWhiteSpace($gameTitle)) {
    $gameTitle = "未題のゲーム"
}

# 2. Check if file exists
$newFilePath = Join-Path $baseDir $gameId
if (Test-Path $newFilePath) {
    Write-Host "そのファイル名 ($gameId) は既に存在します。別の名前で試してください。"
    Pause
    exit
}

# 3. Copy template
$templatePath = Join-Path $baseDir "game_page.html"
if (-not (Test-Path $templatePath)) {
    Write-Host "エラー: テンプレートファイル (game_page.html) が見つかりません。"
    Pause
    exit
}
Copy-Item $templatePath $newFilePath

# 4. Update the new file's title temporarily (Verified user will overwrite content anyway, but good to set title)
# (Optional skip for simplicity, user uses editor to overwrite everything)

# 5. Add link to index.html
$indexPath = Join-Path $baseDir "index.html"
if (-not (Test-Path $indexPath)) {
    Write-Host "エラー: index.html が見つかりません。"
    Pause
    exit
}

$content = Get-Content $indexPath -Encoding UTF8 -Raw
$marker = "<!-- LINK_INSERTION_POINT -->"

if ($content -notmatch $marker) {
    Write-Host "エラー: index.html に挿入ポイント ($marker) が見つかりません。"
    Pause
    exit
}

$newLink = @"
                <li class="game-link-item">
                    <a href="$gameId" class="game-link">
                        <span class="arrow">▶</span> $gameTitle
                    </a>
                </li>
                $marker
"@

$newContent = $content.Replace($marker, $newLink)
Set-Content $indexPath -Value $newContent -Encoding UTF8

Write-Host "成功！"
Write-Host "1. 新しいファイル ($gameId) を作成しました。"
Write-Host "2. index.html にリンクを追加しました。"
Write-Host "--------------------------------------------------"
Write-Host "次は editor.html を使ってゲーム紹介文を作成し、"
Write-Host "$gameId の中身を書き換えてください。"
Pause
