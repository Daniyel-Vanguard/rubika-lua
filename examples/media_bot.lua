-- examples/media_bot.lua
-- 📁 ربات ارسال مدیا - عکس، فایل، صدا، ویدیو

local rubika = require("rubika")

local bot = rubika.Robot:new("YOUR_BOT_TOKEN_HERE")

print("📁 ربات مدیا فعال شد!")
print("🎯 دستورات: /start, /media, /gallery, /send_voice")

-- تابع ایجاد منوی مدیا
local function create_media_menu()
    local builder = rubika.InlineBuilder:new()
    return builder
        :row(
            builder:button_simple("send_photo", "🖼️ ارسال عکس"),
            builder:button_simple("send_document", "📄 ارسال فایل")
        )
        :row(
            builder:button_simple("send_voice", "🎤 ارسال صوت"),
            builder:button_simple("send_music", "🎵 ارسال موزیک")
        )
        :row(
            builder:button_simple("send_gif", "🔁 ارسال GIF"),
            builder:button_simple("gallery", "📸 گالری عکس")
        )
        :build()
end

-- هندلر پیام‌های متنی
bot:on_message()(function(self, msg)
    local text = msg.text or ""
    
    print("📨 دریافت: " .. text)
    
    if text == "/start" then
        local keyboard = create_media_menu()
        local welcome = "📁 **ربات ارسال مدیا**\n\n"
        welcome = welcome .. "این ربات قابلیت ارسال انواع فایل و مدیا را دارد.\n\n"
        welcome = welcome .. "📋 قابلیت‌ها:\n"
        welcome = welcome .. "• 🖼️ ارسال عکس\n"
        welcome = welcome .. "• 📄 ارسال فایل\n"
        welcome = welcome .. "• 🎤 ارسال صوت\n"
        welcome = welcome .. "• 🎵 ارسال موزیک\n"
        welcome = welcome .. "• 🔁 ارسال GIF\n"
        welcome = welcome .. "• 📸 گالری عکس\n\n"
        welcome = welcome .. "💡 از منوی زیر انتخاب کنید:"
        
        msg:reply(welcome, nil, keyboard)
        
    elseif text == "/media" then
        local keyboard = create_media_menu()
        msg:reply("📁 منوی مدیا:", nil, keyboard)
        
    elseif text == "/gallery" then
        send_photo_gallery(self, msg.chat_id)
        
    elseif text == "/send_voice" then
        -- ارسال فایل صوتی نمونه
        send_sample_voice(self, msg.chat_id)
        
    elseif text == "test" then
        -- تست ارسال تمام انواع مدیا
        test_all_media(self, msg.chat_id)
    end
end)

-- تابع ارسال گالری عکس
function send_photo_gallery(bot_instance, chat_id)
    print("📸 ارسال گالری عکس به " .. chat_id)
    
    -- عکس ۱
    bot_instance:send_image(chat_id, "examples/assets/nature.jpg", nil, 
        "🌲 **منظره طبیعت**\n\nعکس زیبایی از طبیعت بکر")
    
    -- عکس ۲ (اگر فایل وجود ندارد، از URL استفاده می‌کند)
    local success = pcall(function()
        bot_instance:send_image(chat_id, "examples/assets/city.jpg", nil,
            "🏙️ **نمای شهر**\n\nنمایی از یک شهر مدرن")
    end)
    
    if not success then
        -- استفاده از URL به عنوان fallback
        bot_instance:send_image(chat_id, 
            "https://picsum.photos/600/400", nil,
            "🏙️ **نمای شهر**\n\nعکس نمونه از اینترنت")
    end
    
    -- عکس ۳
    bot_instance:send_image(chat_id, 
        "https://picsum.photos/600/400?random=1", nil,
        "🎨 **اثر هنری**\n\nعکس هنری رندوم")
end

-- تابع ارسال صوت نمونه
function send_sample_voice(bot_instance, chat_id)
    print("🎤 ارسال صوت به " .. chat_id)
    
    local success = pcall(function()
        bot_instance:send_voice(chat_id, "examples/assets/sample.ogg", nil,
            "🎤 پیام صوتی نمونه\n\nاین یک پیام صوتی تست است")
    end)
    
    if not success then
        bot_instance:send_message(chat_id,
            "❌ فایل صوتی نمونه یافت نشد.\n\n💡 برای تست، یک فایل OGG در مسیر examples/assets/sample.ogg قرار دهید.")
    end
end

-- تابع تست تمام مدیا
function test_all_media(bot_instance, chat_id)
    print("🧪 تست تمام مدیا برای " .. chat_id)
    
    bot_instance:send_message(chat_id, "🧪 **شروع تست ارسال مدیا...**")
    
    -- ۱. ارسال عکس
    bot_instance:send_image(chat_id, 
        "https://picsum.photos/500/300", nil,
        "🖼️ تست عکس\n\nاین یک عکس تست است")
    
    -- ۲. ارسال فایل PDF نمونه
    bot_instance:send_message(chat_id, "📄 در حال ارسال فایل PDF...")
    
    local pdf_success = pcall(function()
        bot_instance:send_document(chat_id, "examples/assets/sample.pdf", nil,
            "📄 فایل PDF نمونه\n\nاین یک فایل PDF تست است")
    end)
    
    if not pdf_success then
        bot_instance:send_message(chat_id,
            "📄 **فایل PDF نمونه**\n\n(فایل فیزیکی موجود نیست)")
    end
    
    -- ۳. ارسال GIF
    bot_instance:send_message(chat_id, "🔁 در حال ارسال GIF...")
    bot_instance:send_gif(chat_id,
        "https://media.giphy.com/media/3o7aTskHEUdgCQAXde/giphy.gif", nil,
        "🔁 GIF تست\n\nانیمیشن نمونه")
    
    bot_instance:send_message(chat_id, "✅ **تست مدیا کامل شد!**")
end

-- هندلرهای callback برای منوی مدیا
bot:on_callback("send_photo")(function(self, msg)
    msg:reply("🖼️ در حال ارسال عکس...")
    
    self:send_image(msg.chat_id,
        "https://picsum.photos/600/400", nil,
        "🖼️ **عکس نمونه**\n\nاین یک عکس تست از ربات مدیا است")
end)

bot:on_callback("send_document")(function(self, msg)
    msg:reply("📄 در حال ارسال فایل...")
    
    local success = pcall(function()
        self:send_document(msg.chat_id, "examples/assets/sample.pdf", nil,
            "📄 **فایل PDF نمونه**\n\nاین یک فایل تست است")
    end)
    
    if not success then
        self:send_message(msg.chat_id,
            "📄 **فایل متنی نمونه**\n\nمحتوای فایل:\n\nاین یک فایل متنی نمونه است که از طریق ربات مدیا ارسال شده است.\n\n📅 تاریخ: " .. os.date("%Y-%m-%d") .. "\n🕒 زمان: " .. os.date("%H:%M:%S") .. "\n\n✅ ارسال موفقیت‌آمیز")
    end
end)

bot:on_callback("send_voice")(function(self, msg)
    msg:reply("🎤 در حال ارسال پیام صوتی...")
    send_sample_voice(self, msg.chat_id)
end)

bot:on_callback("send_music")(function(self, msg)
    msg:reply("🎵 در حال ارسال موزیک...")
    
    local success = pcall(function()
        self:send_music(msg.chat_id, "examples/assets/sample.mp3", nil,
            "🎵 **آهنگ نمونه**\n\nاین یک فایل صوتی تست است")
    end)
    
    if not success then
        self:send_message(msg.chat_id,
            "🎵 **آهنگ نمونه**\n\n(فایل صوتی موجود نیست)\n\n💡 برای تست، یک فایل MP3 در مسیر examples/assets/sample.mp3 قرار دهید.")
    end
end)

bot:on_callback("send_gif")(function(self, msg)
    msg:reply("🔁 در حال ارسال GIF...")
    
    self:send_gif(msg.chat_id,
        "https://media.giphy.com/media/3o7aTskHEUdgCQAXde/giphy.gif", nil,
        "🔁 **GIF نمونه**\n\nانیمیشن تست از ربات مدیا")
end)

bot:on_callback("gallery")(function(self, msg)
    msg:reply("📸 در حال ارسال گالری عکس...")
    send_photo_gallery(self, msg.chat_id)
end)

-- هندلر خطاهای مدیا
bot:on_message()(function(self, msg)
    local text = msg.text or ""
    
    -- اگر پیام با "ارسال" شروع شود
    if text:match("^ارسال عکس") then
        self:send_image(msg.chat_id,
            "https://picsum.photos/500/300?random=" .. os.time(), nil,
            "🖼️ عکس درخواستی\n\n" .. text)
            
    elseif text:match("^ارسال فایل") then
        self:send_message(msg.chat_id,
            "📄 **فایل متنی**\n\nمحتوای فایل:\n\nدرخواست: " .. text .. "\n\nتاریخ: " .. os.date("%Y-%m-%d") .. "\nچت آیدی: " .. msg.chat_id)
    end
end)

-- اجرای ربات
print("🎯 ربات مدیا آماده است!")
print("💡 از /start برای مشاهده منو استفاده کنید")

bot:run()
