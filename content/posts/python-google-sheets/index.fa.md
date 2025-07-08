---
title: "کار با google sheets در پایتون"
slug: "python-google-sheets"
date: 2023-06-08T14:00:00+03:30
lastmod: 2023-06-08T14:00:00+03:30
tags: ["پایتون", "گوگل شیت", "python", "google sheets"]
description: "در این پست، سعی می‌کنیم پایتون رو به Google Sheets وصل کنیم و باهاش یک پروژه ساده بسازیم"
---
# آشنایی با Google Sheets

گوگل شیت (که البته Google Sheets درسته!)، یک برنامه مشابه اکسل، تحت وب و رایگانه. این برنامه روی همه پلتفرم‌های رایج مثل [Android](https://play.google.com/store/apps/details?id=com.google.android.apps.docs.editors.sheets) و [iOS](https://apps.apple.com/us/app/google-sheets/id842849113) هم در دسترسه. تنها چیزی که برای کار با گوگل شیت نیاز داریم، داشتن حساب کاربری در گوگله. اگر گوشی اندرویدی یا حساب Gmail دارید، حتما اکانت گوگل هم دارید و می‌تونید با همون حساب [وارد گوگل‌شیت بشید](https://docs.google.com/spreadsheets/u/0/). در این پست فرض بر اینه که گوگل‌شیت رو می‌شناسید و قصد دارید ازش در کنار پایتون استفاده کنید.

به عنوان یک کاربر نهایی، می‌تونید از طریق سایت گوگل شیت واردش بشید و باهاش کار کنید. اما اگر قصد کار با اون از طریق بات (مثلا یک کد پایتون) رو دارید، نیاز به آماده‌سازی های بیشتری خواهید داشت. در ادامه قصد داریم گوگل شیت رو برای کار از طریق پایتون آماده کنیم و سپس با نوشتن کد پایتون، با داده‌های درون اون کار کنیم.

# آشنایی با Google Cloud

گوگل کلود (Google Cloud) مجموعه‌ای از خدمات ابریه که شامل تعداد زیادی ابزار برای ذخیره‌سازی و محاسبات و... است. این زیرساخت و پلتفرم‌های مشابه اون مثل AWS، کمک می‌کنن تا برای ساخت یه محصول نرم افزاری، درگیر زیرساخت‌ها (ذخیره‌سازی، محاسبات، امنیت، مقیاس‌پذیری و...) نشیم و فقط روی بیزنس خودمون تمرکز کنیم.

ابتدا لازمه که وارد سایت [پلتفرم ابری گوگل](https://console.cloud.google.com) بشید. این سایت از ایران در دسترس نیست و لازمه از ابزارهایی مثل w-i-n-d-s-c-r-i-b-e-.-c-o-m (- ها رو پاک کنید) استفاده کنید. (ظاهر این وب سایت چند بار تغییر کرده، اما مراحل همون هست که بیان شده، بنابراین اختلالی در روند کار ایجاد نمی‌شه). از طریق گزینه Select a Project و سپس انتخاب New Project یک پروژه جدید بسازید. یک اسم برای پروژه انتخاب کنید، لوکیشن رو روی No Organization بذارید و Create رو بزنید تا پروژه ساخته بشه. در ابتدا، داشبوری شامل اطلاعات کلی پروژه، مصارف و امکانات می‌بینید.

## فعال‌سازی API‌ها

با انتخاب گزینه APIs & Services و سپس Enable APIs & Services، وارد صفحه‌ای می‌شیم که اطلاعات سرویس‌هایی که تا الان APIشون فعال شده رو نشون میده. گزینه Enable APIs & Services رو انتخاب می‌کنیم. وارد صفحه‌ای می‌شیم که اطلاعات APIهای در دسترس رو نشون میده.  از این صفحه یک بار روی Google Drive API و یک بار روی Google Sheets API کلیک می‌کنیم و در صفحه‌ی مربوط به هر کدوم، گزینه Enable رو می‌زنیم تا فعال بشن.

## ایجاد اطلاعات ورود

برای استفاده از این سرویس‌های گوگل کلود، نیاز به داشتن اطلاعات احراز هویت داریم. این اطلاعات، با اطلاعات ورود به حساب کاربری گوگل فرق دارن و برای هر پروژه جدا هستن. از منوی چپ، گزینه‌ی APIs & Services و بخش Credentials میشه این اطلاعات رو به دست آورد. وارد صفحه‌ی Credentials می‌شیم و با انتخاب Create Credentials و سپس Service account وارد فرم ساخت Service Account می‌شیم. برای کار با سرویس‌ها، چند نوع احراز هویت مختلف می‌شه انجام داد، مثلا با کمک API Key یا OAuth. در اینجا برنامه‌ی ما قراره به شکل لوکال و در لپتاپ خودمون اجرا بشه. ساده‌ترین انتخاب برامون Service Account است.

در فیلد service account name یک نام برای سرویس انتخاب می‌کنیم، فیلد بعدی، ID رو خودکار تولید خواهد کرد، در service account description هم توضیحی برای سرویسمون می‌نویسیم. create and continue رو می‌زنیم تا وارد مرحله‌ی بعد بشیم. در مرحله‌ی بعد، سطح دسترسی این service account به پروژه رو مشخص می‌کنیم. برای پروژه فعلی دسترسی رو روی owner یا editor می‌ذاریم. با زدن continue به مرحله بعد می‌ریم که میشه دسترسی سایر افراد به service account رو مشخص کرد. اگر قرار نیست شخص دیگه‌ای به service account دسترسی داشته باشه، با انتخاب done مراحل رو به اتمام می‌رسونیم. service account ساخته شده، آدرس ایمیلی که در تصویر میبینید رو در مراحل بعد نیاز خواهیم داشت. service accountای که ساختیم رو انتخاب می‌کنیم، در تب keys، گزینه add key و سپس create new key رو انتخاب می‌کنیم. نوع کلید رو روی json میذاریم و سپس create. فایلی با پسوند json  دانلود میشه.

![python google sheet create credential](./images/python-google-sheet-create-credential.jpg#center)

# ساخت Spreadsheet

وارد گوگل شیت میشیم و یک پروژه به نام PySheet میسازیم. نام worksheet رو از Sheet1 به SampleSheet تغییر میدیم. این spreadsheet رو با [ایمیلی](#service-account-email) که توسط service account بهمون داده شد، با سطح دسترسی editor به اشتراک میذاریم.

# ساخت پروژه‌ی پایتون

پروژه پایتون رو در محیط مدنظرمون (مثلا PyCharm) می‌سازیم. برای کار با گوگل شیت در پایتون، چند پکیج وجود دارن که در این پروژه از [gspread](https://docs.gspread.org/) استفاده خواهیم کرد.

```python
import gspread

credentials = {
  "type": "service_account",
  "project_id": "XXXXXXXXXX",
  "private_key_id": "XXXXXXXXXX",
  "private_key": "-----BEGIN PRIVATE KEY-----\XXXXXXXXXX\n-----END PRIVATE KEY-----\n",
  "client_email": "aaa-965@glass-amplifier-392314.iam.gserviceaccount.com",
  "client_id": "100929656955613337657",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/aaa-965%40glass-amplifier-392314.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

gc = gspread.service_account_from_dict(credentials)

sh = gc.open("PySheet")

worksheet = sh.worksheet("SampleSheet")

worksheet.update('A1', 'XXX')

val = worksheet.acell('A1').value
print(val)
```

متغیر credentials محتوای فایل jsonای که دانلود کرده بودیم رو در خودش داره. اون فایل json رو باز کنید (مثلا با notepad) و محتواش رو کپی کنید و در کد بالا قرار بدید. \[🚩 این روشِ استفاده از اطلاعات احراز هویت امن نیست، صرفا برای ساده‌تر بودن ازش استفاده شده، از روش‌هایی در که در داکیومنت gspread گفته شده استفاده کنید\]

متغیر sh آبجکت پروژه رو در خودش داره، متغیر worksheet آبجکت شیت‌ای که روش کار خواهیم کرد رو در خودش داره. در کد بالا، محتوای سلول A1 رو با مقدار مورد نظرمون آپدیت کردیم و سپس محتواش رو پرینت کردیم. برای استفاده از همه‌ی امکانات پکیج gspread [داکیومنتش](https://docs.gspread.org/) رو ببینید.

{{< edit/edit >}}