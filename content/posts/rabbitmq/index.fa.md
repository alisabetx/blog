---
title: "کار با RabbitMQ"
slug: "rabbitmq"
date: 2025-02-28T14:00:00+03:30
lastmod: 2025-02-28T14:00:00+03:30
tags: ["rabbitmq", "ربیت ام کیو"]
author: "علی ثابت"
draft: false
comments: true
ShowToc: true
description: "با rabbitmq به صورت عملی کار کنیم"
---
{{< edit/edit >}}
# نصب RabbitMQ

ابتدا باید زبان برنامه نویسی [Erlang](https://en.wikipedia.org/wiki/Erlang_programming_language) رو نصب کنید. این زبان بخاطر ویژگی‌هایی که داره، برای ساختن RabbitMQ مناسب بوده. وارد [سایت ارلنگ](https://www.erlang.org) بشید و از تب‌های بالا، download رو انتخاب کنید و download windows installer رو بزنید. نصبش ساده‌ست و با چند کلیک انجام میشه. حالا اگر در cmd ویندوز عبارت erl رو تایپ کنید، باید چیزی مشابه این عکس ببینید.

![erlang succesful setup](./images/erlang-succesful-setup.png#center)

اگر خطای

```bash
'erl' is not recognized as an internal or external command, operable program or batch file.
```

گرفتید، یعنی ارلنگ به Path سیستم اضافه نشده و باید این کار رو دستی انجام بدید. آدرس ارلنگ کجاست؟ انتظار داریم در

```bash
C:\Program Files\Erlang OTP\bin
```

باشه، مگر اینکه اینجا نباشه و باید بگردید ببینید کجا نصب شده! به طور دقیق، آدرس پوشه bin ارلنگ رو نیاز دارید.
حالا باید اون رو به Path سیستم اضافه کنید. برای این کار وارد

```bash
This PC > Properties > Advanced system setting > Environment variables > System variables > Path > Edit > New
```

بشید و آدرس پوشه bin ارلنگ رو paste کنید. OK بزنید و تمام.
همچنین باید در System variables، این رو هم ببیند:

![add erlang to system variables](./images/add-erlang-to-system-variables.png#center)

حالا باید خودِ RabbitMQ رو نصب کنید. روش سرراستِ نصب در ویندوز، رفتن به [صفحه مختص ویندوز](https://www.rabbitmq.com/docs/install-windows) و انتخاب Using the official installer as an administrative userست. در این بخش نکات مهمی رو توضیح داده که خوبه بخونید. بعد از انتخاب نسخه مورد نظر برای دانلود، میتونید RabbitMQ رو از گیتهاب دانلود کنید. در زمان نوشتن این پست، آخرین نسخه 4.0.7 بوده و گیتهاب‌اش اینجوریه:

```bash
https://github.com/rabbitmq/rabbitmq-server/releases/tag/v4.0.7
```

![download rabbitmq](./images/download-rabbitmq.png#center)

فایل exe که سرراست‌ترین نوع نصب رو داره، دانلود و نصب کنید. چطور مطمئن بشیم RabbitMQ درست کار میکنه؟ به محل نصب RabbitMQ برید و آدرس‌اش رو کپی کنید. برای من

```bash
C:\Program Files\RabbitMQ Server\rabbitmq\_server-4.0.7\sbin
```

بود. حالا cmd رو run as administrator کنید (لازمه حتما این کار رو انجام بدید، در حالت عادی نمیشه) و بزنید:

```bash
cd C:\Program Files\RabbitMQ Server\rabbitmq\_server-4.0.7\sbin
```

در واقع رفتیم به محل نصب RabbitMQ. اگر بعد از زدن دستور

```bash
rabbitmq-plugins.bat enable rabbitmq\_management
```

چیزی شبیه این تصویر دیدید،

![cmd rabbitmq management](./images/cmd-rabbitmq-management.png#center)

و بعد از زدن دستور

```bash
rabbitmq-plugins enable rabbitmq\_shovel rabbitmq\_shovel\_management
```

چیزی شبیه این تصویر دیدید،

![cmd rabbitmq management](./images/cmd-rabbitmq-management-2.png#center)

یعنی کار به درستی انجام شده.

خوبه که

```bash
C:\Program Files\RabbitMQ Server\rabbitmq\_server-4.0.7\sbin
```

رو هم به Path سیستم اضافه کنیم، مشابه کاری که برای ارلنگ انجام دادیم.

در ادامه، لازمه فایل hosts رو اصلاح کنیم. برنامه Notepad (یا برنامه های مشابه) رو run as administrator کنید، از منوی File گزینه Open رو بزنید و در آدرس بار بالا،

```bash
C:\Windows\System32\drivers\etc
```

رو وارد کنید. لازمه نوع فایلها رو به All files تغییر بدید تا همه نوع فایلها رو ببینید.

![](data:image/png;base64...)
![rabbitmq edit hosts](./images/rabbitmq-edit-hosts.png#center)

فایل hosts بالایی رو انتخاب کنید و در خطوط پایانی،

```bash
127.0.0.1 rabbitmq
```

رو وارد و فایل رو save کنید.

یه بار دیگه cmd رو run as administrator کنید و دستور

```bash
net stop RabbitMQ
net start RabbitMQ
```

رو بزنید با RabbitMQ ری‌استارت بشه. در حالت پیش فرض، RabbitMQ روی پورت 15672 اجرا میشه. چطور بفهمیم این پورت بازه؟ دستور

```bash
netstat -ano | findstr :15672
```

رو بزنید و اگر چیزی شبیه این تصویر دیدید،

![net stat 15672](./images/net-stat-15672.png#center)

خوشحال باشید! در مرورگر، آدرس

```bash
http://localhost:15672/
```

رو بزنید. اگر یه داشبورد این شکلی دیدید،

![rabbitmq-dashboard](./images/rabbitmq-dashboard.png#center)

یعنی همه چیز به درستی انجام شده. در غیر این صورت، در جایی مشکلی وجود داشته! با

```bash
username: guest
password: guest
```

وارد بشید.
