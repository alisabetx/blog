---
title: "asp dotnet core (قسمت پنج)"
slug: "aspnet-core-part-05"
date: 2025-06-19T14:00:00+03:30
lastmod: 2025-05-24T14:00:00+03:30
tags: ["asp.net core", "dotnet", "c#", "asp.net", "asp.net core", "دات نت"]
description: "مفاهیم اولیه‌ی asp dotnet core"
draft: true
---

اصول سالید (SOLID)، وابسته به زبان و فریمورک خاصی نیستند و در همه زبان‌های برنامه‌نویسی قابل پیاده‌سازی‌اند. هدف اصلی آن‌ها، داشتن کدهایی با کمترین وابستگی بین ماژول‌ها (کلاس‌ها، متدها، سرویس‌ها و...)، منعطف و قابل نگهداری است.

1. اصل **Single Responsibility Principle (SRP)**
هر کلاس یا ماژول نرم‌افزاری باید فقط یک دلیل برای تغییر داشته باشه؛ یعنی فقط یک وظیفه‌ی مشخص داشته باشه و فقط یک کار انجام بده.

![SRP](./images/SRP.png#center)

مثلاً ممکن است بخواهیم یک سیستم پرداخت پیاده‌سازی کنیم؛

```csharp
public class PaymentService
{
    public void Pay()
    {
        // پردازش پرداخت
    }

    public void LogToFile(string message)
    {
        // لاگ زدن
    }

    public void SendEmail(string email)
    {
        // ارسال ایمیل به کاربر
    }
}
```

اینجا کلاس `PaymentService` هم پرداخت می‌کند، هم لاگ می‌گیرد، هم ایمیل می‌فرستد؛ این یعنی نقض SRP.

برای رعایت اصل SRP، کد را به این شکل تغییر می‌دهیم:

```csharp
public class PaymentService
{
    public void Pay() { ... }
}

public class FileLogger
{
    public void Log(string message) { ... }
}

public class EmailNotifier
{
    public void Send(string email) { ... }
}
```

2. اصل **Open/Closed Principle (OCP)**
کلاس‌ها باید برای توسعه باز و برای تغییر بسته باشند.
یعنی وقتی نیاز دارید رفتار یک کلاس رو تغییر بدید، نباید داخل همان کلاس دست بزنید! به‌جای آن، رفتار جدید رو با یک کلاس جدید یا با ارث‌بری/تزریق بنویسید.

**چرا این کار خوب است؟**
کدهای قبلی را دست نمی‌زنید، باگ جدید ایجاد نمی‌کنید، تست‌های قبلی همچنان معتبر می‌مانند و نیازی به تغییر ندارند.

مثلا کدی داریم که لیست افراد رو بدون ترتیب خاصی برمیگردونه:

```csharp
public class PersonService
{
    public List<Person> GetPersons()
    {
        return _dbContext.Persons.ToList();
    }
}
```

حالا نیاز جدیدی مطرح شده است: اینکه لیست افراد را به ترتیب حروف الفبا بگیریم.

بدون رعایت OCP، در همان کد قبلی دست می‌بریم و تغییرش می‌دهیم؛

```csharp
public class PersonService
{
    public List<Person> GetPersons()
    {
        return _dbContext.Persons.OrderBy(p => p.Name).ToList();
    }
}
```

این باعث می‌شود عملکرد برنامه در همه جا تغییر کند، حتی جاهایی که نیاز نبود!

برای رعایت OCP دو روش داریم؛ هر دو روش باعث می‌شوند بتوانید کد را گسترش دهید بدون اینکه کد قبلی را تغییر دهید.

- **اینترفیس ها (Interfaces)**
ایجاد پیاده‌سازی‌های مختلف با استفاده از یک اینترفیس مشترک

```csharp
public interface IPersonService
{
    List<Person> GetPersons();
}
```

```csharp
public class DefaultPersonService : IPersonService
{
    public List<Person> GetPersons()
    {
        return _dbContext.Persons.ToList();
    }
}
```

```csharp
public class SortedPersonService : IPersonService
{
    public List<Person> GetPersons()
    {
        return _dbContext.Persons.OrderBy(p => p.Name).ToList();
    }
}
```

حالا می‌توانید با DI تصمیم بگیرید کدام نسخه اجرا شود و نیازی به دست زدن به DefaultPersonService ندارید.

- **ارث بری (Inheritance)**
ایجاد یک کلاس فرزند و override کردن فقط همون متدهایی که نیاز به تغییر دارن.
```csharp
public class PersonService
{
    public virtual List<Person> GetPersons()
    {
        return _dbContext.Persons.ToList();
    }
}
```

متد مورد نظر در کلاسِ پدر، به صورت `virtual` تعریف میشه.

```csharp
public class SortedPersonService : PersonService
{
    public override List<Person> GetPersons()
    {
        return _dbContext.Persons.OrderBy(p => p.Name).ToList();
    }
}
```

متد مورد نظر در کلاسِ فرزند، با `override` بازنویسی میشه.

3. اصل **Liskov Substitution Principle (LSP)**

کلاس‌های فرزند باید بتوانند بدون دردسر جای کلاس پدر استفاده شوند، بدون اینکه منطق برنامه به هم بریزد.  
یعنی اگر یک متد در برنامه با `ParentClass` کار می‌کند، باید بتوانید خیلی راحت یک شیء از `ChildClass` را جایگزین آن کنید و همه‌چیز درست کار کند، انگار نه انگار چیزی عوض شده.

این فقط مخصوص ارث‌بری نیست، در اینترفیس‌ها هم صدق می‌کند.  
اگر یک interface یا کلاس پایه ساختید، کلاس‌هایی که از آن استفاده می‌کنند **نباید قانون جدید بگذارند، محدودیت اضافه کنند یا رفتار عجیب و غریب نشان دهند**.  
چون آن‌وقت کدی که با نسخه‌ی اصلی درست کار می‌کرد، ممکن است با این یکی خراب شود، که یعنی نقض اصل Liskov.

مثلاً اپلیکیشنی داریم که باید بعد از ثبت‌نام برای کاربر پیام خوش‌آمدگویی بفرستد. پیاده‌سازی فعلی به این صورت است:

```csharp
public interface INotifier
{
    void Notify(string message);
}
```

```csharp
public class EmailNotifier : INotifier
{
    public void Notify(string message)
    {
        Console.WriteLine($"📧 ایمیل ارسال شد: {message}");
    }
}
```

```csharp
public class SmsNotifier : INotifier
{
    public void Notify(string message)
    {
        Console.WriteLine($"📩 پیامک ارسال شد: {message}");
    }
}
```

```csharp
public void SendWelcomeMessage(INotifier notifier)
{
    notifier.Notify("خوش اومدی به اپ ما!");
}
```

تا اینجا همه چیز عالبه. اما فرض کنیم چنین متدی داریم:

```csharp
public class PushNotifier : INotifier
{
    public void Notify(string message)
    {
        if (message.Length > 50)
            throw new ArgumentException("پیام برای نوتیف باید زیر ۵۰ کاراکتر باشه!");
        
        Console.WriteLine("📲 نوتیفیکیشن فرستاده شد");
    }
}
```

در واقع چون پیامک، محدودیت کاراکتر داره، مجبور شدیم قانونی در `PushNotifier` براش بذاریم. فکر می‌کردیم INotifier هر پیامی رو می‌تونه بفرسته. ولی الان با `PushNotifier`، برنامه ممکنه کرش کنه.

برای حل این مسئله، PushNotifier اصلاً نباید از همون interface استفاده کنه و باید یه interface جدا داشته باشه:

```csharp
public interface IShortMessageNotifier
{
    void NotifyShort(string shortMessage);
}
```

اگه یه کلاس خاص باعث میشه که مجبور شی کدت رو براش اختصاصی کنی، شرط براش بزاری، یا تو استفاده ازش خطا بگیری، یعنی اون کلاس **رفتار متفاوتی داره و نباید زیرمجموعه interface پدرش باشه**.

4. اصل **Interface Segregation Principle (ISP)**
هیچ کلاسی نباید مجبور باشه متدهایی رو پیاده‌سازی کنه که ازشون استفاده نمی‌کنه. یعنی به‌جای اینکه یه اینترفیس بزرگ و سنگین بسازی، چندتا اینترفیس کوچیک و تخصصی بساز.

![ISP](./images/ISP.png#center)

مثلا قراره یه بازی طراحی کنیم و شخصیت‌های بازی قابلیت‌های مختلفی دارن:
- بعضیا فقط می‌دون
- بعضیا فقط پرواز می‌کنن
- بعضیا فقط شنا می‌کنن
- بعضیا همه‌شو بلدن

بدون در نظر گرفتن اصل ISP، چنین پیاده سازی ای خواهیم داشت:

```csharp
public interface IGameCharacter
{
    void Run();
    void Fly();
    void Swim();
}
```

حالا فرض کن یه سگ تو بازی داری، که فقط می‌دوه!

```csharp
public class Dog : IGameCharacter
{
    public void Run()
    {
        Console.WriteLine("سگ داره می‌دوه!");
    }

    public void Fly()
    {
        throw new NotImplementedException(); // سگ مگه می‌پره؟ 🙄
    }

    public void Swim()
    {
        throw new NotImplementedException(); // سگ مگه شنا میکنه؟ 🙄
    }
}
```

اینجا سگ داره متدهایی رو پیاده می‌کنه که بهش ربطی نداره، این یعنی نقض ISP.

با رعایت ISP، کد به این صورت تغییر خواهد کرد:

```csharp
public interface IRunner
{
    void Run();
}

public interface IFlyer
{
    void Fly();
}

public interface ISwimmer
{
    void Swim();
}
```

```csharp
public class Dog : IRunner
{
    public void Run()
    {
        Console.WriteLine("سگ می‌دوه!");
    }
}

public class Fish : ISwimmer
{
    public void Swim()
    {
        Console.WriteLine("ماهی داره شنا می‌کنه!");
    }
}

public class Superman : IRunner, IFlyer, ISwimmer
{
    public void Run() => Console.WriteLine("سوپرمن داره می‌دوه!");
    public void Fly() => Console.WriteLine("سوپرمن داره می‌پره!");
    public void Swim() => Console.WriteLine("سوپرمن تو آب هم می‌ره!");
}
```

اینترفیس ها تخصصی شدن، حالا هر کاراکتری بنا به نیازش، اینترفیس مربوط به خودش رو پیاده میکنه، سوپرمن که میتونه همه کارهارو انجام بده، همه اینترفیس ها رو پیاده میکنه!

- سگ فقط می‌دوه، نه چیزی بیشتر!
- ماهی فقط شنا می‌کنه، نه چیز دیگه!
- سوپرمن همه‌کاره‌ست!

هیچ کسی مجبور نیست کاری کنه که بلد نیست، و این یعنی رعایت کامل Interface Segregation.

5. اصل **Dependency Inversion Principle (DIP)**
ماژول‌های سطح بالا نباید به ماژول‌های سطح پایین وابسته باشن؛ هر دو باید به Abstraction (انتزاع) وابسته باشن، نه به جزئیات.
این سناریوی ساده رو در نظر بگیریم؛ در اینجا Controller یک Client است و Service یک Dependency است.
```csharp
public class MyController : Controller
{
  private readonly MyService _service;
  public MyController()
  {
    _service = new MyService(); // Direct
  }
  public IActionResult ActionMethod()
  {
    _service.ServiceMethod();
  }
}
```
```csharp
public class MyService
{
  public void ServiceMethod()
  {
    // Do something
  }
}
```
در اینجا، `MyController` به شکل مستقیم وابسته به `MyService` شده. چه مشکلاتی داره؟

- یه ماژول سطح بالا (MyController) به یک ماژول سطح پایین (MyService) وابسته شده و وابستگی‌شون tightly-coupled است، یعنی شدید و مستقیم.
- توسعه‌دهنده‌ی ماژول سطح بالا (MyController) باید صبر کنه تا ماژول سطح پایین (MyService) کامل بشه.
- اگه بخوایم یه ماژول سطح پایین (MyService) رو با یه ماژول جدید (MyService2) جایگزین کنیم، باید کد زیادی رو تغییر بدیم.
- هر تغییری در ماژول سطح پایین (MyService)، باعث میشه ماژول سطح بالا (MyController) هم تغییر کنه.

راه حل؟ استفاده از **اصل Dependency Inversion**
به‌جای اینکه ماژول سطح بالا مستقیماً به ماژول سطح پایین وابسته باشه، هر دو باید به یک Abstraction (مثل یک Interface یا Contract) وابسته باشن. اینطوری وابستگی‌ها از "کلاس‌ها" به "قراردادها" منتقل میشه و انعطاف‌پذیری سیستم میره بالا.

سناریوی واقعی؛ در یک تیم برنامه نویسی، یک نفر مسئول پیاده سازی ماژولِ سطح پایین پرداخت (Payment) و یک نفر مسئول پیاده سازی ماژول سطح بالا (Order) است.

روش نادرست و بدون اصل DI به این صورته:
```csharp
public class OrderService
{
    private readonly MellatPaymentService _paymentService;

    public OrderService()
    {
        _paymentService = new MellatPaymentService();
    }

    public void Pay()
    {
        _paymentService.Pay();
    }
}
```
حالا اگر بخواهیم به جای درگاه بانک ملت، از سامان استفاده کنیم چه؟
پیاده سازی این کد با رعایت اصل DI به این صورته:
```csharp
public interface IPaymentService
{
    void Pay();
}
```

```csharp
public class MellatPaymentService : IPaymentService
{
    public void Pay()
    {
        Console.WriteLine("پرداخت با ملت");
    }
}
```

```csharp
public class OrderService
{
    private readonly IPaymentService _paymentService;

    public OrderService(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    public void Pay()
    {
        _paymentService.Pay();
    }
}
```

اینجا در ماژول سطح بالا (OrderService) دیگه مستقیما با ماژول سطح پایین (MellatPaymentService) کار نمیکنیم، بلکه با اینترفیس IPaymentService کار میکنیم. برای OrderService مهم نیست که سرویس پرداخت چجوری داره پرداخت رو هندل میکنه (ملت، سامان یا هر درگاه دیگری)؛ اون به خودش مربوطه! فقط یه قرار داد مشترک با هم دارن به نام Pay، که میگه این داده ها رو بهت میدم و تو هم بعد از اتمام کار، فلان داده ها رو به من برگردون.

{{< edit/edit >}}

# منابع
[Udemy](https://www.udemy.com/course/asp-net-core-true-ultimate-guide-real-project/)
[microsoft](https://learn.microsoft.com/en-us/aspnet/core/introduction-to-aspnet-core)
