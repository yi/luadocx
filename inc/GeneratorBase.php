<?php

require_once(__DIR__ . '/Michelf/MarkdownExtra.inc.php');

function markdown($contents)
{
    return \Michelf\MarkdownExtra::defaultTransform($contents);
}

function linkToModule($moduleName)
{

}

abstract class GeneratorBase
{
    protected $config;
    protected $modules;

    private $chars = array('.', '-', '/', ':');

    public function __construct(Config $config, array $modules)
    {
        $this->config = $config;
        $this->modules = $modules;
        usort($this->modules, array($this, 'compareTwoModule'));
    }

    protected function getModuleFilename($moduleName, $extname)
    {
        return strtolower(str_replace($this->chars, '_', $moduleName)) . $extname;
    }

    protected function getModulePath($destDir, $moduleName, $extname)
    {
        return $destDir . DS . $this->getModuleFilename($moduleName, $extname);
    }

    protected function getModuleFunctionFilename($moduleName, $functionName, $extname)
    {
        $parts = explode('.', $moduleName);
        $last = $parts[count($parts) - 1];
        $parts = explode('.', $functionName);
        $first = $parts[0];
        if ($first == $last)
        {
            array_shift($parts);
            $functionName = implode('.', $parts);
        }
        return strtolower(str_replace($this->chars, '_', $moduleName . '_function_' . $functionName)) . $extname;
    }

    protected function getModuleFunctionPath($destDir, $moduleName, $functionName, $extname)
    {
        return $destDir . DS . $this->getModuleFunctionFilename($moduleName, $functionName, $extname);
    }

    protected function compareTwoModule($one, $two)
    {
        $oneDepth = substr_count($one['moduleName'], '.');
        $twoDepth = substr_count($two['moduleName'], '.');
        if ($oneDepth == 0 && $twoDepth == 0) return strcmp($one['moduleName'], $two['moduleName']);
        if ($oneDepth == 0) return -1;
        if ($twoDepth == 0) return 1;

        return strcmp($one['moduleName'], $two['moduleName']);
    }

    protected function copyFile($srcDir, $destDir, $filename)
    {
        copy(rtrim($srcDir, '/\\') . DS . $filename, rtrim($destDir, '/\\') . DS . $filename);
    }
}
