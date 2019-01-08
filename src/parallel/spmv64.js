var coo_mflops = -1, csr_mflops = -1, dia_mflops = -1, ell_mflops = -1, diaII_mflops = -1;
var coo_sum=-1, csr_sum=-1, dia_sum=-1, ell_sum=-1, diaII_sum = -1;
var coo_sd=-1, csr_sd=-1, dia_sd=-1, ell_sd=-1, diaII_sd = -1;
var anz = 0;
var coo_flops = [], csr_flops = [], dia_flops = [], ell_flops = [], diaII_flops = [];
var N;
var variance;
var inner_max = 100000, outer_max = 30;
let memory = Module['wasmMemory'];
var pending_workers = num_workers; 
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
  this.w_y_view = []; 
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
}

function sswasm_CSR_t(row_index, col_index, val_index, nrows, nnz){
  this.row;
  this.col;
  this.val;
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nrows = nrows;
  this.nnz = nnz;
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
  var y = new Float64Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  return parseInt(fletcher_sum(y));
}

function init_x(x_view){
  var x = new Float64Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  for(var i = 0; i < x_view.x_nelem; i++)
    x[i] = i;
}


function clear_w_y(workers){
  for(var i = 0; i < num_workers; i++){
    var w_y = new Float64Array(memory.buffer, workers.w_y_view[i].y_index, workers.w_y_view[i].y_nelem);
    w_y.fill(0);
  }
}

function clear_y(y_view){
  var y = new Float64Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  y.fill(0);
}

function pretty_print_COO(A_coo){
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var coo_val = new Float64Array(memory.buffer, A_coo.val_index, A_coo.nnz); 
  
  console.log("nnz : ", A_coo.nnz); 
  console.log("coo_row_index :", A_coo.row_index);
  console.log("coo_col_index :", A_coo.col_index);
  console.log("coo_val_index :", A_coo.val_index);
  for(var i = 0; i < A_coo.nnz; i++)
    console.log(coo_row[i], coo_col[i], coo_val[i]);
}

function pretty_print_CSR(A_csr){
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float64Array(memory.buffer, A_csr.val_index, A_csr.nnz); 
  
  console.log("nnz : ", A_csr.nnz); 
  console.log("csr_row_index :", A_csr.row_index);
  console.log("csr_col_index :", A_csr.col_index);
  console.log("csr_val_index :", A_csr.val_index);
  for(var i = 0; i < A_csr.nrows; i++){
    for(var j = csr_row[i]; j < csr_row[i+1] ; j++)
      console.log(i, csr_col[j], csr_val[j]);
  }
}


function pretty_print_DIA(A_dia){
  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float64Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);

  console.log("nnz : ", A_dia.nnz);
  console.log("dia_offset_index :", A_dia.offset_index);
  console.log("dia_data_index :", A_dia.data_index);
  for(var i = 0; i < A_dia.ndiags; i++){
    for(var j = 0; j < A_dia.nrows; j++){
      if (data[j * A_dia.ndiags + i] != 0)
        console.log(i, offset[j] + i, data[j*A_dia.nrows + i], A_dia.data_index + 8 * (j * A_dia.nrows + i));
    }
  }
}

function pretty_print_DIAII(A_diaII){
  var offset = new Int32Array(memory.buffer, A_diaII.offset_index, A_diaII.ndiags);
  var data = new Float64Array(memory.buffer, A_diaII.data_index, A_diaII.ndiags * A_diaII.stride);

  console.log("nnz : ", A_diaII.nnz);
  console.log("dia_offset_index :", A_diaII.offset_index);
  console.log("dia_data_index :", A_diaII.data_index);
  for(var i = 0; i < A_diaII.ndiags; i++){
    for(var j = 0; j < A_diaII.nrows; j++){
      if (data[i * A_diaII.nrows + j] != 0)
        console.log(j, offset[i] + j, data[i*A_diaII.nrows + j], A_diaII.data_index + 8 * (i * A_diaII.nrows + j));
    }
  }
}

function pretty_print_ELL(A_ell){
  var indices = new Int32Array(memory.buffer, A_ell.indices_index, A_ell.ncols * A_ell.nrows);
  var data = new Float64Array(memory.buffer, A_ell.data_index, A_ell.ncols * A_ell.nrows); 

  console.log("nnz : ", A_ell.nnz);
  console.log("ell_indices_index :", A_ell.indices_index);
  console.log("ell_data_index :", A_ell.data_index);

  for(var j = 0; j < A_ell.ncols; j++){
    for(var i = 0; i < A_ell.nrows; i++){
      if (data[j * A_ell.nrows + i] != 0)
        console.log(i, indices[j * A_ell.nrows + i] , data[j * A_ell.nrows + i], A_ell.data_index + 8 * (j * A_ell.nrows + i));
    }
  }
}

function pretty_print_x(x_view){
  var x = new Float64Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  console.log("x_index :", x_view.x_index); 
  for(var i = 0; i < x_view.x_nelem; i++)
    console.log(x[i]);
}


function pretty_print_y(y_view){
  var y = new Float64Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  console.log("y_index :", y_view.y_index); 
  for(var i = 0; i <y_view.y_nelem; i++)
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

// data array is stored row-wise 
function csr_ell(A_csr, A_ell)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float64Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var indices = new Int32Array(memory.buffer, A_ell.indices_index, A_ell.ncols * A_ell.nrows);
  var data = new Float64Array(memory.buffer, A_ell.data_index, A_ell.ncols * A_ell.nrows);

  var nz = A_csr.nnz; 
  var N = A_csr.nrows;
  var nc = A_ell.ncols;
 
   var i, j, k, temp, max = 0;
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
  var csr_val = new Float64Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float64Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);

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
  var csr_val = new Float64Array(memory.buffer, A_csr.val_index, A_csr.nnz);
  
  var offset = new Int32Array(memory.buffer, A_diaII.offset_index, A_diaII.ndiags);
  var data = new Float64Array(memory.buffer, A_diaII.data_index, A_diaII.ndiags * A_diaII.stride);
  
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
  var coo_val = new Float64Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

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
  var val = new Float64Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.nrows + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float64Array(memory.buffer, A_csr.val_index, A_csr.nnz); 
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

  

function get_inner_max()
{
  if(anz > 1000000) inner_max = 1;
  else if (anz > 100000) inner_max = 10;
  else if (anz > 50000) inner_max = 50;
  else if(anz > 10000) inner_max = 100;
  else if(anz > 2000) inner_max = 1000;
  else if(anz > 100) inner_max = 10000;
}

async function sswasm_init()
{
  var obj = await WebAssembly.instantiateStreaming(fetch('matmachjs.wasm'), Module);
  malloc_instance = obj.instance;
  obj = await WebAssembly.instantiateStreaming(fetch('spmv_64.wasm'), { js: { mem: memory }, 
    console: { log: function(arg) {
      console.log(arg);}} 
  });
  sparse_instance = obj.instance;
  sparse_module = obj.module;
}

function sswasm_spmv_coo(A_coo, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    if(typeof A_coo === "undefined"){
      console.log("matrix is undefined");
      reject(1);
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      reject(1);
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      reject(1);
    }
    var nnz_per_worker = Math.floor(anz/num_workers);
    var rem = anz - nnz_per_worker * num_workers;
    function runCOO(){
      pending_workers = num_workers;
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker + rem, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, workers.w_y_view[i].y_index, 1]);
        else
          workers.worker[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, workers.w_y_view[i].y_index, 1]);
        workers.worker[i].onmessage = storeCOO;
      }
    }
    function storeCOO(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        for(var i = 0; i < num_workers; i++)
          sparse_instance.exports.sum(y_view.y_index, workers.w_y_view[i].y_index, N);
        resolve(0);
      }
    }
    runCOO();
  });
}

function coo_test(A_coo, x_view, y_view, workers)
{
  return new Promise(function(resolve){
  console.log("COO");
  console.log(inner_max);
  if(typeof A_coo === "undefined"){
    console.log("matrix is undefined");
    reject(1);
  }
  if(typeof x_view === "undefined"){
    console.log("vector x is undefined");
    reject(1);
  }
  if(typeof y_view === "undefined"){
    console.log("vector y is undefined");
    reject(1);
  }
  var nnz_per_worker = Math.floor(anz/num_workers);
  var rem = anz - nnz_per_worker * num_workers;
  var t1, t2, tt = 0.0;
  var t = 0;
  function runCOO(){
    pending_workers = num_workers;
    clear_y(y_view);
    clear_w_y(workers);
    t1 = Date.now();
    for(var i = 0; i < num_workers; i++){
      if(i == num_workers - 1)
        workers.worker[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker + rem, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, workers.w_y_view[i].y_index, inner_max]);
      else
        workers.worker[i].postMessage([1, i, i * nnz_per_worker, (i+1) * nnz_per_worker, A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, workers.w_y_view[i].y_index, inner_max]);
      workers.worker[i].onmessage = storeCOO;
    }
  }

  function storeCOO(event){
    pending_workers -= 1;
    if(pending_workers <= 0){
      for(var i = 0; i < num_workers; i++)
        sparse_instance.exports.sum(y_view.y_index, workers.w_y_view[i].y_index, N);
      t2 = Date.now();
      if(t >= 10){
        coo_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
        tt += t2 - t1;
      }
      t++;
      if(t < (outer_max + 10))
        runCOO();
      else{
        tt = tt/1000;
	coo_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
	variance = 0;
	for(var i = 0; i < outer_max; i++)
	  variance += (coo_mflops - coo_flops[i]) * (coo_mflops - coo_flops[i]);
	variance /= outer_max;
	coo_sd = Math.sqrt(variance);
        coo_sum = fletcher_sum_y(y_view);
        console.log('coo sum is ', coo_sum);
        console.log('coo mflops is ', coo_mflops);
        console.log("Returned to main thread");
        resolve(0);
      }
    }
  }
  runCOO();
  });
}

function csr_test(A_csr, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    console.log("CSR");
    if(typeof A_csr === "undefined"){
      console.log("matrix is undefined");
      return;
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return;
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return;
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runCSR(){
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage([2, i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage([2, i, i * N_per_worker, (i+1) * N_per_worker, A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeCSR;
      }
    }
   
    function storeCSR(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          csr_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10))
          runCSR();
        else{
          tt = tt/1000;
          csr_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
          variance /= outer_max;
          csr_sd = Math.sqrt(variance);
          csr_sum = fletcher_sum_y(y_view);
          console.log('csr sum is ', csr_sum);
          console.log('csr mflops is ', csr_mflops);
          console.log("Returned to main thread");
          resolve(0);
        }
      }
    }
    runCSR();
  });
}

function dia_test(A_dia, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    console.log("DIA");
    if(typeof A_dia === "undefined"){
      console.log("matrix is undefined");
      return;
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return;
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return;
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runDIA()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage([3, i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage([3, i, i * N_per_worker, (i+1) * N_per_worker, A_dia.offset_index, A_dia.data_index, A_dia.ndiags, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeDIA;
      }
    }

    function storeDIA(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          dia_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10))
          runDIA();
        else{
          tt = tt/1000;
          dia_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (dia_mflops - dia_flops[i]) * (dia_mflops - dia_flops[i]);
          variance /= outer_max;
          dia_sd = Math.sqrt(variance);
          dia_sum = fletcher_sum_y(y_view);
          console.log('dia sum is ', dia_sum);
          console.log('dia mflops is ', dia_mflops);
          console.log("Returned to main thread");
          resolve(0);
        }
      }
    }
    runDIA();
  });
}

function diaII_test(A_diaII, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    console.log("DIA II");
    if(typeof A_diaII === "undefined"){
      console.log("matrix is undefined");
      return;
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return;
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return;
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runDIAII()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      clear_w_y(workers);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage([5, i, i * N_per_worker, (i+1) * N_per_worker - 1 + rem_N, A_diaII.offset_index, A_diaII.data_index, A_diaII.ndiags, N, A_diaII.stride, x_view.x_index, workers.w_y_view[i].y_index, inner_max]);
        else
          workers.worker[i].postMessage([5, i, i * N_per_worker, (i+1) * N_per_worker - 1, A_diaII.offset_index, A_diaII.data_index, A_diaII.ndiags, N, A_diaII.stride, x_view.x_index, workers.w_y_view[i].y_index, inner_max]);
        workers.worker[i].onmessage = storeDIAII;
      }
    }
    function storeDIAII(event){
      pending_workers -= 1;
      if(pending_workers <= 0){
        for(var i = 0; i < num_workers; i++)
          sparse_instance.exports.sum(y_view.y_index, workers.w_y_view[i].y_index, N);
        t2 = Date.now();
        if(t >= 10){
          diaII_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10))
          runDIAII();
        else{
          tt = tt/1000;
          diaII_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
          variance = 0;
          for(var i = 0; i < outer_max; i++)
            variance += (diaII_mflops - diaII_flops[i]) * (diaII_mflops - diaII_flops[i]);
          variance /= outer_max;
          diaII_sd = Math.sqrt(variance);
          diaII_sum = fletcher_sum_y(y_view);
          console.log('diaII sum is ', diaII_sum);
          console.log('diaII mflops is ', diaII_mflops);
          console.log("Returned to main thread");
          resolve(0);
        }
      }
    }
    runDIAII();
  });
}



function ell_test(A_ell, x_view, y_view, workers)
{
  return new Promise(function(resolve){
    console.log("ELL");
    if(typeof A_ell === "undefined"){
      console.log("matrix is undefined");
      return;
    }
    if(typeof x_view === "undefined"){
      console.log("vector x is undefined");
      return;
    }
    if(typeof y_view === "undefined"){
      console.log("vector y is undefined");
      return;
    }
    var t1, t2, tt = 0.0;
    var N_per_worker = Math.floor(N/num_workers);
    var rem_N  = N - N_per_worker * num_workers;
    var t = 0;
    function runELL()
    {
      pending_workers = num_workers;
      clear_y(y_view);
      t1 = Date.now();
      for(var i = 0; i < num_workers; i++){
        if(i == num_workers - 1)
          workers.worker[i].postMessage([4, i, i * N_per_worker, (i+1) * N_per_worker + rem_N, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        else
          workers.worker[i].postMessage([4, i, i * N_per_worker, (i+1) * N_per_worker, A_ell.indices_index, A_ell.data_index, A_ell.ncols, N, x_view.x_index, y_view.y_index, inner_max]);
        workers.worker[i].onmessage = storeELL;
      }
    }

    function storeELL(event)
    {
      pending_workers -= 1;
      if(pending_workers <= 0){
        t2 = Date.now();
        if(t >= 10){
          ell_flops[t-10] = 1/Math.pow(10,6) * 2 * anz * inner_max/ ((t2 - t1)/1000);
          tt += t2 - t1;
        }
        t++;
        if(t < (outer_max + 10))
          runELL();
        else{
          tt = tt/1000;
          ell_mflops = 1/Math.pow(10,6) * 2 * anz * outer_max * inner_max/ tt;
	  variance = 0;
	  for(var i = 0; i < outer_max; i++)
	    variance += (ell_mflops - ell_flops[i]) * (ell_mflops - ell_flops[i]);
	  variance /= outer_max;
	  ell_sd = Math.sqrt(variance);
	  ell_sum = fletcher_sum_y(y_view);
          console.log('ell sum is ', ell_sum);
	  console.log('ell mflops is ', ell_mflops);
	  console.log("Returned to main thread");
          resolve(0);
        }
      }
    }
    runELL();
  });
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
  var coo_val = new Float64Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

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
  var coo_val_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * anz);
  var A_coo = new sswasm_COO_t(coo_row_index, coo_col_index, coo_val_index, anz); 
  return A_coo;
}

function allocate_CSR(mm_info)
{
  // CSR memory allocation
  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (mm_info.nrows + 1));
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * anz);
  var csr_val_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * anz);
  var A_csr = new sswasm_CSR_t(csr_row_index, csr_col_index, csr_val_index, mm_info.nrows, anz);
  return A_csr;
}

function allocate_DIAII(mm_info, ndiags, stride)
{ 
  // DIA memory allocation
  var offset_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ndiags);
  var dia_data_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * ndiags * stride);
  var A_diaII = new sswasm_DIA_t(offset_index, dia_data_index, ndiags, mm_info.nrows, stride, anz);
  return A_diaII;
}

function allocate_DIA(mm_info, ndiags, stride)
{
  // DIA memory allocation
  var offset_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ndiags);
  var dia_data_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * ndiags * stride);
  var A_dia = new sswasm_DIA_t(offset_index, dia_data_index, ndiags, mm_info.nrows, stride, anz);
  return A_dia;
}

function allocate_ELL(mm_info, ncols)
{
  // ELL memory allocation
  var indices_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ncols * mm_info.nrows);
  var ell_data_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * ncols * mm_info.nrows);
  var A_ell = new sswasm_ELL_t(indices_index, ell_data_index, ncols, mm_info.nrows, anz);
  return A_ell;
}

function allocate_x(mm_info)
{
  var x_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * mm_info.ncols);
  var x_view = new sswasm_x_t(x_index, mm_info.ncols);
  return x_view;
}

function allocate_y(mm_info)
{
  var y_index = malloc_instance.exports._malloc(Float64Array.BYTES_PER_ELEMENT * mm_info.nrows);
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
  const bytesPerPage = 64 * 1024;
  var max_pages = 16384;
  let buffer = memory.buffer;
  console.log(buffer instanceof SharedArrayBuffer);
  
  var A_coo = allocate_COO(mm_info);
  create_COO_from_MM(mm_info, A_coo); 

  var A_csr = allocate_CSR(mm_info);
  //convert COO to CSR
  coo_csr(A_coo, A_csr);

  //get DIA info
  var result = num_diags(A_csr);
  var nd = result[0];
  var stride = result[1];
  //get ELL info
  var nc = num_cols(A_csr);
  var A_dia, A_diaII, A_ell;

  if(nd*stride < Math.pow(2,27)){ 
    A_dia = allocate_DIA(mm_info, nd, stride);
    A_diaII = allocate_DIA(mm_info, nd, stride);
    //convert CSR to DIA
    csr_dia(A_csr, A_dia);
    //convert CSR to DIAII
    csr_diaII(A_csr, A_diaII);
  }

  if(nc*mm_info.nrows < Math.pow(2,27)){
    A_ell = allocate_ELL(mm_info, nc);
    //convert CSR to ELL
    csr_ell(A_csr, A_ell);
  } 

  var x_view = allocate_x(mm_info);
  init_x(x_view);

  var y_view = allocate_y(mm_info);
  clear_y(y_view);

  return [A_coo, A_csr, A_dia, A_ell, A_diaII, x_view, y_view];
}

function free_memory_test(A_coo, A_csr, A_dia, A_ell, x_view, y_view)
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

  if(typeof x_view !== 'undefined')
    malloc_instance.exports._free(x_view.x_index);

  if(typeof y_view !== 'undefined')
    malloc_instance.exports._free(y_view.y_index);
}

function init_workers(mm_info)
{
  return new Promise(function(resolve){
  var w = new sswasm_workers_t(num_workers);
  pending_workers = num_workers;
  for(var i = 0; i < num_workers; i++){
    w.worker[i] = new Worker('worker64.js'); 
    var w_y_view = allocate_y(mm_info);
    w.w_y_view.push(w_y_view);
    w.worker[i].onmessage = loaded;
    w.worker[i].postMessage([0, i, sparse_module, memory]);
  }
  function loaded(event)
  {
    pending_workers -= 1;
    if(pending_workers <= 0){
      console.log("all workers loaded");
      resolve(w);
    }
  }
  });
}



function spmv_test(files, callback)
{
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, A_dia, A_ell, A_diaII, x_view, y_view;
  [A_coo, A_csr, A_dia, A_ell, A_diaII, x_view, y_view] = allocate_memory_test(mm_info);
  
  console.log("memory allocated");

  var workers_promise = init_workers(mm_info);
  workers_promise.then(w => {
    console.log("workers loaded");
    var coo_promise = coo_test(A_coo, x_view, y_view, w);
    coo_promise.then(coo_value => {
      var csr_promise = csr_test(A_csr, x_view, y_view, w);
      csr_promise.then(csr_value => {
        var dia_promise = dia_test(A_dia, x_view, y_view, w);
        dia_promise.then(dia_value => {
          var ell_promise = ell_test(A_ell, x_view, y_view, w);
          ell_promise.then(ell_value => {
            var diaII_promise = diaII_test(A_diaII, x_view, y_view, w);
            diaII_promise.then(diaII_value => {
              free_memory_test(A_coo, A_csr, A_dia, A_ell, x_view, y_view);
              console.log("done");
              callback();
            });
          });
        });
      });
    });
  });
}

/* 
   Function to read the file
   Input : File object (https://developer.mozilla.org/en-US/docs/Web/API/File)
   Return : String containing the input file data 
*/
function parse_file(file)
{
  // 32MB blob size
  var limit = 32 * 1024 * 1024;
  var size = file.size;
  console.log(size);
  var num = Math.ceil(size/limit);
  console.log("num of blocks : ", num);
  var file_arr = [];

  function read_file_block(file, i){
    if(i >= num){
      var file_data = file_arr.join("");
      return file_data;
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
}



var load_files = function(fileno, files, num, callback1, callback2){
  var request = new XMLHttpRequest();
  var myname = filename + (Math.floor(fileno/10)).toString() + (fileno%10).toString() + '.mtx'
  console.log(myname);
  request.onreadystatechange = function() {
    if(request.readyState == 4 && request.status == 200){
      try{
        files[fileno] = request.responseText.split("\n");
        fileno++;
        if(fileno < num)
          load_files(fileno, files, num, callback1, callback2);
        else
          callback2(files, callback1);
      }
      catch(e){
        console.log('Error : ', e);
        callback1();
      }
    } 
  }
  request.open('GET', myname, true);
  request.send();
}

function spmv(callback)
{
  var files = new Array(num);
  load_files(0, files, num, callback, spmv_test);
}
