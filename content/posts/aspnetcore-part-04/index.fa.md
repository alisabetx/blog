---
title: "asp dotnet core (قسمت چهار)"
slug: "aspnet-core-part-04"
date: 2023-01-01T14:00:00+03:30
lastmod: 2023-01-01T14:00:00+03:30
tags: ["asp.net core"]
author: "علی ثابت"
draft: true
comments: true
ShowToc: true
description: "آموزش مفاهیم اولیه‌ی asp dotnet core"
---
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{{< edit/edit >}}
آشنایی با DIP (Dependency Inversion Principle) و IoC (Inversion of Control) و DI (Dependency Injection) و IoC Container
# اصول طراحی و الگوی طراحی
قبل از شروع باید با دو مفهوم اصول طراحی و الگو طراحی آشنا بشیم.
## اصول طراحی (Design Principle)
اصول طراحی، اصول و نقشه راه سطح بالاییه که برای طراحی بهتر نرم‌افزار پیشنهاد می‌شه و راهکاری برای پیاده سازی پیشنهاد نمی‌ده، بلکه مدل هایی مفهومی و قوانینی رو برای طراحی بهتر پیشنهاد می کنه، مثل  SOLID.
## الگو های طراحی (Design Pattern)
الگوهای طراحی، راهکار های سطح پایینی هستند که به طور مشخص راهکار و نحوه‌ی پیاده‌سازی با استفاده از زبان های برنامه نویسی مختلف رو ارائه می کنند. به زبان ساده، راه حل های عملی و قابل پیاده سازی برای طراحی بهتر هستند که بر پایه‌ی اصول طراحی (Design Principles) پیاده‌سازی شده‌اند، مثل Singleton. الگوهای طراحی در واقع reusable solution for a common problem هستند.
# Service
سرویس (Service) قسمتی از برنامه است که منطق بیزنس رو در خودش داره، مثلا محاسبات و اعتبارسنجی‌ها.
سرویس یک لایه‌ی انتزاعی یا میانی (abstraction/middle layer) بین لایه‌ی نمایش (presentation/application layer) و لایه‌ی داده (data layer) است که باعث جدا شدن منطق بیزنس از نمایش و داده می‌شه (و این چیز خوبیه!). Service، توسط Controller فراخوانی می‌شه. مثلا قصد داریم فقط به افرادی که در زمان ثبت نام، بالای 18 سال سن دارند اجازه‌ی ثبت نام بدیم. کاربر فرمِ پرشده رو ثبت می‌کنه و به کنترلر میفرسته. به جای اینکه بررسیِ مجاز بودنِ سنِ کاربر رو در کنترلر انجام بدیم، در لایه‌ی سرویس پیاده‌اش می‌کنیم و نتیحه رو به کنترلر میفرستیم.
![sevices-and-controllers](./images/sevices-and-controllers.png#center)
Serviceها رو میشه درون web application فعلی یا در یک Class Library جدا بذاریم (ساخت New Project و انتخاب پروژه از نوعِ Class Library). انتخاب دوم معمولا بهتره، چون امکان استفاده و تست کردن بدون وابستگی به اجزای دیگر برنامه رو فراهم می‌کنه.
# Direct Dependency
فرض کنید سرویسی داریم که لیستی از شهرها رو بنا به منطقی (که الان برامون مهم نیست) برمی‌گردونه. قراره از این سرویس در کنترلر استفاده کنیم. ساختار پروژه، بدون در نظر گرفتن قسمت‌هایی که باهاشون کاری نداریم، به این صورت است:
```md
├─ App
│  ├─ Controllers
│  │  └─ HomeController.cs
└─ Services
   └─ CitiesService.cs
```

```cs
public class CitiesService
{
    private List<string> _cities;

    public CitiesService()
    {
        _cities = new List<string>() { 
        "London",
        "Paris",
        "New York",
        "Tokyo",
        "Rome"
        };
    }

    public List<string> GetCities()
    {
        return _cities;
    }
}
```

```cs
public class HomeController : Controller
{
    private readonly CitiesService _citiesService;

    public HomeController()
    {
        _citiesService = new CitiesService();
    }

    [Route("/")]
    public IActionResult Index()
    {
        List<string> cities = _citiesService.GetCities();
        return View(cities);
    }
}
```
در این حالت نیاز داریم پروژه Services (از نوع class library) رو وارد پروژه App (از نوع web app) کنیم، چون قراره ازش استفاده بشه. باید referenceای از پروژه Services رو در App داشته باشیم. روی پروژه‌ی مقصد (App) کلیک راست می‌کنیم، ابتدا Add و سپس Project Reference رو انتخاب می‌کنیم. تیک گزینه‌ی Services رو می‌زنیم. در انتها، در HomeController، باید `using Services` رو اضافه کنیم.
تا الان، service از controller جدا شده و در controller، به منطقی که قراره لیست شهرها رو به ما بده کاری نداریم، فقط به service درخواست می‌دیم که لیست شهرها رو بده. کاری که در کد بالا انجام دادیم، Direct Dependency بود. در این حالت ماژول‌های سطح بالا (higher-level modules) که بهشون client هم می‌گیم، به ماژول‌های سطح پایین (low-level modules) که بهشون (dependency) هم می‌گیم، وابسته شده‌اند.
![direct-dependency](./images/direct-dependency.png#center)
این کار چه مشکلاتی ایجاد می‌کنه؟
* ماژول‌های سطح بالا و ماژول‌های سطح پایین tightly-coupled (محکم جفت!) شده‌اند
* توسعه‌دهندگان ماژول‌های سطح بالا (مثل Controller) باید منتظر بمونن تا فرایندِ توسعه‌ی ماژول‌های سطح پایین (مثل Service) تموم بشه تا بتونن کارشون رو شروع کنن
* اگر ماژول سطح پایین به هر دلیلی تغییر کند، عملا ماژول‌های سطح بالا هم باید تغییر کنند
* فرایند تست، ایزوله نخواهد بود و امکان تست یک ماژول بدون تاثیر گذاشتن و تاثیر گرفتن از ماژول‌های دیگر فراهم نیست
# اصلِ Dependency Inversion
مشکل‌سازترین قسمت برنامه‌ی بالا، سازنده (Constructor)ِ HomeController است. چرا؟ چون ما رو به پیاده‌سازی کلاس `CitiesService` وابسته کرده و اگر اون رو قبلا پیاده‌سازی نکرده باشیم، امکان استفاده از متدهاش رو نداریم. عملا Controller، به Service وابسته شده و همیشه معطل‌ش می‌مونه. از طرفی اگر قرار باشه در آینده به دلیل نیازی که به وجود میاد، از `CitiesService2` استفاده کنم، باید در تمام برنامه، اون رو جایگزین `CitiesService` کنم، کاری زمان‌بر و با احتمال خطای بالا. در نظر بگیرید که ممکنه ده‌ها Controller داشته باشید.
برای حل این مشکل، باید Dependency Inversion Principle رو رعایت کنیم.
Dependency Inversion Principle (DIP) یک اصل طراحیه (که فارغ از زبان و فریم‌ورک و بدون اینکه نحوه‌ی پیاده‌سازی‌اش رو مشخص کنه)، مشکل Dependency رو حل می‌کنه. پیاده‌سازی‌اش میشه Inversion of Control (IoC).

**اصل Dependency Inversion چی میگه؟**
* ماژول‌های سطح بالا (higher-level modules/client) نباید به ماژول‌های سطح پایین (low-level modules/dependency) وابسته باشند، هر دو باید به انتزاع (interfaces/abstract class) وابسته باشند
* انتزاع‌ها نباید وابسته به جزئیات (client و dependency) باشند، جزئیات (client و dependency) باید وابسته به انتزاع‌ها باشند
![dependency-inversion-principle](./images/dependency-inversion-principle-(DIP).png#center)
خب یعنی چی؟! ابتدا ببینیم با اعمال DIP چه تغییری در برنامه رخ میده.
```md
├─ App
│  ├─ Controllers
│  │  └─ HomeController.cs
├─ ServiceContracts
│  │  └─ ICitiesService.cs
└─ Services
   └─ CitiesService.cs
```

```cs
public interface ICitiesService
{
  List<string> GetCities();
}
```

```cs
public class CitiesService : ICitiesService
{
    private List<string> _cities;

    public CitiesService()
    {
        _cities = new List<string>() { 
        "London",
        "Paris",
        "New York",
        "Tokyo",
        "Rome"
        };
    }

    public List<string> GetCities()
    {
        return _cities;
    }
}
```

```cs
public class HomeController : Controller
{
    private readonly ICitiesService _citiesService;

    public HomeController()
    {
        _citiesService = null;
    }

    [Route("/")]
    public IActionResult Index()
    {
        List<string> cities = _citiesService.GetCities();
        return View(cities);
    }
}
```

```cs
// Program.cs
builder.Services.Add(new ServiceDescriptor(
  typeof(ICitiesService),
  typeof(CitiesService),
  ServiceLifetime.Transient
));
```
ابتدا باید در پروژه Services به ServiceContracts ارجاع (reference) بدیم.

در `ICitiesService` گفتیم که متدی به نام `GetCities` داریم که `List<string>` برمی‌گردونه و پارامتری نداره. به پیاده‌سازی‌اش کار نداریم، اینکه از چه دیتابیسی می‌خونه، با چه فایل‌هایی کار می‌کنه و با چه performanceای این کار رو انجام میده، از دیدِ منِ client مهم نیست، فقط باید متدی به نام `GetCities` باشه که `List<string>` برمی‌گردونه و در این مورد خاص، پارامتری نداره.

در `HomeController` به جای `CitiesService` از `ICitiesService` استفاده کرده‌ایم. اما چطور در `constructor` شی بسازیم؟ DIP پاسخی برای این مسئله نداره و باید از Dependency Injection استفاده کنیم، فعلا `null` گذاشته‌ایم. IoC وظیفه‌ی ساخت object رو بر عهده داره، وظیفه‌ی اضافه کردن اون object به reference variable، بر عهده‌ی DI است.

از دیدِ توسعه‌دهنده‌ای که مشغولِ کار روی Controllerهاست، جزئیاتِ کار ماژول‌های سطح پایین پنهان شده و این اتفاق خوبیه. یک ماژول سطح بالا به جای وابستگی به ماژول سطح پایین، به انتزاع (interface) وابسته شده.
از طرف دیگر، برای توسعه‌دهنده‌ای که مشغولِ کار روی Serviceهاست، اهمیتی نداره که CitiesService کجاها استفاده شده و قراره بشه، اون وظیفه داره که CitiesServiceای رو پیاده‌سازی کنه که قراره ICitiesService رو پیاده‌سازی کنه، یعنی چی؟ یعنی ICitiesService بهش میگه که من متد پیاده‌نشده‌ای به نام `GetCities` دارم که پارامتر نداره و خروجی‌اش `List<string>` است. تو (CitiesService) بیا و پیاده‌سازی‌اش رو انجام بده.
# Inversion of Control (IoC)
Inversion of Control (IoC) یک الگوی طراحیه که IoC container رو برای پیاده‌سازیِ Dependency Inversion Principle (DIP) پیشنهاد می‌ده. با انتقال کنترل به IoC container، اون رو معکوس می‌کنه (توضیح داده خواهد شد!). الگوی "Don't call us, we will call you" رو پیاده می‌کنه. می‌تونه به وسیله‌ی الگوهای طراحی دیگری مثل events و service locator و... هم پیاده‌سازی بشه.
![ioc](./images/ioc.png#center)
همه‌ی dependencyها باید در IServiceCollection تعریف بشن (روش بهتری برای معرفی وجود داره که بعدا معرفی خواهد شد).
```cs
builder.Services.Add(
  new ServiceDescriptor(
    typeof (Interface),
    typeof (Service)
    ServiceLifetime.LifeTime
  )
);
```
# Dependency Injection (DI)
Dependency injection (DI) یک الگوی طراحیه. الگویی که در واقع تکنیکی برای به دست آوردن Inversion of Control (IoC) بین clientها و dependencyهاشونه. DI  کمک می‌کنه که یک پیاده‌سازی از کامپوننت سطح پایین رو به کامپوننت سطح بالا تزریق (inject) کنیم. کلاس client، شیِ dependency رو به عنوان پارامتر در constructor یا method دریافت می‌کنه.
![di](./images/di.png#center)
# منابع
[udemy](https://www.udemy.com/course/asp-net-core-true-ultimate-guide-real-project/)
[microsoft](https://learn.microsoft.com/en-us/aspnet/core/introduction-to-aspnet-core)
https://virgool.io/@m_75524684