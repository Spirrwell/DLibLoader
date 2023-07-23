# DLibLoader
D library that loads dynamic libraries on Windows, Linux, and macOS. Based on this C++ library: https://github.com/craftablescience/LibLoader

## General usage
```d
import std.stdio;
import std.typecons;
import libloader;

void main() {
	// You don't need to specify the extension .dll, .so, or .dylib, but you can
	library lib = library( "path/to/library", ".dll" );
	
	if ( lib.isLoaded() ) {
		if ( lib.callC!(void)( "MyCoolCFun" ) ) {
			writeln( "Success" );
		}
		else {
			writeln( "Failed" );
		}

		Nullable!float result = lib.callC!(float)( "MyCoolFloatCFun" );
		if ( result.isNull() ) {
			writeln( "Failed" );
		}
		else {
			writeln( result.get() );
		}
	}
}
```
