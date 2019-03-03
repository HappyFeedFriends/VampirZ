function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

function math.round(x)
	if x%2 ~= 0.5 then
		return math.floor(x+0.5)
	end
	return x-0.5
end

function math.clamp(x, min, max)
	return math.max(min, math.min(max, x))
end

function math.maxTable(data)
	if not data or type(data) ~= "table" then
		return false
	end 
	local max
	for i = 1,#data do
		if data[i+1] then
			max = max and max >= math.max(data[i],data[i+1]) and max or  math.max(data[i],data[i+1])
		end
	end 
	return max
end