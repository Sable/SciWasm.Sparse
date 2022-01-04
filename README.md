# SciWasm.Sparse

SciWasm.Sparse is a WebAssembly/JavaScript library module for highly efficient web-based sparse matrix computations.
This hand-tuned library supports both serial and parallel Sparse BLAS Level II operations, element-wise operations, 
and conversion routines for a number of sparse matrix storage formats.

## To run a serial sparse matrix-vector multiplication benchmark
    ./run.py -b <browser> -p single <matrix_market_input_file_path>
where \<browser\> is *chrome* for Google Chrome and *firefox* for Mozilla Firefox
    
## Supported Sparse BLAS Level II Operations

| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| SpMV | Sparse Matrix-Vector Multiplication | Available |
| SpTS | Sparse Triangular  Solve | Available |
  
## Supported Element-Wise Operations

| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| ceil | ceiling function | in progress |
| floor | floor function | in progress |
| deg2rad | degrees to radians function | in progress |
| rad2deg | radians to degrees function | in progress |
| expm1 |  exp(x) - 1 | in progress |
| log1p | log(1 + x) | in progress |
| power | power function | in progress |
| rint | round function | in progress |
| trunc | truncate function | in progress |
| sign | sign indication | in progress |
| sin | Trigonometric sine | in progress |
| tan | Trigonometric tangent | in progress |
| sqrt | square-root function | in progress |
| multiply | element-wise multiply by scalar, vector or matrix | in progress|

## Supported Format Conversion Operations
| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| coo_csr | COO to CSR | Available |
| coo_dia | COO to DIA | in progress |
| coo_ell | COO to ELL | in progress |
| csr_coo | CSR to COO | in progress |
| csr_dia | CSR to DIA | Available |
| csr_ell | CSR to ELL | Available |
| dia_coo | DIA to COO | in progress |
| dia_csr | DIA to CSR | in progress |
| dia_ell | DIA to ELL | in progress |
| ell_coo | ELL to COO | in progress |
| ell_csr | ELL to CSR | in progress |
| ell_dia | ELL to DIA | in progress |

## Other Supported Operations
| Operation | Description | Implementation Status |
| --------- | ----------- | --------------------- |
| transpose | returns transposed sparse matrix | in progress |
| diagonal | returns kth diagonal | in progress |
| set_diag | set kth diagonal's elements | in progress |
| sum | sum matrix elements over given axis | in progress |
| mean | arithmetic mean over given axis | in progress |
| max | maximum over given axis | in progress |
| min | minimum over given axis | in progress |
| resize | resize matrix in-place | in progress |
