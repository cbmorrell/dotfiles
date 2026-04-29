local module = {}

function module.extend_table(destination, new_data)
  for key, value in pairs(new_data) do
    if type(key) == "number" then
      -- Handle array values (e.g., new_data = {{flag = true}})
      table.insert(destination, value)
    else
      -- Handle map values (e.g., new_data = {flag = true})
      destination[key] = value
    end
  end

  return destination
end

return module
