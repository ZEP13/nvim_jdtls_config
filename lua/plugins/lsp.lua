return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'mfussenegger/nvim-jdtls',
        'hrsh7th/nvim-cmp',  
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'L3MON4D3/LuaSnip',      
        'rafamadriz/friendly-snippets', 
    },
    config = function()
        require('config.lsp').setup()
    end,
}
