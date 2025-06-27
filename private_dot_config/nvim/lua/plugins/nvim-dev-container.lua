return {
  {
    "https://codeberg.org/esensar/nvim-dev-container",
    config = function()
      require("devcontainer").setup({
        container_runtime = "docker",
        compose_command = "docker-compose",
        attach_mounts = {
          neovim_config = {
            enabled = true,
            options = { "readonly" },
          },
          neovim_data = {
            enabled = false,
            options = {},
          },
          -- Only useful if using neovim 0.8.0+
          neovim_state = {
            enabled = true,
            options = {},
          },
        },
      })
    end,
  },
}
