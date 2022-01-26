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
| multiply | element-wise multiply by scalar | Available|

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
| transpose | returns transposed sparse matrix | Available |
| diagonal | returns kth diagonal | Available |
| set_diag | set kth diagonal's elements | Available |
| sum | sum matrix elements over given axis | in progress |
| mean | arithmetic mean over given axis | in progress |
| max | maximum over given axis | in progress |
| min | minimum over given axis | in progress |
| resize | resize matrix in-place | in progress |
