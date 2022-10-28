#include <stdint.h>;
#include "src/plzma_out_streams.hpp"
#include<iostream>
#include<string>
using namespace std;
using namespace plzma;

class MyProgressDelegate : public ProgressDelegate {
public:
    virtual void onProgress(void * LIBPLZMA_NULLABLE context, const String & path, const double progress) override final {
#if defined(LIBPLZMA_OS_WINDOWS)
        std::wcout << L"Path: " << path.wide() << L", progress: " << progress << std::endl;
#else
        std::cout << "Path: " << path.utf8() << ", progress: " << progress << std::endl;
#endif
    }
};

static MyProgressDelegate * _progressDelegate = new MyProgressDelegate();

static int parseStrings(char *cmd, char argv[16][512]) {
    int size = strlen(cmd);
    int preChar = 0;
    int a = 0;
    int b = 0;
    for (int i = 0; i < size; ++i) {
        char c = cmd[i];
        switch (c) {
        case ' ':
        case '\t':
            if (preChar == 1) {
                argv[a][b++] = '\0';
                a++;
                b = 0;
                preChar = 0;
            }
            break;

        default:
            preChar = 1;
            argv[a][b++] = c;
            break;
        }
    }

    if (cmd[size - 1] != ' ' && cmd[size - 1] != '\t') {
        argv[a][b] = '\0';
        a++;
    }
    return a;
}

extern "C" int32_t compressFiles(char *files, char *toZipFullPath){
    try {
         const auto archivePathOutStream = makeSharedOutStream(Path(toZipFullPath));

         // 2. Create encoder with output stream, type of the archive, compression method and optional progress delegate.
         auto encoder = makeSharedEncoder(archivePathOutStream, plzma_file_type_7z, plzma_method_LZMA2);
         encoder->setProgressDelegate(_progressDelegate);

         int numArgs;
         // 最大支持16个参数
         char temp[16][512] = {0};
         numArgs = parseStrings(files, temp);
         char *args[16] = {0};
         for (int i = 0; i < numArgs; ++i) {
             args[i] = temp[i];
         }

         for (int i = 0; i < numArgs; i++){
             encoder->add(Path(args[i]));
         }

         // 3. Open.
         bool opened = encoder->open();

         // 4. Compress.
         bool compressed = encoder->compress();
         return 0;
    } catch (const Exception & exception) {
         std::cout << "Exception: " << exception.what() << std::endl;
         return 1;
    }
}

extern "C" int32_t compressPath(char *fromPath, char *toZipFullPath){
    try {
        // 1. Create output stream for writing archive's file content.
        //  1.1. Using file path.
        const auto archivePathOutStream = makeSharedOutStream(Path(toZipFullPath));

        // 2. Create encoder with output stream, type of the archive, compression method and optional progress delegate.
        auto encoder = makeSharedEncoder(archivePathOutStream, plzma_file_type_7z, plzma_method_LZMA2);
        encoder->setProgressDelegate(_progressDelegate);

        // 3. Add content for archiving.
        //  3.1. Single file path with optional path inside the archive.
        //encoder->add(Path("dir/my_file1.txt"));  // store as "dir/my_file1.txt", as is.
        //encoder->add(Path("dir/my_file2.txt"), 0, Path("renamed_file2.txt")); // store as "renamed_file2.txt"

        //  3.2. Single directory path with optional directory iteration option and optional path inside the archive.
        encoder->add(Path(fromPath)); // store as "dir1/..."

        // 4. Open.
        bool opened = encoder->open();

        // 4. Compress.
        bool compressed = encoder->compress();
        return 0;
    } catch (const Exception & exception) {
        std::cout << "Exception: " << exception.what() << std::endl;
        return 1;
    }
}

extern "C" int32_t decompress(char *fromZipFullPath, char *toPath){
    try {
        // 1. Create a source input stream for reading archive file content.
        //  1.1. Create a source input stream with the path to an archive file.
        Path archivePath(fromZipFullPath);
        auto archivePathInStream = makeSharedInStream(archivePath /* std::move(archivePath) */);

        // 2. Create decoder with source input stream, type of archive and provide optional delegate.
        auto decoder = makeSharedDecoder(archivePathInStream, plzma_file_type_7z);
        decoder->setProgressDelegate(_progressDelegate);

        bool opened = decoder->open();

        // 3. Select archive items for extracting or testing.
        //  3.1. Select all archive items.
        auto allArchiveItems = decoder->items();

        // 4. Extract all items to a directory. In this case, you can skip the step #3.
        bool extracted = decoder->extract(Path(toPath));
        return 0;
    } catch (const Exception & exception) {
        std::cout << "Exception: " << exception.what() << std::endl;
        return 1;
    }
}

