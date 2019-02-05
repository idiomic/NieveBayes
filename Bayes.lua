local Bayes = {}
Bayes.__index = Bayes

function Bayes:prob(features, class)
	local prob
	if class then
		prob = self[#self][class].prob
	else
		prob = self[#self][class].invProb
	end

	for i, value in next, features do
		if value then
			prob = prob + self[i][class].prob
		elseif value == '0' then
			prob = prob + self[i][class].invProb
		end
	end

	return prob
end

function Bayes:classify(features)
	return self:prob(features, true) > self:prob(features, false)
end

local function finalize(feature)
	local value = feature.count / feature.total
	feature.prob = math.log(value)
	if feature.prob == -math.huge then
		feature.prob = 0
	end
	feature.invProb = math.log(1 - value)
	if feature.invProb == -math.huge then
		feature.invProb = 0
	end
end

return function(parse)
	local new = {}
	for i, name in next, parse() do
		new[i] = {
			name = name,
			[true] = {
				count = 0;
				total = 0;
			};
			[false] = {
				count = 0;
				total = 0;
			};
		}
	end

	local class = #new

	for instance in parse do
		for i, feature in next, new do
			local featureClass = feature[instance[class]]
			featureClass.total = featureClass.total + 1
			if instance[i] then
				featureClass.count = featureClass.count + 1
			end
		end
	end

	for _, feature in next, new do
		finalize(feature[true])
		finalize(feature[false])
	end

	-- for i, feature in next, new do
	-- 	print(i, true, feature[true].count, feature[true].total)
	-- 	print(i, false, feature[false].count, feature[false].total)
	-- end

	return setmetatable(new, Bayes)
end