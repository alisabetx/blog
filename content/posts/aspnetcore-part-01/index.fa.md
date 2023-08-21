---
title: "aspnet core (قسمت یک)"
slug: "aspnet-core-part-01"
date: 2023-08-20T14:00:00+03:30
lastmod: 2023-08-20T14:00:00+03:30
tags: ["asp.net core"]
author: "علی ثابت"
draft: false
comments: true
description: "مقدمه‌ای از asp.net core و آمادگی برای شروع دوره"
---
سرور
----

اپ‌های داتنت‌کور برای گرفتن درخواست‌ها (request) و ارسال پاسخ (response) به سرور (server) نیاز دارن. سرورِ پیش‌فرض داتنت‌کور، kestrel است که می‌تونه در محیط توسعه (development) و واقعی (production) استفاده بشه، اما معمولا از kestrel به عنوان application server و از reverse proxy serverها مثل iis و nginx در محیط واقعی استفاده می‌کنیم.

{{< figure src="./images/dotnet-core-servers.png" alt="dotnet core servers" >}}

در حالتی که فقط kestrel رو داشته باشیم، http requestها از شبکه محلی (local network) یا اینترنت به kestrel میرسن و اون هم درخواست‌ها رو به شکل آبجکت‌های httpcontext به application ارسال می‌کنه. application پردازش‌های لازم رو انجام میده و جواب رو به kestrel میده تا اون، جواب رو به client برسونه. یک مسیرِ رفت و برگشتی.

اما kestrel هنوز خیلی از قابلیت‌های مورد نیازِ این روزهای وب رو نداره، بنابراین لازمه از reverse proxy serverهایی مثل iis و nginx و... استفاده بشه تا امکاناتی مثل load balancing و url rewriting و caching و خیلی قابلیت‌های دیگه رو در اختیار ما بذارن. بنابراین در محیط واقعی، یک ایستگاه قبل از kestrel اضافه میشه. اما برای محیط توسعه چطور؟ برای شبیه‌سازی قابلیت‌های reverse proxy serverها در محیط توسعه، می‌تونیم از iis express استفاده کنیم که عملکرد iis رو شبیه‌سازی می‌کنه.

kestrel در حالت پیش‌فرض فعاله و اگر برنامه اجرا میشه و یک url باز میشه، یعنی داره درست کار میکنه. اما iis express چطور؟ لازمه که وارد فایل launchsettings.json (در فولدر properties) بشیم. فایل launchsettings.json یک فایل با [فرمت json](https://en.wikipedia.org/wiki/JSON) است که کانفیک‌های پروژه در اون قرار داره. profileها مجموعه‌ای از تنظیمات هستن که به یک سرور خاص اجازه میدن که برنامه‌مون رو اجرا کنه. مثلا اگه نام برنامه FirstApp باشه، دو پروفایل با نام‌های FirstApp (که میشه تغییرش داد) و IIS Express خواهیم داشت. commandName، سروری که قراره برنامه روش اجرا بشه رو مشخص می‌کنه، مقدار Project به معنیِ استفاده از کسترل است. هنگام اجرای برنامه میشه انتخاب کرد که با کدوم پروفایل اجرا بشه. پروفایل پیش‌فرض، FirstApp است که kestrel رو برای اجرا انتخاب می‌کنه و ما هم با همین پروفایل پیش می‌ریم.

* * *

http
----

حضور ما در وب، به کمک http امکان‌پذیر شده. [http](https://en.wikipedia.org/wiki/HTTP)، مجموعه قوانینیه که برای ارسال درخواست از client به server و از server به client طراحی شده. به عنوان توسعه‌دهنده‌ی وب نیازی به جزئیات کارکردش نداریم ولی لازمه کاربردهاش رو بلد باشیم. https هم همون http است که لایه امنیت (security) بهش اضافه شده.

{{< figure src="./images/http.png" alt="http" >}}

درخواست‌ها (request) رو میشه در مرورگر دید. کافیه در صفحه‌ای که هستیم کلیک راست کنیم، inspect رو انتخاب کنیم، به تب network بریم و با زدن کلید F5 صفحه رو رفرش کنیم. هر http response شامل بخش‌های Start Line و Response Headers و Response Body است. Start Line شامل مواردی مثل http version و status code است. یکی از status codeهای معروف 404 (به معنای پیدا نشدن چیزی که دنبالش بودیم) است. [لیست همه‌ی http status codeها اینجاست](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status). Response Header شامل اطلاعاتی مثل date و server و... است که [لیست کامل اون‌ها اینجاست](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers).

* * *

middleware
----------

middlewareها، اجزایی هستند که در مسیر (pipeline) برنامه قرار می‌گیرند تا به درخواست‌ها و پاسخ‌ها رسیدگی کنند. هر middleware، باید یک کار انجام بده (اصل S از اصول SOLID). middlewareها به شکل زنجیره‌ای، یکی پس از دیگری و به همون ترتیبی که در برنامه تعریف شده، اجرا میشن. ممکنه در مسیر برنامه، چند middleware داشته باشیم. هر کدوم از اون‌ها، یا از نوع non-terminating هستن و request رو به middleware بعدی پاس میدن یا از نوع terminating هستن و request رو به middleware بعدی پاس نمیدن.

{{< figure src="./images/middlewares-chain.png" alt="middlewares chain" >}}

### استفاده از middleware

middlewareها رو به دو روش میشه ساخت، نوشتن به صورت request delegate (استفاده از lambda expressionها (برای کارهای ساده)) یا نوشتن class (برای کارهای پیچیده). برای تعریف middlewareهای نوعِ non-terminating از متد Use و برای تعریف middleware نوعِ terminating از متد Run استفاده می‌کنیم. پارامتر context که در هر دو متد وجود داره، اطلاعات request رو در خودش داره. پارامتر next در واقع delegate بعدی در مسیر رو معرفی می‌کنه (اگر next رو در بدنه‌ی middleware صدا نزنیم، عملا اون رو به middleware نوعِ terminating تبدیل کرده‌ایم).

```csharp
app.Use(async (HttpContext context, RequestDelegate next) {
  //before logic 
  await next(context);
  //after logic
});
```

```csharp
app.Run(async (Httpcontext context) => {
  //code
});
```

middlewareها به شکل زنجیره‌ای و یکی پس از دیگری و به صورت رفت و برگشتی کار می‌کنند. به همین دلیل در تصویر بالا before logic و after logic داریم. در مسیرِ رفت (از client به server)، before logic اجرا میشه و در مسیرِ برگشت (از server به client)، after logic اجرا میشه. این موضوع در کد زیر و خروجی اون قابل مشاهده‌ست.

```csharp
app.Use(async(context, next) =>
{
  await context.Response.WriteAsync("Hello first middleware\r\n");
  await next(context);
  await context.Response.WriteAsync("Bye first middleware\r\n");
});

app.Use(async(context, next) =>
{
  await context.Response.WriteAsync("Hello second middleware\r\n");
  await next(context);
  await context.Response.WriteAsync("Bye second middleware\r\n");
});

app.Run(async context =>
{
  await context.Response.WriteAsync("Hello third middleware\r\n");
  await context.Response.WriteAsync("Hello run\r\n");
  await context.Response.WriteAsync("Bye run\r\n");
});
```

```text
Hello first middleware
Hello second middleware
Hello third middleware
Hello run
Bye run
Bye second middleware
Bye first middleware 
```

علاوه بر متد Use که برای میدلورهای نوعِ non-terminating و متد Run که برای میدلورهای terminating استفاده می‌شه، متدهای دیگری هم داریم. متدی به نام UseWhen وجود داره که حالت شرطی داره، یعنی شرایطی رو بررسی می‌کنه و اگر اون شرایط برقرار بود، شاخه جدیدی در pipeline ایجاد می‌کنه و البته دوباره به pipeline برمی‌گرده.

![Middleware UseWhen](https://alirsabet.com/wp-content/uploads/2023/08/Middleware-UseWhen-1024x470.png)

{{< figure src="./images/YYYYYYYYYYYYYYYYYYY.png" alt="XXXXXXXXXXXXXXXXXXX" >}}

### ![Middleware UseWhen code](https://alirsabet.com/wp-content/uploads/2023/08/Middleware-UseWhen-code-300x132.png)

{{< figure src="./images/YYYYYYYYYYYYYYYYYYY.png" alt="XXXXXXXXXXXXXXXXXXX" >}}

### ساخت middleware دلخواه

گاهی نیاز می‌شه middlewareی داشته باشیم که شامل چند دستور مختلفه. در این حالت نوشتن همه‌ی دستورات در فایل Program.cs و به شکل lambda expression، خوانایی کد رو کم می‌کنه. بهتره custom middlewareای بنویسیم که در یک کلاس جدا قرار داره. میدلور دلخواه رو می‌شه به روش‌های convention-based و factory-based ساخت. روش factory-based انعطاف‌پذیری بیشتری داره. در روش convention-based، میدلورها در ابتدای اجرای برنامه ساخته می‌شن، در حالی که در روش factory-based به ازای هر درخواست ساخته می‌شن. ([اطلاعات بیشتر](https://www.infoworld.com/article/3696983/how-to-use-factory-based-middleware-activation-in-aspnet-core.html))

در روش convention-based، کلاس جداگانه‌ای به نام MiddlewareClassName برای middleware می‌نویسیم.

![conventional middleware](https://alirsabet.com/wp-content/uploads/2023/08/conventional-middleware-300x244.png)

![conventional middleware registration](https://alirsabet.com/wp-content/uploads/2023/08/conventional-middleware-registration-300x69.png)

{{< figure src="./images/YYYYYYYYYYYYYYYYYYY.png" alt="XXXXXXXXXXXXXXXXXXX" >}}

{{< figure src="./images/YYYYYYYYYYYYYYYYYYY.png" alt="XXXXXXXXXXXXXXXXXXX" >}}

در روش factory-based، کلاس جداگانه‌ای به نام MyCustomMiddleware برای middleware می‌نویسیم که اینترفیس IMiddleware رو پیاده‌سازی می‌کنه.

![MyCustomMiddleware](https://alirsabet.com/wp-content/uploads/2023/08/MyCustomMiddleware-300x117.png)

![MyCustomMiddleware registration](https://alirsabet.com/wp-content/uploads/2023/08/MyCustomMiddleware-registration-300x93.png)

به کمک قابلیت [extension method](https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/extension-methods)، تعریف یک middleware دلخواه به روش factory-based و معرفیِ اون در Program.cs می‌تونه ساده‌تر انجام بشه.

![MyCustomMiddleware ext](https://alirsabet.com/wp-content/uploads/2023/08/MyCustomMiddleware-ext-300x163.png)

![MyCustomMiddleware ext registration](https://alirsabet.com/wp-content/uploads/2023/08/MyCustomMiddleware-ext-registration-300x93.png)

### ترتیب اجرا

در داتنت‌کور، از قبل میدلورهایی تعریف شده، از طرفی ممکنه در پروژه نیاز به ساخت میدلورهای دلخواه هم داشته باشیم. با توجه به اینکه ترتیبِ اجرای میدلورها اهمیت داره، مایکروسافت ترتیب زیر رو پیشنهاد می‌کنه.

![The Right Order of Middleware schema](https://alirsabet.com/wp-content/uploads/2023/08/The-Right-Order-of-Middleware-1024x560.png)

![order of middlewares](https://alirsabet.com/wp-content/uploads/2023/08/order-of-middlewares-300x197.png)

* * *

routing
-------

به فرایندی که در طیِ اون، HTTP requestsها به endpointهای مربوطه ارتباط داده می‌شن، routing گفته میشه. این کار با بررسی HTTP method و url انجام میشه. مثلا وقتی کاربر آدرس alirsabet.com/home رو وارد کرد، باید بتونیم اون رو به endpoint مربوط به home بفرستیم تا صفحه‌ی موردنظر رو ببینه. زمانی که یک میدلور بر اساس routing اجرا میشه بهش endpoint گفته میشه.

![routing](https://alirsabet.com/wp-content/uploads/2023/08/routing-1024x270.png)

مسیریابی در داتنت‌کور به وسیله‌ی میدلورهای UseRouting و UseEndPoints انجام میشه. UseRouting، یک endpoint متناسب با HTTP method و url رو پیدا می‌کنه و UseEndPoints اون endpoint مناسب که توسط UseRouting پیدا شده رو اجرا می‌کنه.

![use routing use endpoints](https://alirsabet.com/wp-content/uploads/2023/08/use-routing-use-endpoints-300x145.png)

### mapها

Mapها چی هستن؟ قوانینی هستند برای اینکه requestهای دریافتی رو به بخش‌های مختلف برنامه ارتباط بدن. Map برای همه‌ی HTTP methodها کار می‌کنه اما میشه با MapGet فقط به درخواست‌های Get و با MapPost فقط به درخواست‌های Post پاسخ داد. مثلا در این تصویر، Map به همه‌ی درخواست‌هایی که با "path" شروع می‌شن رسیدگی می‌کنه، MapGet به درخواست‌های نوعِ Get که با "path" شروع می‌شن رسیدگی می‌کنه و MapPost به درخواست‌های نوعِ Post که با "path" شروع می‌شن رسیدگی می‌کنه.

![map mapget mappost](https://alirsabet.com/wp-content/uploads/2023/08/map-mapget-mappost-300x239.png)

### متد GetEndpoint

یکی از متدهایی که در context وجود داره، GetEndpoint است که شی‌ای از نوع Microsoft.AspNetCore.Http.Endpoint برمی‌گردونه. وقتی از UseRouting استفاده می‌کنیم، endpointهای متناسب با HTTP method و url رو به برنامه میشناسونیم، پس قبل از UseRouting، برنامه این شناخت رو نخواهد داشت. در کد زیر، endPoint اول null خواهد بود و endPoint دوم، اطلاعات endpoint رو خواهد داشت (چون بعد از UseRouting اومده).

![getendpoints](https://alirsabet.com/wp-content/uploads/2023/08/getendpoints-300x268.png)

### route parameters

آدرس‌هایی که ما رو به محتوای مورد نظرمون می‌رسونن، یک قسمت ثابت و یک قسمت متغیر دارن، مثلا در یک سیستمِ نمایشِ اطلاعاتِ کارمندان، "employee/profile/ali" ما رو به اطلاعات پروفایل علی و "employee/profile/reza" ما رو به اطلاعات رضا می‌رسونه. بخشِ "employee/profile" در هر دو مشترکه. به اون قسمت‌هایی که میتونه تغییر کنه و مقادیر مختلف بگیره، route parameter می‌گن. route parameterها رو داخل {} می‌ذاریم.

![Route Parameters](https://alirsabet.com/wp-content/uploads/2023/08/Route-Parameters-1024x224.png)

![route parameter example](https://alirsabet.com/wp-content/uploads/2023/08/route-parameter-example-300x80.png)

مثلا در کد زیر اگر آدرس وارد شده به صورت "files/sample.txt" باشه، وارد endpoint اول و اگه به صورت "employee/profile/ali" باشه وارد endpoint دوم می‌شیم.

![route parameters](https://alirsabet.com/wp-content/uploads/2023/08/route-parameters-1-300x202.png)

### default/optional value

وقتی الگویی برای url تعریف می‌کنیم، انتظار داریم url وارد شده دقیقا مطابق اون باشه. اما اگر به هر دلیلی مطابق نباشه چی؟ میشه برای پارامترها مقدار پیش‌فرض (default) گذاشت، یعنی اگر مقدار وارد نشده بود، مقدارِ پیش‌فرضِ default\_value رو به جاش بذاره. مثلا در برنامه، لیستی از کالاها با شناسه‌ی 1 تا 100 داریم. قصد داریم منطق برنامه به شکلی باشه که اگر کاربر در url، شناسه‌ی id رو وارد کرد، اطلاعات کالای با شناسه‌ی id رو ببینه، اما اگر شناسه‌ی کالا رو وارد نکرد، اطلاعات کالای با شناسه‌ی 1 رو ببینه.

![routing default parameter](https://alirsabet.com/wp-content/uploads/2023/08/routing-default-parameter-300x145.png)

راهِ دیگرِ هندل کردن این موضوع، استفاده از مقدار اختیاری (optional) است. مثلا قصد داریم پارامتر id اختیاری باشه.

![Optional Route Parameters](https://alirsabet.com/wp-content/uploads/2023/08/Optional-Route-Parameters-300x136.png)

* * *

controllerها
------------

در یک پروژه‌ی واقعی نمیشه همه‌ی actionهایی که نیاز است رو در فایل Program وارد کنیم. Controller، کلاسیه که action methodهای مرتبط به هم رو در اون گروه‌بندی می‌کنیم. زمانی که request میاد، action methodها یک کارِ خاص رو انجام میدن و response رو برمی‌گردونن.

![controllers](https://alirsabet.com/wp-content/uploads/2023/08/controllers-1024x259.png)

کنترلرها معمولا 4 وظیفه اصلی دارن:

*   reading requests: خواندن requestها و استخراج مقادیر از اون‌ها، مثل query string و headers و body و cookie و...
*   validation: اعتبارسنجی requestها
*   invoking models: فراخوانی منطق بیزنس (که بهشون service می‌گیم)
*   preparing response: انتخاب پاسخ (action result) مناسب و ارسال اون به کاربر

کنترلرها به یک یا دو روش زیر شناخته میشن:

*   نامِ کلاس، پسوند Controller داشته باشه، مثلا HomeController
*   ویژگی (attribute) \[Controller\] روی اون یا base classش اعمال بشه

![Creating Controllers](https://alirsabet.com/wp-content/uploads/2023/08/Creating-Controllers-300x106.png)

بهتره کنترلرها رو در فولدر Controllers قرار بدیم، یک کار اختیاری اما خوب اینه که کلاس از نوع public باشه و از Microsoft.AspNetCore.Mvc.Controller ارث‌بری کنه. در کنترلر زیر، اگه requestای از نوع GET به آدرس "/Home/" بیاد (مثلا کاربر در مرورگر آدرس وارد کنه)، وارد متد Index می‌شیم و اگه "/Home/Welcome/" رو وارد کنه، وارد متد Welcome می‌شیم.

![Sample Controller](https://alirsabet.com/wp-content/uploads/2023/08/Sample-Controller-300x260.png)

اگر کنترلر بالا رو تعریف کرده باشیم و هر یک از آدرس‌های بیان شده رو وارد کنیم، برنامه کار نخواهد کرد، به 2 دلیل:

*   کلاس کنترلر در داتنت‌کور، جزو سرویس‌هاست و باید به عنوان service class به برنامه معرفی بشه (DI)
*   قابلیت routing باید برای متدهای کلاس کنترلر تعریف بشه

![controllers DI and map](https://alirsabet.com/wp-content/uploads/2023/08/controllers-DI-and-map-300x158.png)

در تصویر بالا خط 2 همه‌ی کنترلرهای برنامه رو به عنوان service معرفی می‌کنه و زمانی که یک endpoint به اون‌ها نیاز داشته باشه، قابل دسترس خواهند بود. خط 4 همه‌ی action methodها رو به عنوان endpoint معرفی می‌کنه و عملا نیاز نیست تک‌تک مشخص کنیم که هر endpoint به کجا بره، کاری که در شکل زیر انجام شده و توصیه نمیشه.

![UseEndpoints not recommended](https://alirsabet.com/wp-content/uploads/2023/08/UseEndpoints-not-recommended-300x117.png)

حالا باید قالبی برای urlها تعریف کنیم و به برنامه بدیم تا بدونه urlهایی که میان به چه شکل هستن. روش attribute routing اینه که بالای هر action، دقیقا url رو بیاریم. الان با وارد کردن آدرس "/test/" وارد متد زیر میشیم.

![route attribute non efficient](https://alirsabet.com/wp-content/uploads/2023/08/route-attribute-non-efficient-300x145.png)

روش بهتر اینه که قالب کلی رو مشخص کنیم.

### انواع resultها

**ContentResult**

ContentResult می‌تونه هر نوع پاسخی باشه و بستگی به [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types) (مایم‌تایپ) داره. MIME type چیه؟ یک شناسه‌ی دو قسمتی که فرمت فایل‌ها رو مشخص می‌کنه، مثلا text/plain و text/html و application/json و...

![ContentResult](https://alirsabet.com/wp-content/uploads/2023/08/ContentResult-300x80.png)

**JsonResult**

JsonResult پاسخ (مثلا شی‌ای از کلاس Person) رو در قالب فرمت json برمی‌گردونه.

![JsonResult](https://alirsabet.com/wp-content/uploads/2023/08/JsonResult-300x139.png)

**FileResult**

FileResult محتوای فایل رو به عنوان پاسخ برمی‌گردونه، مثلا pdf و txt و zip.

VirtualFileResult فایلی که در WebRoot (فولدر wwwroot) با زیرفولدرهاش قرار داره رو برمی‌گردونه. (قبلا باید app.UseStaticFiles رو صدا زده باشیم)

PhysicalFileResult فایلی که الزاما در WebRoot (فولدر wwwroot) قرار نداره رو برمی‌گردونه.

![FileResult](https://alirsabet.com/wp-content/uploads/2023/08/FileResult-300x199.png)

FileContentResult فایل رو به شکل آرایه‌ای از بایت‌ها برمی‌گردونه.

![FileContentResult](https://alirsabet.com/wp-content/uploads/2023/08/FileContentResult-300x112.png)

**IActionResult**

IActionResult، اینترفیسِ والدِ همه‌ی کلاس‌های action result مثل ContentResult و JsonResult و... است. بنابراین می‎‌تونیم نوع مقدار خروجیِ همه‌ی action methodها رو IActionResult بذاریم.

![IActionResult](https://alirsabet.com/wp-content/uploads/2023/08/IActionResult-1024x484.png)

استفاده از IActionResult برای مشخص کردن نوع خروجیِ action methodها پیشنهاد میشه. فرض کنید قصد داریم در action method زیر، اگر در query string مقدار bookid وارد شده باشه، فایل sample.pdf رو برگردونیم و در غیر این صورت، یک Content حاوی پیام مناسب برگردونیم. این کار به راحتی قابل انجامه.

![IActionResult recommended](https://alirsabet.com/wp-content/uploads/2023/08/IActionResult-recommended-300x223.png)

**StatusCodeResult**

معمولا علاقه‌مندیم در پاسخی که برمی‌گردونیم، status code رو هم مشخص کنیم تا چک کردنش توسط client ساده باشه. معروف‌ترین status codeها، 200 و 400 و 401 و 404 و 500 هستن. [لیست کامل اینجاست](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status).

![StatusCodeResult](https://alirsabet.com/wp-content/uploads/2023/08/StatusCodeResult-300x223.png)

**Redirect Result**

Redirect result، کد 301 یا 302 رو به مرورگر ارسال می‌کنه، با این هدف که به یک url یا action دیگه [redirect](https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections) بشه. چرا ممکنه به redirect نیاز پیدا کنیم؟ در یک سناریوی ساده فرض کنید قبلا فروشگاه اینترنتی کتاب داشته‌اید که در آدرس "/bookstore/" قرار داشت،اما حالا قراره علاوه بر کتاب، کالاهای دیگری هم بفروشید و می‌خواهید دسته‌ی کتاب‌ها رو به "/store/books/" منتقل کنید. این کار به راحتی امکان‌پذیره، اما اگر کسانی آدرس قبلی رو در مرورگر ذخیره (bookmark) باشند چی؟ اگر آدرس قبلی رو وارد کنند، باید اون‌ها رو به آدرس جدید بفرستیم (redirect کنیم).

![Redirect Results](https://alirsabet.com/wp-content/uploads/2023/08/Redirect-Results-1024x328.png)

RedirectToActionResult بر اساس نام action و نام controller، از یک action method به یک action method دیگر redirect می‌کند.

![RedirectToActionResult](https://alirsabet.com/wp-content/uploads/2023/08/RedirectToActionResult-300x92.png)

LocalRedirectResult بر اساس یک url مشخص، از یک action method به یک action method دیگر redirect می‌کند.

![LocalRedirectResult](https://alirsabet.com/wp-content/uploads/2023/08/LocalRedirectResult-300x132.png)

RedirectResult از یک action method به هر url دیگری (داخل یا خارج از برنامه) redirect می‌کند.

![RedirectResult](https://alirsabet.com/wp-content/uploads/2023/08/RedirectResult-300x132.png)

* * *

model binding
-------------

در کنترلرها و ویوها به داده‌هایی که از http requestها می‌آیند نیاز داریم، بنابراین باید اون‌ها تک‌به‌تک در action methodها دریافت کنیم. کاری تکراری و سخت و احتمالا پر از خطا. Model Binding یکی از ویژگی‌های asp.net core است که مقادیر را از http requestها می‌خواند و آن‌ها را به عنوان ورودی (argument) به action methodها می‌دهد. در Model Binding، داده‌ها به ترتیبِ form fields و request body و route data و query string parameters خوانده می‌شن و این ترتیب مهمه.

![Model Binding](https://alirsabet.com/wp-content/uploads/2023/08/Model-Binding-1024x374.png)

### \[FromQuery\] و \[FromRoute\]

![[FromQuery] and [FromRoute]](https://alirsabet.com/wp-content/uploads/2023/08/FromQuery-and-FromRoute-1024x411.png)

اگر بخواهیم مقادیر رو از query string بخونیم از \[FromQuery\] و اگر بخواهیم مقادیر رو از route data بخونیم از \[FromRoute\] استفاده می‌کنیم (میشه از هر دو استفاده کرد و برای هر پارامتر ورودی چداگانه تعیین کنیم که \[FromQuery\] باشه یا \[FromRoute\]). چون ممکنه null باشن از ? استفاده می‌کنیم.

![[FromQuery] and [FromRoute] code](https://alirsabet.com/wp-content/uploads/2023/08/FromQuery-and-FromRoute-code-300x173.png)

Model کلاسیه که از طریق propertyها، ساختار داده‎‌ای که قراره از طریق request بگیریم یا از طریق response بفرستیم رو مشخص می‌کنه و اون رو به نام POCO (Plain Old CLR Objects) هم می‌شناسیم.

![POCO](https://alirsabet.com/wp-content/uploads/2023/08/POCO-1024x308.png)

![Model class ClassName](https://alirsabet.com/wp-content/uploads/2023/08/Model-class-ClassName-300x93.png)

### form fields

گاهی کاربر یک فرم رو پُر می‌کنه و با کلیک روی دکمه‌ی "ثبت"، اطلاعات در دیتابیس ذخیره میشه. این فرایند چطور کار می‌کنه؟ به کمک متد POST در HTTP و form fieldها. دو روش برای ثبت form fieldها داریم.

در روش form-urlencoded که روش پیش‌فرضِ HTML است، مقدار Content-Type در Request Headers به صورت زیر تعریف میشه و مقادیر فرم به صورت query string در Request Body قرار می‌گیره (شبیه‌سازی به کمک متد POST و روش x-www-form-urlencoded در Postman).

![form-urlencoded](https://alirsabet.com/wp-content/uploads/2023/08/form-urlencoded-300x106.png)

در روش form-data مقدار Content-Type در Request Headers به صورت زیر تعریف میشه و مقادیر فرم با فرمت نمایش داده شده در Request Body قرار می‌گیره (شبیه‌سازی به کمک متد POST و روش form-data در Postman).

![form-data](https://alirsabet.com/wp-content/uploads/2023/08/form-data-300x171.png)

معمولا در حالتی که فیلدهای کمی (مثلا 5 تا) داریم، روش form-urlencoded کار می‌کنه، اما در حالتی که فیلدها زیاد هستند و فایل هم در فرم داریم، از روش form-data استفاده می‌کنیم.

### Model Validation

فرض کنید که model binding انجام شده و به مقادیرِ مدل دست پیدا کرده‌ایم. چطور اون‌ها رو اعتبارسنجی کنیم؟ مثلا انتظار داریم نام افراد فقط شامل حروف انگلیسی، ایمیل‌شون حتما شامل "@" و شماره موبایل‌شون 11 رقم باشه. به این کار Model Validation می‌گن. در این روش، به کمک \[attribute\]ها، قوانین مورد نظرمون رو برای هر property معرفی می‌کنیم.

![Model Validation](https://alirsabet.com/wp-content/uploads/2023/08/Model-Validation-1024x349.png)

![Model Validation code](https://alirsabet.com/wp-content/uploads/2023/08/Model-Validation-code-300x114.png)

مثلا در تصویر زیر، کلاس Person رو با چند property معرفی کرده‌ایم و برای هر کدام، چند validation گذاشته‌ایم و در صورت عدم تطابق، پیام مناسب (ErrorMessage) به کاربر برمی‌گردونیم. [لیست کامل attributeها اینجاست](https://learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations).

![Model Validation person](https://alirsabet.com/wp-content/uploads/2023/08/Model-Validation-person-300x265.png)

ModelState یکی از ویژگی‌های ControllerBase است که در action methodها در دسترسه و میتونه وضعیتِ معتبر بودنِ مدل رو به ما اعلام کنه. ModelState سه property مهم داره.

*   IsValid یک مقدار boolean است و مشخص می‌کنه که آیا مدل معتبر است یا نه. اگر یک یا چند خطا در اعتبارسنجی رخ داده باشه، false و در غیر این‌صورت، true برمی‌گردونه
*   ErrorCount تعداد خطاها در فرایند اعتبارسنجی رو نشون میده
*   Values لیستی از خطاهای همه‌ی propertyهای مدل رو نشون میده

![Model Validation controller](https://alirsabet.com/wp-content/uploads/2023/08/Model-Validation-controller-300x141.png)

### Custom Validations

داتنت‌کور، attributeهای زیادی در اختیارمون گذاشته که به کمک اون‌ها میشه validation انجام داد. اما اگر نیاز به یک validation خاص داشته باشیم چی؟ می‌تونیم Custom Validation بنویسیم.

![custom ValidationAttribute](https://alirsabet.com/wp-content/uploads/2023/08/custom-ValidationAttribute-300x99.png)

فرض کنید قراره اعتبارسنجی جدیدی به برنامه اضافه کنیم تا مطمئن بشیم سال تولد افراد، قبل از 2000 است، بنابراین قصد داریم MinimumYearValidatorAttribute رو بسازیم. خوبه که فولدر جداگانه‌ای به نام CustomValidators بسازیم و validatorمون رو در اون قرار بدیم. این کلاس باید از ValidationAttribute (که کلاسِ پایه‌ی همه‌ی attributeهاست) ارث‌بری کنه و متد IsValid رو override کنه.

![MinimumYearValidatorAttribute code](https://alirsabet.com/wp-content/uploads/2023/08/MinimumYearValidatorAttribute-code-300x287.png)

### Custom Validations with Multiple Properties

...