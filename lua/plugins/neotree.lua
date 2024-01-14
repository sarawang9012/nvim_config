local function getTelescopeOpts(state, path)
	return {
		cwd = path,
		search_dirs = { path },
		attach_mappings = function(prompt_bufnr, map)
			local actions = require("telescope.actions")
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local action_state = require("telescope.actions.state")
				local selection = action_state.get_selected_entry()
				local filename = selection.filename
				if filename == nil then
					filename = selection[1]
				end
				-- any way to open the file without triggering auto-close event of neo-tree?
				require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
			end)
			return true
		end,
	}
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{
			"-",
			function()
				require("neo-tree.command").execute({
					toggle = true,
					source = "filesystem",
					position = "left",
				})
			end,
			desc = "Buffers (root dir)",
		},
--		{
--		"<leader>r",
--			function()
--				require("neo-tree.command").execute({
--					toggle = true,
--					source = "buffers",
--					position = "left",
--				})
--			end,
--			desc = "Buffers (root dir)",
--		},
	},
	config = function()
		local neo_tree = require("neo-tree")
		neo_tree.setup({
			event_handlers = {
				{
					event = "file_opened",
					handler = function(file_path)
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
			window = {
				mappings = {
					["e"] = function()
						vim.api.nvim_exec("Neotree focus filesystem left", true)
					end,
					["b"] = function()
						vim.api.nvim_exec("Neotree focus buffers left", true)
					end,
					["g"] = function()
						vim.api.nvim_exec("Neotree focus git_status left", true)
					end,
					-- navigation with HJKL
					-- h to fold folder
					-- l to open folder
					-- j to navigate down
					-- k to navigate up
					["h"] = function(state)
						local node = state.tree:get_node()
						if node.type == "directory" and node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						else
							require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
						end
					end,
					["l"] = function(state)
						local node = state.tree:get_node()
						if node.type == "directory" then
							if not node:is_expanded() then
								require("neo-tree.sources.filesystem").toggle_directory(state, node)
							elseif node:has_children() then
								require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
							end
						end
					end,
          -- open file without losing sidebar focus
					["<tab>"] = function(state)
						state.commands["open"](state)
						vim.cmd("Neotree reveal")
					end,
				},
			},
			popup_border_style = "NC",
			filesystem = {
				window = {
					mappings = {
						["c"] = "open_and_clear_filter",
						["tf"] = "telescope_find",
						["tg"] = "telescope_grep",
						["D"] = "diff_files",
					},
				},
				commands = {
					open_and_clear_filter = function(state)
						local node = state.tree:get_node()
						if node and node.type == "file" then
							local file_path = node:get_id()
							-- reuse built-in commands to open and clear filter
							local cmds = require("neo-tree.sources.filesystem.commands")
							cmds.open(state)
							cmds.clear_filter(state)
							-- reveal the selected file without focusing the tree
							require("neo-tree.sources.filesystem").navigate(state, state.path, file_path)
						end
					end,
					telescope_find = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						require("telescope.builtin").find_files(getTelescopeOpts(state, path))
					end,
					telescope_grep = function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						require("telescope.builtin").live_grep(getTelescopeOpts(state, path))
					end,

					diff_files = function(state)
						local node = state.tree:get_node()
						local log = require("neo-tree.log")
						state.clipboard = state.clipboard or {}
						if diff_Node and diff_Node ~= tostring(node.id) then
							local current_Diff = node.id
							require("neo-tree.utils").open_file(state, diff_Node, open)
							vim.cmd("vert diffs " .. current_Diff)
							log.info("Diffing " .. diff_Name .. " against " .. node.name)
							diff_Node = nil
							current_Diff = nil
							state.clipboard = {}
							require("neo-tree.ui.renderer").redraw(state)
						else
							local existing = state.clipboard[node.id]
							if existing and existing.action == "diff" then
								state.clipboard[node.id] = nil
								diff_Node = nil
								require("neo-tree.ui.renderer").redraw(state)
							else
								state.clipboard[node.id] = { action = "diff", node = node }
								diff_Name = state.clipboard[node.id].node.name
								diff_Node = tostring(state.clipboard[node.id].node.id)
								log.info("Diff source file " .. diff_Name)
								require("neo-tree.ui.renderer").redraw(state)
							end
						end
					end,
				},
			},
		})
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>")
	end,
}
