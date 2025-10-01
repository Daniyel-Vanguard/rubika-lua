# 🤖 Rubika Bot - Lua

یک ربات قدرتمند برای پیام‌رسان روبیکا با قابلیت‌های کامل، نوشته شده در Lua

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Rubika](https://img.shields.io/badge/Rubika-Bot-FF6B6B?style=for-the-badge)
![Webhook](https://img.shields.io/badge/Webhook-Enabled-4ECDC4?style=for-the-badge)

## ✨ ویژگی‌ها

- ✅ پشتیبانی از Webhook و Polling
- ✅ کیبورد اینلاین پیشرفته
- ✅ ارسال انواع مدیا (عکس، ویدیو، فایل، صدا)
- ✅ مدیریت کامل کاربران
- ✅ قابلیت‌های پیشرفته مانند انتخاب‌گر، تقویم، موقعیت‌یاب
- ✅ معماری ماژولار و قابل توسعه
- ✅ مستندات کامل

## 🚀 راه‌اندازی سریع

### پیش‌نیازها

```bash
# نصب Lua (روی Arch Linux)
sudo pacman -S lua

# نصب کتابخانه‌های مورد نیاز
luarocks install lua-cjson
luarocks install luasocket
luarocks install luasec
```

## نصب و اجرا

1. کلون کردن ریپوزیتوری

```bash
git clone https://github.com/yourusername/rubika-bot-lua.git
cd rubika-bot-lua
```

1. تنظیم توکن ربات

```bash
cp config.example.lua config.lua
# توکن ربات خود را در فایل config.lua قرار دهید
```

1. اجرا در حالت Polling (تست)

```bash
lua polling_bot.lua
```

1. اجرا در حالت Webhook (Production)

```bash
lua webhook_server.lua
```

# 🔧 پیکربندی

فایل config.lua

```lua
return {
    bot = {
        token = "YOUR_BOT_TOKEN_HERE",
        timeout = 30,
        platform = "web"
    },
    
    webhook = {
        enabled = true,
        url = "https://yourdomain.com/webhook",
        port = 8080
    },
    
    server = {
        host = "0.0.0.0",
        port = 8080
    }
}
```

# دریافت توکن ربات

1. به @BotFather در روبیکا مراجعه کنید
2. دستور /start را ارسال کنید
3. نام و یوزرنیم ربات را انتخاب کنید
4. توکن دریافتی را در فایل ربات یا config قرار دهید

🌐 راه‌اندازی Webhook

با استفاده از Ngrok (تست محلی)

```bash
# نصب Ngrok
yay -S ngrok

# اجرای Ngrok
ngrok authtoken YOUR_AUTH_TOKEN
ngrok http 8080

# در ترمینال دیگر
lua webhook_server.lua
```

با استفاده از Cloudflare Tunnel

```bash
# نصب Cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# راه‌اندازی تونل
cloudflared tunnel login
cloudflared tunnel create my-bot
cloudflared tunnel run my-bot --url http://localhost:8080
```

روی VPS واقعی

```nginx
# فایل پیکربندی Nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/private.key;
    
    location /webhook {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

📚 مثال‌های کد

ایجاد یک ربات ساده

```lua
local rubika = require("rubika")

local bot = rubika.Robot:new("YOUR_BOT_TOKEN")

bot:on_message()(function(self, msg)
    if msg.text == "/start" then
        msg:reply("سلام! به ربات خوش آمدید 👋")
    elseif msg.text == "/info" then
        local name = self:get_name(msg.chat_id)
        msg:reply("اسم شما: " .. name)
    end
end)

bot:run()
```

استفاده از کیبورد اینلاین

```lua
bot:on_message()(function(self, msg)
    if msg.text == "/menu" then
        local builder = rubika.InlineBuilder:new()
        local keyboard = builder
            :row(
                builder:button_simple("help", "📖 راهنما"),
                builder:button_simple("about", "ℹ️ درباره")
            )
            :row(
                builder:button_link("website", "🌐 وبسایت", "https://example.com")
            )
            :build()
        
        msg:reply("منوی اصلی:", nil, keyboard)
    end
end)

-- هندلر دکمه‌ها
bot:on_callback("help")(function(self, msg)
    msg:reply("این بخش راهنماست!")
end)
```

ارسال مدیا

```lua
-- ارسال عکس
bot:send_image(chat_id, "path/to/image.jpg", "متن همراه عکس")

-- ارسال فایل
bot:send_document(chat_id, "path/to/file.pdf", "شرح فایل")

-- ارسال صدا
bot:send_voice(chat_id, "path/to/audio.ogg")
```

🏗️ ساختار پروژه

```
rubika-bot-lua/
├── rubika.lua              # کتابخانه اصلی
├── webhook_server.lua      # سرور وب‌هوک
├── polling_bot.lua         # ربات Polling
├── config.example.lua      # مثال پیکربندی
├── config.lua             # فایل پیکربندی (ایجاد شود)
├── examples/              # مثال‌های مختلف
│   ├── simple_bot.lua
│   ├── keyboard_bot.lua
│   └── media_bot.lua
├── docs/                  # مستندات
└── README.md
```

# 🔄 تفاوت Webhook و Polling
  
<table>
  <tr>
    <th>ویژگی</th>
    <th>Webhook</th>
    <th>Polling</th>
  </tr>
  <tr>
    <td>سرعت ⚡</td>
    <td>سریع</td>
    <td>🐢 کند</td>
  </tr>
   <tr>
    <td>منابع</td>
    <td>کم مصرف</td>
    <td>پر مصرف</td>
  </tr>
      </tr>
   <tr>
    <td>قابلیت‌ها</td>
    <td>کامل</td>
    <td>محدود</td>
  </tr>
    </tr>
   <tr>
    <td>پیچیدگی</td>
    <td>متوسط</td>
    <td>ساده</td>
  </tr>

</table>
  

  
  
نیازمندی‌ها سرور عمومی اینترنت معمولی

# 🐛 عیب‌یابی

مشکلات رایج

1. خطای اتصال
   · اتصال اینترنت را بررسی کنید
   · توکن ربات را چک کنید
2. کیبورد نمایش داده نمی‌شود
   · از حالت Webhook استفاده کنید
   · در Polling کیبورد کار نمی‌کند
3. خطای SSL در Webhook
   · گواهی SSL را تنظیم کنید
   · از Cloudflare Tunnel استفاده کنید

لاگ‌گیری

```lua
-- فعال کردن لاگ مفصل
bot:on_message()(function(self, msg)
    print("📨 پیام از " .. msg.chat_id .. ": " .. (msg.text or "بدون متن"))
    -- پردازش پیام
end)
```

# 🤝 مشارکت

مشارکت‌ها همیشه welcome هستند!

1. فورک کنید
2. برنچ feature ایجاد کنید (git checkout -b feature/AmazingFeature)
3. کامیت کنید (git commit -m 'Add some AmazingFeature')
4. push کنید (git push origin feature/AmazingFeature)
5. Pull Request ایجاد کنید

# 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است. برای اطلاعات بیشتر فایل LICENSE را مطالعه کنید.

# 📞 پشتیبانی

· 📧 ایمیل: hadipishghadam13@gmail.com
· 💬 Issue: ایجاد Issue
· 📚 مستندات: Wiki

🙏 تشکر

از تمامی مشارکت‌کنندگان و جامعه Lua که این پروژه را ممکن ساختند تشکر می‌کنیم.

---

⭐ اگر این پروژه را مفید یافتید، لطفاً ستاره بدهید!

