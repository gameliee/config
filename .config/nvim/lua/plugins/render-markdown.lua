return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      render_modes = { "n", "c", "i", "v" },
    },
    keys = {
      {
        "<leader>um",
        function()
          local m = require("render-markdown")
          m.toggle()
        end,
        desc = "Toggle Markdown/Mermaid Rendering",
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      -- Fixes mermaid diagram freezing the live preview in browser
      -- Makes it only update when you leave Insert mode or save
      vim.g.mkdp_refresh_slow = 1
    end,
  }
}
