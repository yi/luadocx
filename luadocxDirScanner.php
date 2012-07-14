<?php

require(__DIR__ . '/luadocxFileParser.php');

class DirScanner
{

    private $sourceFilesDir;
    private $outputDir;
    private $title;
    private $rootModuleName;
    private $indexModuleName;

    public function __construct(array $params)
    {
        $this->sourceFilesDir  = $params['sourceFilesDir'];
        $this->outputDir       = $params['outputDir'];
        $this->title           = isset($params['title']) ? $params['title'] : '';
        $this->rootModuleName  = isset($params['rootModuleName']) ? $params['rootModuleName'] : '';
        $this->indexModuleName = isset($params['indexModuleName']) ? $params['indexModuleName'] : 'main';
    }

    private function compareTwoModule($one, $two)
    {
        $oneDepth = substr_count($one['moduleName'], '.');
        $twoDepth = substr_count($two['moduleName'], '.');
        if ($oneDepth == 0 && $twoDepth == 0) return strcmp($one['moduleName'], $two['moduleName']);
        if ($oneDepth == 0) return -1;
        if ($twoDepth == 0) return 1;

        return strcmp($one['moduleName'], $two['moduleName']);
    }

    public function execute()
    {
        $paths = $this->getFiles($this->sourceFilesDir);

        $prefixLength = strlen($this->sourceFilesDir);
        $modules = array();
        $indexModule = null;
        for ($i = 0; $i < count($paths); $i++)
        {
            $path = $paths[$i];
            $filename = trim(substr(substr($path, 0, -3), $prefixLength), "/\\.");
            $moduleName = str_replace(DS, '.', $filename);
            if (!empty($this->rootModuleName))
            {
                $moduleName = $this->rootModuleName . '.' . $moduleName;
            }
            $module = array(
                'path'           => $path,
                'filename'       => $filename,
                'moduleName'     => $moduleName,
                'outputFilename' => strtolower($moduleName) . '.html',
            );
            if ($moduleName == $this->indexModuleName)
            {
                $module['outputFilename'] = 'index.html';
                $indexModule = $module;
            }
            else
            {
                $modules[] = $module;
            }
        }
        usort($modules, array($this, 'compareTwoModule'));

        if (!$indexModule)
        {
            printf("\nnot found index module.\n");
            return false;
        }

        array_unshift($modules, $indexModule);

        foreach ($modules as $module)
        {
            printf('processing %s ...', $module['moduleName']);
            $parser = new FileParser($this->title, $module['moduleName'], $indexModule['outputFilename']);
            $parser->parse($module['path']);

            $outputPath = $this->outputDir . DS . $module['outputFilename'];
            file_put_contents($outputPath, $parser->html($modules));
            print("ok\n");
        }

        copy(__DIR__ . DS . 'luadocx.css', $this->outputDir . DS . 'luadocx.css');
        print("copy css file.\n");
        print("\n");

        return true;
    }

    private function getFiles($dir)
    {
        $files = array();
        $dir = rtrim($dir, "/\\") . DS;
        $dh = opendir($dir);
        if ($dh == false) { return $files; }

        while (($file = readdir($dh)) !== false)
        {
            if ($file{0} == '.') { continue; }

            $path = $dir . $file;
            if (is_dir($path))
            {
                $files = array_merge($files, $this->getFiles($path));
            }
            elseif (is_file($path))
            {
                $files[] = $path;
            }
        }
        closedir($dh);
        return $files;
    }

}
