# riscv-gnu-toolchain-container

### Build

```bash
docker build -t riscv-gcc:12.2.0 -f Dockerfile .
```

### Run

```bash
docker run -it --rm -v "${PWD}:/work" -w "/work" riscv-gcc:12.2.0 riscv64-unknown-gnu-linux-gnu-gcc -static -o hello hello.c
```
