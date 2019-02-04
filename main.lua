local Bayes = require 'Bayes'

io.input './small/test1_1.csv'

local line = {}
local function parse(str)
	for field in str:gmatch '[^%s,]+' do
		line[#line + 1] = field
	end
	return line
end

local bayes = Bayes(parse)
local test = {1, 1, 1, 1, 1, 1, 1, 1, 1}
print(bayes:prob(test, '1'))
print(bayes:prob(test, '-1'))
