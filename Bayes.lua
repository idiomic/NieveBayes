local Bayes = {}
Bayes.__index = Bayes

function Bayes:loadChunk(chunk)
end

function Bayes:finalize(class)
	for _, feature in ipairs(self) do
		local f = feature[class]
		local v = f.count / f.total
		f.prob = math.log(v)
		f.invProb = math.log(1 - v)
	end
end

function Bayes:prob(features, class)
	local prob
	if class == '1' then
		prob = self[#self][class].prob
	else
		prob = self[#self][class].invProb
	end

	for i, value in next, features do
		if value == '1' then
			prob = prob + self[i][class].prob
		elseif value == '0' then
			prob = prob + self[i][class].invProb
		end
	end

	return prob
end

return function (parse)
	local new = {}
	local iterator = io.lines()
	local header = iterator()
	for i, name in next, parse(header) do
		print(i, name)
		new[i] = {
			name = name,
			['1'] = {
				count = 0;
				total = 0;
			};
			['-1'] = {
				count = 0;
				total = 0;
			};
		}
	end

	local class = #new
	local first = iterator()
	for line in iterator, first, first do
		local instance = parse(line)
		local classValue = instance[class]
		for i, feature in next, new do
			local featureClass = feature[classValue]
			if featureClass then
				if instance[i] then
					featureClass.total = featureClass.total + 1
					if instance[i] == '1' then
						featureClass.count = featureClass.count + 1
					end
				end
			end
		end
	end

	return setmetatable(new, Bayes)
end