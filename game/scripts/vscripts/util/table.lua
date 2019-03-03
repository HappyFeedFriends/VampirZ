function table.nearestOrLowerKey(t, key)
	if not t then return end
	local selectedKey
	for k,v in pairs(t) do
		if k <= key and (not selectedKey or math.abs(k - key) < math.abs(selectedKey - key)) then
			selectedKey = k
		end
	end
	return t[selectedKey]
end

function table.merge(input1, input2)
	for i,v in pairs(input2) do
		input1[i] = v
	end
end
function table.FindStringTable(stringFind,table)
if not table then return false end
	for _,Name in pairs(table) do
		if Name then
			if type(Name) == "table" then
				return table.FindStringTable(stringFind,Name) and true
			elseif stringFind:find(Name) then
				return true
			end 
		end
	end	
	return false
end

function table.deepcopy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[table.deepcopy(k, s)] = table.deepcopy(v, s) end
	return res
end

function table.contains(table, element)
	if table then
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
	end
	return false
end

function table.length(table)
	local n
	for _,_ in pairs(table) do
		n = (n or 0) + 1
	end 
	return n
end 

function table.swap(array, index1, index2)
	array[index1], array[index2] = array[index2], array[index1]
end

function table.shuffle(array)
	local counter = #array
	while counter > 1 do
		local index = RandomInt(1, counter)
		table.swap(array, index, counter)
		counter = counter - 1
	end
end

function table.includes(table, element)
	if table then
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
	end
	return false
end

function table.equals(tbl1, tbl2)
    if table.count(tbl1) ~= table.count(tbl2) then return false end
		for k,v in pairs(tbl1) do
			if not (tbl2[k] or tbl2[v] ) or (tbl1[k] ~= tbl2[k]) or (tbl1[v] ~= tbl2[v]) then
				return false
			end 
		end 
    return true
end 

function table.count(inputTable)
	local counter = 0
	for _,_ in pairs(inputTable) do
		counter = counter + 1
	end
	return counter
end

function table.iterate(inputTable)
	local toutput = {}
	for _,v in pairs(inputTable) do
		table.insert(toutput, v)
	end
	return toutput
end

function table.deepmerge(t1, t2)
	for k,v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				table.deepmerge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end