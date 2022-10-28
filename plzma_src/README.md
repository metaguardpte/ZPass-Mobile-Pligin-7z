delegatePlzma.cpp is the entrance to access 7zip functions

### build so for android
1. go to android/
2. execute ndk-build (r25b) 

### build dylib for ios
1. mkdir build
2. cd build
3. cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../ios.toolchain.cmake -DPLATFORM=OS64 -DENABLE_BITCODE=TRUE
4. cmake --build . --config Release
