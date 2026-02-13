--!strict
--[[
    TableUtil.lua
    Common table utility functions
]]

local TableUtil = {}

function TableUtil.deepCopy<T>(original: T): T
    if type(original) ~= "table" then
        return original
    end

    local copy = {}
    for key, value in original :: any do
        copy[TableUtil.deepCopy(key)] = TableUtil.deepCopy(value)
    end
    return copy :: any
end

function TableUtil.merge(base: { [string]: any }, override: { [string]: any }): { [string]: any }
    local result = TableUtil.deepCopy(base)
    for key, value in override do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = TableUtil.merge(result[key], value)
        else
            result[key] = TableUtil.deepCopy(value)
        end
    end
    return result
end

function TableUtil.find<T>(tbl: { T }, predicate: (T) -> boolean): T?
    for _, value in tbl do
        if predicate(value) then
            return value
        end
    end
    return nil
end

function TableUtil.filter<T>(tbl: { T }, predicate: (T) -> boolean): { T }
    local result = {}
    for _, value in tbl do
        if predicate(value) then
            table.insert(result, value)
        end
    end
    return result
end

function TableUtil.map<T, U>(tbl: { T }, transform: (T) -> U): { U }
    local result = {}
    for _, value in tbl do
        table.insert(result, transform(value))
    end
    return result
end

function TableUtil.count(tbl: { [any]: any }): number
    local n = 0
    for _ in tbl do
        n += 1
    end
    return n
end

return TableUtil
