local ok, jdtls = pcall(require, 'jdtls')
if not ok then
    vim.notify('jdtls plugin not found. Install mfussenegger/nvim-jdtls', vim.log.levels.ERROR)
    return
end

local fn = vim.fn
local uv = vim.loop
local home = fn.expand('~')

local mason_jdtls = fn.stdpath('data') .. '/mason/packages/jdtls'
local plugins_dir = mason_jdtls .. '/plugins'
local config_dir_base = mason_jdtls .. '/config_'

local os_name = (function()
    local uname = uv.os_uname().sysname
    if uname:match('Linux') then
        return 'linux'
    elseif uname:match('Darwin') then
        return 'mac'
    elseif uname:match('Windows') or uname:match('MINGW') then
        return 'win'
    else
        return 'linux'
    end
end)()

local config_path = config_dir_base .. os_name

local function find_equinox_jar()
    if fn.isdirectory(plugins_dir) == 0 then
        return nil
    end

    local jars = fn.globpath(plugins_dir, 'org.eclipse.equinox.launcher_*.jar', true, true)
    if type(jars) ~= 'table' or #jars == 0 then
        return nil
    end

    for _, p in ipairs(jars) do
        local name = fn.fnamemodify(p, ':t')
        if not name:match('cocoa') and not name:match('gtk') and not name:match('win32') then
            return p
        end
    end

    return jars[1]
end

local equinox_jar = find_equinox_jar()
if not equinox_jar then
    vim.notify('Impossible de trouver org.eclipse.equinox.launcher_*.jar dans: ' .. plugins_dir, vim.log.levels.ERROR)
    return
end

local project_name = fn.fnamemodify(fn.getcwd(), ':p:h:t')
local workspace_dir = fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

local bundles = {}
local mason_bundles_dir = mason_jdtls .. '/bundles'
local fallback_bundles = home .. '/.local/share/jdtls/bundles'

local function gather_bundles(dir)
    if fn.isdirectory(dir) == 0 then
        return {}
    end
    local g = fn.globpath(dir, '*.jar', true, true)
    if type(g) ~= 'table' then
        return {}
    end
    return g
end

vim.list_extend(bundles, gather_bundles(mason_bundles_dir))
vim.list_extend(bundles, gather_bundles(fallback_bundles))

local java_cmd = 'java'
if vim.env.JAVA_HOME and vim.fn.executable(vim.env.JAVA_HOME .. '/bin/java') == 1 then
    java_cmd = vim.env.JAVA_HOME .. '/bin/java'
elseif fn.executable('java') == 1 then
    java_cmd = 'java'
else
    vim.notify('Aucun binaire java trouvé dans JAVA_HOME ni dans PATH.', vim.log.levels.WARN)
end

local config = {
    cmd = {
        java_cmd,
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx2g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        -- ajoutez cette ligne :
        '-javaagent:' .. mason_jdtls .. '/lombok.jar',
        '-jar', equinox_jar,
        '-configuration', config_path,
        '-data', workspace_dir,
    },

    root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),

    settings = {
        java = {
            contentProvider = { preferred = "fernflower" },
            eclipse = { downloadSources = true },
            signatureHelp = { enabled = true },
            references = { includeDecompiledSources = true },
        },
    },

    init_options = {
        bundles = bundles,
        extendedClientCapabilities = {
            advancedExtractRefactoringSupport = true,
            advancedOrganizeImportsSupport = true,
            classFileContentsSupport = true,
            executeClientCommandSupport = true,
            generateConstructorsPromptSupport = true,
            generateDelegateMethodsPromptSupport = true,
            generateToStringPromptSupport = true,
            hashCodeEqualsPromptSupport = true,
            inferSelectionSupport = {
                "extractMethod",
                "extractVariable",
                "extractConstant",
                "extractVariableAllOccurrence",
            },
            moveRefactoringSupport = true,
            overrideMethodsPromptSupport = true,
        },
    },

    on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)

        pcall(function()
            require('jdtls.setup').add_commands()
            require('jdtls').setup_dap({ hotcodereplace = 'auto' })
        end)
    end,
}

jdtls.start_or_attach(config)
