return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'mfussenegger/nvim-jdtls', -- LSP pour Java (Spring Boot, etc.)
        'hrsh7th/nvim-cmp',    -- auto-completion core
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'L3MON4D3/LuaSnip',         -- snippets engine
        'rafamadriz/friendly-snippets', -- snippets par défaut
    },
    config = function()
        -- Appelle ton fichier lua/config/lsp.lua
        require('config.lsp').setup()
    end,
}
