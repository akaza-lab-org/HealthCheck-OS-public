# Sub PC Tasks Only

サブPCで行う作業だけをまとめる。サブPCは限定作業用であり、本番電子カルテPC上の設定・DB・AHK座標を直接管理しない。

## 1. 初回だけ行う設定

```powershell
mkdir C:\data\GitHub_org
cd C:\data\GitHub_org

git clone https://github.com/akaza-lab-org/HealthCheck-OS.git
git clone https://github.com/akaza-lab-org/clinic-app.git kensin
git clone https://github.com/akaza-lab-org/AHK_setting.git
```

Git設定:

```powershell
git config --global user.name "your-name"
git config --global user.email "your-email"
git config --global core.autocrlf true
```

AutoHotkey v2確認:

```powershell
Test-Path "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

## 2. 作業前確認

```powershell
git -C C:\data\GitHub_org\HealthCheck-OS status --short -b
git -C C:\data\GitHub_org\kensin status --short -b
git -C C:\data\GitHub_org\AHK_setting status --short -b
```

未コミット変更がある場合は、内容を確認してから作業する。

## 3. kensin ZIP生成

```powershell
cd C:\data\GitHub_org\kensin
git pull
pytest
.\build_portable.bat
```

生成物:

```text
C:\data\GitHub_org\kensin\dist\kenshin_<version>_<commit>.zip
```

USBへコピー:

```text
USB:\kensin_release\incoming\
```

## 4. AHK変更時の確認

AHKを変更した場合だけ実行する。

```powershell
cd C:\data\GitHub_org\AHK_setting
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "kenshin_order_bridge.ahk"
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "main.ahk"
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut /Validate "config_editor.ahk"
```

## 5. 軽微なfix

サブPCで許可するfix:

- 表示文言の修正
- 明らかな小バグ修正
- テスト追加
- 配布手順・ドキュメント修正
- AHK bridge の軽微な引数処理修正

fix後:

```powershell
cd C:\data\GitHub_org\kensin
pytest
.\build_portable.bat
```

AHKを触った場合はAHK `/Validate` も実行する。

## 6. USBで持ち帰るもの

サブPCから電子カルテPCへ渡すもの:

```text
dist\kenshin_<version>_<commit>.zip
```

電子カルテPCからサブPCへ戻すもの:

```text
更新ログ
エラーログ
スクリーンショット
現場メモ
```

患者情報を含むログやスクリーンショットは、GitHubへ入れない。

## 7. サブPCでやらないこと

- 本番DBを直接編集しない
- 電子カルテPCの `settings.json` を上書きしない
- 電子カルテPCの AHK `config.ini` を上書きしない
- USB上でGit作業をしない
- 本番電子カルテPCで `git pull` や `pip install` をしない
- 本番電子カルテPCで `build_portable.bat` を実行しない
- 実患者データをGitHubへ入れない

## 8. 作業完了時に残す記録

GitHub Issue またはPRに以下を書く。

```text
実施内容:
対象repo:
生成ZIP:
commit:
テスト結果:
AHK Validate結果:
USB受け渡し結果:
commit:
push:
注意点:
```

サブPCで軽微なfixを行った場合も、検証後は原則pushする。ただし、本番設定・患者情報・AHK `config.ini` の端末固有変更はpushしない。
