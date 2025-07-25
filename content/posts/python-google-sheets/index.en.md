---
title: "Using Google Sheets with Python"
slug: "python-google-sheets"
date: 2024-03-15T14:00:00+03:30
lastmod: 2024-04-14T14:00:00+03:30
tags: ["python", "google sheets", "automation", "gspread", "google api", "python projects"]
description: "Learn how to connect Python to Google Sheets using the gspread library. This tutorial covers setting up Google Cloud, enabling APIs, and writing a Python script to read and write data to a spreadsheet." 
keywords: ["python google sheets", "gspread tutorial", "python automation", "google sheets api python"]
---

# Getting to Know Google Sheets

Google Sheets (which is the correct name!) is a web-based app similar to Excel and it's free. This app is available on all popular platforms like [Android](https://play.google.com/store/apps/details?id=com.google.android.apps.docs.editors.sheets) and [iOS](https://apps.apple.com/us/app/google-sheets/id842849113). The only thing you need to work with Google Sheets is a Google account. If you have an Android phone or a Gmail account, you definitely have a Google account and you can log into Google Sheets with that account [here](https://docs.google.com/spreadsheets/u/0/). This post assumes you know what Google Sheets is and want to use it alongside Python.

As an end user, you can access Google Sheets through the website and work with it. But if you want to work with it through a bot (like a Python script), you need some extra preparations. Next, we'll prepare Google Sheets for working with Python and then write Python code to work with its data.

# Getting to Know Google Cloud

Google Cloud is a collection of cloud services that includes many tools for storage, computing, and more. This infrastructure and similar platforms like AWS help us focus only on our business without worrying about infrastructure (storage, computing, security, scalability, etc.) when building a software product.

First, you need to visit the [Google Cloud Platform](https://console.cloud.google.com) website. The appearance of this website has changed a few times, but the steps remain the same, so there should be no disruption in the process. Use the Select a Project option and then choose New Project to create a new project. Pick a name for the project, set the location to No Organization, and click Create to create the project. Initially, you'll see a dashboard with general project info, usage, and features.

## Enabling APIs

By selecting APIs & Services and then Enable APIs & Services, you enter a page showing the services whose APIs are already enabled. Click Enable APIs & Services again. You'll see a page listing available APIs. From this page, click on Google Drive API once and Google Sheets API once, and on each page, click Enable to activate them.

## Creating Credentials

To use these Google Cloud services, you need authentication credentials. These are different from your Google account login info and are specific to each project. From the left menu, go to APIs & Services and then Credentials to get these credentials. Enter the Credentials page and select Create Credentials, then Service Account to open the Service Account creation form. There are several authentication methods, like API Key or OAuth. Here, our program will run locally on our laptop. The simplest choice for us is Service Account.

In the service account name field, enter a name for the service. The next field, ID, will be generated automatically. In the service account description, write a description for your service. Click create and continue to go to the next step. In the next step, specify the access level of this Service Account to the project. For the current project, set access to owner or editor. Click continue to go to the next step where you can specify access for others to the Service Account. If no one else should have access, click done to finish. The created Service Account's email address shown in the image will be needed later. Select the created Service Account, go to the keys tab, click add key, then create new key. Set the key type to json and click create. A json file will be downloaded.

![python google sheet create credential](./images/python-google-sheet-create-credential.jpg#center)

# Creating a Spreadsheet

Go to Google Sheets and create a project named PySheet. Change the Worksheet name from Sheet1 to SampleSheet. Share this Spreadsheet with the [email](#service-account-email) provided by the Service Account with Editor access.

# Creating the Python Project

Create the Python project in your preferred environment (e.g., PyCharm). To work with Google Sheets in Python, there are several packages; in this project, we'll use [gspread](https://docs.gspread.org/).

```python
import gspread

credentials = {
  "type": "service_account",
  "project_id": "ABC",
  "private_key_id": "DEF",
  "private_key": "-----BEGIN PRIVATE KEY-----\GHI\n-----END PRIVATE KEY-----\n",
  "client_email": "aaa-965@glass-amplifier-392314.iam.gserviceaccount.com",
  "client_id": "1234567890",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/abcd.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

gc = gspread.service_account_from_dict(credentials)

sh = gc.open("PySheet")

worksheet = sh.worksheet("SampleSheet")

worksheet.update('A1', 'XXX')

val = worksheet.acell('A1').value

print(val)
```

The credentials variable contains the content of the json file we downloaded. Open that json file (e.g., with Notepad), copy its content, and paste it into the code above. [🚩 This method of using credentials is not secure; it is used here just for simplicity. Use the methods described in the gspread documentation.]

The sh variable holds the project object, and the worksheet variable holds the sheet object we will work on. In the code above, we update the content of cell A1 with our desired value and then print its content. For all features of the gspread package, see its [documentation](https://docs.gspread.org/).

{{< edit >}}