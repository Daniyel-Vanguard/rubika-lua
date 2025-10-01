-- 🔍 ربات تشخیص نوع چت - کاربر، گروه، کانال

local rubika = require("rubika")

local bot = rubika.Robot:new("YOUR_BOT_TOKEN_HERE")

print("🔍 ربات تشخیص نوع چت فعال شد!")
print("💡 در هر چتی /info را ارسال کنید")

-- تابع ایجاد منوی مدیریت چت
local function create_chat_management_menu(chat_type)
    local builder = rubika.InlineBuilder:new()
    
    if chat_type == "User" then
        return builder
            :row(
                builder:button_simple("user_info", "👤 اطلاعات کاربر"),
                builder:button_simple("user_stats", "📊 آمار کاربر")
            )
            :build()
    elseif chat_type == "Group" then
        return builder
            :row(
                builder:button_simple("group_info", "👥 اطلاعات گروه"),
                builder:button_simple("group_members", "👥 لیست اعضا")
            )
            :row(
                builder:button_simple("group_stats", "📊 آمار گروه")
            )
            :build()
    elseif chat_type == "Channel" then
        return builder
            :row(
                builder:button_simple("channel_info", "📢 اطلاعات کانال"),
                builder:button_simple("channel_stats", "📊 آمار کانال")
            )
            :build()
    else
        return builder
            :row(
                builder:button_simple("unknown_info", "❓ اطلاعات چت")
            )
            :build()
    end
end

-- هندلر اصلی
bot:on_message()(function(self, msg)
    local text = msg.text or ""
    local chat_id = msg.chat_id
    
    print("📨 پیام از چت " .. chat_id .. ": " .. text)
    
    if text == "/start" then
        local chat_info = self:get_chat_info(chat_id)
        local welcome = chat_info.type_emoji .. " **به ربات تشخیص چت خوش آمدید!**\n\n"
        welcome = welcome .. "🔍 **نوع چت فعلی:** " .. chat_info.type_fa .. "\n"
        
        if chat_info.type == "User" then
            welcome = welcome .. "👤 **نام:** " .. (chat_info.first_name or "") .. " " .. (chat_info.last_name or "") .. "\n"
            welcome = welcome .. "🔗 **یوزرنیم:** @" .. (chat_info.username or "ندارد") .. "\n"
        else
            welcome = welcome .. "🏷️ **عنوان:** " .. (chat_info.title or "ندارد") .. "\n"
            welcome = welcome .. "👥 **تعداد اعضا:** " .. (chat_info.members_count or "نامعلوم") .. "\n"
        end
        
        welcome = welcome .. "\n📋 **دستورات قابل استفاده:**\n"
        welcome = welcome .. "• /info - اطلاعات کامل چت\n"
        welcome = welcome .. "• /type - تشخیص نوع چت\n"
        welcome = welcome .. "• /members - لیست اعضا (گروه/کانال)\n"
        welcome = welcome .. "• /stats - آمار چت\n\n"
        welcome = welcome .. "💡 از منوی زیر نیز می‌توانید استفاده کنید"
        
        local keyboard = create_chat_management_menu(chat_info.type)
        msg:reply(welcome, nil, keyboard)
        
    elseif text == "/info" then
        send_chat_info(self, msg)
        
    elseif text == "/type" then
        send_chat_type_info(self, msg)
        
    elseif text == "/members" then
        send_chat_members(self, msg)
        
    elseif text == "/stats" then
        send_chat_stats(self, msg)
        
    elseif text == "سلام" then
        local chat_info = self:get_chat_info(chat_id)
        local greeting = chat_info.type_emoji .. " سلام! "
        
        if chat_info.type == "User" then
            greeting = greeting .. (chat_info.first_name or "کاربر") .. " عزیز! 👋"
        elseif chat_info.type == "Group" then
            greeting = greeting .. "اعضای گروه! 👥"
        elseif chat_info.type == "Channel" then
            greeting = greeting .. "مخاطبان کانال! 📢"
        end
        
        msg:reply(greeting)
    end
end)

-- تابع ارسال اطلاعات چت
function send_chat_info(bot_instance, msg)
    local chat_id = msg.chat_id
    local chat_info = bot_instance:get_chat_info(chat_id)
    
    if not chat_info then
        msg:reply("❌ خطا در دریافت اطلاعات چت")
        return
    end
    
    local info_text = chat_info.type_emoji .. " **اطلاعات کامل چت**\n\n"
    info_text = info_text .. "🔸 **نوع:** " .. chat_info.type_fa .. " (" .. chat_info.type .. ")\n"
    
    if chat_info.type == "User" then
        info_text = info_text .. "🔸 **نام:** " .. (chat_info.first_name or "") .. " " .. (chat_info.last_name or "") .. "\n"
        info_text = info_text .. "🔸 **یوزرنیم:** @" .. (chat_info.username or "ندارد") .. "\n"
        info_text = info_text .. "🔸 **آیدی:** " .. chat_id .. "\n"
    else
        info_text = info_text .. "🔸 **عنوان:** " .. (chat_info.title or "ندارد") .. "\n"
        info_text = info_text .. "🔸 **یوزرنیم:** @" .. (chat_info.username or "ندارد") .. "\n"
        info_text = info_text .. "🔸 **تعداد اعضا:** " .. (chat_info.members_count or "نامعلوم") .. "\n"
        info_text = info_text .. "🔸 **آیدی:** " .. chat_id .. "\n"
    end
    
    info_text = info_text .. "🔸 **تأیید شده:** " .. (chat_info.is_verified and "✅" or "❌") .. "\n"
    info_text = info_text .. "🔸 **ربات:** " .. (chat_info.is_robot and "✅" or "❌") .. "\n"
    info_text = info_text .. "🔸 **حذف شده:** " .. (chat_info.is_deleted and "✅" : "❌") .. "\n"
    
    msg:reply(info_text)
end

-- تابع ارسال اطلاعات نوع چت
function send_chat_type_info(bot_instance, msg)
    local chat_id = msg.chat_id
    
    local type_info = "🔍 **تشخیص نوع چت**\n\n"
    
    if bot_instance:is_private_chat(chat_id) then
        type_info = type_info .. "✅ **چت خصوصی** 👤\n\n"
        type_info = type_info .. "• امکان ارسال پیام خصوصی\n"
        type_info = type_info .. "• دسترسی کامل به اطلاعات کاربر\n"
        type_info = type_info .. "• مناسب برای پشتیبانی و خدمات\n"
        
    elseif bot_instance:is_group(chat_id) then
        type_info = type_info .. "✅ **گروه** 👥\n\n"
        type_info = type_info .. "• امکان مدیریت اعضا\n"
        type_info = type_info .. "• قابلیت ارسال به همه اعضا\n"
        type_info = type_info .. "• مناسب برای جوامع و تیم‌ها\n"
        
    elseif bot_instance:is_channel(chat_id) then
        type_info = type_info .. "✅ **کانال** 📢\n\n"
        type_info = type_info .. "• امکان ارسال پیام به مخاطبان\n"
        type_info = type_info .. "• مناسب برای اطلاع‌رسانی\n"
        type_info = type_info .. "• معمولاً فقط ادمین می‌تواند ارسال کند\n"
        
    else
        type_info = type_info .. "❓ **نوع ناشناخته**\n\n"
        type_info = type_info .. "• نوع چت قابل تشخیص نیست\n"
    end
    
    type_info = type_info .. "\n💡 **نکته:** دسترسی ربات به اطلاعات بستگی به سطح دسترسی دارد"
    
    msg:reply(type_info)
end

-- تابع ارسال لیست اعضا
function send_chat_members(bot_instance, msg)
    local chat_id = msg.chat_id
    
    if bot_instance:is_private_chat(chat_id) then
        msg:reply("👤 **چت خصوصی**\n\nدر چت خصوصی فقط شما حضور دارید!")
        return
    end
    
    msg:reply("⏳ در حال دریافت لیست اعضا...")
    
    local members = bot_instance:get_chat_members(chat_id, 20)
    
    if not members or not members.data or not members.data.members then
        msg:reply("❌ خطا در دریافت لیست اعضا\n\n💡 ممکن است ربات دسترسی لازم را نداشته باشد")
        return
    end
    
    local members_text = "👥 **لیست اعضا**\n\n"
    local count = 0
    
    for _, member in ipairs(members.data.members) do
        count = count + 1
        members_text = members_text .. count .. ". "
        
        if member.first_name then
            members_text = members_text .. member.first_name
            if member.last_name then
                members_text = members_text .. " " .. member.last_name
            end
        else
            members_text = members_text .. "کاربر " .. count
        end
        
        if member.username then
            members_text = members_text .. " (@" .. member.username .. ")"
        end
        
        members_text = members_text .. "\n"
        
        -- محدودیت طول پیام
        if count >= 15 then
            members_text = members_text .. "\n... و سایر اعضا"
            break
        end
    end
    
    members_text = members_text .. "\n📊 **تعداد کل:** " .. count .. " عضو"
    
    msg:reply(members_text)
end

-- تابع ارسال آمار چت
function send_chat_stats(bot_instance, msg)
    local chat_id = msg.chat_id
    local chat_info = bot_instance:get_chat_info(chat_id)
    
    local stats = "📊 **آمار چت**\n\n"
    
    if chat_info.type == "User" then
        stats = stats .. "👤 **چت خصوصی با کاربر**\n\n"
        stats = stats .. "🔹 نوع: کاربر عادی\n"
        stats = stats .. "🔹 وضعیت: " .. (chat_info.is_verified and "تأیید شده ✅" : "عادی") .. "\n"
        stats = stats .. "🔹 ربات: " .. (chat_info.is_robot and "بله 🤖" : "خیر 👤") .. "\n"
        
    elseif chat_info.type == "Group" then
        stats = stats .. "👥 **گروه**\n\n"
        stats = stats .. "🔹 تعداد اعضا: " .. (chat_info.members_count or "نامعلوم") .. "\n"
        stats = stats .. "🔹 نوع: گروه عمومی\n"
        stats = stats .. "🔹 وضعیت: فعال\n"
        
    elseif chat_info.type == "Channel" then
        stats = stats .. "📢 **کانال**\n\n"
        stats = stats .. "🔹 تعداد اعضا: " .. (chat_info.members_count or "نامعلوم") .. "\n"
        stats = stats .. "🔹 نوع: کانال اطلاع‌رسانی\n"
        stats = stats .. "🔹 وضعیت: " .. (chat_info.is_verified and "تأیید شده ✅" : "عادی") .. "\n"
    end
    
    stats = stats .. "\n🆔 **آیدی چت:** " .. chat_id
    stats = stats .. "\n📅 **تاریخ بررسی:** " .. os.date("%Y-%m-%d %H:%M")
    
    msg:reply(stats)
end

-- هندلرهای callback برای منوی مدیریت
bot:on_callback("user_info")(function(self, msg)
    send_chat_info(self, msg)
end)

bot:on_callback("user_stats")(function(self, msg)
    send_chat_stats(self, msg)
end)

bot:on_callback("group_info")(function(self, msg)
    send_chat_info(self, msg)
end)

bot:on_callback("group_members")(function(self, msg)
    send_chat_members(self, msg)
end)

bot:on_callback("group_stats")(function(self, msg)
    send_chat_stats(self, msg)
end)

bot:on_callback("channel_info")(function(self, msg)
    send_chat_info(self, msg)
end)

bot:on_callback("channel_stats")(function(self, msg)
    send_chat_stats(self, msg)
end)

-- هندلر برای پیام‌های ارسالی در انواع مختلف چت
bot:on_message()(function(self, msg)
    local chat_id = msg.chat_id
    local chat_type = self:get_chat_type(chat_id)
    
    -- لاگ نوع چت
    print("💬 پیام در " .. 
        (chat_type == "User" and "چت خصوصی 👤" or 
         chat_type == "Group" and "گروه 👥" or 
         chat_type == "Channel" and "کانال 📢" or 
         "ناشناخته ❓") .. 
        " از " .. chat_id)
    
    -- پاسخ خودکار بر اساس نوع چت
    if msg.text and msg.text:match("^ربات") then
        local response = ""
        
        if chat_type == "User" then
            response = "👤 در خدمت شما هستم!"
        elseif chat_type == "Group" then
            response = "👥 به گروه خوش آمدید! من ربات این گروه هستم."
        elseif chat_type == "Channel" then
            response = "📢 به کانال خوش آمدید! من ربات مدیریت کانال هستم."
        else
            response = "🤖 بله؟"
        end
        
        msg:reply(response)
    end
end)

-- اجرای ربات
print("🎯 ربات تشخیص نوع چت آماده است!")
print("💡 در هر چتی /info را ارسال کنید")

bot:run()
