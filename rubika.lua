local cjson = require("cjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local API_URL = "https://botapi.rubika.ir/v3"

local function show_last_six_words(text)
    text = text:gsub("^%s*(.-)%s*$", "%1")
    return text:sub(-6)
end

local Message = {}
Message.__index = Message

function Message:new(bot, chat_id, message_id, sender_id, text, raw_data)
    local obj = {
        bot = bot,
        chat_id = chat_id,
        message_id = message_id,
        sender_id = sender_id,
        text = text,
        raw_data = raw_data or {},
        aux_data = raw_data.aux_data or nil,
        args = {}
    }
    setmetatable(obj, Message)
    return obj
end

function Message:reply(text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type)
    return self.bot:send_message(self.chat_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type)
end

local InlineMessage = {}
InlineMessage.__index = InlineMessage

function InlineMessage:new(bot, raw_data)
    local obj = {
        bot = bot,
        raw_data = raw_data or {}
    }
    setmetatable(obj, InlineMessage)
    return obj
end

local InlineBuilder = {}
InlineBuilder.__index = InlineBuilder

function InlineBuilder:new()
    local obj = { rows = {} }
    setmetatable(obj, InlineBuilder)
    return obj
end

function InlineBuilder:row(...)
    local buttons = {...}
    if #buttons == 0 then
        error("حداقل یک دکمه باید به row داده شود")
    end
    table.insert(self.rows, {buttons = buttons})
    return self
end

function InlineBuilder:button_simple(id, text)
    return {id = id, type = "Simple", button_text = text}
end

function InlineBuilder:button_selection(id, text, selection)
    return {
        id = id,
        type = "Selection",
        button_text = text,
        button_selection = selection
    }
end

function InlineBuilder:button_calendar(id, title, type_, default_value, min_year, max_year)
    local calendar = {title = title, type = type_}
    if default_value then calendar.default_value = default_value end
    if min_year then calendar.min_year = min_year end
    if max_year then calendar.max_year = max_year end
    return {
        id = id,
        type = "Calendar",
        button_text = title,
        button_calendar = calendar
    }
end

function InlineBuilder:button_number_picker(id, title, min_value, max_value, default_value)
    local picker = {title = title, min_value = min_value, max_value = max_value}
    if default_value then picker.default_value = default_value end
    return {
        id = id,
        type = "NumberPicker",
        button_text = title,
        button_number_picker = picker
    }
end

function InlineBuilder:button_string_picker(id, title, items, default_value)
    local picker = {items = items}
    if default_value then picker.default_value = default_value end
    if title then picker.title = title end
    return {
        id = id,
        type = "StringPicker",
        button_text = title or "انتخاب",
        button_string_picker = picker
    }
end

function InlineBuilder:button_location(id, type_, location_image_url, default_pointer_location, default_map_location, title)
    local loc = {type = type_, location_image_url = location_image_url}
    if default_pointer_location then loc.default_pointer_location = default_pointer_location end
    if default_map_location then loc.default_map_location = default_map_location end
    if title then loc.title = title end
    return {
        id = id,
        type = "Location",
        button_text = title or "موقعیت مکانی",
        button_location = loc
    }
end

function InlineBuilder:button_textbox(id, title, type_line, type_keypad, place_holder, default_value)
    local textbox = {type_line = type_line, type_keypad = type_keypad}
    if place_holder then textbox.place_holder = place_holder end
    if default_value then textbox.default_value = default_value end
    if title then textbox.title = title end
    return {
        id = id,
        type = "Textbox",
        button_text = title or "متن",
        button_textbox = textbox
    }
end

function InlineBuilder:button_payment(id, title, amount, description)
    local payment = {title = title, amount = amount}
    if description then payment.description = description end
    return {
        id = id,
        type = "Payment",
        button_text = title,
        button_payment = payment
    }
end

function InlineBuilder:button_camera_image(id, title)
    return {id = id, type = "CameraImage", button_text = title}
end

function InlineBuilder:button_camera_video(id, title)
    return {id = id, type = "CameraVideo", button_text = title}
end

function InlineBuilder:button_gallery_image(id, title)
    return {id = id, type = "GalleryImage", button_text = title}
end

function InlineBuilder:button_gallery_video(id, title)
    return {id = id, type = "GalleryVideo", button_text = title}
end

function InlineBuilder:button_file(id, title)
    return {id = id, type = "File", button_text = title}
end

function InlineBuilder:button_audio(id, title)
    return {id = id, type = "Audio", button_text = title}
end

function InlineBuilder:button_record_audio(id, title)
    return {id = id, type = "RecordAudio", button_text = title}
end

function InlineBuilder:button_my_phone_number(id, title)
    return {id = id, type = "MyPhoneNumber", button_text = title}
end

function InlineBuilder:button_my_location(id, title)
    return {id = id, type = "MyLocation", button_text = title}
end

function InlineBuilder:button_link(id, title, url)
    return {id = id, type = "Link", button_text = title, url = url}
end

function InlineBuilder:button_ask_my_phone_number(id, title)
    return {id = id, type = "AskMyPhoneNumber", button_text = title}
end

function InlineBuilder:button_ask_location(id, title)
    return {id = id, type = "AskLocation", button_text = title}
end

function InlineBuilder:button_barcode(id, title)
    return {id = id, type = "Barcode", button_text = title}
end

function InlineBuilder:build()
    return {rows = self.rows}
end

local ChatKeypadBuilder = {}
ChatKeypadBuilder.__index = ChatKeypadBuilder

function ChatKeypadBuilder:new()
    local obj = { rows = {} }
    setmetatable(obj, ChatKeypadBuilder)
    return obj
end

function ChatKeypadBuilder:row(...)
    local buttons = {...}
    table.insert(self.rows, {buttons = buttons})
    return self
end

function ChatKeypadBuilder:button(id, text, type)
    return {id = id, type = type or "Simple", button_text = text}
end

function ChatKeypadBuilder:build(resize_keyboard, on_time_keyboard)
    return {
        rows = self.rows,
        resize_keyboard = resize_keyboard ~= false,
        on_time_keyboard = on_time_keyboard or false
    }
end

local function create_simple_keyboard(buttons)
    local keyboard = {rows = {}}
    for _, row in ipairs(buttons) do
        local row_buttons = {}
        for _, text in ipairs(row) do
            table.insert(row_buttons, {id = "btn_" .. text, type = "Simple", button_text = text})
        end
        table.insert(keyboard.rows, {buttons = row_buttons})
    end
    keyboard.resize_keyboard = true
    keyboard.on_time_keyboard = false
    return keyboard
end

local Robot = {}
Robot.__index = Robot

function Robot:new(token, session_name, auth, Key, platform, timeout)
    local obj = {
        token = token,
        timeout = timeout or 10,
        auth = auth,
        session_name = session_name,
        Key = Key,
        platform = platform or "web",
        _offset_id = nil,
        sessions = {},
        _callback_handler = nil,
        _message_handler = nil,
        _inline_query_handler = nil,
        _callback_handlers = {}
    }
    setmetatable(obj, Robot)
    return obj
end

function Robot:_post(method, data)
    local url = API_URL .. "/" .. self.token .. "/" .. method
    local json_data = cjson.encode(data)
    
    local response_body = {}
    local request = {
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #json_data
        },
        source = ltn12.source.string(json_data),
        sink = ltn12.sink.table(response_body)
    }
    
    local success, status_code = https.request(request)
    
    if not success then
        error("API request failed: " .. (status_code or "unknown error"))
    end
    
    local response_text = table.concat(response_body)
    return cjson.decode(response_text)
end

function Robot:get_me()
    return self:_post("getMe", {})
end

function Robot:on_message(filters, commands)
    return function(func)
        self._message_handler = {
            func = func,
            filters = filters,
            commands = commands
        }
        return func
    end
end

function Robot:on_callback(button_id)
    return function(func)
        table.insert(self._callback_handlers, {
            func = func,
            button_id = button_id
        })
        return func
    end
end

function Robot:on_inline_query()
    return function(func)
        self._inline_query_handler = func
        return func
    end
end

function Robot:_process_update(update)
    if update.type == 'ReceiveQuery' then
        local msg = update.inline_message or {}
        if self._inline_query_handler then
            local context = InlineMessage:new(self, msg)
            self._inline_query_handler(self, context)
        end
        return
    end

    if update.type == 'NewMessage' then
        local msg = update.new_message or {}
        local chat_id = update.chat_id
        local message_id = msg.message_id
        local sender_id = msg.sender_id
        local text = msg.text

        if msg.time and (os.time() - tonumber(msg.time)) > 20 then
            return
        end

        local context = Message:new(self, chat_id, message_id, sender_id, text, msg)

        if context.aux_data and #self._callback_handlers > 0 then
            for _, handler in ipairs(self._callback_handlers) do
                if not handler.button_id or context.aux_data.button_id == handler.button_id then
                    handler.func(self, context)
                    return
                end
            end
        end

        if self._message_handler then
            local handler = self._message_handler

            if handler.commands then
                if not context.text or not context.text:match("^/") then
                    return
                end
                local parts = {}
                for part in context.text:gmatch("%S+") do
                    table.insert(parts, part)
                end
                local cmd = parts[1]:sub(2)
                local found = false
                for _, command in ipairs(handler.commands) do
                    if command == cmd then
                        found = true
                        break
                    end
                end
                if not found then
                    return
                end
                context.args = {}
                for i = 2, #parts do
                    table.insert(context.args, parts[i])
                end
            end

            if handler.filters and not handler.filters(context) then
                return
            end

            handler.func(self, context)
        end
    end
end

function Robot:run()
    if self._offset_id == nil then
        local success, latest = pcall(function() 
            return self:get_updates(100) 
        end)
        if success and latest and latest.data and latest.data.updates then
            self._offset_id = latest.data.next_offset_id
        end
    end

    while true do
        local success, updates = pcall(function()
            return self:get_updates(self._offset_id, 100)
        end)
        if success and updates and updates.data then
            for _, update in ipairs(updates.data.updates or {}) do
                self:_process_update(update)
            end
            self._offset_id = updates.data.next_offset_id or self._offset_id
        end
        os.execute("sleep 1")
    end
end

function Robot:get_chat_type(chat_id)
    local chat = self:get_chat(chat_id)
    if chat and chat.data and chat.data.chat then
        return chat.data.chat.type or "User"
    end
    return "User"
end

function Robot:is_private_chat(chat_id)
    return self:get_chat_type(chat_id) == "User"
end

function Robot:is_group(chat_id)
    return self:get_chat_type(chat_id) == "Group"
end

function Robot:is_channel(chat_id)
    return self:get_chat_type(chat_id) == "Channel"
end

function Robot:get_chat_info(chat_id)
    local chat = self:get_chat(chat_id)
    if not chat or not chat.data or not chat.data.chat then
        return nil
    end
    
    local chat_data = chat.data.chat
    local info = {
        id = chat_id,
        type = chat_data.type or "User",
        title = chat_data.title,
        first_name = chat_data.first_name,
        last_name = chat_data.last_name,
        username = chat_data.username,
        is_verified = chat_data.is_verified or false,
        is_robot = chat_data.is_robot or false,
        is_deleted = chat_data.is_deleted or false,
        members_count = chat_data.members_count or 1
    }
    
    if info.type == "User" then
        info.type_fa = "کاربر"
        info.type_emoji = "👤"
    elseif info.type == "Group" then
        info.type_fa = "گروه"
        info.type_emoji = "👥"
    elseif info.type == "Channel" then
        info.type_fa = "کانال"
        info.type_emoji = "📢"
    else
        info.type_fa = "ناشناخته"
        info.type_emoji = "❓"
    end
    
    return info
end

function Robot:get_chat_members(chat_id, limit)
    limit = limit or 50
    local result = self:_post("getChatMembers", {
        chat_id = chat_id,
        limit = limit
    })
    return result
end


function Robot:is_user_in_chat(chat_id, user_id)
    local members = self:get_chat_members(chat_id)
    if members and members.data and members.data.members then
        for _, member in ipairs(members.data.members) do
            if member.user_id == user_id then
                return true
            end
        end
    end
    return false
end

function Robot:send_smart_message(chat_id, text, ...)
    local chat_type = self:get_chat_type(chat_id)
    local prefix = ""
    
    if chat_type == "Group" then
        prefix = "👥 گروه: "
    elseif chat_type == "Channel" then
        prefix = "📢 کانال: "
    else
        prefix = "👤 کاربر: "
    end
    
    return self:send_message(chat_id, prefix .. text, ...)
end


function Robot:send_message(chat_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type)
    local payload = {
        chat_id = chat_id,
        text = text,
        disable_notification = disable_notification or false
    }
    
    if chat_keypad then 
        payload.chat_keypad = chat_keypad
        payload.chat_keypad_type = chat_keypad_type or "New"
    end
    
    if inline_keypad then 
        payload.inline_keypad = inline_keypad
    end
    
    if reply_to_message_id then 
        payload.reply_to_message_id = reply_to_message_id 
    end
    
    return self:_post("sendMessage", payload)
end

function Robot:send_poll(chat_id, question, options)
    return self:_post("sendPoll", {
        chat_id = chat_id,
        question = question,
        options = options
    })
end

function Robot:send_location(chat_id, latitude, longitude, disable_notification, inline_keypad, reply_to_message_id, chat_keypad_type)
    local payload = {
        chat_id = chat_id,
        latitude = latitude,
        longitude = longitude,
        disable_notification = disable_notification or false
    }
    
    if inline_keypad then payload.inline_keypad = inline_keypad end
    if reply_to_message_id then payload.reply_to_message_id = reply_to_message_id end
    
    if chat_keypad_type then 
        payload.chat_keypad_type = chat_keypad_type 
    end
    
    local clean_payload = {}
    for k, v in pairs(payload) do
        if v ~= nil then clean_payload[k] = v end
    end
    
    return self:_post("sendLocation", clean_payload)
end

function Robot:send_contact(chat_id, first_name, last_name, phone_number)
    return self:_post("sendContact", {
        chat_id = chat_id,
        first_name = first_name,
        last_name = last_name,
        phone_number = phone_number
    })
end

function Robot:get_chat(chat_id)
    return self:_post("getChat", {chat_id = chat_id})
end

function Robot:upload_media_file(upload_url, name, file_path)
    local is_temp_file = false
    local actual_path = file_path
    
    if type(file_path) == "string" and file_path:match("^http") then
        local response, status = https.request(file_path)
        if status ~= 200 then
            error("Failed to download file from URL (" .. status .. ")")
        end
        local temp_file = os.tmpname()
        local file = io.open(temp_file, "wb")
        file:write(response)
        file:close()
        actual_path = temp_file
        is_temp_file = true
    end
    
    local file = io.open(actual_path, "rb")
    local file_content = file:read("*all")
    file:close()
    
    local response_body = {}
    local request = {
        url = upload_url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/octet-stream",
            ["Content-Length"] = #file_content
        },
        source = ltn12.source.string(file_content),
        sink = ltn12.sink.table(response_body)
    }
    
    local success, status_code = https.request(request)
    if not success or status_code ~= 200 then
        error("Upload failed (" .. (status_code or "unknown") .. ")")
    end
    
    local response_text = table.concat(response_body)
    local data = cjson.decode(response_text)
    
    if is_temp_file then
        os.remove(actual_path)
    end
    
    return data.data.file_id
end

function Robot:get_upload_url(media_type)
    local allowed = {"File", "Image", "Voice", "Music", "Gif"}
    local valid = false
    for _, allowed_type in ipairs(allowed) do
        if allowed_type == media_type then
            valid = true
            break
        end
    end
    if not valid then
        error("Invalid media type. Must be one of: " .. table.concat(allowed, ", "))
    end
    local result = self:_post("requestSendFile", {type = media_type})
    return result.data.upload_url
end

function Robot:_send_uploaded_file(chat_id, file_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type)
    local payload = {
        chat_id = chat_id,
        file_id = file_id,
        text = text,
        disable_notification = disable_notification or false,
    }
    
    if chat_keypad then 
        payload.chat_keypad = chat_keypad
        payload.chat_keypad_type = chat_keypad_type or "New"
    end
    
    if inline_keypad then payload.inline_keypad = inline_keypad end
    if reply_to_message_id then payload.reply_to_message_id = tostring(reply_to_message_id) end
    
    return self:_post("sendFile", payload)
end

function Robot:send_document(chat_id, path, file_id, text, file_name, inline_keypad, chat_keypad, reply_to_message_id, disable_notification, chat_keypad_type)
    if path then
        file_name = file_name or path:match("([^/\\]+)$")
        local upload_url = self:get_upload_url("File")
        file_id = self:upload_media_file(upload_url, file_name, path)
    end
    if not file_id then
        error("Either path or file_id must be provided.")
    end
    return self:_send_uploaded_file(chat_id, file_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type or "New")
end

function Robot:send_music(chat_id, path, file_id, text, file_name, inline_keypad, chat_keypad, reply_to_message_id, disable_notification, chat_keypad_type)
    if path then
        file_name = file_name or path:match("([^/\\]+)$")
        local upload_url = self:get_upload_url("Music")
        file_id = self:upload_media_file(upload_url, file_name, path)
    end
    if not file_id then
        error("Either path or file_id must be provided.")
    end
    return self:_send_uploaded_file(chat_id, file_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type or "New")
end

function Robot:send_voice(chat_id, path, file_id, text, file_name, inline_keypad, chat_keypad, reply_to_message_id, disable_notification, chat_keypad_type)
    if path then
        file_name = file_name or path:match("([^/\\]+)$")
        local upload_url = self:get_upload_url("Voice")
        file_id = self:upload_media_file(upload_url, file_name, path)
    end
    if not file_id then
        error("Either path or file_id must be provided.")
    end
    return self:_send_uploaded_file(chat_id, file_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type or "New")
end

function Robot:send_image(chat_id, path, file_id, text, file_name, inline_keypad, chat_keypad, reply_to_message_id, disable_notification, chat_keypad_type)
    if path then
        file_name = file_name or path:match("([^/\\]+)$")
        local upload_url = self:get_upload_url("Image")
        file_id = self:upload_media_file(upload_url, file_name, path)
    end
    if not file_id then
        error("Either path or file_id must be provided.")
    end
    return self:_send_uploaded_file(chat_id, file_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type or "New")
end

function Robot:send_gif(chat_id, path, file_id, text, file_name, inline_keypad, chat_keypad, reply_to_message_id, disable_notification, chat_keypad_type)
    if path then
        file_name = file_name or path:match("([^/\\]+)$")
        local upload_url = self:get_upload_url("Gif")
        file_id = self:upload_media_file(upload_url, file_name, path)
    end
    if not file_id then
        error("Either path or file_id must be provided.")
    end
    return self:_send_uploaded_file(chat_id, file_id, text, chat_keypad, inline_keypad, disable_notification, reply_to_message_id, chat_keypad_type or "New")
end

function Robot:get_updates(offset_id, limit)
    local data = {}
    if offset_id then data.offset_id = offset_id end
    if limit then data.limit = limit end
    return self:_post("getUpdates", data)
end

function Robot:forward_message(from_chat_id, message_id, to_chat_id, disable_notification)
    return self:_post("forwardMessage", {
        from_chat_id = from_chat_id,
        message_id = message_id,
        to_chat_id = to_chat_id,
        disable_notification = disable_notification or false
    })
end

function Robot:edit_message_text(chat_id, message_id, text)
    return self:_post("editMessageText", {
        chat_id = chat_id,
        message_id = message_id,
        text = text
    })
end

function Robot:edit_inline_keypad(chat_id, message_id, inline_keypad)
    return self:_post("editInlineKeypad", {
        chat_id = chat_id,
        message_id = message_id,
        inline_keypad = inline_keypad
    })
end

function Robot:delete_message(chat_id, message_id)
    return self:_post("deleteMessage", {
        chat_id = chat_id,
        message_id = message_id
    })
end

function Robot:set_commands(bot_commands)
    return self:_post("setCommands", {bot_commands = bot_commands})
end

function Robot:update_bot_endpoint(url, type)
    return self:_post("updateBotEndpoints", {
        url = url,
        type = type
    })
end

function Robot:remove_keypad(chat_id)
    return self:_post("editChatKeypad", {
        chat_id = chat_id,
        chat_keypad_type = "Removed"
    })
end

function Robot:edit_chat_keypad(chat_id, chat_keypad)
    return self:_post("editChatKeypad", {
        chat_id = chat_id,
        chat_keypad_type = "New",
        chat_keypad = chat_keypad
    })
end

function Robot:get_name(chat_id)
    local success, chat = pcall(function() return self:get_chat(chat_id) end)
    if success and chat and chat.data and chat.data.chat then
        local chat_info = chat.data.chat
        local first_name = chat_info.first_name or ""
        local last_name = chat_info.last_name or ""
        if first_name ~= "" and last_name ~= "" then
            return first_name .. " " .. last_name
        elseif first_name ~= "" then
            return first_name
        elseif last_name ~= "" then
            return last_name
        else
            return "Unknown"
        end
    else
        return "Unknown"
    end
end

function Robot:get_username(chat_id)
    local chat_info = self:get_chat(chat_id).data.chat or {}
    return chat_info.username or "None"
end

return {
    Robot = Robot,
    Message = Message,
    InlineMessage = InlineMessage,
    InlineBuilder = InlineBuilder,
    ChatKeypadBuilder = ChatKeypadBuilder,
    create_simple_keyboard = create_simple_keyboard
}