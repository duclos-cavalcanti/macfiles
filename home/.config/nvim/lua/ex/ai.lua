if os.getenv("USER") == "dduclos-cavalcanti" then
    return {
        'augmentcode/augment.vim',
        config = function() 
            vim.g.augment_workspace_folders = {
                '/Users/dduclos-cavalcanti/Documents/macfiles',
                '/Users/dduclos-cavalcanti/Documents/work/kms',
                '/Users/dduclos-cavalcanti/Documents/work/vault-releases/vault-cold-bridge/',
            }
        end,
    }
else
    return {}
end
