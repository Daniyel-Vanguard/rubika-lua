# 🚀 شروع سریع

این راهنما به شما کمک می‌کند در 5 دقیقه اولین ربات روبیکا خود را بسازید.

## قدم ۱: نصب پیش‌نیازها

### روی Arch Linux:
```bash
sudo pacman -S lua
luarocks install lua-cjson luasocket luasec
```
# روی Ubuntu/Debian:
```bash
sudo apt install lua5.4
sudo apt install liblua5.4-dev
luarocks install lua-cjson luasocket luasec
```
# قدم ۲: دریافت توکن ربات

    در روبیکا به @BotFather مراجعه کنید

    دستور /start را ارسال کنید

    نام ربات را وارد کنید (مثلاً: My Test Bot)

    یوزرنیم ربات را وارد کنید (مثلاً: MyTestRobot)

    توکن دریافتی را ذخیره کنید 
    
# قدم ۳: ایجاد اولین ربات

فایل my_first_bot.lua ایجاد کنید:
```lua
local rubika = require("rubika")

-- ایجاد ربات با توکن دریافتی
local bot = rubika.Robot:new("YOUR_BOT_TOKEN_HERE")

-- هندلر پیام‌ها
bot:on_message()(function(self, msg)
    local text = msg.text or ""
    
    if text == "/start" then
        msg:reply("🎉 سلام! به اولین ربات من خوش آمدید!")
        
    elseif text == "/help" then
        msg:reply("📖 این ربات ساده با Lua ساخته شده است")
        
    elseif text == "اسم من" then
        local name = self:get_name(msg.chat_id)
        msg:reply("👤 اسم شما: " .. name)
        
    elseif text == "ساعت" then
        msg:reply("🕒 زمان: " .. os.date("%H:%M:%S"))
        
    else
        msg:reply("🤔 دستور '" .. text .. "' را متوجه نشدم!")
    end
end)

-- اجرای ربات
print("🤖 ربات فعال شد!")
bot:run()
```
# قدم ۴: اجرای ربات
```bash
lua my_first_bot.lua

```

# قدم ۵: تست ربات

    در روبیکا به ربات خود مراجعه کنید

    دستور /start را ارسال کنید

    سایر دستورات را تست کنید

# 🎯 قدم بعدی

<a href="https://github.com/Daniyel-Vanguard/rubika-lua/blob/main/docs/API_REFERENCE.md">مستندات کامل API</a>
    اضافه کردن کیبورد

    ارسال مدیا

