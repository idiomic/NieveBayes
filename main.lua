local Bayes = require 'Bayes'

local start = os.clock()

local iterator = io.lines(arg[1])
local _instance = {}
local function parse()
	local line = iterator()
	if not line then
		return nil
	end

	local i = 1
	for field in line:gmatch '[^%s,]+' do
		_instance[i] = field == '1'
		i = i + 1
	end
	return _instance
end

local bayes = Bayes(parse)

local doneTraining = os.clock()

iterator = io.lines(arg[1])
parse()

local truePositive = 0
local falsePositive = 0
local trueNegative = 0
local falseNegative = 0

local class = #bayes
for instance in parse do
	local c = instance[class]
	instance[class] = nil
	local result = bayes:classify(instance)
	if c then
		if result then
			truePositive = truePositive + 1
		else
			falseNegative = falseNegative + 1
		end
	elseif result then
		falsePositive = falsePositive + 1
	else
		trueNegative = trueNegative + 1
	end
end

local finish = os.clock()

print("Training Time:", doneTraining - start)
print("Testing Time:", finish - doneTraining)
print(truePositive, '\t', falsePositive)
print(falseNegative, '\t', trueNegative)
print(
	(truePositive + trueNegative)
	/
	(truePositive + falsePositive + trueNegative +falseNegative)
)
