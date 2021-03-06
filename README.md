# luadocx

## PHP 脚本工具

Documentation Generator Tool for the Lua language

<br />

~~~

LuaDocX - Generate documents from Lua source files


-   extract tags (module, class, function) from Lua source files. write to JSON file.

    luadocx extract -c config_file_path source_files_dir json_file_dir


-   generate offline HTML docments:

    luadocx generate -c config_file_path json_file_dir html_files_dir

~~~


## CoffeeScript 脚本工具

### `json2snippet.coffee`

将 `luadocx extract` 生产出来的 `structure.json` 文件转变为 Vim snipMate 的代码片段


需要安装

 1. 安装 [NodeJS](http://nodejs.org/download/)
 2. CoffeeScript: `npm install coffee-script -g`
 3. 安装相关依赖 `npm install`


用法：

```bash
 ./json2snippet.coffee -i ~/temp/json/structure.json -s
```

说明：

```bash
# ./json2snippet.coffee -h

Usage: json2snippet.coffee [options]

Options:

  -h, --help                      output usage information
  -V, --version                   output the version number
  -i, --input [VALUE]             the structure json file generated by luadocx extract
  -v, --verbos                    be verbos when true
  -s, --includeZeroParamFunction  when this switch turned out, the output snippets will include functions with zero params. It's suggested to use $LUA_PATH rather then including 0-param functions in snippets
  -l, --language [type]           which target language [lua, moon] the snippet should be served to
```



