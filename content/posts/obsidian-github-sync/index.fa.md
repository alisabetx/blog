---
title: "سینک کردن Obsidian با Github"
slug: "obsidian-github-sync"
date: 2026-02-13T14:00:00+03:30
lastmod: 2026-02-13T14:00:00+03:30
tags: ["obsidian", "git", "github"]
description: "آموزش 0 تا 100 بکاپ خودکار نوت‌ها (مثل Obsidian) روی GitHub Private با اسکریپت PowerShell و تنظیم Task Scheduler هر 15 دقیقه"
---

هدف این پست اینه که نوت‌هات (مثلا Obsidian) هر ۱۵ دقیقه بررسی بشن و اگر تغییری داشتند، خودکار commit و push بشن توی یک ریپازیتوری Private در GitHub.

این کار عملا دو تا نتیجه‌ی مهم داره:
1) بکاپ امن و نسخه‌بندی‌شده داری (هر تغییر تاریخچه داره)
2) لازم نیست هر بار دستی push کنی

قبل از شروع، خیلی کوتاه فرض‌های این آموزش:

* سیستم عامل: Windows 10 یا Windows 11
* نوت‌ها داخل یک فولدر مشخص هستند (مثلا `D:\Obsidian`)
* اکانت GitHub داری
* Git روی ویندوز نصب میشه و از خط فرمان قابل استفاده‌ست

# ساخت ریپازیتوری در GitHub {#create-private-repo}

1. وارد GitHub شو
2. روی New repository بزن
3. یک اسم برای repo بده (مثلا `obsidian-notes` یا هر چی دوست داری)
4. گزینه‌ی **Private** رو انتخاب کن
5. Create repository رو بزن ([GitHub Docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository?utm_source=chatgpt.com "Creating a new repository"))

نکته مهم:

- فعلا README و .gitignore و License رو از GitHub نساز (اختیاریه)، چون ما می‌خوایم فولدر فعلی رو push کنیم.

# تبدیل فولدر به repo و اتصال به GitHub {#init-and-connect}

یک PowerShell باز کن و این‌ها رو مرحله به مرحله انجام بده.

## رفتن داخل فولدر {#cd}

```bash
cd D:\Obsidian
```

## ساخت git repo محلی {#git-init}

```bash
git init
```

## ساخت .gitignore {#gitignore}

چون قراره اسکریپت ما فایل لاگ بسازه، اگر لاگ‌ها رو ignore نکنی، ممکنه همیشه تغییر تشخیص داده بشه و بی‌خودی commit بزنه.

یک فایل به اسم `.gitignore` داخل `D:\Obsidian` بساز و این‌ها رو داخلش بذار:

```gitignore
.obsidian/workspace.json
.obsidian/cache/
.trash/
.logs/
*.log
```

## 3.4 اولین commit {#first-commit}

```bash
git add -A
git commit -m "Initial commit"
```

## 3.5 افزودن remote {#add-remote}

برگرد به صفحه‌ی repo توی GitHub:
- روی دکمه‌ی **Code** بزن
- بخش HTTPS رو انتخاب کن
- URL رو Copy کن (مثلا چیزی شبیه `https://github.com/.../... .git`)
حالا در PowerShell این دستور رو بزن (این ترفند، URL رو از Clipboard برمی‌داره):

```bash
git remote add origin (Get-Clipboard)
```

برای اطمینان:

```bash
git remote -v
```

## push اولیه و ذخیره شدن لاگین {#first-push}

بهتره branch رو `main` کنیم (استاندارد جدید بیشتر repo ها همینه):

```bash
git branch -M main
```

حالا push:

```bash
git push -u origin main
```

این مرحله ممکنه:

- یک پنجره مرورگر برای لاگین باز کنه
- یا ازت اجازه دسترسی بگیره
- یا اطلاعات رو ذخیره کنه
    

هدف اینه که یک بار لاگین انجام بشه و بعدش دفعات بعدی push بدون سوال کار کنه. ([GitHub Docs](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git?utm_source=chatgpt.com "Caching your GitHub credentials in Git"))

# قدم 4: نوشتن اسکریپت برای Auto Commit & Push {#powershell-script}

ایده اسکریپت:

1. مطمئن میشه مسیر درست و repo معتبره
    
2. `git status --porcelain` رو می‌خونه
    
3. اگر تغییری نبود، خارج میشه
    
4. اگر تغییر بود، add → commit → push
    
5. همه چیز رو توی فایل لاگ می‌نویسه
    

## 4.1 ساخت فولدر اسکریپت {#script-folder}

داخل repo یک فولدر بساز:

- `D:\Obsidian\.scripts`
    

و فایل زیر رو داخلش بساز:

- `D:\Obsidian\.scripts\auto-git-push.ps1`
    

## 4.2 کد کامل اسکریپت {#script-code}

این نسخه هم ساده‌ست، هم برای لاگ گرفتن مناسب، هم دردسر Quote کردن آرگومان‌ها رو نداره:

```bash
# ================================
# Auto Git Commit & Push Script (beginner-friendly + robust logging)
# Repo: D:\Obsidian
# Script: D:\Obsidian\.scripts\auto-git-push.ps1
# Logs: D:\Obsidian\.logs\auto-git-push_YYYY-MM-DD.log
# ================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoPath = "D:\Obsidian"
$LogDir   = Join-Path $RepoPath ".logs"
$LogFile  = Join-Path $LogDir ("auto-git-push_{0}.log" -f (Get-Date -Format "yyyy-MM-dd"))

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet("INFO","WARN","ERROR")][string]$Level = "INFO"
    )
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[{0}] [{1}] {2}" -f $ts, $Level, $Message
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)][string[]]$Args
    )

    # Run git in repo directory; capture both stdout/stderr
    $output = & git -C $RepoPath @Args 2>&1
    $exit   = $LASTEXITCODE

    return [pscustomobject]@{
        ExitCode = $exit
        Output   = ($output | Out-String)
        Command  = ("git -C " + $RepoPath + " " + ($Args -join " "))
    }
}

try {
    if (-not (Test-Path -LiteralPath $RepoPath -PathType Container)) {
        throw "Repository path not found: $RepoPath"
    }

    Ensure-Dir $LogDir

    Write-Log "========== Auto Git Push START =========="

    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCmd) {
        throw "git is not available in PATH"
    }
    Write-Log "Git detected: $($gitCmd.Source)"

    # Ensure repo
    $r = Invoke-Git @("rev-parse","--is-inside-work-tree")
    if ($r.ExitCode -ne 0 -or $r.Output.Trim() -ne "true") {
        Write-Log $r.Command "ERROR"
        if ($r.Output) { Write-Log ($r.Output.Trim()) "ERROR" }
        throw "This directory is not a git repository"
    }

    # Current branch
    $b = Invoke-Git @("branch","--show-current")
    if ($b.ExitCode -ne 0) {
        Write-Log $b.Command "ERROR"
        if ($b.Output) { Write-Log ($b.Output.Trim()) "ERROR" }
        throw "Cannot detect current branch"
    }
    $branch = $b.Output.Trim()
    Write-Log "Current branch: $branch"

    # Remote exists?
    $rem = Invoke-Git @("remote")
    if ($rem.ExitCode -ne 0) {
        Write-Log $rem.Command "ERROR"
        if ($rem.Output) { Write-Log ($rem.Output.Trim()) "ERROR" }
        throw "Cannot read git remotes"
    }
    if ([string]::IsNullOrWhiteSpace($rem.Output)) {
        throw "No git remote configured"
    }
    Write-Log ("Remote(s): " + ($rem.Output.Trim() -replace "\r?\n", ", "))

    # Refresh index
    [void](Invoke-Git @("update-index","-q","--refresh"))

    # Check changes
    $st = Invoke-Git @("status","--porcelain")
    if ($st.ExitCode -ne 0) {
        Write-Log $st.Command "ERROR"
        if ($st.Output) { Write-Log ($st.Output.Trim()) "ERROR" }
        throw "git status failed"
    }

    if ([string]::IsNullOrWhiteSpace($st.Output)) {
        Write-Log "No changes detected. Nothing to commit."
        Write-Log "========== Auto Git Push END =========="
        exit 0
    }

    Write-Log "Changes detected:"
    $st.Output -split "`r?`n" | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_)) { Write-Log ("  " + $_.Trim()) }
    }

    # Stage
    $add = Invoke-Git @("add","-A")
    if ($add.ExitCode -ne 0) {
        Write-Log $add.Command "ERROR"
        if ($add.Output) { Write-Log ($add.Output.Trim()) "ERROR" }
        throw "git add failed"
    }
    Write-Log "All changes staged"

    # Commit
    $commitMsg = "Auto update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $cm = Invoke-Git @("commit","-m",$commitMsg)
    if ($cm.ExitCode -ne 0) {
        Write-Log $cm.Command "ERROR"
        if ($cm.Output) { Write-Log ($cm.Output.Trim()) "ERROR" }
        throw "git commit failed"
    }
    if ($cm.Output) { Write-Log ($cm.Output.Trim()) }
    Write-Log "Committed with message: $commitMsg"

    # Push
    Write-Log "Pushing to remote..."
    $ps = Invoke-Git @("push")
    Write-Log $ps.Command
    if ($ps.Output) {
        ($ps.Output -split "`r?`n") | ForEach-Object { if($_){ Write-Log $_ } }
    }

    if ($ps.ExitCode -ne 0) {
        throw "git push failed (ExitCode=$($ps.ExitCode))"
    }

    Write-Log "Push successful"
    Write-Log "========== Auto Git Push END =========="
    exit 0
}
catch {
    Write-Log ("FATAL ERROR: " + $_.Exception.Message) "ERROR"
    Write-Log (($_ | Out-String).Trim()) "ERROR"
    Write-Log "========== Auto Git Push FAILED =========="
    exit 1
}
```

### نکته‌ی مهم: چرا `.logs/` رو ignore کردیم؟

چون اسکریپت هر بار داخل `.logs` می‌نویسه؛ اگر ignore نکنی، خودش باعث “تغییر” میشه و ممکنه هر بار commit بزنه حتی اگر نوت‌ها تغییر نکرده باشن.

# قدم 5: تست دستی اسکریپت {#manual-test}

قبل از Task Scheduler، یک بار دستی اجراش کن:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\Obsidian\.scripts\auto-git-push.ps1"
```

اگر اولین بار باشه، ممکنه لازم باشه همون دفعه‌ی اول لاگین GitHub کامل انجام بشه (مرورگر باز بشه). ([GitHub Docs](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git?utm_source=chatgpt.com "Caching your GitHub credentials in Git"))

بعد از اجرا:

- فایل لاگ رو ببین: `D:\Obsidian\.logs\auto-git-push_YYYY-MM-DD.log`
    
- صفحه GitHub repo رو refresh کن و ببین commit جدید اومده یا نه
    

# قدم 6: تنظیم Task Scheduler برای اجرای هر 15 دقیقه {#task-scheduler-setup}

هدف اینه که ویندوز هر ۱۵ دقیقه اسکریپت رو اجرا کنه.

## 6.1 باز کردن Task Scheduler {#open-ts}

Start Menu رو باز کن و سرچ کن: **Task Scheduler**  
و اجراش کن.

## 6.2 ساخت Task جدید {#create-task}

روی **Create Task** بزن (نه Create Basic Task، چون تنظیمات دقیق‌تر می‌خوایم).

### تب General {#ts-general}

- Name: مثلا `Auto Git Push (Obsidian)`
    
- گزینه‌ی **Run whether user is logged on or not** رو انتخاب کن (اگر می‌خوای حتی وقتی لاگ‌آوتی هم اجرا بشه)
    
- تیک **Run with highest privileges** رو هم بزن (برای جلوگیری از بعضی خطاهای دسترسی)
    

### تب Triggers {#ts-triggers}

- New
    
- Begin the task: On a schedule
    
- Daily
    
- Start: یک زمان دلخواه (مثلا 09:00)
    
- تیک **Repeat task every:** `15 minutes`
    
- **for a duration of:** `1 day`
    
- OK
    

این مدل تنظیم باعث میشه هر روز تکرار ۱۵ دقیقه‌ای داشته باشی.

### تب Actions {#ts-actions}

- New
    
- Action: Start a program
    
- Program/script:
    

```txt
powershell.exe
```

- Add arguments:
    

```txt
-NoProfile -ExecutionPolicy Bypass -File "D:\Obsidian\.scripts\auto-git-push.ps1"
```

- Start in (optional):
    

```txt
D:\Obsidian
```

OK

### تب Conditions {#ts-conditions}

برای اینکه وسط کار بی‌دلیل متوقف نشه:

- اگر لپ‌تاپ داری، تیک **Start the task only if the computer is on AC power** رو بردار
    
- تیک‌های Idle رو هم بردار (اگر نمی‌خوای وابسته به idle باشه)
    

### تب Settings {#ts-settings}

این قسمت خیلی مهمه:

- تیک **Allow task to be run on demand** روشن باشه
    
- تیک **Run task as soon as possible after a scheduled start is missed** روشن باشه
    
- گزینه‌ی **If the task is already running, then the following rule applies:**  
    بذارش روی **Do not start a new instance** (این باعث میشه اگر یه اجرا طول کشید، اجرای بعدی همزمان نشه) ([Super User](https://superuser.com/questions/1708988/if-the-task-is-already-running-setting-in-windows-task-scheduler?utm_source=chatgpt.com "\"If the task is already running...\" setting in Windows ..."))
    

در نهایت OK بزن. ممکنه ازت پسورد ویندوز رو بپرسه (اگر حالت run whether user… رو انتخاب کرده باشی).

## 6.3 تست از داخل Task Scheduler {#ts-test}

روی Task ساخته شده راست کلیک کن و **Run** رو بزن.  
بعد:

- در تب History (اگر فعال باشه) وضعیت رو ببین
    
- و مهم‌تر: فایل لاگ رو چک کن
    

# چک‌لیست تست (مثل test case) {#test-cases}

برای اینکه مطمئن شی همه چیز درست کار می‌کنه، این سناریوها رو تست کن:

```txt
1) هیچ تغییری نده → اسکریپت باید بنویسه "No changes detected" و exit 0
2) یک فایل .md جدید بساز → باید commit و push انجام بشه
3) یک فایل موجود رو تغییر بده → باید commit و push انجام بشه
4) یک فایل رو rename کن → باید تغییرات ثبت و push بشه
5) یک فایل رو حذف کن → باید حذف هم commit و push بشه
```

# مشکلات رایج و رفعشان {#troubleshooting}

## 1) خطای git is not available in PATH {#git-not-in-path}

- Git درست نصب نشده یا PATH ست نشده
    
- راه سریع: Git for Windows رو دوباره نصب کن (گزینه‌های پیش‌فرض)
    

## 2) موقع push خطای Authentication failed میاد {#auth-failed}

چند حالت رایج:

- Git قدیمیه و Credential Manager درست OAuth نمی‌کنه → Git for Windows رو آپدیت کن ([GitHub Docs](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git?utm_source=chatgpt.com "Caching your GitHub credentials in Git"))
    
- یک بار باید دستی `git push` انجام بدی تا لاگین مرورگری و ذخیره شدن credential انجام بشه ([GitHub Docs](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git?utm_source=chatgpt.com "Caching your GitHub credentials in Git"))
    
- اگر Credential های خراب ذخیره شده:
    
    - Windows Credential Manager رو باز کن و credential مربوط به `git:https://github.com` رو پاک/اصلاح کن (این کار معمولا مشکل رو حل می‌کنه) ([Stack Overflow](https://stackoverflow.com/questions/70588353/how-to-add-a-github-personal-access-token-into-windows-credentials-windows-10?utm_source=chatgpt.com "How to add a github personal access token into windows ..."))
        

### راه جایگزین (اگر OAuth/Browser جواب نداد): Personal Access Token {#pat-alternative}

اگر مجبور شدی از PAT استفاده کنی:

- در GitHub برو بخش Personal access tokens و یک token بساز (ترجیحا fine-grained با دسترسی محدود) ([GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens?utm_source=chatgpt.com "Managing your personal access tokens"))
    
- سپس موقع push، به جای Password، همون token رو وارد کن
    
- نکته امنیتی: token رو داخل اسکریپت ذخیره نکن؛ بذار Credential Manager نگهش داره
    

(GitHub خودش fine-grained رو توصیه می‌کنه چون محدود و امن‌تره) ([GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens?utm_source=chatgpt.com "Managing your personal access tokens"))

## 3) Task Scheduler اجرا میشه ولی چیزی push نمیشه {#ts-runs-no-push}

- اول لاگ رو چک کن: `D:\Obsidian\.logs\...`
    
- اگر نوشته No changes detected، یعنی واقعا تغییر ندیدی یا فایل‌ها خارج از repo تغییر کردند
    
- اگر repoPath اشتباه باشه، توی لاگ می‌فهمی
    

## 4) Task اجرا نمیشه یا “0x1” می‌خوره {#ts-0x1}

- معمولا به خاطر مسیر اشتباه فایل ps1 یا permission هست
    
- مسیر `-File "..."` رو دقیقا چک کن
    
- Run with highest privileges رو روشن کن
    
- یک بار با Run دستی تست کن
    

# نکات امنیتی {#security}

- ریپازیتوری رو Private نگه دار (این آموزش هم روی Private طراحی شده) ([GitHub Docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository?utm_source=chatgpt.com "Creating a new repository"))
    
- هر چیزی که توی نوت‌هاست، فرض کن ممکنه روزی لو بره (مثلا اگر اشتباها repo رو Public کردی). پس:
    
    - پسوردها، توکن‌ها، کلیدها رو داخل نوت‌ها ننویس
        
- اگر از PAT استفاده کردی:
    
    - تاریخ انقضا بذار
        
    - فقط به همون repo دسترسی بده (fine-grained) ([GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens?utm_source=chatgpt.com "Managing your personal access tokens"))
        

{{< edit >}}

# منابع {#references}

- مستندات ساخت ریپازیتوری در GitHub ([GitHub Docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository?utm_source=chatgpt.com "Creating a new repository"))
    
- مستندات GitHub درباره ذخیره کردن credential ها (روی HTTPS) ([GitHub Docs](https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git?utm_source=chatgpt.com "Caching your GitHub credentials in Git"))
    
- مستندات Git درباره credential helper و Git Credential Manager ([Git](https://git-scm.com/doc/credential-helpers?utm_source=chatgpt.com "Git credential helpers"))
    
- توضیح گزینه “If the task is already running…” در Task Scheduler ([Super User](https://superuser.com/questions/1708988/if-the-task-is-already-running-setting-in-windows-task-scheduler?utm_source=chatgpt.com "\"If the task is already running...\" setting in Windows ..."))
    


{{< edit >}}