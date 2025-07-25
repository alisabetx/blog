---
title: "سوالات مصاحبه asp dotnet core"
slug: "aspnetcore-interview"
date: 2025-01-11T14:00:00+03:30
lastmod: 2025-07-21T14:00:00+03:30
tags: ["asp.net core", "dotnet", "c#", "asp.net", "دات نت"]
description: "سوالات مصاحبه‌ی asp dotnet core"
---

### Common Intermediate Language (CIL) چیه؟

{{< primary_quote >}}
یه زبان میانی که همه‌ی زبون‌های .NET مثل C# و F# به اون کامپایل می‌شن، قبل از اینکه تبدیل به کد ماشین بشن.
{{< /primary_quote >}}

Common Intermediate Language یا به اختصار CIL (یا گاهی IL) یه زبان برنامه‌نویسیه که کدهایی که با زبون‌های دات‌نت مثل #C یا VB می‌نویسی، اول به این زبان تبدیل می‌شن.

وقتی یه برنامه‌ی دات‌نتی می‌سازی، مثلا یه اپ با C#، اول کدت به CIL تبدیل می‌شه. بعد وقتی برنامه رو اجرا می‌کنی، کامپایلر JIT (Just-In-Time) که مال CLR هست، این CIL رو در لحظه به کد ماشین (binary) تبدیل می‌کنه که توسط سیستم‌عامل قابل اجرا باشه.

نکته جالب اینه که چون همه‌ی زبون‌های دات‌نت به یه زبان وسطی (CIL) تبدیل می‌شن، می‌تونی مثلاً یه کلاس C# داشته باشی که از یه کلاس F# ارث‌بری کرده. چون هر دوتاشون در نهایت به CIL تبدیل می‌شن و CLR می‌تونه اون‌ها رو بفهمه.

{{< secondary_quote >}}
چطوریه که یه کلاس C# می‌تونه از یه کلاس F# ارث‌بری کنه؟  
چون جفتشون به CIL کامپایل می‌شن و CIL یکیه برای همه.
{{< /secondary_quote >}}

{{< secondary_quote >}}
آیا کامپایلر C# مستقیماً کد رو به باینری تبدیل می‌کنه؟  
نه، اول به CIL تبدیل می‌شه، بعد توی اجرا به کد باینری.
{{< /secondary_quote >}}

{{< secondary_quote >}}
چجوری می‌شه CIL یه پروژه رو دید؟  
با ابزارهایی مثل ILDasm می‌تونی فایل DLL رو باز کنی و CIL رو ببینی.
{{< /secondary_quote >}}

{{< secondary_quote >}}
JIT Compiler چیه؟  
کامپایلریه توی CLR که وقتی برنامه اجرا می‌شه، کد CIL رو در لحظه به کد باینری سیستم‌عامل تبدیل می‌کنه.
{{< /secondary_quote >}}

---

### Common Language Runtime (CLR) چیه؟

{{< primary_quote >}}
CLR محیط اجرای دات‌نت هست که اجرای اپلیکیشن رو مدیریت می‌کنه (مثل مدیریت حافظه، خطاها، تایپ‌ها و…).
{{< /primary_quote >}}

Common Language Runtime یا به اختصار CLR، هسته‌ی اجرایی دات‌نت هست. یه جور محیط اجرا (runtime environment) که همه چی رو موقع اجرای برنامه کنترل می‌کنه. انگار یه سیستم‌عامل کوچولوئه که بین برنامه‌ی تو و سیستم‌عامل واقعی مثل ویندوز قرار می‌گیره.

چند تا کار مهمی که CLR انجام می‌ده:

- Just-In-Time Compilation (JIT)
همون‌طور که توی سؤال قبل گفتیم، کد CIL رو درست قبل از اجرا تبدیل به کد باینری سیستم می‌کنه. این باعث می‌شه برنامه‌ها cross-platform باشن، چون تا لحظه‌ی اجرا به سیستم‌عامل خاصی وابسته نیستن.

- Memory Management
CLR خودش حافظه رو مدیریت می‌کنه، یعنی وقتی یه شیء جدید می‌سازی، حافظه براش اختصاص می‌ده و وقتی نیاز نباشه، Garbage Collector میاد پاکش می‌کنه و حافظه رو آزاد می‌کنه. یعنی لازم نیست خودت دستی حافظه رو مدیریت کنی مثل زبان C.

- Exception Handling
موقع بروز خطا (مثل تقسیم بر صفر یا نال بودن یه آبجکت)، CLR کنترل اجرای برنامه رو به بخش مناسب منتقل می‌کنه. مثلاً می‌فرستت توی catch اون خطا.

- Thread Management
اجرای برنامه‌های چند نخی (multi-threaded) رو کنترل می‌کنه.

- Type Safety با کمک CTS (Common Type System)
یعنی CLR مطمئنه که همه‌ی زبون‌های دات‌نت (مثل C#, F#, VB.NET) با یه سیستم تایپ سازگارن، پس یه کلاس C# می‌تونه از یه کلاس F# ارث‌بری کنه بدون مشکل.

- مدیریت متادیتا
اطلاعاتی مثل اسم کلاس‌ها، متدها، پارامترها و… رو هم ذخیره و استفاده می‌کنه.

---

### boxing و unboxing چی هستن؟

{{< primary_quote >}}
Boxing یعنی تبدیل یه نوع مقدار (مثل int) به object (یعنی پیچیدنش توی یه reference type)،
Unboxing یعنی برگردوندن همون مقدار از object به نوع اصلیش.
{{< /primary_quote >}}

در دات‌نت دو نوع کلی داده داریم:

**Value type (مثل int، float، struct)**: روی استک ذخیره می‌شن
**Reference type (مثل string، object، کلاس‌ها)**: روی heap ذخیره می‌شن

Boxing یعنی اینکه یه value type رو بذاری توی یه reference type.

```csahrp
int number = 5;
object boxed = number;
```

Unboxing یعنی از اون object دوباره مقدار اصلی رو بکشی بیرون. Unboxing حتماً باید با cast باشه.

```csahrp
int unboxed = (int)boxed;
```

Boxing و Unboxing هزینه داره! چون باید حافظه روی heap ساخته بشه یا cast انجام بشه. این کارا کندتر از کار با خود value typeهاست.

چرا اصلاً وجود دارن؟
چون قدیما (قبل از genericها) مثلا ArrayList بود که می‌خواست هر چیزی رو تو خودش نگه داره. اونجا مجبور بودی int یا float رو boxing کنی.

{{< secondary_quote >}}
هزینه‌ی استفاده از boxing چیه؟  
ساختن آبجکت جدید و allocate کردن حافظه
{{< /secondary_quote >}}

{{< secondary_quote >}}
آیا string به object هم boxing حساب می‌شه؟  
نه، چون string خودش reference typeه
{{< /secondary_quote >}}

---

{{< edit >}}

# منابع
[Udemy](https://www.udemy.com/course/csharpnet-50-essential-interview-questions-junior-level/)
[Udemy](https://www.udemy.com/course/csharpnet-50-essential-interview-questions-mid-level/)
[microsoft](https://learn.microsoft.com/en-us/aspnet/core/introduction-to-aspnet-core)