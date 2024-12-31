# riscv-gnu-toolchain-container

### Build

```bash
docker build -t riscv-gcc:latest -f Dockerfile .
```

### Run

```bash
docker run -it --rm -v "${PWD}:/work" -w "/work" riscv-gcc:latest riscv64-unknown-gnu-linux-gnu-gcc -static -o hello hello.c
```
