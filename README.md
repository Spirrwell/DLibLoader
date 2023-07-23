# DLibLoader
D library that loads dynamic libraries on Windows, Linux, and macOS. Based on this C++ library: https://github.com/craftablescience/LibLoader

## General usage
```d
import std.stdio;
import std.typecons;
import libloader;

void main() {
	library lib = library( "build/test" );
	
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
