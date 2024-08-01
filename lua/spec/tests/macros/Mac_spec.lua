local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")

_G["nyoom/modules"] = nil

local function _2_()
	local function _3_()
		local function _4_(name_55_auto)
			local function _5_(module_56_auto)
				return autoload("lz.n").trigger_load(module_56_auto)
			end
			vim.iter({ "debug" }):each(_5_)
			return vim.cmd.packadd(name_55_auto)
		end
		return assert.are.same(type({ "foo", load = _4_ }), "table")
	end

	local function _6_()
		return assert.are.same(nil, nil)
	end
	return it("LazyP:: Want/Deps", _3_), it("LazyP:: Packadd spec", _6_)
end
describe("LazyP Spec Test", _2_)

local function _7_()
	local function _8_()
		return assert.are.same(2, 2)
	end
	return it("LazP Spec Test", _8_)
end
return describe("mac:: let!", _7_)
