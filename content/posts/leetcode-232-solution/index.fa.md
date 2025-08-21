---
title: "حل سوال 232 لیت‌کد"
slug: "leetcode-232-solution"
date: 2023-10-15T14:00:00+03:30
lastmod: 2023-11-24T14:00:00+03:30
tags: ["leetcode", "queue", "stack", "data structure", "الگوریتم"]
description: "در این پست سوال 232 لیت‌کد (implement queue using stacks) رو حل می‌کنیم"
---
برای دسترسی به سوال 232 لیت‌کد میتونید از این [لینک](https://leetcode.com/problems/implement-queue-using-stacks/) استفاده کنید. سطح این سوال Easy است.

# شرایط مسئله {#problem-statement}

در این مرحله، شرایط خاص مسئله و حالت‌های edge case رو بررسی می‌کنیم. این شرایط باید در توضیحات سوال یا مثال‌ها مشخص شده باشن یا اینکه از پاسخ‌های پیش فرض استفاده کنیم.

*   آیا متدهای مورد نظر که قراره با Stack پیاده بشن، باید با پیچیدگی زمانی که برای ساختمان داده‌ی Queue داریم پیاده بشن؟ نه الزاما، اما باید تا جای ممکن بهینه باشن.
*   آیا الزاما باید از یک Stack برای هر عملیات استفاده بشه؟ خیر، ممکنه برای هر عملیات چند Stack استفاده بشن، خروجی و پیچیدگی نهایی مهمه.

# راه حل منطقی {#solution-approach}

در این مرحله به دنبال working solution هستیم، یعنی راه حلی منطقی که بتونه مسئله رو حل کنه. به راه حل بهینه فکر نمی‌کنیم. درگیر زبان برنامه نویسی و محدودیت‌های اون هم نخواهیم بود.

قراره ساختمان داده‌ی Queue رو به کمک ساختمان داده‌ی Stack پیاده‌سازی کنیم. چهار عمل اصلی Queue عبارت‌اند از:

*   enqueue: یک مقدار رو به انتهای Queue اضافه می‌کنه
*   dequeue: یک مقدار رو از ابتدای Queue حذف می‌کنه و برمی‌گردونه
*   peek: یک مقدار رو از ابتدای Queue برمی‌گردونه
*   empty: بررسی می‌کنه که آیا Queue خالی است یا خیر؟ جوابش true/false است

فرض می‌کنیم یک Stack و یک Queue داریم. می‌خواهیم شباهت‌ها و تفاوت‌هایشان را بررسی کنیم. مقادیر مورد نظر برای درج در این ساختمان‌داده‌ها، اعداد 1 و 2 و 3 و 4 و 5 (به ترتیب) هستند.

## پیاده‌سازی enqueue {#enqueue-implementation}

در زمان درج، تفاوتی مشاهده نمی‌شود. مقادیر به همان ترتیب 1 و 2 و 3 و 4 و 5 وارد Stack و Queue می‌شوند.

```txt
Queue = [1, 2, 3, 4, 5]
Stack = [1, 2, 3, 4, 5]
```

## پیاده‌سازی dequeue {#dequeue-implementation}

در زمان خروج (pop)، مقادیرِ درون Queue به ترتیبی که وارد شده بودند، خارج می‌شوند (FIFO)، یعنی ابتدا 1، سپس 2، بعد 3 و 4 و 5 خارج می‌شوند. مقادیرِ درون Stack برعکسِ ترتیبی که وارد شده بودند، خارج می‌شوند (LIFO)، یعنی ابتدا 5، سپس 4، بعد 3 و 2 و 1 خارج می‌شوند.

اما اگر Stack را وارونه (reverse) کنیم چه؟ در این حالت شبیه Queue می‌شود و عناصر به ترتیبِ 1، سپس 2، بعد 3 و 4 و 5 خارج می‌شوند. پس راهِ اینکه بتونیم Queue رو به کمک Stack بنویسیم، اینه که Stack وارونه بشه. یعنی بیایم عناصرِ StackOne رو pop کنیم و به ترتیب، وارد StackTwo کنیم. همانطور که در شکل زیر مشخص است. در واقع خروجیِ StackTwo، شبیه Queue خواهد بود.

```txt
Queue = [1, 2, 3, 4, 5]
When pop Queue = 1, 2, 3, 4, 5
stackOne = [1, 2, 3, 4, 5]
When pop stackOne = 5, 4, 3, 2, 1
stackTwo = [5, 4, 3, 2, 1]
When pop stackOne = 1, 2, 3, 4, 5
```

این سناریو رو در نظر بگیرید. اعداد 1 و 2 و 3 و 4 و 5 داخل Queue هستن. خواسته‌ی سوال رو پیاده کرده‌ایم و به کمک دو Stack، خروجی مورد نظر رو (در StackTwo) به دست آورده‌ایم. حالا تصمیم می‌گیریم دو عدد خارج کنیم، دو عدد دیگه وارد کنیم و سپس سه عدد خارج کنیم. در پایان هم دو عدد باقی‌مانده رو خارج کنیم.

در مرحله‌ی اول، خارج کردن دو عدد از Queue و StackTwo بدون مشکل رخ میده و خروجی نهایی، همون چیزیه که انتظار داریم.

در مرحله‌ی دوم، می‌خواهیم اعداد 6 و 7 رو اضافه کنیم. برای Queue، این کار به سادگی انجام می‌شه و به انتهای اون اضافه میشن. موقعی که بخواهیم مرحله‌ی سوم رو اجرا کنیم، اعداد 3 و 4 و 5 برداشته میشن. اگه همین کار رو در مورد StackTwo انجام بدیم، نتیجه غلط خواهد بود، چون به شکل \[5,4,3,6,7\] درمیاد و در زمان اجرای مرحله‌ی سوم، خروجیِ آن، 7 و 6 و 3 است که با نتیجه‌ی Queue فرق داره. اگه عناصر 6 و 7 رو به StackOne اضافه کنیم چطور؟ StackOne خالی بود، حالا به شکل \[6,7\] دراومده و StackTwo به شکل \[5,4,3\] است. حالا اگه از StackTwo خروج انجام بدیم، نتیجه مثل Queue خواهد شد.

در مرحله‌ی آخر، اعداد 6 و 7 رو از Queue خارج می‌کنیم. StackOne به شکل \[6,7\] و StackTwo خالی است. با StackTwo که نمیشه کار کرد، اگه بخواهیم از StackOne هم pop کنیم، نتیجه برعکسِ Queue خواهد بود. پس همون کاری رو انجام می‌دیم که ابتدا انجام دادیم، عناصر درون StackOne رو pop می‌کنیم و وارد StackTwo می‌کنیم و از StackTwo خارج می‌کنیم. در واقع هر وقت StackTwo خالی شد، عناصرِ درونِ StackOne رو pop می‌کنیم و وارد StackTwo می‌کنیم.

```txt
Queue = [1, 2, 3, 4, 5]
(Temp) StackOne = [1, 2, 3, 4, 5]
stackTwo = [5, 4, 3, 2, 1]
----------------Step1----------------
Queue = [_, _, 3, 4, 5] -> 1, 2
StackOne = []
stackTwo = [5, 4, 3,_ ,_] -> 1, 2
----------------Step2----------------
Queue = [_, _, _, 6, 7] -> 3, 4, 5
StackOne = [6, 7]
stackTwo = [_,_,_] -> 3,4,5
----------------Step3----------------
Queue = [6,7]
StackOne = [6,7]
stackTwo = []
----------------Step4----------------
Queue = [6, 7] -> 6, 7
StackOne = []
stackTwo = [7, 6] -> 6, 7
```

# تبدیل راه حل به کد {#code-implementation}

```csharp
using System.Collections.Generic;
public class QueueWithStacks <T> 
{

    private Stack <T> inStack;
    private Stack <T> outStack;

    public QueueWithStacks() {
      inStack = new Stack <T>();
      outStack = new Stack <T>();
    }

    public void Enqueue(T val) {
      inStack.Push(val);
    }

    public T Dequeue(T val) {
      if (outStack.Count == 0) {
        while (inStack.Count > 0) {
          outStack.Push(inStack.Pop());
        }
      }
      return outStack.Pop();
    }

    public T Peek() {
      if (outStack.Count == 0) {
        while (inStack.Count > 0) {
          outStack.Push(inStack.Pop());
        }
      }
      return outStack.Peek();
    }

    public bool Empty() {
      return inStack.Count == 0 && outStack.Count == 0;
    }
}
```

{{< edit >}}

# منابع {#references}
[Udemy](https://www.udemy.com/course/master-the-coding-interview-big-tech-faang-interviews/)