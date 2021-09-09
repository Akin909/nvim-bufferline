local utils = require("tests.utils")
local Buffer = utils.MockBuffer

describe("Group tests - ", function()
  local groups

  before_each(function()
    package.loaded["bufferline.groups"] = nil
    groups = require("bufferline.groups")
  end)

  it("should add user groups on setup", function()
    groups.setup({
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              matcher = function(buf)
                return buf.name:includes("dummy")
              end,
            },
          },
        },
      },
    })
    assert.is_equal(vim.tbl_count(groups.state.user_groups), 2)
  end)

  it("should sanitise invalid names", function()
    groups.setup({
      options = {
        groups = {
          items = {
            {
              name = "test group",
              matcher = function(buf)
                return buf.name:includes("dummy")
              end,
            },
          },
        },
      },
    })
    assert.is_equal(groups.state.user_groups[1].name, "test_group")
  end)

  it("should set highlights on setup", function()
    local config = {
      highlights = {
        buffer_selected = {
          guifg = "black",
          guibg = "white",
        },
        buffer_visible = {
          guifg = "black",
          guibg = "white",
        },
        buffer = {
          guifg = "black",
          guibg = "white",
        },
      },
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              highlight = { guifg = "red" },
              matcher = function(buf)
                return buf.name:includes("dummy")
              end,
            },
          },
        },
      },
    }
    groups.setup(config)
    assert.truthy(config.highlights.test_group_selected)
    assert.truthy(config.highlights.test_group_visible)
    assert.truthy(config.highlights.test_group)

    assert.equal(config.highlights.test_group.guifg, "red")
  end)

  it("should sort tabs by groups", function()
    groups.setup({
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              matcher = function(buf)
                return buf.name:includes("dummy")
              end,
            },
          },
        },
      },
    })
    local sorted, tabs_by_group = groups.sort_by_groups({
      Buffer:new({ filename = "dummy-1.txt", group = 1 }),
      Buffer:new({ filename = "dummy-2.txt", group = 1 }),
      Buffer:new({ filename = "file-2.txt", group = 2 }),
    })
    assert.is_equal(#sorted, 3)
    assert.equal(sorted[1]:as_buffer().filename, "dummy-1.txt")
    assert.equal(sorted[#sorted]:as_buffer().filename, "file-2.txt")

    assert.is_equal(vim.tbl_count(tabs_by_group), 2)
  end)

  it("should add group markers", function()
    local config = {
      highlights = {},
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              matcher = function(buf)
                return buf.filename:includes("dummy")
              end,
            },
          },
        },
      },
    }
    require("bufferline").setup(config)
    utils.vim_enter()
    groups.setup(config)
    local tabs = {
      Buffer:new({ filename = "dummy-1.txt", group = 1 }),
      Buffer:new({ filename = "dummy-2.txt", group = 1 }),
      Buffer:new({ filename = "file-2.txt", group = 2 }),
    }
    tabs = groups.render(tabs, function(t)
      return t
    end)
    assert.equal(#tabs, 5)
    local g_start = tabs[1]
    local g_end = tabs[4]
    assert.is_equal(g_start.type, "group_start")
    assert.is_equal(g_end.type, "group_end")
    assert.is_truthy(g_start.component():match("test%-group"))
  end)

  it("should sort each group individually", function()
    local config = {
      highlights = {},
      options = {
        groups = {
          items = {
            {
              name = "A",
              matcher = function(buf)
                return buf.filename:match("%.txt")
              end,
            },
            {
              name = "B",
              matcher = function(buf)
                return buf.filename:match("%.js")
              end,
            },
            {
              name = "C",
              matcher = function(buf)
                return buf.filename:match("%.dart")
              end,
            },
          },
        },
      },
    }
    require("bufferline").setup(config)
    utils.vim_enter()
    groups.setup(config)
    local tabs = {
      Buffer:new({ filename = "b.txt", group = 1 }),
      Buffer:new({ filename = "a.txt", group = 1 }),
      Buffer:new({ filename = "d.txt", group = 2 }),
      Buffer:new({ filename = "c.txt", group = 2 }),
      Buffer:new({ filename = "h.txt", group = 3 }),
      Buffer:new({ filename = "g.txt", group = 3 }),
    }
    tabs = groups.render(tabs, function(t)
      table.sort(t, function(a, b)
        return a.filename < b.filename
      end)
      return t
    end)
    assert.is_equal(tabs[2]:as_buffer().filename, "a.txt")
    assert.is_equal(tabs[3]:as_buffer().filename, "b.txt")
    assert.is_equal(tabs[6]:as_buffer().filename, "c.txt")
    assert.is_equal(tabs[7]:as_buffer().filename, "d.txt")
    assert.is_equal(tabs[10]:as_buffer().filename, "g.txt")
    assert.is_equal(tabs[11]:as_buffer().filename, "h.txt")
  end)
end)
