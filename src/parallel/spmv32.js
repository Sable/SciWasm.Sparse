var anz = 0;
var N;
var inner_max = 1000000, outer_max = 30;
let memory = Module['wasmMemory'];
var pending_workers = num_workers; 
var workers;
var malloc_instance;
var sparse_instance;
var sparse_module;
var w_loaded;


function sswasm_workers_t(nworkers)
{
  this.nworkers;
  this.worker = [];
  this.loaded = 0;
  this.running = false;
}

function sswasm_MM_info()
{
  this.field = '';
  this.symmetry = '';
  this.nrows = 0;
  this.ncols = 0;
  this.nentries = 0;
  this.row;
  this.col;
  this.val;
  this.anz = 0;
}

function sswasm_COO_t(row_index, col_index, val_index, nnz)
{
  this.row;
  this.col;
  this.val;
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nnz = nnz;
  this.w_y_view = []; 
}

function sswasm_CSR_t(row_index, col_index, val_index, nnz_row_index, nrows, nnz){
  this.row;
  this.col;
  this.val;
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nnz_row_index = nnz_row_index;
  this.nrows = nrows;
  this.nnz = nnz;
  this.permutation_index;
  this.permutation;
  this.num_zero_rows = 0;
  this.num_one_rows = 0;
  this.num_two_rows = 0;
  this.num_three_rows = 0;
}

function sswasm_DIA_t(offset_index, data_index, ndiags, nrows, stride, nnz){
  this.offset;
  this.data;
  this.offset_index = offset_index;
  this.data_index = data_index;;
  this.ndiags = ndiags;
  this.nrows = nrows;
  this.stride = stride;
  this.nnz = nnz;
}

function sswasm_ELL_t(indices_index, data_index, ncols, nrows, nnz){
  this.indices;
  this.data;
  this.indices_index = indices_index;
  this.data_index = data_index;
  this.ncols = ncols;
  this.nrows = nrows;
  this.nnz = nnz;
}

function sswasm_x_t(x_index, x_nelem){
  this.x;
  this.x_index = x_index;
  this.x_nelem = x_nelem;
}

function sswasm_y_t(y_index, y_nelem){
  this.y;
  this.y_index = y_index;
  this.y_nelem = y_nelem;
}

function matlab_modulo(x, y) {
  var n = Math.floor(x/y);
  return x - n*y;
}

function fletcher_sum(A) {
  var sum1 = 0;
  var sum2 = 0;

  for (var i = 0; i < A.length; ++i) {
    sum1 = matlab_modulo((sum1 + A[i]),255);
    sum2 = matlab_modulo((sum2 + sum1),255);
  }
  return sum2 * 256 + sum1;
}

function fletcher_sum_y(y_view)
{
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  return parseInt(fletcher_sum(y));
}

function init_x(x_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  for(var i = 0; i < x_view.x_nelem; i++)
    x[i] = i;
}


function clear_w_y(A){
  for(var i = 0; i < num_workers; i++){
    var w_y = new Float32Array(memory.buffer, A.w_y_view[i].y_index, A.w_y_view[i].y_nelem);
    w_y.fill(0);
  }
}

function clear_y(y_view){
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  y.fill(0);
}

function pretty_print_COO(A_coo){
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var coo_val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 
  
  console.log("nnz : ", A_coo.nnz); 
  console.log("coo_row_index :", A_coo.row_index);
  console.log("coo_col_index :", A_coo.col_index);
  console.log("coo_val_index :", A_coo.val_index);
  //for(var i = 0; i < A_coo.nnz; i++)
  for(var i = 0; i < 10; i++)
    console.log(coo_row[i], coo_col[i], coo_val[i]);
}

function pretty_print_CSR(A_csr){
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 
  
  console.log("nnz : ", A_csr.nnz); 
  console.log("csr_row_index :", A_csr.row_index);
  console.log("csr_col_index :", A_csr.col_index);
  console.log("csr_val_index :", A_csr.val_index);
  for(var i = 0; i < A_csr.nrows; i++){
    for(var j = csr_row[i]; j < csr_row[i+1] ; j++)
      console.log(i, csr_col[j], csr_val[j]);
  }
}

function pretty_print_CSR_permutation(A_csr){
  var permutation = new Int32Array(memory.buffer, A_csr.permutation_index, A_csr.nrows); 
  //for(var i = 0; i < A_csr.nrows; i++){
  for(var i = 0; i < 20; i++){
      console.log(i, permutation[i]);
  }
}


function pretty_print_DIAII(A_dia){
  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float32Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);

  console.log("nnz : ", A_dia.nnz);
  console.log("dia_offset_index :", A_dia.offset_index);
  console.log("dia_data_index :", A_dia.data_index);
  for(var i = 0; i < A_dia.ndiags; i++){
    for(var j = 0; j < A_dia.nrows; j++){
      if (data[i * A_dia.nrows + j] != 0)
        console.log(j, offset[i] + j, data[i*A_dia.nrows + j], A_dia.data_index + 4 * (i * A_dia.nrows + j));
    }
  }
}

function pretty_print_DIA(A_dia){
  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float32Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);

  console.log("nnz : ", A_dia.nnz);
  console.log("dia_offset_index :", A_dia.offset_index);
  console.log("dia_data_index :", A_dia.data_index);
  for(var i = 0; i < A_dia.nrows; i++){
    for(var j = 0; j < A_dia.ndiags; j++){
      if (data[i * A_dia.ndiags + j] != 0)
        console.log(i, i + offset[j], data[i*A_dia.ndiags + j], A_dia.data_index + 4 * (i * A_dia.ndiags + j));
    }
  }
}

function pretty_print_ELL(A_ell){
  var indices = new Int32Array(memory.buffer, A_ell.indices_index, A_ell.ncols * A_ell.nrows);
  var data = new Float32Array(memory.buffer, A_ell.data_index, A_ell.ncols * A_ell.nrows); 

  console.log("nnz : ", A_ell.nnz);
  console.log("nrows : ", A_ell.nrows);
  console.log("ncols : ", A_ell.ncols);
  console.log("ell_indices_index :", A_ell.indices_index);
  console.log("ell_data_index :", A_ell.data_index);

  for(var i = 0; i < A_ell.nrows; i++){
    for(var j = 0; j < A_ell.ncols; j++){
      if (data[i * A_ell.ncols + j] != 0)
        console.log(i, indices[i * A_ell.ncols + j] , data[i * A_ell.ncols + j], A_ell.data_index + 4 * (i * A_ell.ncols + j));
    }
  }
}

function pretty_print_ELLII(A_ellII){
  var indices = new Int32Array(memory.buffer, A_ellII.indices_index, A_ellII.ncols * A_ellII.nrows);
  var data = new Float32Array(memory.buffer, A_ellII.data_index, A_ellII.ncols * A_ellII.nrows);

  console.log("nnz : ", A_ellII.nnz);
  console.log("nrows : ", A_ellII.nrows);
  console.log("ncols : ", A_ellII.ncols);
  console.log("ell_indices_index :", A_ellII.indices_index);
  console.log("ell_data_index :", A_ellII.data_index);

  for(var i = 0; i < A_ellII.ncols; i++){
    for(var j = 0; j < A_ellII.nrows; j++){
      if (data[i * A_ellII.nrows + j] > 0)
        console.log(j, indices[i * A_ellII.nrows + j] , data[i * A_ellII.nrows + j], A_ellII.data_index + 4 * (i * A_ellII.nrows + j));
    }
  }
}

function pretty_print_x(x_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  console.log("x_index :", x_view.x_index); 
  //for(var i = 0; i < x_view.x_nelem; i++)
  for(var i = 0; i < 10; i++)
    console.log(x[i]);
}


function pretty_print_y(y_view){
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  console.log("y_index :", y_view.y_index); 
  //for(var i = 0; i <y_view.y_nelem; i++)
  for(var i = 0; i <12; i++)
    console.log(y[i]);
}

function num_cols(A_csr)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var N = A_csr.nrows;
  var temp, max = 0;
  for(var i = 0; i < N ; i++){
    temp = csr_row[i+1] - csr_row[i];
    if (max < temp)
      max = temp;
  }
  return max;
}

// data array is stored column-wise 
function csr_ellII(A_csr, A_ellII)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var indices = new Int32Array(memory.buffer, A_ellII.indices_index, A_ellII.ncols * A_ellII.nrows);
  var data = new Float32Array(memory.buffer, A_ellII.data_index, A_ellII.ncols * A_ellII.nrows);
  indices.fill(0);
  data.fill(0);

  var nz = A_csr.nnz; 
  var N = A_csr.nrows;
  var nc = A_ellII.ncols;
 
  var i, j, k;
  for(i = 0; i < N; i++){
    k = 0;
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      data[k*N+i] = csr_val[j];
      indices[k*N+i] = csr_col[j];
      k++;
    }
  }
}


// data array is stored row-wise 
function csr_ell(A_csr, A_ell)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var indices = new Int32Array(memory.buffer, A_ell.indices_index, A_ell.ncols * A_ell.nrows);
  var data = new Float32Array(memory.buffer, A_ell.data_index, A_ell.ncols * A_ell.nrows);
  indices.fill(0);
  data.fill(0);

  var nz = A_csr.nnz; 
  var N = A_csr.nrows;
  var nc = A_ell.ncols;
 
  var i, j, k;
  for(i = 0; i < N; i++){
    k = 0;
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      data[i*nc+k] = csr_val[j];
      indices[i*nc+k] = csr_col[j];
      k++;
    }
  }
}

function num_diags(A_csr)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var N = A_csr.nrows;
  var ind = new Int32Array(2*N-1);
  var num_diag = 0;
  ind.fill(0);
  for(var i = 0; i < N ; i++){
    for(var j = csr_row[i]; j<csr_row[i+1]; j++){
      if(!ind[N+csr_col[j]-i-1]++)
        num_diag++;
    }
  }
  var diag_no = -(parseInt((2*N-1)/2));
  var min = Math.abs(diag_no);
  for(var i = 0; i < 2*N-1; i++){
    if(ind[i]){
      if(min > Math.abs(diag_no))
        min = Math.abs(diag_no); 
    }
    diag_no++; 
  }
  //stride = N - min;
  stride = N;
  return [num_diag,stride];
}


// data array is stored row-wise 
function csr_dia(A_csr, A_dia)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float32Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);
  data.fill(0);

  var nz = A_csr.nnz; 
  var N = A_csr.nrows;
  var stride = A_dia.stride;

  var ind = new Int32Array(2*N-1);
  var i, j;
  ind.fill(0);

  for(i = 0; i < N; i++){
    for(j = csr_row[i]; j < csr_row[i+1]; j++){ 
      ind[N+csr_col[j]-i-1]++;
    }
  }
  var diag_no = -(parseInt((2*N-1)/2));
  var index = 0;
  for(i = 0; i < 2*N-1; i++){
    if(ind[i])
      offset[index++] = diag_no;
    diag_no++; 
  }
  var c;
  
  for(i = 0; i < N; i++){
    for(j = csr_row[i]; j < csr_row[i+1]; j++){ 
      c = csr_col[j];  
      for(k = 0; k < offset.length; k++){
        if(c - i == offset[k]){
          data[i*offset.length+k] = csr_val[j];
          break;
        }
      }
    }
  }
}

// data array is stored column-wise 
function csr_diaII(A_csr, A_diaII)
{ 
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1);
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz);
  
  var offset = new Int32Array(memory.buffer, A_diaII.offset_index, A_diaII.ndiags);
  var data = new Float32Array(memory.buffer, A_diaII.data_index, A_diaII.ndiags * A_diaII.stride);
  data.fill(0);
  
  var nz = A_csr.nnz; 
  var N = A_csr.nrows;
  var stride = A_diaII.stride;
  
  var ind = new Int32Array(2*N-1);
  var i, j, move;
  ind.fill(0);
  
  for(i = 0; i < N; i++){ 
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      ind[N+csr_col[j]-i-1]++;
    }
  }
  var diag_no = -(parseInt((2*N-1)/2));
  var index = 0; 
  for(i = 0; i < 2*N-1; i++){
    if(ind[i])
      offset[index++] = diag_no;
    diag_no++;
  }
  var c;
  
  for(i = 0; i < N; i++){
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      c = csr_col[j];
      for(k = 0; k < offset.length; k++){
        move = 0;
        if(c - i == offset[k]){
          if(offset[k] < 0)
            move = N - stride; 
          data[k*stride+i-move] = csr_val[j];
          break;
        }
      }
    }
  }
}



function quick_sort_COO(A_coo, left, right)
{
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var coo_val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

  var i = left
  var j = right;
  var pivot = coo_row[parseInt((left + right) / 2)];
  var pivot_col = coo_col[parseInt((left + right) / 2)];

  /* partition */
  while(i <= j) {
    while((coo_row[i] < pivot) || (coo_row[i] == pivot && coo_col[i] < pivot_col))
      i++;
    while((coo_row[j] > pivot) || (coo_row[j] == pivot && coo_col[j] > pivot_col))
      j--;
    if(i <= j) {
      coo_row[j] = [coo_row[i], coo_row[i] = coo_row[j]][0];
      coo_col[j] = [coo_col[i], coo_col[i] = coo_col[j]][0];
      coo_val[j] = [coo_val[i], coo_val[i] = coo_val[j]][0];
      i++;
      j--;
    }
  }

  /* recursion */
  if(left < j)
    quick_sort_COO(A_coo, left, j);
  if (i < right)
    quick_sort_COO(A_coo, i, right);
}



function sort(start, end, array1, array2)
{ 
  var i, j, temp;
  for(i = 0; i < end-start-1; i++){
    for(j = start; j < end-i-1; j++){
      if(array1[j] > array1[j+1]){
        temp = array1[j];
        array1[j] = array1[j+1];
        array1[j+1] = temp;
        temp = array2[j];
        array2[j] = array2[j+1];
        array2[j+1] = temp;
      }
    }
  }
}

function coo_csr(A_coo, A_csr)
{
  var row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 
  csr_row.fill(0);
  csr_col.fill(0);
  csr_val.fill(0);
 
  var nz = A_csr.nnz; 
  var N = A_csr.nrows;

  var i;
  for(i = 0; i < nz; i++){
    csr_row[row[i]]++; 
  }

  var j = 0, j0 = 0;
  for(i = 0; i < N; i++){
    j0 = csr_row[i];
    csr_row[i] = j;
    j += j0;
  }

  for(i = 0; i < nz; i++){
    j = csr_row[row[i]];
    csr_col[j] = col[i];
    csr_val[j] = val[i];
    csr_row[row[i]]++;
  }

  for(i = N-1; i > 0; i--){
    csr_row[i] = csr_row[i-1]; 
  }
  csr_row[0] = 0;
  csr_row[N] = nz;
  for(i = 0; i < N; i++)
    sort(csr_row[i], csr_row[i+1], csr_col, csr_val); 
}

  
function sort_rows_by_nnz(A_csr)
{
  var N = A_csr.nrows;
  var nz = A_csr.nnz;
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz);
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz);

  var freq = new Int32Array(N+1);
  freq.fill(0);
  var starting_index = new Int32Array(N+1);
  var i = 0;


  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (N + 1));
  var csr_nnz_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * nz);
  var csr_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * nz);
  var A_csr_new = new sswasm_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, N, nz);
  A_csr_new.permutation_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var permutation = new Int32Array(memory.buffer, A_csr_new.permutation_index, N);
  var nnz_per_row = new Int32Array(memory.buffer, A_csr_new.nnz_row_index, N); 

  console.log("calculate nnz per row and frequency");
  for(i = 0; i < N; i++){
    nnz_per_row[i] = csr_row[i+1] - csr_row[i];
    freq[nnz_per_row[i]]++; 
  }

  console.log("calculate starting index");
  starting_index[0] = 0;
  for(i = 1; i <= N; i++){
    starting_index[i] = starting_index[i-1] + freq[i-1];
  }

  var csr_row_new = new Int32Array(memory.buffer, A_csr_new.row_index, A_csr_new.nrows + 1);
  var csr_col_new = new Int32Array(memory.buffer, A_csr_new.col_index, A_csr_new.nnz);
  var csr_val_new = new Float32Array(memory.buffer, A_csr_new.val_index, A_csr_new.nnz);
  csr_row_new.fill(0);
  csr_col_new.fill(0);
  csr_val_new.fill(0);
  A_csr_new.num_zero_rows = freq[0];
  A_csr_new.num_one_rows = freq[0] + freq[1];
  A_csr_new.num_two_rows = freq[0] + freq[1] + freq[2];
  A_csr_new.num_three_rows = freq[0] + freq[1] + freq[2] + freq[3];
 
  console.log("calculate permutation")	
  for(i = 0; i < N; i++){
    permutation[starting_index[nnz_per_row[i]]] = i;
    starting_index[nnz_per_row[i]]++;
  }
  //pretty_print_CSR_permutation(A_csr);
  
  console.log("calculate new CSR")	
  var j = 0, temp, k;
  csr_row_new[0] = 0;
  for(i = 0; i < N; i++){
   k = csr_row[permutation[i]];
   temp = nnz_per_row[permutation[i]]; 
   //console.log(i, temp);
   csr_row_new[i+1] = csr_row_new[i] + temp; 
   while(temp != 0){
     csr_col_new[j] = csr_col[k];  
     csr_val_new[j++] = csr_val[k++];  
     temp--;
   }
  }
  //pretty_print_CSR(A_csr_new);
  return A_csr_new;
}

function sort_y_rows_by_nnz(y_view, A_csr)
{
  var N = A_csr.nrows;
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  var permutation = new Int32Array(memory.buffer, A_csr.permutation_index, N);

  var y_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * N);
  var y_new = new Float32Array(memory.buffer, y_index, N);
 
  for(i = 0; i < N; i++){
    y_new[permutation[i]] = y[i];
  }

  y_view.y_index = y_index;
}

function find_next_row(nn, index, visited, nlines, alines, dissim, last_used, csr_row, csr_col, N)
{
  var i, j, min, max, next;
  if(visited[index] == 0){ // this node is a new neighbour
    // set the new neighbour vertex (row) as visited 
    visited[index] = 1;
    alines[nn].fill(0);
    dissim[nn].fill(-1);
    //console.log(index);
    // calulate the used cache lines vector
    for(j = csr_row[index]; j < csr_row[index+1]; j++){
      //console.log(index, csr_col[j], last_used[Math.floor(csr_col[j]/16)]);
      if(last_used[Math.floor(csr_col[j]/16)] != index){
        last_used[Math.floor(csr_col[j]/16)] = index;
      }       
    }

    // calculate same and different number of cache lines between the current vertex and all other rows
    for(i = 0; i < N; i++){
      if(visited[i] != 0)
        continue;
      j = csr_row[i];
      while(j < csr_row[i+1]){
        if(last_used[Math.floor(csr_col[j]/16)] == index){
          alines[nn][i]++;
        }
        j++;
        while(j < csr_row[i+1] && (Math.floor(csr_col[j-1]/16) == Math.floor(csr_col[j]/16))){ 
          j++;
        }
      }
      dissim[nn][i] = nlines[index] + nlines[i] - (2 * alines[nn][i]);
      //console.log(dissim[i]);
      //for(j = csr_row[i]; j < csr_row[i+1]; j++){
        //if(last_used2[Math.floor(csr_col[j]/16)] != i){
          //last_used2[Math.floor(csr_col[j]/16)] = i;
        //}
    }
  }
    
  // set min to N
  min = N;
  // set next to N
  next = N;
  //set max to 0
  max = 0;
  // calculate the next vertex (row)
  for(i = 0; i < N; i++){
    if(dissim[nn][i] >= 0 && visited[i] == 0 && min >= dissim[nn][i]){
      if(min == dissim[nn][i] && max >= alines[nn][i])
	continue;
      min = dissim[nn][i];
      next = i;
      max = alines[nn][i];
    }
  }
  return [next, min, max];
}


function reorder_NN(A_csr, w)
{
  // original CSR
  var N = A_csr.nrows;
  var nz = A_csr.nnz;
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1);
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz);
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz);

  // new CSR 	
  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (N + 1));
  var csr_nnz_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * nz);
  var csr_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * nz);
  var A_csr_new = new sswasm_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, N, nz);
  A_csr_new.permutation_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * N);
  var permutation = new Int32Array(memory.buffer, A_csr_new.permutation_index, N);
  var nnz_per_row = new Int32Array(memory.buffer, A_csr_new.nnz_row_index, N);
  var csr_row_new = new Int32Array(memory.buffer, A_csr_new.row_index, A_csr_new.nrows + 1);
  var csr_col_new = new Int32Array(memory.buffer, A_csr_new.col_index, A_csr_new.nnz);
  var csr_val_new = new Float32Array(memory.buffer, A_csr_new.val_index, A_csr_new.nnz);
  csr_row_new.fill(0);
  csr_col_new.fill(0);
  csr_val_new.fill(0);

  var index = 0, i, j, min, max, next, pos = 0, nnb = 0, count = 0;
  var values;
  var windexes = new Int32Array(w);
  var nlines = new Int32Array(N);
  nlines.fill(0);
  var visited = new Int32Array(N);
  visited.fill(0);
  var tot_num_lines = Math.floor(N/16)+1;
  console.log("total number of cache lines : ", tot_num_lines);
  var last_used = new Int32Array(tot_num_lines);
  last_used.fill(-1);
  var alines = new Array(w);
  var dissim = new Array(w);
  for(i = 0; i < w; i++){
    alines[i] = new Int32Array(N);
    dissim[i] = new Int32Array(N);
  }
  //var last_used2 = new Int32Array(tot_num_lines);
  //last_used2.fill(-1);

  // calculate nnz per row and set empty rows as visited
  console.log("calculate nnz per row and set empty rows as visited");
  for(i = 0; i < N; i++){
    permutation[i] = i;
    nnz_per_row[i] = csr_row[i+1] - csr_row[i];
    //console.log(nnz_per_row[i], permutation[i]);
    if(nnz_per_row[i] == 0)
      visited[i] = 2;  // set visited equal to 2 for empty rows
  }

  console.log("calculate the number of cache lines for all non-empty rows");
  // calculate the number of cache lines for all non-empty rows
  for(i = 0; i < N; i++){
    if(visited[i] != 0)
      continue;
    //last_used.fill(-1);
    j = csr_row[i];
    while(j < csr_row[i+1]){
      nlines[i]++;
      j++;
      //if(last_used[Math.floor(csr_col[j]/16)] == -1){
        //last_used[Math.floor(csr_col[j]/16)] = i;
	
      // checks if next column index belongs to the same cache line, and if the next column belongs to current row
      while(j < csr_row[i+1] && (Math.floor(csr_col[j-1]/16) == Math.floor(csr_col[j]/16))){ 
        j++;
      }
    }
    //console.log(nlines[i]);
  }

  console.log("select the first vertex");
  // select the first vertex
  while(visited[index] != 0){
    index++;
  }	  

  console.log("loop start");
  while(index != N){
    // assign the new neighbour in the set of w nearest neigbours
    windexes[count++] = index;
    if(nnb < w)
      nnb++;
    if(count == w)
      count = 0;
    // set the permutation and the pos
    permutation[pos++] = index;
    // set min to N
    min = N;
    // set next to N
    next = N;
    //set max to 0
    max = 0;
    //console.log(index, count, nnb);
    for(i = 0; i < nnb; i++){
      // reset the new neighbour info to visted row info for all other neighbours (so that this node can't be chosen again) 
      dissim[i][index] = -1;
      alines[i][index] = 0;
      values = find_next_row(i, windexes[i], visited, nlines, alines, dissim, last_used, csr_row, csr_col, N);
      if(min >= values[1]){
	if(min == values[1] && max >= values[2])
	  continue;
	next = values[0];
        min = values[1];
	max = values[2];
      }
    }
    index = next;
  }
  console.log("loop end");

  console.log("set empty rows on the permutation vector");
  // set empty rows on the permutation vector
  for(i = 0; i < N; i++){
    if(visited[i] == 2){
      permutation[pos++] = i;
    }
  }

  pretty_print_CSR_permutation(A_csr_new);


  // calculate reordered CSR
  console.log("calculate new CSR")
  var temp, k;
  j = 0;
  csr_row_new[0] = 0;
  for(i = 0; i < N; i++){
   k = csr_row[permutation[i]];
   temp = nnz_per_row[permutation[i]];
   //console.log(i, temp);
   csr_row_new[i+1] = csr_row_new[i] + temp;
   while(temp != 0){
     csr_col_new[j] = csr_col[k];
     csr_val_new[j++] = csr_val[k++];
     temp--;
   }
  }
  //pretty_print_CSR(A_csr_new);
  return A_csr_new;
}

function get_inner_max()
{
  if(anz > 1000000) inner_max = 1;
  else if (anz > 100000) inner_max = 500;
  else if (anz > 50000) inner_max = 1000;
  else if(anz > 20000) inner_max = 5000;
  else if(anz > 5000) inner_max = 10000;
  else if(anz > 500) inner_max = 100000;
  inner_max *= 5;
}

async function sswasm_init()
{
  var obj = await WebAssembly.instantiateStreaming(fetch('matmachjs.wasm'), Module);
  malloc_instance = obj.instance;
  obj = await WebAssembly.instantiateStreaming(fetch('spmv_opt_32.wasm'), { js: { mem: memory }, 
    console: { log: function(arg) {
      console.log(arg);}} 
  });
  sparse_instance = obj.instance;
  sparse_module = obj.module;
  var workers_promise = sswasm_init_workers();
  workers = await workers_promise; 
  console.log("workers loaded");
}

function sswasm_spmv_coo(A_coo, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    if(typeof A_coo === "undefined"){
      console.log("matrix is undefined");
      return resolve(-1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return resolve(-1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return resolve(-1);
    }
    var nnz_per_worker = Math.floor(anz/num_workers);
    var rem = anz - nnz_per_worker * num_workers;
    function runCOO(){
      pending_workers = num_workers;
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker + rem, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, A_coo.w_y_view[i].y_index, 1]);
        else
          workers.worker[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, A_coo.w_y_view[i].y_index, 1]);
        workers.worker[i].onmessage = storeCOO;
      }
    }
    function storeCOO(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        for(var i = 0; i < num_workers; i++)
          sparse_instance.exports.sum(y_view.y_index, A_coo.w_y_view[i].y_index, N);
        return resolve(0);
      }
    }
    runCOO();
  });
}


function static_nnz(A_csr, num_workers, row_start, row_end, one_row, two_row, three_row, four_row)
{
  var N = A_csr.nrows;
  var nz = A_csr.nnz;
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1);

  var nnz_per_row = new Int32Array(memory.buffer, A_csr.nnz_row_index, N); 
  // Calculate number of non-zeros in each row
  for(i = 0; i < N; i++){
    nnz_per_row[i] = csr_row[i+1] - csr_row[i];
  }

  var rem_nnz = nz;
  var rem_nw = num_workers;
  var ideal_nnz_worker;
  var index = 0, sum = 0, i, j;

  var num_zero_rows =  A_csr.num_zero_rows;
  var num_one_rows =  A_csr.num_one_rows;
  var num_two_rows =  A_csr.num_two_rows;
  var num_three_rows =  A_csr.num_three_rows;
  row_start[0] += num_zero_rows;

  // For each worker
  for(i = 0; i < num_workers; i++){
    one_row[i] = num_zero_rows;
    two_row[i] = num_one_rows;
    three_row[i] = num_two_rows;
    four_row[i] = num_three_rows;

    // If all the rows have been assigned, and some workers are left
    if(index == N){
      row_start[i] = row_end[i] = N;
      one_row[i] = row_start[i];
      two_row[i] = row_start[i];
      three_row[i] = row_start[i];
      four_row[i] = row_start[i];
      continue;
    }
    ideal_nnz_worker = rem_nnz/rem_nw;
    // Assign the row_ptr start
    row_start[i] += index;

    if(nnz_per_row[row_start[i]] == 1){
      one_row[i] = row_start[i];
    }
    else if(nnz_per_row[row_start[i]] == 2){
      one_row[i] = row_start[i];
      two_row[i] = row_start[i];
    }
    else if(nnz_per_row[row_start[i]] == 3){
      one_row[i] = row_start[i];
      two_row[i] = row_start[i];
      three_row[i] = row_start[i];
    }
    else{
      one_row[i] = row_start[i];
      two_row[i] = row_start[i];
      three_row[i] = row_start[i];
      four_row[i] = row_start[i];
    }

    sum = 0;
    for(j = index; j < N; j++){
      if(sum < ideal_nnz_worker){
        sum += nnz_per_row[j];
        index++;
      }
      else{
        // Assign the row_ptr end
        row_end[i] = index;

	if(nnz_per_row[row_end[i]] == 1){
	  two_row[i] = row_end[i];
	  three_row[i] = row_end[i];
	  four_row[i] = row_end[i];
	}
	else if(nnz_per_row[row_end[i]] == 2){
	  three_row[i] = row_end[i];
	  four_row[i] = row_end[i];
	}
	else if(nnz_per_row[row_end[i]] == 3){
	  four_row[i] = row_end[i];
	}
        break;
      }
    }
    // Update the remaining work
    rem_nnz -= sum;
    rem_nw--;
  }
  // Add remaining nnz if any to the last worker
  row_end[i-1] = N;
  for(i = 0; i < num_workers; i++){
    console.log(row_start[i], row_end[i], one_row[i], two_row[i], three_row[i], four_row[i]);
  }	  
}

function read_MM_header(file, mm_info)
{
  /* read the first line for arithmetic field 
  e.g. real, integer, pattern etc.
  and symmetry structure e.g. general, 
  symmetric etc. */  
  var first = file[0].split(" ");
  mm_info.field = first[3];
  mm_info.symmetry = first[4];

  // skip over the comments
  var n = 0;
  while(file[n][0] == "%")
    n++;

  // read the entries info
  var info = file[n++].split(" ");
  mm_info.nrows = Number(info[0]);
  mm_info.ncols = Number(info[1]);
  mm_info.nentries = Number(info[2]);
  console.log(mm_info.nrows, mm_info.ncols, mm_info.nentries);
  return n;
}


function calculate_actual_nnz(file, index, start, mm_info)
{
  for(var j = start; index < file.length - 1; index++){
    var coord = file[index].split(" ");
    mm_info.row[j] = Number(coord[0]);
    mm_info.col[j] = Number(coord[1]);
    if(mm_info.symmetry == "symmetric"){
      if(mm_info.field != "pattern"){
        mm_info.val[j] = Number(coord[2]);
         // exclude explicit zero entries
        if(mm_info.val[j] < 0 || mm_info.val[j] > 0){
          // only one non-zero for each diagonal entry
          if(mm_info.row[j] == mm_info.col[j])
            mm_info.anz++; 
          // two non-zeros for each non-diagonal entry
          else
            mm_info.anz = mm_info.anz + 2;
        }
      }
      else{
        if(mm_info.row[j] == mm_info.col[j])
          mm_info.anz++; 
        else
          mm_info.anz = mm_info.anz + 2;
      } 
    }
    else{
      if(mm_info.field != "pattern"){
        mm_info.val[j] = Number(coord[2]);
         // exclude explicit zero entries
        if(mm_info.val[j] < 0 || mm_info.val[j] > 0)
          mm_info.anz++;
      }
    }
    j++;
  }
  return j;
}

function read_matrix_MM_files(files, num, mm_info, callback)
{ 
  var start = 0;
  mm_info.anz = 0;
  for(var i = 0; i < num; i++){
    var file = files[i];
    var index = 0;
    if(i == 0){
      index = read_MM_header(file, mm_info);
      if(mm_info.nentries > Math.pow(2,27)){
        console.log("entries : cannot allocate this much");
        callback();
      }
      mm_info.row = row = new Int32Array(mm_info.nentries);
      mm_info.col = col = new Int32Array(mm_info.nentries);
      if(mm_info.field != "pattern")
        mm_info.val = val = new Float64Array(mm_info.nentries);
    }
    start = calculate_actual_nnz(file, index, start, mm_info)
  }
  if(mm_info.anz == 0)
    anz = mm_info.nentries;
  else
    anz = mm_info.anz;
  console.log(anz);
  if(anz > Math.pow(2,28)){
    console.log("anz : cannot allocate this much");
    callback();
  }
}

function create_COO_from_MM(mm_info, A_coo)
{
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var coo_val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

  var row = mm_info.row;
  var col = mm_info.col;
  var val = mm_info.val;

  if(mm_info.symmetry == "symmetric"){
    if(mm_info.field == "pattern"){
      for(var i = 0, n = 0; n < mm_info.nentries; n++) {
        coo_row[i] = Number(row[n] - 1);
        coo_col[i] = Number(col[n] - 1);
        coo_val[i] = 1.0;
        if(row[n] == col[n])
          i++;
        else{
          coo_row[i+1] = Number(col[n] - 1);
          coo_col[i+1] = Number(row[n] - 1);
          coo_val[i+1] = 1.0;
          i = i + 2;
        }
      } 
    }
    else{
      for(var i = 0, n = 0; n < mm_info.nentries; n++) {
        if(val[n] < 0 || val[n] > 0){
          coo_row[i] = Number(row[n] - 1);
          coo_col[i] = Number(col[n] - 1);
          coo_val[i] = Number(val[n]);
          if(row[n] == col[n])
            i++;
          else{
            coo_row[i+1] = Number(col[n] - 1);
            coo_col[i+1] = Number(row[n] - 1);
            coo_val[i+1] = Number(val[n]);
            i = i + 2;
          }
        }
      }
    }
  }
  else{
    if(mm_info.field == "pattern"){
      for(var i = 0, n = 0; n < mm_info.nentries; n++, i++) {
        coo_row[i] = Number(row[n] - 1);
        coo_col[i] = Number(col[n] - 1);
        coo_val[i] = 1.0;
      }
    }
    else{
      for(var i = 0, n = 0; n < mm_info.nentries; n++) {
        if(val[n] < 0 || val[n] > 0){
          coo_row[i] = Number(row[n] - 1);
          coo_col[i] = Number(col[n] - 1);
          coo_val[i] = Number(val[n]);
          i++;
        }
      }
    }
  }
  quick_sort_COO(A_coo, 0, anz-1);      
}

function allocate_COO(mm_info)
{
  // COO memory allocation
  var coo_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * anz);
  var coo_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * anz);
  var coo_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * anz);
  var A_coo = new sswasm_COO_t(coo_row_index, coo_col_index, coo_val_index, anz); 
  for(var i = 0; i < num_workers; i++){
    var w_y_view = allocate_y(mm_info);
    A_coo.w_y_view.push(w_y_view);
  }
  return A_coo;
}

function allocate_CSR(mm_info)
{
  // CSR memory allocation
  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (mm_info.nrows + 1));
  var csr_nnz_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * mm_info.nrows);
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * anz);
  var csr_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * anz);
  var A_csr = new sswasm_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, mm_info.nrows, anz);
  return A_csr;
}


function allocate_DIA(mm_info, ndiags, stride)
{
  // DIA memory allocation
  var offset_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ndiags);
  var dia_data_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * ndiags * stride);
  var A_dia = new sswasm_DIA_t(offset_index, dia_data_index, ndiags, mm_info.nrows, stride, anz);
  return A_dia;
}

function allocate_ELL(mm_info, ncols)
{
  // ELL memory allocation
  var indices_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ncols * mm_info.nrows);
  var ell_data_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * ncols * mm_info.nrows);
  var A_ell = new sswasm_ELL_t(indices_index, ell_data_index, ncols, mm_info.nrows, anz);
  return A_ell;
}

function allocate_x(mm_info)
{
  var x_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * mm_info.ncols);
  var x_view = new sswasm_x_t(x_index, mm_info.ncols);
  return x_view;
}

function allocate_y(mm_info)
{
  var y_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * mm_info.nrows);
  var y_view = new sswasm_y_t(y_index, mm_info.nrows);
  return y_view;
}

/* Note: Since an ArrayBuffer’s byteLength is immutable, 
after a successful Memory.prototype.grow() operation the 
buffer getter will return a new ArrayBuffer object 
(with the new byteLength) and any previous ArrayBuffer 
objects become “detached”, or disconnected from the 
underlying memory they previously pointed to.*/ 
function allocate_memory_test(mm_info)
{
  /*const bytesPerPage = 64 * 1024;
  var max_pages = 32767;
  let buffer = memory.buffer;
  console.log(buffer instanceof SharedArrayBuffer);*/
  
  var A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo); 
  console.log("COO allocated");

  var A_csr = allocate_CSR(mm_info);
  //convert COO to CSR
  coo_csr(A_coo, A_csr);
  console.log("CSR allocated");

  //get DIA info
  var result = num_diags(A_csr);
  var nd = result[0];
  var stride = result[1];
  //get ELL info
  var nc = num_cols(A_csr);
  var A_dia, A_diaII, A_ell, A_ellII;

  if(nd*stride < Math.pow(2,27) && (((stride * nd)/anz) <= 12)){ 
    A_dia = allocate_DIA(mm_info, nd, stride);
    A_diaII = allocate_DIA(mm_info, nd, stride);
    //convert CSR to DIA
    csr_dia(A_csr, A_dia);
    //convert CSR to DIAII
    csr_diaII(A_csr, A_diaII);
  }

  if((nc*mm_info.nrows < Math.pow(2,27)) && (((mm_info.nrows * nc)/anz) <= 12)){
    A_ell = allocate_ELL(mm_info, nc);
    A_ellII = allocate_ELL(mm_info, nc);
    //convert CSR to ELL
    csr_ell(A_csr, A_ell);
    //convert CSR to ELLII
    csr_ellII(A_csr, A_ellII);
  } 

  var x_view = allocate_x(mm_info);
  init_x(x_view);

  var y_view = allocate_y(mm_info);
  clear_y(y_view);

  return [A_coo, A_csr, A_dia, A_ell, A_diaII, A_ellII, x_view, y_view];
}

function free_memory_coo(A_coo)
{
  if(typeof A_coo !== 'undefined'){ 
    malloc_instance.exports._free(A_coo.row_index);
    malloc_instance.exports._free(A_coo.col_index);
    malloc_instance.exports._free(A_coo.col_index);
    for(var i = 0; i < num_workers; i++){
      free_memory_y(A_coo.w_y_view[i]);
    }
  }
}

function free_memory_csr(A_csr)
{
  if(typeof A_csr !== 'undefined'){ 
    malloc_instance.exports._free(A_csr.row_index);
    malloc_instance.exports._free(A_csr.col_index);
    malloc_instance.exports._free(A_csr.col_index);
  }
}


function free_memory_dia(A_dia) 
{
  if(typeof A_dia !== 'undefined'){ 
    malloc_instance.exports._free(A_dia.offset_index);
    malloc_instance.exports._free(A_dia.data_index);
  }
}

function free_memory_ell(A_ell)
{
  if(typeof A_ell !== 'undefined'){
    malloc_instance.exports._free(A_ell.indices_index);
    malloc_instance.exports._free(A_ell.data_index);
  }
}

function free_memory_x(x_view)
{
  if(typeof x_view !== 'undefined')
    malloc_instance.exports._free(x_view.x_index);
}

function free_memory_y(y_view)
{
  if(typeof y_view !== 'undefined')
    malloc_instance.exports._free(y_view.y_index);
}

function free_memory_test(A_coo, A_csr, A_dia, A_ell, A_diaII, A_ellII, x_view, y_view)
{
  if(typeof A_coo !== 'undefined'){ 
    malloc_instance.exports._free(A_coo.row_index);
    malloc_instance.exports._free(A_coo.col_index);
    malloc_instance.exports._free(A_coo.col_index);
  }

  if(typeof A_csr !== 'undefined'){ 
    malloc_instance.exports._free(A_csr.row_index);
    malloc_instance.exports._free(A_csr.col_index);
    malloc_instance.exports._free(A_csr.col_index);
  }

  if(typeof A_dia !== 'undefined'){ 
    malloc_instance.exports._free(A_dia.offset_index);
    malloc_instance.exports._free(A_dia.data_index);
  }

  if(typeof A_ell !== 'undefined'){ 
    malloc_instance.exports._free(A_ell.indices_index);
    malloc_instance.exports._free(A_ell.data_index);
  }

  if(typeof A_diaII !== 'undefined'){ 
    malloc_instance.exports._free(A_diaII.offset_index);
    malloc_instance.exports._free(A_diaII.data_index);
  }

  if(typeof A_ellII !== 'undefined'){ 
    malloc_instance.exports._free(A_ellII.indices_index);
    malloc_instance.exports._free(A_ellII.data_index);
  }

  if(typeof x_view !== 'undefined')
    malloc_instance.exports._free(x_view.x_index);

  if(typeof y_view !== 'undefined')
    malloc_instance.exports._free(y_view.y_index);
}

function sswasm_init_workers()
{
  return new Promise(function(resolve){
  var w = new sswasm_workers_t(num_workers);
  pending_workers = num_workers;
  for(var i = 0; i < num_workers; i++){
    w.worker[i] = new Worker('worker32.js'); 
    w.worker[i].onmessage = loaded;
    w.worker[i].postMessage([0, i, sparse_module, memory]);
  }
  function loaded(event)
  {
    pending_workers -= 1;
    if(pending_workers <= 0){
      console.log("all workers loaded");
      return resolve(w);
    }
  }
  });
}


/* 
   Function to read the file
   Input : File object (https://developer.mozilla.org/en-US/docs/Web/API/File)
   Return : String containing the input file data 
*/
function sswasm_load_matrix_file(file)
{
  return new Promise(function(resolve) {
    // 32MB blob size
    var limit = 32 * 1024 * 1024;
    var size = file.size;
    console.log(size);
    var num = Math.ceil(size/limit);
    console.log("num of blocks : ", num);
    var file_arr = [];

    function read_file_block(file, i){
      if(i >= num){
        var file_data = file_arr.join("").split("\n");
        return resolve(file_data);
      }
      var start = i * limit;
      var end = ((i + 1)* limit) > file.size ? file.size : (i+1) * limit;
      console.log(start, end);
      var reader = new FileReader();
      reader.onloadend = function(evt) {
        if (evt.target.readyState == FileReader.DONE) { 
          file_arr.push(evt.target.result);
          read_file_block(file, i + 1);
        }
      };
      var blob = file.slice(start, end);
      reader.readAsText(blob);
    }

    read_file_block(file, 0);
  });
}



var load_file = function(){
  return new Promise(function(resolve, reject) {
    var files = new Array(num);
    var load_files = function(fileno, files, num){
      var request = new XMLHttpRequest();
      var myname = filename + (Math.floor(fileno/10)).toString() + (fileno%10).toString() + '.mtx'
      console.log(myname);
      request.onreadystatechange = function() {
        console.log("state change " + myname, request.readyState, request.status);
        if(request.readyState == 4 && request.status == 200){
          try{
            files[fileno] = request.responseText.split("\n");
            fileno++;
            if(fileno < num)
              load_files(fileno, files, num);
            else{
              console.log("resolved");
              return resolve(files);
            }
          }
          catch(e){
            console.log('Error : ', e);
            reject(new Error(e));
          }
        }  
      }
      request.open('GET', myname, true);
      request.send();
      console.log(myname + " request sent");
    }
    load_files(0, files, num);
  });
}

