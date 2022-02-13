# SciWasm.Sparse

SciWasm.Sparse is a web-based computing framework that offers efficient and scalable sparse matrix CPU kernels to support 
high-performance computing in web browsers. It supports both serial and parallel Sparse BLAS Level II operations, 
element-wise operations, and conversion routines for a number of sparse matrix storage formats.

## To run a serial single-precision sparse matrix-vector multiplication (SpMV) benchmark
    cd sequential/tests
    ./run -b <browser> -p single -t spmv <matrix_market_input_file_path>
where \<browser\> is *chrome* for Google Chrome and *firefox* for Mozilla Firefox
    
## Supported Sparse BLAS Level II Operations

| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| SpMV | Sparse Matrix-Vector Multiplication | Available |
| SpTS | Sparse Triangular  Solve | Available |
  
## Supported Element-Wise Operations

| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| ceil | ceiling function | Available |
| floor | floor function | Available |
| deg2rad | degrees to radians function | Available |
| rad2deg | radians to degrees function | Available |
| expm1 |  exp(x) - 1 | Available |
| log1p | log(1 + x) | Available |
| power | power function | Available |
| rint | round function | Available |
| trunc | truncate function | Available |
| sign | sign indication | Available |
| sin | Trigonometric sine | Available |
| tan | Trigonometric tangent | Available |
| sqrt | square-root function | Available |
| multiply | element-wise multiply by scalar | Available |

## Supported Format Conversion Operations
| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| coo_csr | COO to CSR | Available |
| csr_dia | CSR to DIA | Available |
| csr_ell | CSR to ELL | Available |

## Other Supported Operations
| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| transpose | returns transposed sparse matrix | Available |
| eliminate_zeros | removes zero entries from the matrix | Available |
