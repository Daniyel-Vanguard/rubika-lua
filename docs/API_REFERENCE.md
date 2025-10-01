
# 📚 مرجع API

 کلاس اصلی: Robot
# متدهای اصلی
on_message(filters, commands)

ثبت هندلر برای پیام‌های دریافتی
```lua
bot:on_message()(function(self, msg)
    -- پردازش تمام پیام‌ها
end)

-- فقط پیام‌های متنی
bot:on_message(function(msg)
    return msg.text ~= nil
end)(function(self, msg)
    -- پردازش پیام‌های متنی
end)

-- فقط دستورات خاص
bot:on_message(nil, {"start", "help"})(function(self, msg)
    -- پردازش دستورات /start و /help
end)
```
on_callback(button_id)

ثبت هندلر برای کلیک دکمه‌ها
```lua
-- همه callback‌ها
bot:on_callback()(function(self, msg)
    print("دکمه فشرده شد:", msg.aux_data.button_id)
end)

-- callback خاص
bot:on_callback("my_button")(function(self, msg)
    msg:reply("دکمه من فشرده شد!")
end)
```
send_message(chat_id, text, chat_keypad, inline_keypad, ...)

ارسال پیام متنی
```lua
bot:send_message(chat_id, "سلام دنیا!")

-- با کیبورد
local keyboard = -- ساخت کیبورد
bot:send_message(chat_id, "پیام با کیبورد", nil, keyboard)
```
get_me()

دریافت اطلاعات ربات
```lua
local me = bot:get_me()
print("نام ربات:", me.data.bot.bot_title)
```
get_chat(chat_id)

دریافت اطلاعات چت
```lua
local chat = bot:get_chat(chat_id)
print("نام کاربر:", chat.data.chat.first_name)
```
get_name(chat_id)

دریافت نام کاربر
```lua
local name = bot:get_name(chat_id)
```
run()

اجرای ربات (حالت Polling)
```lua
bot:run()
```
# کلاس Message
### ویژگی‌ها

    chat_id - آیدی چت

    message_id - آیدی پیام

    sender_id - آیدی فرستنده

    text - متن پیام

    raw_data - داده‌های خام

    args - آرگومان‌های دستور

#متدها
reply(text, ...)

پاسخ به پیام
```lua
msg:reply("پاسخ به پیام")
```
# ارسال مدیا
send_image(chat_id, path, file_id, text, ...)
```lua
bot:send_image(chat_id, "photo.jpg", nil, "این یک عکس است")
```
send_document(chat_id, path, file_id, text, ...)
```lua
bot:send_document(chat_id, "file.pdf", nil, "فایل PDF")
```
send_voice(chat_id, path, file_id, text, ...)
```lua
bot:send_voice(chat_id, "voice.ogg", nil, "پیام صوتی")
```
send_music(chat_id, path, file_id, text, ...)
```lua
bot:send_music(chat_id, "music.mp3", nil, "آهنگ")
```
send_gif(chat_id, path, file_id, text, ...)
```lua
bot:send_gif(chat_id, "animation.gif", nil, "GIF")
```
# مدیریت پیام‌ها
edit_message_text(chat_id, message_id, text)
```lua
bot:edit_message_text(chat_id, message_id, "متن ویرایش شده")
```
delete_message(chat_id, message_id)
```lua
bot:delete_message(chat_id, message_id)
```
forward_message(from_chat_id, message_id, to_chat_id, ...)
```lua
bot:forward_message(chat1, msg_id, chat2)
```
# مدیریت کیبورد
remove_keypad(chat_id)
```lua
bot:remove_keypad(chat_id)
```
edit_chat_keypad(chat_id, chat_keypad)
```lua
local keyboard = -- ساخت کیبورد
bot:edit_chat_keypad(chat_id, keyboard)
```
edit_inline_keypad(chat_id, message_id, inline_keypad)
```lua
bot:edit_inline_keypad(chat_id, message_id, new_keyboard)
```
