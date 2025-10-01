# ⌨️ راهنمای کیبوردها

## انواع کیبورد

### ۱. اینلاین کیبورد (Inline Keyboard)
- زیر پیام نمایش داده می‌شود
- فقط در وب‌هوک کار می‌کند
- callback ارسال می‌کند

### ۲. کیبورد چت (Chat Keypad)  
- جایگزین کیبورد معمولی می‌شود
- در حالت Polling نمایش داده می‌شود (اما callback ندارد)
- همیشه نمایش داده می‌شود

## اینلاین کیبورد

### ساختار پایه

```lua
local builder = rubika.InlineBuilder:new()
local keyboard = builder
    :row(
        builder:button_simple("btn1", "دکمه ۱"),
        builder:button_simple("btn2", "دکمه ۲")
    )
    :row(
        builder:button_simple("btn3", "دکمه ۳")
    )
    :build()

msg:reply("پیام با کیبورد", nil, keyboard)
```
# انواع دکمه‌ها
دکمه ساده
```lua
builder:button_simple("button_id", "متن دکمه")
```
# دکمه لینک
```lua
builder:button_link("link_btn", "وبسایت", "https://example.com")
```
دکمه انتخاب (Selection)
```lua
builder:button_selection("select_btn", "انتخاب شهر", {
    selection_id = "city_selection",
    search_type = "None", 
    get_type = "Local",
    items = {
        {id = "tehran", title = "تهران"},
        {id = "mashhad", title = "مشهد"}
    },
    is_multi_selection = false,
    columns_count = "2",
    title = "شهر خود را انتخاب کنید"
})
```
دکمه تقویم
```lua
builder:button_calendar("cal_btn", "تاریخ", "DatePersian", "1402/10/15")
```
دکمه انتخاب عدد
```lua
builder:button_number_picker("num_btn", "سن", "1", "100", "25")
```
دکمه انتخاب از لیست
```lua
builder:button_string_picker("str_btn", "رنگ", {"قرمز", "آبی", "سبز"}, "قرمز")
```
دکمه موقعیت‌یاب
```lua
builder:button_location("loc_btn", "Picker", "https://example.com/loc.png")
```
هندلر callback
```lua
bot:on_callback("button_id")(function(self, msg)
    msg:reply("دکمه فشرده شد!")
end)

-- هندلر برای همه دکمه‌ها
bot:on_callback()(function(self, msg)
    local button_id = msg.aux_data.button_id
    msg:reply("دکمه " .. button_id .. " فشرده شد")
end)
```
# کیبورد چت
ساخت کیبورد چت
```lua
local chat_builder = rubika.ChatKeypadBuilder:new()
local chat_keyboard = chat_builder
    :row(
        chat_builder:button("btn1", "دکمه ۱"),
        chat_builder:button("btn2", "دکمه ۲")
    )
    :build()

msg:reply("پیام با کیبورد چت", chat_keyboard)
```
حذف کیبورد چت
```lua
bot:remove_keypad(chat_id)
```
مثال عملی: منوی ربات
```lua
local function create_main_menu()
    local builder = rubika.InlineBuilder:new()
    return builder
        :row(
            builder:button_simple("products", "🛍️ محصولات"),
            builder:button_simple("support", "🎯 پشتیبانی")
        )
        :row(
            builder:button_simple("about", "ℹ️ درباره ما"),
            builder:button_link("website", "🌐 وبسایت", "https://example.com")
        )
        :row(
            builder:button_selection("category", "📂 دسته‌بندی", {
                selection_id = "cat_sel",
                items = {
                    {id = "tech", title = "تکنولوژی"},
                    {id = "art", title = "هنر"},
                    {id = "sport", title = "ورزش"}
                },
                columns_count = "2",
                title = "لطفا دسته‌بندی انتخاب کنید"
            })
        )
        :build()
end

bot:on_message()(function(self, msg)
    if msg.text == "/start" then
        local keyboard = create_main_menu()
        msg:reply("🎪 به فروشگاه ما خوش آمدید!", nil, keyboard)
    end
end)

-- هندلر دکمه‌ها
bot:on_callback("products")(function(self, msg)
    msg:reply("📦 بخش محصولات")
end)

bot:on_callback("support")(function(self, msg)
    msg:reply("🎯 بخش پشتیبانی")
end)
```
### نکات مهم

- اینلاین کیبورد فقط در وب‌هوک کار می‌کند

- کیبورد چت در Polling نمایش داده می‌شود اما callback ندارد
