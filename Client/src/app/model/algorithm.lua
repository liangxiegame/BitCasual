

function crushCountForTime(count)
	if count <= 4 then
		return 4
	else
		return count * 1.1 * (1 + count * 0.01)
	end
end

function lineCountForTime(count)
	return count * 10 * (1 + count * 0.01)
end