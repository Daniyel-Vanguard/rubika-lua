# 🌐 راهنمای کامل Webhook

## تفاوت Webhook و Polling

| ویژگی | Webhook | Polling |
|-------|---------|---------|
| سرعت | ⚡ فوری | 🐢 تأخیر چند ثانیه |
| منابع | کم مصرف | پر مصرف (درخواست مداوم) |
| قابلیت‌ها | ✅ کامل | ❌ محدود (بدون کیبورد) |
| پیچیدگی | 🔧 متوسط | 🟢 ساده |
| نیازمندی | سرور عمومی | اینترنت معمولی |

## راه‌اندازی Webhook

### قدم ۱: تنظیم وب‌هوک

```lua
local rubika = require("rubika")

local bot = rubika.Robot:new("YOUR_BOT_TOKEN")

-- تنظیم آدرس وب‌هوک (یکبار اجرا شود)
local webhook_url = "https://yourdomain.com/webhook"
local result = bot:update_bot_endpoint(webhook_url, "Webhook")

print("Webhook setup:", require("cjson").encode(result))
```
### قدم ۲: ایجاد سرور وب‌هوک
#### فایل webhook_server.lua:
```lua
local http = require("http")
local json = require("cjson")
local rubika = require("rubika")

local bot = rubika.Robot:new("YOUR_BOT_TOKEN")

local function webhook_handler(req, res)
    if req.method ~= "POST" then
        res:write_head(405, {["Content-Type"] = "text/plain"})
        res:finish("Method Not Allowed")
        return
    end
    
    local body = ""
    req:on("data", function(chunk)
        body = body .. chunk
    end)
    
    req:on("end", function()
        print("📨 Webhook received")
        
        local success, update = pcall(json.decode, body)
        if success then
            process_webhook_update(update)
        end
        
        res:write_head(200, {["Content-Type"] = "application/json"})
        res:finish(json.encode({status = "ok"}))
    end)
end

function process_webhook_update(update)
    if update.type == "NewMessage" then
        handle_message(update)
    elseif update.type == "Callback" then
        handle_callback(update)
    end
end

function handle_message(update)
    local msg = update.new_message or {}
    local chat_id = update.chat_id
    local text = msg.text or ""
    
    if text == "/start" then
        local builder = rubika.InlineBuilder:new()
        local keyboard = builder
            :row(
                builder:button_simple("help", "📖 راهنما"),
                builder:button_simple("about", "ℹ️ درباره")
            )
            :build()
        
        bot:send_message(chat_id, "به ربات وب‌هوک خوش آمدید! 🌐", nil, keyboard)
    end
end

function handle_callback(update)
    local aux_data = update.aux_data or {}
    local button_id = aux_data.button_id
    local chat_id = update.chat_id
    
    if button_id == "help" then
        bot:send_message(chat_id, "این راهنمای ربات است!")
    end
end

-- راه‌اندازی سرور
local server = http.create_server(webhook_handler)
server:listen(8080)

print("🚀 Webhook server running on port 8080")
```
#### تست با Ngrok
```bash
# نصب
yay -S ngrok

# احراز هویت
ngrok authtoken YOUR_AUTH_TOKEN

# اجرا
ngrok http 8080
```
#### تنظیم وب‌هوک با Ngrok
```lua
local ngrok_url = "https://YOUR_NGROK_SUBDOMAIN.ngrok.io/webhook"
local result = bot:update_bot_endpoint(ngrok_url, "Webhook")
```
### دپلوی روی سرور واقعی
#### با Nginx
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    location /webhook {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```
#### با Docker
```dockerfile
FROM alpine:latest

RUN apk add --no-cache lua5.4 lua5.4-dev
RUN apk add --no-cache git
RUN git clone https://github.com/yourusername/rubika-bot-lua /app

WORKDIR /app
CMD ["lua", "webhook_server.lua"]
```
### مدیریت خطاها
#### بررسی وضعیت وب‌هوک
```lua
local function check_webhook_status()
    local result = bot:update_bot_endpoint("", "GetStatus")
    print("Webhook status:", json.encode(result))
end
```
#### fallback به Polling
```lua
local function start_bot()
    local webhook_success = setup_webhook()
    
    if not webhook_success then
        print("⚠️ Falling back to Polling mode")
        bot:run()  -- حالت Polling
    end
end
```
### امنیت
#### تأیید IP روبیکا
```lua
local RUBIKA_IPS = {
    "185.143.232.0/24",
    "185.143.233.0/24"
}

function is_rubika_ip(ip)
    -- منطق بررسی IP
    return true
end
```
#### بررسی Signature
```lua
function verify_signature(headers, body)
    -- بررسی signature header
    return true
end
```
### مانیتورینگ
#### سلامت سرویس
```lua
local function health_check()
    return {
        status = "healthy",
        timestamp = os.time(),
        mode = "webhook"
    }
end
```
#### لاگ‌گیری
```lua
function log_webhook(update)
    local log_entry = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        type = update.type,
        chat_id = update.chat_id,
        text = update.new_message and update.new_message.text or "N/A"
    }
    
    print("📊 Webhook log:", json.encode(log_entry))
end
```
### بهترین روش‌ها

1.همیشه خطاها را مدیریت کنید

2.از HTTPS استفاده کنید

3.سرور را مانیتور کنید

4.لاگ‌های مناسب داشته باشید

Plan B برای fallback داشته باشید
