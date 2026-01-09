local module = {}

function module.extend_table(destination, source)
    for key, value in pairs(source) do
        destination[key] = value
    end
    return destination
end

return module
