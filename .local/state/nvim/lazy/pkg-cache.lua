return {pkgs={{source="lazy",name="noice.nvim",spec=function()
return {
  -- nui.nvim can be lazy loaded
  { "MunifTanjim/nui.nvim", lazy = true },
  {
    "folke/noice.nvim",
  },
}

end,dir="/home/gpx/.local/share/nvim/lazy/noice.nvim",file="lazy.lua",},{source="lazy",name="plenary.nvim",spec={"nvim-lua/plenary.nvim",lazy=true,},dir="/home/gpx/.local/share/nvim/lazy/plenary.nvim",file="community",},},version=12,}