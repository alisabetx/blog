---
title: "سوالات مصاحبه asp dotnet core"
slug: "aspnetcore-interview"
date: 2025-01-11T14:00:00+03:30
lastmod: 2025-07-21T14:00:00+03:30
tags: ["asp.net core", "dotnet", "c#", "asp.net", "دات نت"]
description: "سوالات مصاحبه‌ی asp dotnet core"
---

### Common Intermediate Language (CIL) چیه؟ {#common-intermediate-language-cil}

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

### Common Language Runtime (CLR) چیه؟ {#common-language-runtime-clr}

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

### boxing و unboxing چی هستن؟ {#boxing-unboxing}

{{< primary_quote >}}
Boxing یعنی تبدیل یه value type (مثل int) به object (یعنی پیچیدنش توی یه reference type)،
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

### خطاهای اصلی در دات‌نت چی هستن؟ {#long-section-0}

{{< primary_quote >}}
- خطاهای کامپایل (Syntax Errors)
- خطاهای زمان اجرا (Runtime Errors)
- خطاهای منطقی (Logical Errors)
{{< /primary_quote >}}

- خطاهای کامپایل (Syntax Errors):
وقتی کدت از لحاظ نگارشی غلطه، مثلاً یه ; رو جا انداختی یا اسم متغیر رو اشتباه نوشتی. اینا موقع نوشتن برنامه توسط کامپایلر یا IDE (مثل ویژوال استودیو) شناسایی می‌شن. اگه این خطاها برطرف نشن، برنامه اصلاً اجرا نمی‌شه.

- خطاهای زمان اجرا (Runtime Errors):
برنامه کامپایل می‌شه ولی موقع اجرا خراب می‌شه. مثلاً می‌خوای از یه لیست خالی عضو بگیری یا یه عدد رو به صفر تقسیم کنی.

- خطاهای منطقی (Logical Errors):
اینا خطرناک‌ترینن. چون برنامه اجرا می‌شه، کرش نمی‌کنه، ولی خروجی‌ای که می‌ده اشتباهه! مثلا اگر بخوایم میانگین سه عدد رو حساب کنیم و کد زیر رو بنویسیم، برنامه بدون مشکل خروجی میده، اما خروجی غلطه.
```csharp
public double CalculateAverage(int a, int b, int c)
{
    return a + b + c / 3;
}
```
دلیل؟ اولویت عملگرها. فقط c بر 3 تقسیم می‌شود، نه مجموع a + b + c.
کد درست به این صورت است:
```csharp
public double CalculateAverage(int a, int b, int c)
{
    return (a + b + c) / 3.0;
}
```
برای جلوگیری از این خطاها، بهترین راه نوشتن Unit Test هست.

---

### مدیریت خطا (Exception Handling) در C# چطوریه؟ {#exceptions}

{{< primary_quote >}}
با استفاده از try-catch-finally.

- try: جاییه که ممکنه خطا پیش بیاد
- catch: وقتی خطا پیش اومد، اینجا مشخص می‌کنی چکار کنه
- finally: همیشه اجرا می‌شه، چه خطا بیاد چه نیاد
{{< /primary_quote >}}

هر برنامه‌ای ممکنه تو شرایط خاص با خطا مواجه بشه. مثلاً:
حافظه کم بیاد، که میشه `OutOfMemoryException`.
لیست خالی باشه و بخوای ازش عضو بگیری، که میشه `ArgumentOutOfRangeException`.

همه‌ی Exceptionها در C# از کلاس پایه‌ی `Exception` ارث می‌برن.

```csharp
try {
    // کدی که ممکنه خطا بده
}
catch (Exception ex) {
    // واکنش به خطا
}
finally {
    // همیشه اجرا می‌شه
}
```

- می‌تونی چندتا catch بذاری و نوع خطا رو مشخص کنی (مثلاً اول NullReferenceException بعد Exception کلی‌تر)
- توی finally بهتره کارهایی مثل بستن connection انجام بدی چون مطمئنی اجرا می‌شه

{{< secondary_quote >}}
آیا می‌شه چند catch بعد از یک try داشت؟  
آره، ولی از خاص به عام بچین
{{< /secondary_quote >}}

{{< secondary_quote >}}
چطوری مطمئن شی یه کد همیشه اجرا بشه؟  
بذارش تو `finally`
{{< /secondary_quote >}}

---

### انواع دسترسی‌ها (Access Modifiers) در C# چیا هستن؟ {#access-modifiers-c}

{{< primary_quote >}}
شش نوع دسترسی داریم، `public`، `internal`، `protected`، `protected internal`، `private protected`، `private`.
{{< /primary_quote >}}

Access Modifier یعنی اینکه کی می‌تونه به یه کلاس یا متد یا فیلد دسترسی داشته باشه.

از بازترین تا بسته‌ترین حالت:

- **public**: همه جا، از هر اسمبلی‌ای
- **internal**: فقط تو همون اسمبلی
- **protected**: فقط خود کلاس و کلاس‌های فرزندش
- **protected internal**: اگه تو همون اسمبلی باشه، همه می‌تونن استفاده کنن، اگه بیرون باشه، فقط فرزندها می‌تونن
- **private protected**: فقط تو همون اسمبلی و فقط تو کلاس‌های فرزند
- **private**: فقط تو همون کلاس

---

### کاربرد sealed در C# چیه؟ {#sealed-c}

{{< primary_quote >}}
`sealed` یعنی این کلاس یا متد قابل ارث‌بری یا override نیست.
{{< /primary_quote >}}

دو کاربرد اصلی داره:

1. جلوگیری از ارث‌بری از یک کلاس
مثلا اگه یه کلاس `sealed` باشه، هیچ کلاسی نمی‌تونه ازش ارث ببره.

```csharp
sealed class A {
	
}
```

2. جلوگیری از override شدن متدهای override شده
فقط متدهایی که override شدن رو می‌شه sealed کرد.

```csharp
class A {
    public virtual void X() {}
}

class B : A {
    public sealed override void X() {}
}
```

---

### کاربرد params در C# چیه؟ {#params-c}

{{< primary_quote >}}
کلمه‌ی کلیدی `params` باعث می‌شه بتونی یه تعداد نامشخص از آرگومان‌ها رو به یه متد پاس بدی، ولی همشون باید از یه نوع باشن.
{{< /primary_quote >}}

مثلا:
```csharp
public int Sum(params int[] numbers) {
    return numbers.Sum();
}
```

حالا می‌تونی این متد رو اینجوری صدا بزنی:

```csharp
Sum(1, 2);
Sum(1, 2, 3);
```

- `params` باید آخرین پارامتر در لیست پارامترها باشه.
- فقط می‌تونه برای آرایه‌ی یک‌بعدی استفاده بشه.

---

ادامه

{{< edit >}}

# منابع {#short-section-5}
[Udemy](https://www.udemy.com/course/csharpnet-50-essential-interview-questions-junior-level/)
[Udemy](https://www.udemy.com/course/csharpnet-50-essential-interview-questions-mid-level/)
[microsoft](https://learn.microsoft.com/en-us/aspnet/core/introduction-to-aspnet-core)
