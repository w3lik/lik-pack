---@class UIKit:UIKitClass
---@param kit string
---@return UIKit
function UIKit(kit)
    must(type(kit) == "string")
    return Object(UIKitClass, {
        static = kit,
        options = {
            kit = kit
        }
    })
end