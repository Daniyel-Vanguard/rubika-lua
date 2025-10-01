-- examples/simple_bot.lua
-- 🚀 ساده‌ترین ربات روبیکا - مناسب برای شروع

local rubika = require("rubika")

-- ایجاد ربات با توکن
-- توکن خود را از @RubikaBot دریافت کنید
local bot = rubika.Robot:new("YOUR_BOT_TOKEN_HERE")

print("🤖 ربات ساده فعال شد!")
print("📝 دستورات: /start, /help, /info, ساعت, اسم من")

-- هندلر اصلی برای تمام پیام‌ها
bot:on_message()(function(self, msg)
    local text = msg.text or ""
    
    -- لاگ پیام دریافتی
    print("📨 پیام از " .. msg.chat_id .. ": " .. text)
    
    -- دستور /start
    if text == "/start" then
        local welcome = "🎉 به ربات ساده خوش آمدید!\n\n"
        welcome = welcome .. "این یک ربات نمونه است که با Lua ساخته شده.\n\n"
        welcome = welcome .. "📋 دستورات قابل استفاده:\n"
        welcome = welcome .. "• /start - نمایش این پیام\n"
        welcome = welcome .. "• /help - راهنمای ربات\n"
        welcome = welcome .. "• /info - اطلاعات ربات\n"
        welcome = welcome .. "• ساعت - نمایش زمان\n"
        welcome = welcome .. "• اسم من - نمایش نام شما\n\n"
        welcome = welcome .. "💡 هر پیامی بفرستید، ربات آن را تکرار می‌کند!"
        
        msg:reply(welcome)
        
    -- دستور /help
    elseif text == "/help" then
        local help_text = "📖 راهنمای ربات ساده\n\n"
        help_text = help_text .. "این ربات برای آموزش ساخت ربات با Lua ایجاد شده.\n\n"
        help_text = help_text .. "🛠️ قابلیت‌ها:\n"
        help_text = help_text .. "• پاسخ به پیام‌های متنی\n"
        help_text = help_text .. "• نمایش اطلاعات کاربر\n"
        help_text = help_text .. "• نمایش زمان سرور\n"
        help_text = help_text .. "• تکرار پیام‌ها\n\n"
        help_text = help_text .. "⭐ برای شروع کافیست هر پیامی بفرستید!"
        
        msg:reply(help_text)
        
    -- دستور /info
    elseif text == "/info" then
        -- دریافت اطلاعات ربات
        local me = self:get_me()
        local bot_info = me.data.bot
        
        local info = "🤖 اطلاعات ربات:\n\n"
        info = info .. "🔹 نام: " .. bot_info.bot_title .. "\n"
        info = info .. "🔹 یوزرنیم: @" .. bot_info.username .. "\n"
        info = info .. "🔹 آدرس: " .. (bot_info.share_url or "ندارد") .. "\n"
        info = info .. "🔹 حالت: Polling\n"
        info = info .. "🔹 زبان: Lua\n\n"
        info = info .. "✅ ربات فعال و آماده به کار!"
        
        msg:reply(info)
        
    -- نمایش زمان
    elseif text == "ساعت" or text == "زمان" or text == "time" then
        local current_time = os.date("🕒 زمان: %Y-%m-%d %H:%M:%S")
        msg:reply(current_time)
        
    -- نمایش نام کاربر
    elseif text == "اسم من" or text == "نام من" or text == "name" then
        local user_name = self:get_name(msg.chat_id)
        local username = self:get_username(msg.chat_id)
        
        local name_info = "👤 اطلاعات شما:\n\n"
        name_info = name_info .. "🔸 نام: " .. user_name .. "\n"
        name_info = name_info .. "🔸 یوزرنیم: @" .. username .. "\n"
        name_info = name_info .. "🔸 چت آیدی: " .. msg.chat_id
        
        msg:reply(name_info)
        
    -- سلام و احوالپرسی
    elseif text:match("سلام") or text:match("hello") or text:match("hi") then
        local name = self:get_name(msg.chat_id)
        msg:reply("سلام " .. name .. "! 👋\nچطور می‌تونم کمک کنم؟")
        
    -- تشکر
    elseif text:match("ممنون") or text:match("مرسی") or text:match("thanks") then
        msg:reply("خواهش می‌کنم! 😊\nخوشحالم که مفید بودم.")
        
    -- سوال
    elseif text:match("چطوری") or text:match("حالت") or text:match("چونی") then
        msg:reply("من یک ربات هستم و همیشه خوبم! 🤖\nامیدوارم شما هم حالتون خوب باشه.")
        
    -- پاسخ به سایر پیام‌ها (اکو)
    else
        if text ~= "" then
            local response = "📨 پیام شما:\n\n"
            response = response .. "« " .. text .. " »\n\n"
            response = response .. "💡 برای مشاهده دستورات /help را ارسال کنید."
            
            msg:reply(response)
        end
    end
end)

-- هندلر خطاهای全局
local function error_handler(err)
    print("❌ خطا در ربات: " .. tostring(err))
    print("🔧 ادامه اجرا...")
end

-- اجرای ربات با مدیریت خطا
print("🎯 در حال راه‌اندازی ربات...")
local success, err = pcall(function()
    bot:run()
end)

if not success then
    error_handler(err)
end
