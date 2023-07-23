// Based on this C++ library: https://github.com/craftablescience/LibLoader

module libloader;
import core.runtime;
import std.typecons;
import std.traits;
import core.demangle;

version( Windows ) {
	import core.sys.windows.winbase;
	immutable string DEFAULT_LIBRARY_FILE_TYPE = ".dll";
}
else version( linux ) {
	import core.sys.linux.dlfcn;
	immutable string DEFAULT_LIBRARY_FILE_TYPE = ".so";
}
else version( OSX ) {
	import core.sys.darwin.dlfcn;
	immutable string DEFAULT_LIBRARY_FILE_TYPE = ".dylib";
}
else {
	static assert( false, "Unsupported platform" );
}

struct library {
	public this( immutable string path, immutable string extension = DEFAULT_LIBRARY_FILE_TYPE ) {
		immutable string fullpath = path ~ extension;
		this.libraryHandle = Runtime.loadLibrary( fullpath );
	}

	public ~this() {
		if ( libraryHandle != null ) {
			Runtime.unloadLibrary( libraryHandle );
		}
	}

	@disable this( const ref library );

	public bool isLoaded() const {
		return this.libraryHandle != null;
	}

	public auto callD( T, Args... )( immutable string functionName, Args args ) {
		alias FUNC = T function ( Args );
		immutable string mangledName = mangleFunc!FUNC( functionName ).idup;

		return doCall!FUNC( mangledName, args );
	}

	public auto callC( T, Args... )( immutable string functionName, Args args ) {
		alias FUNC = extern(C) T function ( Args );
		return doCall!FUNC( functionName, args );
	}

	private void* lookup( immutable string functionName ) {
		void** fnLookup = functionName in funcLookup;

		if ( fnLookup ) {
			return *fnLookup;
		}

		version ( Windows ) void* fn = GetProcAddress( this.libraryHandle, functionName.ptr );
		else version ( linux ) void* fn = dlsym( this.libraryHandle, functionName.ptr );
		else version( OSX ) void* fn = dlsym( this.libraryHandle, functionName.ptr );

		if ( fn ) {
			funcLookup[functionName] = fn;
		}

		return fn;
	}

	private auto doCall( FUNCT, Args... )( immutable string functionName, Args args ) {
		FUNCT fn = cast(FUNCT)lookup( functionName );
		alias rType = ReturnType!( FUNCT );

		static if ( is( rType == void ) ) {
			if ( fn == null ) {
				return false;
			}

			fn( args );
			return true;
		}
		else {
			if ( fn == null ) {
				Nullable!rType result;
				return result;
			}

			return nullable( fn( args ) );
		}
	}

	private void* libraryHandle;
	private void*[string] funcLookup;
}
