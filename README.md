# Improved file search for repositories

Short utility for magically adding git/hg/svn repository roots to `&path` when we open version-controlled files.

This makes `gf`, `sfind`, `find`, etc in vim actually work for various relative paths (particularly those in #include statements).

Installation is straightforward. Using `vim-plug`:
```
Plug 'brentyi/vim-repo-file-search'
```

---

We also set the `w:vim_repo_file_search_repo_root` variable to a single path (default: `.`), which can be handy as a general search path.

For example, we can ask `fzf` to emulate the behavior of `ctrlp`:
```
Plug 'brentyi/vim-repo-file-search'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

function! s:smarter_fuzzy_file_search()
    execute "Files " . w:vim_repo_file_search_repo_root
endfunction
nnoremap <C-P> :call <SID>smarter_fuzzy_file_search()<CR>
```
