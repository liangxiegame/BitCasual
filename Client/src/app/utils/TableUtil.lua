TableUtil = {}

function TableUtil:append(tb,value)

	if type(tb) == "table" then
		tb[#tb + 1] = value
	end

end


function TableUtil:push(tb,value)
	tb[#tb + 1] = value
end


function TableUtil:pop(tb)
	local value = tb[#tb]

	tb[#tb] = nil

	return value
end


--倒数
function TableUtil:top(tb)
	return tb[#tb]
end

