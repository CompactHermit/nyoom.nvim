





 local function _1_()

 local function _2_()
 local function _3_(name_58_auto) vim.cmd.packadd(name_58_auto) local function _4_(plug_59_auto) return vim.cmd.packadd(plug_59_auto) end return vim.iter({"tbl", "matter", "ball"}):each(_4_) end return assert.are.same(type({"name", load = _3_}), "table") end return it("LazP Spec Test", _2_) end return describe("LazP:: Want/deps", _1_)