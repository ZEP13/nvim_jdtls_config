local M = {}

M.setup = function()
    local autoformat_filetypes = {
        "lua",
        "javascript",
        "typescript",
        "php",
        "python",
        "html",
        "css",
        "java",
    }

    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then
                return
            end

            if vim.tbl_contains(autoformat_filetypes, vim.bo.filetype) then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = args.buf,
                    callback = function()
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if not client then return end
                        local can_format = false
                        if type(client) == "table" and client.supports_method then
                            pcall(function() if client:supports_method("textDocument/formatting") then can_format = true end end)
                        end
                        if not can_format and client.server_capabilities then
                            if client.server_capabilities.documentFormattingProvider then can_format = true end
                        end

                        if can_format then
                            vim.lsp.buf.format({
                                formatting_options = { tabSize = 4, insertSpaces = true },
                                bufnr = args.buf,
                                id = client.id,
                            })
                        end
                    end,
                })
            end
            if vim.tbl_contains(autoformat_filetypes, vim.bo.filetype) then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = args.buf,
                    callback = function()
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if not client then return end
                        local can_format = false
                        if type(client) == "table" and client.supports_method then
                            pcall(function() if client:supports_method("textDocument/formatting") then can_format = true end end)
                        end
                        if not can_format and client.server_capabilities then
                            if client.server_capabilities.documentFormattingProvider then can_format = true end
                        end

                        if can_format then
                            vim.lsp.buf.format({
                                formatting_options = { tabSize = 4, insertSpaces = true },
                                bufnr = args.buf,
                                id = client.id,
                            })
                        end
                    end,
                })
            end
        end,
    })

    vim.lsp.handlers['textDocument/hover'] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
    vim.lsp.handlers['textDocument/signatureHelp'] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

    vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = {
            style = 'minimal',
            border = 'rounded',
            header = '',
            prefix = '',
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = '✘',
                [vim.diagnostic.severity.WARN]  = '▲',
                [vim.diagnostic.severity.HINT]  = '⚑',
                [vim.diagnostic.severity.INFO]  = '»',
            },
        },
    })

    require('mason').setup({})

    require('mason-lspconfig').setup({
        ensure_installed = {
            "lua_ls",
            "intelephense",
            "ts_ls",
            "eslint",
            "pyright",
            "html",
            "cssls",
            "emmet_ls",
        },
        handlers = {
            function(server_name)
                local ok, lspconfig = pcall(require, 'lspconfig')
                if not ok then
                    vim.notify("lspconfig not available", vim.log.levels.ERROR)
                    return
                end

                local server = lspconfig[server_name]

                if not server then
                    local alias_map = {
                        ts_ls        = "tsserver",
                        tsserver     = "tsserver",
                        cssls        = "cssls",
                        lua_ls       = "lua_ls",
                        emmet_ls     = "emmet_ls",
                        html         = "html",
                        pyright      = "pyright",
                        intelephense = "intelephense",
                        eslint       = "eslint",
                    }
                    local alias = alias_map[server_name]
                    if alias then
                        server = lspconfig[alias]
                    end
                end

                if server and type(server.setup) == "function" then
                    local ok2, err = pcall(function()
                        server.setup({})
                    end)
                    if not ok2 then
                        vim.notify(("Failed to setup LSP %s: %s"):format(server_name, tostring(err)),
                            vim.log.levels.WARN)
                    end
                else
                    vim.notify(("Skipping unknown/unsupported LSP server: " .. tostring(server_name)),
                        vim.log.levels.DEBUG)
                end
            end,

            lua_ls = function()
                require('lspconfig').lua_ls.setup({
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            diagnostics = { globals = { 'vim' } },
                            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                            telemetry = { enable = false },
                        },
                    },
                })
            end,

            ts_ls = function()
                require('lspconfig').tsserver.setup({
                    filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
                    init_options = {
                        preferences = {
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithInsertText = true,
                        },
                    },
                    root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git"),
                })
            end,

            html = function()
                require('lspconfig').html.setup({
                    filetypes = { "html", "javascriptreact", "typescriptreact" },
                })
            end,

            emmet_ls = function()
                require('lspconfig').emmet_ls.setup({
                    filetypes = {
                        'html',
                        'css',
                        'scss',
                        'javascriptreact',
                        'typescriptreact',
                    },
                    init_options = {
                        html = {
                            options = { ["bem.enabled"] = true },
                        },
                    },
                })
            end,

            pyright = function()
                local lspconfig = require('lspconfig')
                local util = require('lspconfig.util')

                lspconfig.pyright.setup({
                    root_dir = function(fname)
                        local root = util.root_pattern(
                            "pyproject.toml",
                            "setup.py",
                            "setup.cfg",
                            "requirements.txt",
                            "Pipfile",
                            "pyrightconfig.json",
                            ".git"
                        )(fname)
                        if root then
                            return root
                        end
                        return util.path.dirname(fname) or vim.loop.cwd()
                    end,

                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                diagnosticMode = "openFilesOnly",
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                })
            end,

        },
    })

    local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
    if has_lspconfig and lspconfig.util and lspconfig.util.default_config then
        local lspconfig_defaults = lspconfig.util.default_config
        lspconfig_defaults.capabilities = vim.tbl_deep_extend(
            'force',
            lspconfig_defaults.capabilities or {},
            (function()
                local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
                if ok then
                    return cmp_nvim_lsp.default_capabilities()
                else
                    return {}
                end
            end)()
        )
    end

    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
            local opts = { buffer = event.buf }
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'x' }, '<f3>', function() vim.lsp.buf.format({ async = true }) end, opts)
            vim.keymap.set('n', '<f4>', vim.lsp.buf.code_action, opts)
        end,
    })

    local cmp_ok, cmp = pcall(require, 'cmp')
    if cmp_ok then
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        cmp.setup({
            preselect = 'item',
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'buffer',  keyword_length = 3 },
                { name = 'luasnip', keyword_length = 2 },
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            formatting = {
                fields = { 'abbr', 'menu', 'kind' },
                format = function(entry, item)
                    local n = entry.source.name
                    if n == 'nvim_lsp' then
                        item.menu = '[LSP]'
                    else
                        item.menu = string.format('[%s]', n)
                    end
                    return item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    local col = vim.fn.col('.') - 1
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = 'select' })
                    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                ['<C-d>'] = cmp.mapping(function(fallback)
                    local luasnip = require('luasnip')
                    if luasnip.jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<C-b>'] = cmp.mapping(function(fallback)
                    local luasnip = require('luasnip')
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
        })
    end
end

return M
