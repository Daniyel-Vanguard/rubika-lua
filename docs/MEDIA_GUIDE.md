# 📁 راهنمای ارسال مدیا

## انواع مدیا قابل ارسال

- 🖼️ عکس (Image)
- 📹 ویدیو (Video) 
- 🎵 موزیک (Music)
- 🎤 صوت (Voice)
- 🔄 GIF
- 📄 فایل (Document)

## ارسال عکس

### از مسیر محلی
```lua
bot:send_image(chat_id, "path/to/image.jpg", nil, "توضیح عکس")
```
#### از URL
```lua
bot:send_image(chat_id, "https://example.com/image.jpg", nil, "عکس از وب")
```
#### با کیبورد
```lua
local keyboard = -- ساخت کیبورد
bot:send_image(chat_id, "photo.jpg", nil, "عکس با کیبورد", nil, keyboard)
```
### ارسال فایل
#### فایل PDF
```lua
bot:send_document(chat_id, "document.pdf", nil, "فایل PDF آموزشی")
```
#### فایل ZIP
```lua
bot:send_document(chat_id, "archive.zip", nil, "فایل فشرده")
```
#### مشخص کردن نام فایل
```lua
bot:send_document(chat_id, "temp_file.tmp", nil, "فایل دیتا", "data.csv")
```
### ارسال صوت
#### فایل صوتی از پیش ضبط شده
```lua
bot:send_voice(chat_id, "voice-message.ogg", nil, "پیام صوتی")
```
#### ارسال موزیک
```lua
bot:send_music(chat_id, "song.mp3", nil, "آهنگ جدید")
```
#### ارسال GIF
```lua
bot:send_gif(chat_id, "animation.gif", nil, "انیمیشن جالب")
```
#### استفاده از file_id
برای جلوگیری از آپلود مجدد فایل‌ها:
```lua
-- اولین بار (دریافت file_id)
local result = bot:send_image(chat_id, "photo.jpg")
local file_id = result.data.message.file_id

-- دفعات بعد (استفاده از file_id)
bot:send_image(chat_id, nil, file_id, "همان عکس")
```
#### مثال عملی: گالری عکس
```lua
local photo_gallery = {
    {"nature.jpg", "منظره طبیعت 🌲"},
    {"city.jpg", "شهر 🏙️"},
    {"art.jpg", "اثر هنری 🎨"}
}

bot:on_message()(function(self, msg)
    if msg.text == "/gallery" then
        local builder = rubika.InlineBuilder:new()
        local keyboard = builder
            :row(
                builder:button_simple("photo1", "عکس ۱"),
                builder:button_simple("photo2", "عکس ۲"),
                builder:button_simple("photo3", "عکس ۳")
            )
            :build()
        
        msg:reply("🎨 گالری عکس:", nil, keyboard)
    end
end)

bot:on_callback("photo1")(function(self, msg)
    bot:send_image(msg.chat_id, "nature.jpg", nil, "منظره زیبای طبیعت")
end)

bot:on_callback("photo2")(function(self, msg)
    bot:send_image(msg.chat_id, "city.jpg", nil, "نمایی از شهر")
end)
```
#### آپلود فایل از URL
```lua
local function send_image_from_url(chat_id, url, caption)
    bot:send_image(chat_id, url, nil, caption)
end

-- استفاده
send_image_from_url(chat_id, "https://picsum.photos/500", "عکس رندوم")
```
#### مدیریت خطا
```lua
local success, result = pcall(function()
    return bot:send_image(chat_id, "nonexistent.jpg", nil, "عکس")
end)

if not success then
    msg:reply("❌ خطا در ارسال عکس")
end
```
### محدودیت‌ها

- حجم عکس: حداکثر ۱۰ مگابایت

- حجم فایل: حداکثر ۵۰ مگابایت

- مدت صوت: حداکثر ۱ دقیقه

- فرمت‌های مجاز: JPG, PNG, MP4, MP3, PDF, ZIP, etc.

### نکات بهینه‌سازی
1.برای فایل‌های تکراری از file_id استفاده کنید

2.فایل‌های بزرگ را از CDN ارسال کنید

3.خطاها را مدیریت کنید

4.از فرمت‌های بهینه استفاده کنید

