-- examples/keyboard_bot.lua
-- ⌨️ ربات با کیبورد اینلاین پیشرفته

local rubika = require("rubika")

local bot = rubika.Robot:new("YOUR_BOT_TOKEN_HERE")

print("🎪 ربات کیبورد فعال شد!")
print("💡 از /start برای نمایش منو استفاده کنید")

-- تابع ایجاد منوی اصلی
local function create_main_menu()
    local builder = rubika.InlineBuilder:new()
    return builder
        :row(
            builder:button_simple("products", "🛍️ محصولات"),
            builder:button_simple("services", "🎯 خدمات")
        )
        :row(
            builder:button_simple("support", "💬 پشتیبانی"),
            builder:button_simple("about", "ℹ️ درباره ما")
        )
        :row(
            builder:button_link("website", "🌐 وبسایت", "https://example.com"),
            builder:button_link("channel", "📢 کانال", "https://rubika.ir/example")
        )
        :build()
end

-- تابع ایجاد منوی محصولات
local function create_products_menu()
    local builder = rubika.InlineBuilder:new()
    return builder
        :row(
            builder:button_simple("product1", "📱 محصول ۱"),
            builder:button_simple("product2", "💻 محصول ۲")
        )
        :row(
            builder:button_simple("product3", "⌚ محصول ۳"),
            builder:button_simple("product4", "🎧 محصول ۴")
        )
        :row(
            builder:button_simple("back_main", "🔙 بازگشت")
        )
        :build()
end

-- تابع ایجاد منوی خدمات
local function create_services_menu()
    local builder = rubika.InlineBuilder:new()
    return builder
        :row(
            builder:button_selection("city", "🏙️ انتخاب شهر", {
                selection_id = "city_selection",
                search_type = "None",
                get_type = "Local",
                items = {
                    {id = "tehran", title = "تهران", description = "پایتخت"},
                    {id = "mashhad", title = "مشهد", description = "شهر زیارتی"},
                    {id = "shiraz", title = "شیراز", description = "شهر فرهنگی"},
                    {id = "esfahan", title = "اصفهان", description = "شهر تاریخی"}
                },
                is_multi_selection = false,
                columns_count = "2",
                title = "شهر خود را انتخاب کنید"
            })
        )
        :row(
            builder:button_string_picker("category", "📂 دسته‌بندی", 
                {"تکنولوژی", "هنر", "ورزش", "آموزش"}, "تکنولوژی")
        )
        :row(
            builder:button_back_main("بازگشت")
        )
        :build()
end

-- تابع ایجاد منوی پیشرفته
local function create_advanced_menu()
    local builder = rubika.InlineBuilder:new()
    return builder
        :row(
            builder:button_calendar("birthday", "📅 تاریخ تولد", "DatePersian", "1370/01/01"),
            builder:button_number_picker("age", "🔢 سن", "18", "80", "25")
        )
        :row(
            builder:button_textbox("name", "📝 نام کامل", "SingleLine", "String", "نام و نام خانوادگی..."),
            builder:button_textbox("bio", "📄 بیوگرافی", "MultiLine", "String", "درباره خود بنویسید...")
        )
        :row(
            builder:button_back_main("بازگشت به اصلی")
        )
        :build()
end

-- هندلر پیام‌های متنی
bot:on_message()(function(self, msg)
    local text = msg.text or ""
    
    print("📨 دریافت: " .. text)
    
    if text == "/start" or text == "منو" then
        local keyboard = create_main_menu()
        local welcome = "🎪 **به فروشگاه آنلاین خوش آمدید!**\n\n"
        welcome = welcome .. "لطفاً از منوی زیر انتخاب کنید:\n\n"
        welcome = welcome .. "🛍️ **محصولات** - مشاهده محصولات ما\n"
        welcome = welcome .. "🎯 **خدمات** - خدمات قابل ارائه\n"
        welcome = welcome .. "💬 **پشتیبانی** - ارتباط با پشتیبانی\n"
        welcome = welcome .. "ℹ️ **درباره** - اطلاعات شرکت\n\n"
        welcome = welcome .. "🌐 **وبسایت** - بازدید از سایت ما"
        
        msg:reply(welcome, nil, keyboard)
        
    elseif text == "/help" then
        msg:reply("📖 **راهنمای کیبورد:**\n\nاین ربات از کیبورد اینلاین استفاده می‌کند.\n\n💡 نکات:\n• روی دکمه‌ها کلیک کنید\n• از منوها برای导航 استفاده کنید\n• کیبوردها در وب‌هوک کامل کار می‌کنند")
        
    elseif text == "ساعت" then
        msg:reply("🕒 " .. os.date("%Y-%m-%d %H:%M:%S"))
    end
end)

-- هندلرهای callback برای منوی اصلی
bot:on_callback("products")(function(self, msg)
    local keyboard = create_products_menu()
    msg:reply("🛍️ **محصولات ما:**\n\nلطفاً محصول مورد نظر را انتخاب کنید:", nil, keyboard)
end)

bot:on_callback("services")(function(self, msg)
    local keyboard = create_services_menu()
    msg:reply("🎯 **خدمات ما:**\n\nلطفاً خدمات مورد نیاز را انتخاب کنید:", nil, keyboard)
end)

bot:on_callback("support")(function(self, msg)
    local builder = rubika.InlineBuilder:new()
    local keyboard = builder
        :row(
            builder:button_simple("call", "📞 تماس تلفنی"),
            builder:button_simple("email", "📧 ارسال ایمیل")
        )
        :row(
            builder:button_simple("ticket", "🎫 تیکت پشتیبانی"),
            builder:button_back_main("بازگشت")
        )
        :build()
    
    msg:reply("💬 **پشتیبانی:**\n\nراه‌های ارتباط با پشتیبانی:", nil, keyboard)
end)

bot:on_callback("about")(function(self, msg)
    local me = bot:get_me()
    local bot_info = me.data.bot
    
    local about = "ℹ️ **درباره ما:**\n\n"
    about = about .. "شرکت نمونه با سال‌ها تجربه در زمینه:\n\n"
    about = about .. "✅ ارائه محصولات با کیفیت\n"
    about = about .. "✅ خدمات پس از فروش عالی\n"
    about = about .. "✅ پشتیبانی 24 ساعته\n\n"
    about = about .. "🤖 این ربات: " .. bot_info.bot_title .. "\n"
    about = about .. "🌐 آدرس: " .. (bot_info.share_url or "ندارد")
    
    msg:reply(about)
end)

-- هندلرهای callback برای منوی محصولات
bot:on_callback("product1")(function(self, msg)
    msg:reply("📱 **محصول ۱:**\n\n• نام: آیفون 14\n• قیمت: 50,000,000 تومان\n• موجودی: ✅\n\n💡 برای خرید با پشتیبانی تماس بگیرید.")
end)

bot:on_callback("product2")(function(self, msg)
    msg:reply("💻 **محصول ۲:**\n\n• نام: مک‌بوک پرو\n• قیمت: 120,000,000 تومان\n• موجودی: ✅\n\n💡 برای خرید با پشتیبانی تماس بگیرید.")
end)

bot:on_callback("product3")(function(self, msg)
    msg:reply("⌚ **محصول ۳:**\n\n• نام: اپل واچ\n• قیمت: 25,000,000 تومان\n• موجودی: ✅\n\n💡 برای خرید با پشتیبانی تماس بگیرید.")
end)

bot:on_callback("product4")(function(self, msg)
    msg:reply("🎧 **محصول ۴:**\n\n• نام: ایرپادز\n• قیمت: 15,000,000 تومان\n• موجودی: ✅\n\n💡 برای خرید با پشتیبانی تماس بگیرید.")
end)

-- هندلرهای callback برای منوی خدمات
bot:on_callback("call")(function(self, msg)
    msg:reply("📞 **تماس تلفنی:**\n\nشماره تماس: 021-12345678\n\nساعات کاری: 9 صبح تا 5 عصر")
end)

bot:on_callback("email")(function(self, msg)
    msg:reply("📧 **ایمیل پشتیبانی:**\n\nآدرس: support@example.com\n\nپاسخگویی: 24 ساعته")
end)

bot:on_callback("ticket")(function(self, msg)
    msg:reply("🎫 **سیستم تیکت:**\n\nلطفاً مشکل خود را به صورت کامل شرح دهید:\n\n1. نوع مشکل\n2. تاریخ وقوع\n3. تصاویر مربوطه\n\n📧 ارسال به: tickets@example.com")
end)

-- هندلر بازگشت
bot:on_callback("back_main")(function(self, msg)
    local keyboard = create_main_menu()
    msg:reply("🔙 به منوی اصلی بازگشتید:", nil, keyboard)
end)

-- هندلر عمومی برای سایر callback‌ها
bot:on_callback()(function(self, msg)
    local button_id = msg.aux_data and msg.aux_data.button_id or "ناشناس"
    print("🔘 دکمه فشرده شد: " .. button_id)
end)

-- اجرای ربات
bot:run()
