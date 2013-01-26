@ECHO OFF
@REM PRESERVE ORIGINAL PATH
@SET CURRENT_DIR=%CD%
@SET PTH_ORG=%PATH%

@ECHO .---------------------------------------------------.
@ECHO #
@ECHO # 		APACHE 2.4.2 automated build script
@ECHO #
@ECHO # author: Martin Lierschof mlierschof@vizrt.com
@ECHO #
@ECHO # Modified script originated from Rainer Jung
@ECHO # http://mail-archives.apache.org/mod_mbox/httpd-dev/201201.mbox/%3C4F0485CC.2070106@kippdata.de%3E
@ECHO #
@ECHO .---------------------------------------------------.

@ECHO .---------------------------------------------------.
@ECHO #  
@ECHO #  					PREREQUISTES
@ECHO #  
@ECHO #  	Make sure to have following preqs installed
@ECHO #  	and you have configured the necessary paths in the config section
@ECHO #  
@ECHO #  
@ECHO #  - Windows SDK 7.1
@ECHO #  - Visual Studio 10
@ECHO #  - perl for Windows (http://www.activestate.com/activeperl + set path in installer)
@ECHO #  - python for Windows (http://www.activestate.com/activepython + set path in installer)
@ECHO #  - cmake for Windows (http://www.cmake.org/cmake/resources/software.html + win32 installer + set path in installer)
@ECHO #
@ECHO #  included in the package:
@ECHO #  - svn binaries for windows (http://www.sliksvn.com/en/download/)
@ECHO #  - gnu tools for Windows (http://gnuwin32.sourceforge.net/)
@ECHO #  - nasm for Windows (http://www.nasm.us/pub/nasm/releasebuilds/2.10rc8/win32/)	
@ECHO #
@ECHO .---------------------------------------------------.

@REM -------------------------------------------------------------
@REM 
@REM                 CONFIG SECTION
@REM 
@REM -------------------------------------------------------------

@REM configure your the script behaviour: not all combinations will work in all cases
@SET DO_DOWNLOAD=1
@SET DO_DOWNLOAD_BUILD=1
@SET DO_COPY_STUFF=1
@SET DO_MANUAL_PREPARE=1
@SET DO_FIXES=1

@REM set paths to your binaries
@SET VC100_VARS_BAT="C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC"
@REM delivered binaries in package
@SET GNU_PTH=%CURRENT_DIR%\bin\GnuWin32
@SET SVN_DIR=%CURRENT_DIR%\bin\svn\bin
@SET NASM_DIR=%CURRENT_DIR%\bin\nasm\

@REM set paths to destination directories
@SET REPOS_DIR=%CURRENT_DIR%\repos
@SET EXTERNAL_BIN_DIR=%CURRENT_DIR%\extern\bin
@SET EXTERNAL_DOWNLOAD_DIR=%CURRENT_DIR%\extern\download
@SET APACHE_DIR=%CURRENT_DIR%\2.4.x
@SET FINAL_DIR=%CURRENT_DIR%\Install

@REM -------------------------------------------------------------
@REM 
@REM                 Script start
@REM 
@REM -------------------------------------------------------------

IF NOT EXIST %EXTERNAL_BIN_DIR% (
	@ECHO # Install dir not existing creating: %EXTERNAL_BIN_DIR%
	mkdir %EXTERNAL_BIN_DIR%
)
IF NOT EXIST %APACHE_DIR% (
	@ECHO # Dest dir not existing creating: %APACHE_DIR%
	mkdir %APACHE_DIR%
)
IF NOT EXIST %EXTERNAL_DOWNLOAD_DIR% (
	@ECHO # Download dir not existing creating: %EXTERNAL_DOWNLOAD_DIR%
	mkdir %EXTERNAL_DOWNLOAD_DIR%
)
IF NOT EXIST %FINAL_DIR% (
	@ECHO # Final dir not existing creating: %FINAL_DIR%
	mkdir %FINAL_DIR%
)

@rem SET PATH=%PTH_ORG%;%GNU_PTH%;%WIN7SDK_DIR%;%NASM_DIR%
@REM Setting visual studio path variables
call %VC100_VARS_BAT%\vcvarsall.bat

@REM SET VERSION NUMBERS FOR HTTPD AND SCRLIB APPS
@REM SET HTTPD VERSION 
@SET HPD_VSN=2.4.x
@REM SET APR VERSION 
@SET APR_VSN=1.5.x
@REM SET APR-ICONV VERSION 
@SET API_VSN=1.1.x
@REM SET APR-UTIL VERSION 
@SET APU_VSN=1.5.x
@REM SET OPENSSL VERSION 
@SET OPS_VSN=1.0.1c
@REM SET PCRE VERSION
@SET PCR_VSN=8.32
@REM SET ZLIB VERSION
@SET ZLB_VSN=1.2.7

@REM SET APR-ICONV RELEASE
@SET API_RVN=r2

@REM SET PACKAGES
@SET OPS_PKG=openssl-%OPS_VSN%
@SET PCR_PKG=pcre-%PCR_VSN%
@SET ZLB_PKG=zlib-%ZLB_VSN%

@REM SET DIRS
@SET HPD_DIR=%REPOS_DIR%\httpd-%HPD_VSN%
@SET APR_DIR=%REPOS_DIR%\apr-%APR_VSN%
@SET API_DIR=%REPOS_DIR%\apr-iconv-%API_VSN%
@SET APU_DIR=%REPOS_DIR%\apr-util-%APU_VSN%

@REM SET PACKAGES
@SET OPS_PKG_EXT=%OPS_PKG%.tar.gz
@SET PCR_PKG_EXT=%PCR_PKG%.tar.gz
@SET ZLB_PKG_EXT=%ZLB_PKG%.tar.gz

@REM SET URLS
@SET HPD_URL=http://svn.apache.org/repos/asf/httpd/httpd/branches/%HPD_VSN%
@SET APR_URL=http://svn.apache.org/repos/asf/apr/apr/branches/%APR_VSN%
@SET API_URL=http://svn.apache.org/repos/asf/apr/apr-iconv/branches/%API_VSN%
@SET APU_URL=http://svn.apache.org/repos/asf/apr/apr-util/branches/%APU_VSN%
@SET OPS_URL=http://www.openssl.org/source/%OPS_PKG_EXT%
@SET PCR_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/%PCR_PKG_EXT%
@SET ZLB_URL=http://www.zlib.net/%ZLB_PKG_EXT%

@ECHO .---------------------------------------------------.
@ECHO #
@ECHO #  STARTING TO DOWNLOAD AND COMPILE APACHE: %HPD_VSN%
@ECHO #
@ECHO # 		SETTINGS:
@ECHO #
@ECHO #	CURRENT_DIR: %CURRENT_DIR%
@ECHO #	GNU_PTH: %GNU_PTH%
@ECHO #
@ECHO #	HPD_VSN: %HPD_VSN%
@ECHO #	APR_VSN: %APR_VSN%
@ECHO #	API_VSN: %API_VSN%
@ECHO #	APU_VSN: %APU_VSN%
@ECHO #	OPS_VSN: %OPS_VSN%
@ECHO #	PCR_VSN: %PCR_VSN%
@ECHO #	ZLB_VSN: %ZLB_VSN%
@ECHO #	API_RVN: %API_RVN%
@ECHO #
@ECHO #	HPD_URL: %HPD_URL%
@ECHO #	APR_URL: %APR_URL%
@ECHO #	API_URL: %API_URL%
@ECHO #	APU_URL: %APU_URL%
@ECHO #	OPS_URL: %OPS_URL%
@ECHO #	PCR_URL: %PCR_URL%
@ECHO #	ZLB_URL: %ZLB_URL%
@ECHO #
@ECHO .---------------------------------------------------.

IF %DO_DOWNLOAD% == 1 (
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		INITIALIZED: STARTING TO DOWNlOAD
	@ECHO #
	@ECHO .---------------------------------------------------.

	@REM GET APACHE SOURCE
	IF EXIST %HPD_DIR% (
		@ECHO UPDATING %HPD_DIR%
		%SVN_DIR%\svn.exe update %HPD_DIR%
	) ELSE (
		@ECHO CHECKOUT %HPD_DIR%
		%SVN_DIR%\svn.exe checkout %HPD_URL% %HPD_DIR%
	)
	
	IF EXIST %APR_DIR% (
		@ECHO UPDATING %APR_DIR%
		%SVN_DIR%\svn.exe update %APR_DIR%
	) ELSE (
		@ECHO CHECKOUT %APR_DIR%
		%SVN_DIR%\svn.exe checkout %APR_URL% %APR_DIR%
	)
	
	IF EXIST %API_DIR% (
		@ECHO UPDATING %API_DIR%
		%SVN_DIR%\svn.exe update %API_DIR%
	) ELSE (
		@ECHO CHECKOUT %API_DIR%
		%SVN_DIR%\svn.exe checkout %API_URL% %API_DIR%
	)
	
	IF EXIST %APU_DIR% (
		@ECHO UPDATING %APU_DIR%
		%SVN_DIR%\svn.exe update %APU_DIR%
	) ELSE (
		@ECHO CHECKOUT %APU_DIR%
		%SVN_DIR%\svn.exe checkout %APU_URL% %APU_DIR%
	)
	
	@REM change to download dir
	cd %EXTERNAL_DOWNLOAD_DIR%
	
	@REM UPDATE OPENSSL SOURCE
	IF EXIST %OPS_PKG_EXT% (
		@ECHO %OPS_PKG_EXT% exists
		@SET VAR_DOWNLOAD_SSL=1
	)
	IF EXIST %OPS_PKG%.tar (
		@ECHO %OPS_PKG%.tar exists
		@SET VAR_DOWNLOAD_SSL=1
	)
	IF NOT DEFINED VAR_DOWNLOAD_SSL (
		@ECHO DOWNLOADING %OPS_URL%
		WGET %OPS_URL%
	)
	IF EXIST "%EXTERNAL_DOWNLOAD_DIR%/openssl" (
		@ECHO Removing dir %EXTERNAL_DOWNLOAD_DIR%/openssl
		rmdir /s /q "%EXTERNAL_DOWNLOAD_DIR%/openssl"
	)
	IF NOT EXIST "%EXTERNAL_DOWNLOAD_DIR%/openssl" (
		@ECHO Extracting %OPS_PKG_EXT%
		IF NOT EXIST %OPS_PKG%.tar (
			GZIP -d %OPS_PKG_EXT%
		)
		TAR xf %OPS_PKG%.tar
		@RENAME %OPS_PKG% openssl
	)
	
	@REM UPDATE PCRE
	IF EXIST %PCR_PKG_EXT% (
		@ECHO %PCR_PKG_EXT% exists
		@SET VAR_DOWNLOAD_PCR=1
	)
	IF EXIST %PCR_PKG%.tar (
		@ECHO %PCR_PKG%.tar exists
		@SET VAR_DOWNLOAD_PCR=1
	)
	IF NOT DEFINED VAR_DOWNLOAD_PCR (
		@ECHO DOWNLOADING %PCR_URL%
		WGET %PCR_URL%
	)
	IF EXIST "%EXTERNAL_DOWNLOAD_DIR%/pcre" (
		@ECHO Removing dir %EXTERNAL_DOWNLOAD_DIR%/pcre
		rmdir /s /q "%EXTERNAL_DOWNLOAD_DIR%/pcre"
	)
	IF NOT EXIST "%EXTERNAL_DOWNLOAD_DIR%/pcre" (
		@ECHO Extracting %PCR_PKG_EXT%
		IF NOT EXIST %PCR_PKG%.tar (
			GZIP -d %PCR_PKG_EXT%
		)
		TAR xf %PCR_PKG%.tar
		@RENAME %PCR_PKG% pcre
	)

	@REM GET ZLIB SOURCE
	IF EXIST %ZLB_PKG_EXT% (
		@ECHO %ZLB_PKG_EXT% exists
		@SET VAR_DOWNLOAD_ZLB=1
	)
	IF EXIST %ZLB_PKG%.tar (
		@ECHO %ZLB_PKG%.tar exists
		@SET VAR_DOWNLOAD_ZLB=1
	)
	IF NOT DEFINED VAR_DOWNLOAD_ZLB (
		@ECHO DOWNLOADING %ZLB_PKG_EXT%
		WGET %ZLB_URL%
	)
	IF EXIST "%EXTERNAL_DOWNLOAD_DIR%/zlib" (
		@ECHO Removing dir %EXTERNAL_DOWNLOAD_DIR%/zlib
		rmdir /s /q "%EXTERNAL_DOWNLOAD_DIR%/zlib"
	)
	IF NOT EXIST "%EXTERNAL_DOWNLOAD_DIR%/zlib" (
		@ECHO Extracting %ZLB_PKG_EXT%
		IF NOT EXIST %ZLB_PKG%.tar (
			GZIP -d %ZLB_PKG_EXT%
		)
		TAR xf %ZLB_PKG%.tar
		@RENAME %ZLB_PKG% zlib
	)
	
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		DOWNLOADED: STARTING TO BUILD
	@ECHO #
	@ECHO .---------------------------------------------------.
) ELSE (
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		NO DOWNLOAD DECLARED: STARTING TO BUILD
	@ECHO #
	@ECHO .---------------------------------------------------.
)

IF %DO_DOWNLOAD_BUILD% == 1 (
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		BUILDING ZLIB
	@ECHO #
	@ECHO .---------------------------------------------------.
	cd %EXTERNAL_DOWNLOAD_DIR%\zlib
	nmake -f win32/Makefile.msc LOC="-DASMV -DASMINF" OBJA="inffas32.obj match686.obj"
	nmake -f win32/Makefile.msc test
	nmake -f win32/Makefile.msc testdll

	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		BUILDING OPENSSL
	@ECHO #			SET NASM TO PATH
	@ECHO #
	@ECHO .---------------------------------------------------.
	cd %EXTERNAL_DOWNLOAD_DIR%\openssl
	IF EXIST %EXTERNAL_BIN_DIR%\openssl (
		@ECHO # %EXTERNAL_BIN_DIR%\openssl exist deleting
		rmdir /s /q "%EXTERNAL_BIN_DIR%\openssl"
	)
	IF NOT EXIST %EXTERNAL_BIN_DIR%\openssl (
		@ECHO # %EXTERNAL_BIN_DIR%\openssl dir not existing creating: %EXTERNAL_BIN_DIR%\openssl
		mkdir %EXTERNAL_BIN_DIR%\openssl
	)
	perl Configure no-idea no-mdc2 enable-zlib VC-WIN32 --prefix=%EXTERNAL_BIN_DIR%\openssl
	@ECHO # openssl configured
	call ms\do_nasm.bat
	@ECHO # openssl assembled
	nmake -f ms\ntdll.mak
	@ECHO # openssl mak
	nmake -f ms\ntdll.mak test
	@ECHO # openssl test
	nmake -f ms\ntdll.mak install
	@ECHO # openssl install

	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		BUILDING pcre
	@ECHO #
	@ECHO .---------------------------------------------------.
	cd %EXTERNAL_DOWNLOAD_DIR%\pcre
	IF EXIST build (
		@ECHO # build exist deleting
		rmdir /s /q "build"
	)
	IF NOT EXIST build (
		@ECHO # build dir not existing creating: build
		mkdir build
	)

	IF EXIST %EXTERNAL_BIN_DIR%\pcre (
		@ECHO # %EXTERNAL_BIN_DIR%\pcre exist deleting
		rmdir /s /q "%EXTERNAL_BIN_DIR%\pcre"
	)
	IF NOT EXIST %EXTERNAL_BIN_DIR%\pcre (
		@ECHO # %EXTERNAL_BIN_DIR%\pcre dir not existing creating: %EXTERNAL_BIN_DIR%\pcre
		mkdir %EXTERNAL_BIN_DIR%\pcre
	)
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		CALLING CMAKE GUI to configure:
	@ECHO #	
	@ECHO #		--- Enter your %EXTERNAL_DOWNLOAD_DIR%\pcre\ as "Where is the source code" and 
	@ECHO #			%EXTERNAL_DOWNLOAD_DIR%\pcre\build as "Where to build the binaries"
	@ECHO #			not using the variable.
	@ECHO #		
	@ECHO #		--- Click "Configure"
	@ECHO #		
	@ECHO #		--- Choose "NMake makefiles"
	@ECHO #		
	@ECHO #		--- Check "BUILD_SHARED_LIBS"
	@ECHO #		--- Check "PCRE_SUPPORT_UTF"
	@ECHO #		--- Set CMAKE_BUILD_TYPE to "RelWithDebInfo"
	@ECHO #		--- Set CMAKE_INSTALL_DIR_PREFIX to %EXTERNAL_BIN_DIR%\pcre
	@ECHO #		
	@ECHO #		--- Click "Configure" again.
	@ECHO #		
	@ECHO #		--- Click "Generate"
	@ECHO #
	@ECHO .---------------------------------------------------.
	cmake-gui
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		BUILD DONE: CMAKE GUI CLOSED
	@ECHO #
	@ECHO .---------------------------------------------------.

	cd build
	nmake -f Makefile
	nmake -f Makefile test
	nmake -f Makefile install
) ELSE (
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # 		no other build declard going on
	@ECHO #
	@ECHO .---------------------------------------------------.
)

@ECHO .---------------------------------------------------.
@ECHO #
@ECHO # 		COPYING THE STUFF
@ECHO #
@ECHO .---------------------------------------------------.

IF %DO_COPY_STUFF% == 1 (
	@ECHO # COPYING %HPD_DIR% TO %APACHE_DIR%\
	xcopy /s/e/y %HPD_DIR% %APACHE_DIR%\
	@ECHO # COPYING %APR_DIR% TO %APACHE_DIR%\srclib\apr\
	xcopy /s/e/y %APR_DIR% %APACHE_DIR%\srclib\apr\
	@ECHO # COPYING %APU_DIR% TO %APACHE_DIR%\srclib\apr-util\
	xcopy /s/e/y %APU_DIR% %APACHE_DIR%\srclib\apr-util\
	@ECHO # COPYING %API_DIR% TO %APACHE_DIR%\srclib\apr-iconv\
	xcopy /s/e/y %API_DIR% %APACHE_DIR%\srclib\apr-iconv\
	@ECHO # COPYING %EXTERNAL_BIN_DIR%\openssl TO %APACHE_DIR%\srclib\openssl\
	xcopy /s/e/y %EXTERNAL_BIN_DIR%\openssl %APACHE_DIR%\srclib\apr-iconv\
	@ECHO # COPYING %EXTERNAL_DOWNLOAD_DIR%\zlib TO %APACHE_DIR%\srclib\zlib\
	xcopy /s/e/y %EXTERNAL_DOWNLOAD_DIR%\zlib %APACHE_DIR%\srclib\zlib\
	@ECHO # COPYING %EXTERNAL_BIN_DIR%\pcre TO %APACHE_DIR%\srclib\pcre\
	xcopy /s/e/y %EXTERNAL_BIN_DIR%\pcre %APACHE_DIR%\srclib\pcre\
	@ECHO # COPYING %EXTERNAL_DOWNLOAD_DIR%\pcre\build\pcre.* TO %APACHE_DIR%\srclib\pcre\
	xcopy /s/e/y %EXTERNAL_DOWNLOAD_DIR%\pcre\build\pcre.* %APACHE_DIR%\srclib\pcre\
)

IF %DO_MANUAL_PREPARE% == 1 (
	cd %APACHE_DIR%
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # Replacing "httpd.vcproj" by "httpd.vcxproj" in Makefile.win 
	@ECHO #
	@ECHO .---------------------------------------------------.
	IF EXIST tempfile.win (
		DEL tempfile.win
	)
	CALL %CURRENT_DIR%\replace.bat vcproj vcxproj makefile.win>tempfile.win
	DEL makefile.win
	RENAME tempfile.win makefile.win
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # Starting Apache.dsw to convert projects
	@ECHO #
	@ECHO # Converting to Apache.sln, press ok and start the conversion
	@ECHO # When conversion is done safe and close the solution
	@ECHO #
	@ECHO # ONLY CONTINUE: After all steps are done
	@ECHO # and solution is saved and closed!
	@ECHO #
	@ECHO .---------------------------------------------------.
	devenv /upgrade Apache.dsw
	@PAUSE
	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # Starting Apache.sln to initialize solution file:
	@ECHO # "Tools - Options". In the Popup choose 
	@ECHO # "Projects and Solutions" and then "Build and Run". 
	@ECHO # Set "maximum number of parallel project builds" to "1".
	@ECHO #
	@ECHO # ONLY CONTINUE: After all steps are done
	@ECHO # and solution is saved and closed!
	@ECHO #
	@ECHO .---------------------------------------------------.
@rem	devenv Apache.sln
	@PAUSE
	@ECHO .---------------------------------------------------.
	@ECHO # Finished convertig VC Apache files
	@ECHO .---------------------------------------------------.
)

IF %DO_FIXES% == 1 (
	@ECHO # COPYING %CURRENT_DIR%\new_refs.py TO %APACHE_DIR%\new_refs.py
	copy %CURRENT_DIR%\new_refs.py %APACHE_DIR%\new_refs.py
	@ECHO # COPYING %CURRENT_DIR%\fixes.pl TO %APACHE_DIR%\fixes.pl
	copy %CURRENT_DIR%\fixes.pl %APACHE_DIR%\fixes.pl

	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # adding new refs to Apache.sln
	@ECHO #
	@ECHO .---------------------------------------------------.
	cd %APACHE_DIR%
	python new_refs.py -i Apache.sln

	@ECHO .---------------------------------------------------.
	@ECHO #
	@ECHO # doing fixes
	@ECHO #
	@ECHO .---------------------------------------------------.
	cd %APACHE_DIR%
	perl fixes.pl
)

cd %APACHE_DIR%
@ECHO .---------------------------------------------------.
@ECHO #
@ECHO # BUILDING APACHE.sln via nmake (cant build via visual studio)
@ECHO #
@ECHO .---------------------------------------------------.
nmake -f Makefile.win PORT=8000 SSLPORT=8443 INSTDIR=%FINAL_DIR% installr

goto SUCCESS

:ERROR
@ECHO .---------------------------------------------------.
@ECHO #
@ECHO # 		ERROR ERROR ERROR
@ECHO #
@ECHO .---------------------------------------------------.
goto FINISH

:SUCCESS
@ECHO 
@ECHO .---------------------------------------------------.
@ECHO #
@ECHO # 		SUCCESS
@ECHO #
@ECHO .---------------------------------------------------.
@ECHO 
goto FINISH

:FINISH 
@REM RESTORE ORIGINAL PATH
@REM @SET PATH=%PTH_ORG%
@REM SET ORIG CD
cd %CURRENT_DIR% 