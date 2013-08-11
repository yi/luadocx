<?php

define('LUADOCX_VERSION', '1.2');
define('DS', DIRECTORY_SEPARATOR);

function help()
{
    print <<<EOT

LuaDocX - Generate documents from Lua source files


-   extract tags (module, class, function) from Lua source files. write to JSON file.

    luadocx extract -c config_file_path source_files_dir json_file_dir


-   generate offline HTML docments:

    luadocx generate -c config_file_path json_file_dir html_files_dir


EOT;
}

if (!isset($argc) || $argc < 4)
{
    help();
    return 1;
}

array_shift($argv);
$params = array(
    'command' => '',
    'configFilePath' => '',
    'srcFilesDir' => '',
    'destDir' => '',
);
while ($arg = array_shift($argv))
{
    if ($arg == '-c')
    {
        $params['configFilePath'] = array_shift($argv);
        continue;
    }

    if ($arg[0] == '-')
    {
        printf("\nERROR: invalid option %s\n", $arg);
        help();
        return 1;
    }

    if (empty($params['command']))
    {
        $params['command'] = $arg;
        continue;
    }
    if (empty($params['srcFilesDir']))
    {
        $params['srcFilesDir'] = $arg;
        continue;
    }
    if (empty($params['destDir']))
    {
        $params['destDir'] = $arg;
    }
}


// check params
$commands = array('extract', 'generate');
if (!in_array($params['command'], $commands))
{
    printf("\nERROR: invalid command %s\n", $params['command']);
    help();
    return 1;
}

if (!is_file($params['configFilePath']))
{
    printf("\nERROR: invalid config file path %s\n", $params['configFilePath']);
    help();
    return 1;
}
$params['configFilePath'] = realpath($params['configFilePath']);

if (!is_dir($params['srcFilesDir']))
{
    printf("\nERROR: invalid srcFilesDir %s\n", $params['srcFilesDir']);
    help();
    return 1;
}
$params['srcFilesDir'] = realpath($params['srcFilesDir']);

if (!is_dir($params['destDir']))
{
    @mkdir($params['destDir']);
    if (!is_dir($params['destDir']))
    {
        printf("\nERROR: invalid destDir %s\n", $params['destDir']);
        help();
        return 1;
    }
}
$params['destDir'] = realpath($params['destDir']);


// execute
require_once(__DIR__ . '/inc/Config.php');

$config = new Config($params['configFilePath']);
if (!$config->isValid())
{
    printf("\nERROR: invalid config file %s\n", $params['configFilePath']);
    help();
    return 1;
}

if ($params['command'] == 'extract')
{
    require_once(__DIR__ . '/inc/DirScanner.php');
    $scanner = new DirScanner($config, $params);
    $modules = $scanner->execute();

    require_once(__DIR__ . '/inc/MarkdownGenerator.php');
    $generator = new MarkdownGenerator($config, $modules);
    $generator->execute($params['destDir']);

    file_put_contents($params['destDir'] . DS . 'modules.json', json_encode($modules));
}
else if ($params['command'] == 'generate')
{
    $modules = json_decode(file_get_contents($params['srcFilesDir'] . DS . 'modules.json'), true);
    require_once(__DIR__ . '/inc/LocalHTMLGenerator.php');
    $generator = new LocalHTMLGenerator($config, $modules);
    $generator->execute($params['srcFilesDir'], $params['destDir']);
}
