# Build for macOS (Intel and Arm64)
rm -rf build obj && mkdir build && mkdir obj && (cd build && cmake .. && make)
