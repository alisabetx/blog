---
title: "aspnet core (قسمت صفر)"
slug: "aspnet-core-part-00"
date: 2023-08-10T14:00:00+03:30
lastmod: 2023-08-10T14:00:00+03:30
tags: ["asp.net core"]
author: "علی ثابت"
draft: false
comments: false
description: "آموزش asp.net core"
---
این پست با هدف نظم دادن به چیزهایی که در مورد ASP.NET Core یاد گرفته‌ام نوشته شده. اگر مطالب علوم کامپیوتر و زبان csharp رو در حد مقدماتی بلد باشید، می‌تونید ازش به عنوان منبع آموزشی برای ASP.NET Core استفاده کنید.

ASP.Net Core چیه؟
-----------------

یک فریم‌ورک cross-platform (قابل اجرا در ویندوز، لینوکس و مک) و [open-source](https://github.com/dotnet/aspnetcore) مبتنی بر داتنت و زبان سی‌شارپ، که میشه باهاش برنامه‌های وب، سرویس و... بسازیم.

نام‌گذاری
---------

مایکروسافت در نام‌گذاری اکوسیستم داتنت، مثل نام‌گذاری نسخه‌های ویندوز، دچار سرگیجه بوده. اگر به اکوسیستم داتنت نگاه کرده باشید، حتما اسم‌های زیادی دیده‌اید که باعث سردرگمی میشه.

*   Asp.Net Web Forms در سال 2002 معرفی شد، مشکلات performanceای زیادی داشت، فقط روی ویندوز اجرا می‌شد، open-source نبود و مدل توسعه‌اش event-driven بود
*   Asp.Net Mvc در سال 2009 معرفی شد، مشکلات performanceای کمتری داشت، فقط روی ویندوز اجرا می‌شد، اجرایش در cloud ساده نبود، open-source شد و مدل توسعه‌اش بر اساس الگوی model-view-controller بود
*   Asp.Net Core در سال 2016 معرفی شد، از ابتدا بازنویسی شد و مشکلات نسخه‌های قبلی رو حل کرد، cross-platform شد و دیگه مختص ویندوز نبود، cloud-friendly شد، open-source شد و مدل توسعه‌اش بر اساس الگوی model-view-controller بود

**در داتنت‌کور، 4 ماژول اصلی داریم.**

*   Asp.Net Core Mvc برای ساخت برنامه‌های وبِ متوسط تا پیچیده
*   Asp.Net Core Web API برای ساخت سرویس‌های RESTful که می‌تونن هر نوع clientای داشته باشن
*   Asp.Net Core Razor Pages برای ساخت برنامه‌های وبِ ساده‌ی متمرکز بر صفحه
*   Asp.Net Core Blazor برای ساخت برنامه‌های وب‌ای که هر دو سمت client و server با سی‌شارپ نوشته شده باشه

پیش‌نیازها
----------

*   زبان سی‌شارپ
*   برنامه‌نویسی شی‌گرا
*   مفاهیم پایه‌ای فرانت مثل HTML و CSS و کمی JS
*   نصب [Visual Studio](https://visualstudio.microsoft.com/downloads/) (نسخه Community هم کافیه) و [SSMS](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) و [Postman](https://www.postman.com/downloads/)

سرفصل‌ها
--------

سرفصل‌ها مطابق دوره‌ی Udemy Asp.Net Core 7 (.NET 7) True Ultimate Guide خواهد بود، البته مطالب بیشتری بهش اضافه خواهد شد. کدها رو می‌تونید در [گیت‌هاب دوره](https://github.com/Harsha-Global/AspNetCore-Harsha) ببینید.