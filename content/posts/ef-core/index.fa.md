---
title: "کار با EF Core"
slug: "ef-core"
date: 2025-03-19T14:00:00+03:30
lastmod: 2025-04-22T14:00:00+03:30
tags: ["EF", "EF Core", "Entity Framework Core"]
description: "با EF Core به صورت عملی کار کنیم"
draft: true
---

# آشنایی با EF Core

(به زودی)

## مقدمه و نصب

(اگر تجربه کار با EF رو دارید، نیاز به خوندن این قسمت نیست). متناسب با ورژن EF Core، ابتدا باید [SDK دات‌نت](https://dotnet.microsoft.com/en-us/download) رو نصب کرده باشیم. بسته به نوع [Provider](https://learn.microsoft.com/en-us/ef/core/providers/) باید EF Core مرتبط با اون رو از طریق [Nuget](https://www.nuget.org/) نصب کنیم. مثلا پکیجی که باید برای کار با SQL Server نصب بشه، با پکیجی که باید برای کار با MySQL نصب بشه، متفاوته. در اینجا قراره با SQL Server کار کنیم، پس [Microsoft.EntityFrameworkCore.SqlServer](https://www.nuget.org/packages/Microsoft.EntityFrameworkCore.sqlserver/) رو نصب میکنیم. EF Core علاوه بر پکیج اصلی، تعدادی ابزار هم داره، ابزارها از طریق CLI (که با دستور dotnet ef) شروع میشن یاPackage Manager Console (که شامل دستوراتی مثل Add-Migration هستن) قابل استفاده اند.

نسخه بندی این پکیج ها به صورت [Semantic Versioning](https://semver.org/) است و لازمه که major version (عدد سمت چپ) همه‌شون با هم برابر باشه.

مهمترین ابزارها:

```
Microsoft.EntityFrameworkCore.Tools
Microsoft.EntityFrameworkCore.Design
```

## ساخت اولین برنامه

در اینجا قراره مرحله به مرحله، یک وب‌اپ ساده که با EF Core کار میکنه بسازیم. توی Visual Studio به این شکل اپ رو میسازیم:
1. ایجاد پروژه جدید با انتخاب Create a new Project
2. انتخاب ASP.Net Core Empty به عنوان نوع پروژه
3. انتخاب نام برای پروژه، مثلا EfSampleProject
4. عدم تغییر در تنظیمات اولیه پروژه و ساخت اون با Create
5. نصب پکیج ها از طریق Tools، سپس NuGet Package Manager، سپس Manage Nuget Packages for Solution.
```
Microsoft.EntityFrameworkCore.sqlserver
Microsoft.EntityFrameworkCore.Tools
Microsoft.EntityFrameworkCore.Design
```

(ادامه دارد)

# قسمت عملی

## طول عمر DbContext

طول عمر یک DbContext از زمانیه که یک نمونه (instance) از اون ساخته بشه، تا زمانی که اون instance از بین بره (dispose بشه). `DbContext instance` ساخته شده که برای یه کار استفاده بشه، به زبان حرفه ای تر، `unit of work`. مارتین فاولر میگه:

> A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done, it figures out everything that needs to be done to alter the database as a result of your work.

به زبان ساده، فرض کن یه اپلیکیشن داری که توش کاربر می‌تونه یه سفارش ثبت کنه. برای این کار شاید چندتا عملیات مختلف باید انجام بشه:

1. یه سفارش جدید بسازی
2. چندتا آیتم به اون سفارش اضافه کنی
3. موجودی محصولات رو کم کنی
4. مبلغ کل رو حساب کنی

این‌ها همه با دیتابیس در ارتباط هستن. حالا Unit of Work مثل یه "سبد" می‌مونه که همه‌ی این تغییرات رو تو خودش جمع می‌کنه ولی هنوز هیچی رو به دیتابیس نمی‌فرسته.

وقتی همه‌ی کارات تموم شد و مطمئن شدی که مشکلی نیست، به Unit of Work می‌گی:
«حالا همه‌ی این تغییرات رو یکجا انجام بده!» اون‌ موقع یه SaveChanges یا Commit صدا زده می‌شه و همه‌چی با هم به دیتابیس فرستاده می‌شه.
اگر وسط راه به خطا خوردی، چون هنوز چیزی ثبت نشده، راحت می‌تونی بگی: «بی‌خیال! هیچ تغییری اعمال نکن.».
یعنی:

>یا همه تغییرات با هم ذخیره می‌شن، یا اصلاً هیچ‌کدوم ذخیره نمی‌شن (در صورت خطا).

یه unit-of-work معمول در استفاده از EF Core شامل این موارد است:

- ساخت یک instance از DbContext
- زیرنظرگرفتن (track کردنِ) instanceهای entityها. entityها زمانی track میشن که:
	- از کوئری برگردند
	- به DbContext اضافه یا آپدیت بشن
- 

{{< edit >}}

# منابع
[Microsoft Learn](https://learn.microsoft.com/)