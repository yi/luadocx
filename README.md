## luadocx

Documentation Generator Tool for the Lua language

<br />

### Get Started

~~~ .shell
Usage: luadocx [-t title] [-r root] [-i index] [-x exclude] source_files_dir output_dir

Parameters:
    -t title of the documents
    -r root module name
    -i index module name
    -x excludes
~~~

<br />

### Examples:

~~~ .shell
$ php luadocx.php -t "My App Docuemtns" -r MyApp -i MyApp.main MyApp/ docs/
$ php luadocx.php -r MyApp -x "MyApp.tests,MyApp.data" MyApp/ docs/
~~~

<br />

See example/doc/index.html
