# zip_plugin

A 7zip plugin project to do compress/decompress within 7z format.

## Getting Started
1. Add p7zip.cpp (7zip wrapper) to 7zip_source_code\p7zip_16.02\CPP\7zip\p7zip.cpp
2. build android-so from ./7zip_source_code
	go to 7zip_source_code\p7zip_16.02\CPP\ANDROID\7zr\jni
	change Android.mk:
		add text: ../../../../CPP/7zip/p7zip.cpp \   to the end of section LOCAL_SRC_FILES
	change Application.mk:
		APP_ABI := armeabi-v7a arm64-v8a
		APP_PLATFORM := android-14
	download android-ndk-r13b
	run android-ndk-r13b\ndk-build
	finally we have lib7zr.so at 7zip_source_code\p7zip_16.02\CPP\ANDROID\7zr\libs
3. build ios-dylib from ./7zip_source_code

