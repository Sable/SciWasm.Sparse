function sswasm_MM_info(){
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

function sswasm_COO_t(row_index, col_index, val_index, nnz){
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nnz = nnz;
}

function sswasm_CSR_t(row_index, col_index, val_index, nrows, nnz){
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nrows = nrows;
  this.nnz = nnz;
}

function sswasm_DIA_t(offset_index, data_index, ndiags, nrows, stride, nnz){
  this.offset_index = offset_index;
  this.data_index = data_index;;
  this.ndiags = ndiags;
  this.nrows = nrows;
  this.stride = stride;
  this.nnz = nnz;
}

function sswasm_ELL_t(indices_index, data_index, ncols, nrows, nnz){
  this.indices_index = indices_index;
  this.data_index = data_index;
  this.ncols = ncols;
  this.nrows = nrows;
  this.nnz = nnz;
}

function sswasm_x_t(x, x_index){
  this.x = x;
  this.x_index = x_index;
}

function sswasm_y_t(y, y_index){
  this.y = y;
  this.y_index = y_index;
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

function num_cols(csr_row, N)
{
  var temp, max = 0;
  for(var i = 0; i < N ; i++){
    temp = csr_row[i+1] - csr_row[i];
    if (max < temp)
      max = temp;
  }
  return max;
}

function csr_ell(csr_row, csr_col, csr_val, indices, data, nz, N){
  var i, j, k, temp, max = 0;
  for(i = 0; i < N; i++){
    k = 0;
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      data[k*N+i] = csr_val[j];
      indices[k*N+i] = csr_col[j];
      k++;
    }
  }
}

function num_diags(N,csr_row,csr_col)
{
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
  stride = N - min;
  return [num_diag,stride];
}


function csr_dia(csr_row, csr_col, csr_val, offset, data, nz, N, stride){
  var ind = [], i, j, move;
  for(i = 0; i < 2*N-1; i++){
    ind[i] = 0; 
  }
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
  return stride;
}


function quick_sort(arr, arr2, arr3, left, right)
{
  var i = left
  var j = right;
  var pivot = arr[parseInt((left + right) / 2)];
  var pivot_col = arr2[parseInt((left + right) / 2)];

  /* partition */
  while(i <= j) {
    while((arr[i] < pivot) || (arr[i] == pivot && arr2[i] < pivot_col))
      i++;
    while((arr[j] > pivot) || (arr[j] == pivot && arr2[j] > pivot_col))
      j--;
    if(i <= j) {
      arr[j] = [arr[i], arr[i] = arr[j]][0];
      arr2[j] = [arr2[i], arr2[i] = arr2[j]][0];
      arr3[j] = [arr3[i], arr3[i] = arr3[j]][0];
      i++;
      j--;
    }
  }

  /* recursion */
  if(left < j)
    quick_sort(arr, arr2, arr3, left, j);
  if (i < right)
    quick_sort(arr, arr2, arr3, i, right);
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

function coo_csr(row, col, val, N, nz, csr_row, csr_col, csr_val){
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

  var r, c, data;
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

  
var coo_mflops = -1, csr_mflops = -1, dia_mflops = -1, ell_mflops = -1;
var coo_sum=-1, csr_sum=-1, dia_sum=-1, ell_sum=-1;
var coo_sd=-1, csr_sd=-1, dia_sd=-1, ell_sd=-1;
var anz = 0;
var coo_flops = [], csr_flops = [], dia_flops = [], ell_flops = [];
var N;
var variance;
var inside = 0, inner_max = 100000, outer_max = 30;
let memory = Module['wasmMemory'];
var malloc_instance;
var sparse_instance;

function get_inner_max()
{
  if(anz > 1000000) inner_max = 1;
  else if (anz > 100000) inner_max = 10;
  else if (anz > 50000) inner_max = 50;
  else if(anz > 10000) inner_max = 100;
  else if(anz > 2000) inner_max = 1000;
  else if(anz > 100) inner_max = 10000;
}

async function init()
{
  var obj = await WebAssembly.instantiateStreaming(fetch('matmachjs.wasm'), Module);
  return obj.instance;
}

function coo_test(A_coo, x_view, y_view)
{
  console.log("COO");
  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    y_view.y.fill(0.0);
    sparse_instance.exports.spmv_coo_wrapper(A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, y_view.y_index, A_coo.nnz, inner_max);
  }
  for(var i = 0; i < outer_max; i++){
    y_view.y.fill(0.0);
    t1 = Date.now();
    sparse_instance.exports.spmv_coo_wrapper(A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, y_view.y_index, A_coo.nnz, inner_max);
    t2 = Date.now();
    coo_flops[i] = 1/Math.pow(10,6) * 2 * inner_max * A_coo.nnz/((t2 - t1)/1000);
    tt = tt + t2 - t1;
  }
  tt = tt/1000; 
  coo_mflops = 1/Math.pow(10,6) * 2 * A_coo.nnz * inner_max * outer_max/ tt;
  variance = 0;
  for(var i = 0; i < outer_max; i++)
    variance += (coo_mflops - coo_flops[i]) * (coo_mflops - coo_flops[i]);
  variance /= outer_max;
  coo_sd = Math.sqrt(variance);
  coo_sum = parseInt(fletcher_sum(y_view.y));
  console.log('coo sum is ', coo_sum);
  console.log('coo sd is ', coo_sd);
}

function csr_test(A_csr, x_view, y_view)
{
  console.log("CSR");
  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    y_view.y.fill(0.0);
    sparse_instance.exports.spmv_csr_wrapper(A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, A_csr.nrows, inner_max);
  }
  for(var i = 0; i < outer_max; i++){
    y_view.y.fill(0.0);
    t1 = Date.now();
    sparse_instance.exports.spmv_csr_wrapper(A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, A_csr.nrows, inner_max);
    t2 = Date.now();
    csr_flops[i] = 1/Math.pow(10,6) * 2 * inner_max * A_csr.nnz/((t2 - t1)/1000);
    tt = tt + t2 - t1;
  }
  tt = tt/1000; 
  csr_mflops = 1/Math.pow(10,6) * 2 * A_csr.nnz * inner_max * outer_max/ tt;
  variance = 0;
  for(var i = 0; i < outer_max; i++)
    variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
  variance /= outer_max;
  csr_sd = Math.sqrt(variance);
  csr_sum = parseInt(fletcher_sum(y_view.y));
  console.log('csr sum is ', csr_sum);
  console.log('csr sd is ', csr_sd);
}

function dia_test(A_dia, x_view, y_view)
{
  console.log("DIA");
  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    y_view.y.fill(0.0);
    sparse_instance.exports.spmv_dia_wrapper(A_dia.offset_index, A_dia.data_index, A_dia.nrows, A_dia.ndiags, A_dia.stride, x_view.x_index, y_view.y_index, inner_max);
  }
  for(var i = 0; i < outer_max; i++){
    y_view.y.fill(0.0);
    t1 = Date.now();
    sparse_instance.exports.spmv_dia_wrapper(A_dia.offset_index, A_dia.data_index, A_dia.nrows, A_dia.ndiags, A_dia.stride, x_view.x_index, y_view.y_index, inner_max);
    t2 = Date.now();
    dia_flops[i] = 1/Math.pow(10,6) * 2 * inner_max * A_dia.nnz/((t2 - t1)/1000);
    tt = tt + t2 - t1;
  }
  tt = tt/1000; 
  dia_mflops = 1/Math.pow(10,6) * 2 * A_dia.nnz * inner_max * outer_max/ tt;
  variance = 0;
  for(var i = 0; i < outer_max; i++)
    variance += (dia_mflops - dia_flops[i]) * (dia_mflops - dia_flops[i]);
  variance /= outer_max;
  dia_sd = Math.sqrt(variance);
  dia_sum = parseInt(fletcher_sum(y_view.y));
  console.log('dia sum is ', dia_sum);
  console.log('dia sd is ', dia_sd);
}

function ell_test(A_ell, x_view, y_view)
{
  console.log("ELL");
  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    y_view.y.fill(0.0);
    sparse_instance.exports.spmv_ell_wrapper(A_ell.indices_index, A_ell.data_index, A_ell.nrows, A_ell.ncols, x_view.x_index, y_view.y_index, inner_max);
  }
  for(var i = 0; i < outer_max; i++){
    y_view.y.fill(0.0);
    t1 = Date.now();
    sparse_instance.exports.spmv_ell_wrapper(A_ell.indices_index, A_ell.data_index, A_ell.nrows, A_ell.ncols, x_view.x_index, y_view.y_index, inner_max);
    t2 = Date.now();
    ell_flops[i] = 1/Math.pow(10,6) * 2 * inner_max * A_ell.nnz/((t2 - t1)/1000);
    tt = tt + t2 - t1;
  }
  tt = tt/1000; 
  ell_mflops = 1/Math.pow(10,6) * 2 * A_ell.nnz * inner_max * outer_max/ tt;
  variance = 0;
  for(var i = 0; i < outer_max; i++)
    variance += (ell_mflops - ell_flops[i]) * (ell_mflops - ell_flops[i]);
  variance /= outer_max;
  ell_sd = Math.sqrt(variance);
  ell_sum = parseInt(fletcher_sum(y_view.y));
  console.log('ell sum is ', ell_sum);
  console.log('ell sd is ', ell_sd);
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

function create_COO_from_MM(mm_info, coo_row, coo_col, coo_val, row, col, val)
{
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
}

function allocate_memory_test(mm_info)
{
  // Total Memory required  = COO + CSR + x + y 
  var total_length = Int32Array.BYTES_PER_ELEMENT * 3 * anz + Int32Array.BYTES_PER_ELEMENT * (mm_info.nrows + 1)  + Float32Array.BYTES_PER_ELEMENT * 2 * anz + Float32Array.BYTES_PER_ELEMENT * mm_info.nrows + Float32Array.BYTES_PER_ELEMENT * mm_info.ncols; 
  const bytesPerPage = 64 * 1024;
  var max_pages = 16384;
  console.log(memory.buffer.byteLength / bytesPerPage);
  var coo_row_index = 0;
  
  console.log(total_length);
  
  coo_row_index = malloc_instance.exports._malloc(total_length);

  // COO memory allocation
  //var coo_row_index = 0;
  let coo_row = new Int32Array(memory.buffer, coo_row_index, anz); 
  console.log(coo_row_index);
  var coo_col_index = coo_row_index + coo_row.byteLength; 
  let coo_col = new Int32Array(memory.buffer, coo_col_index, anz);
  console.log(coo_col_index);
  var coo_val_index = coo_col_index + coo_col.byteLength;
  console.log(coo_val_index);
  let coo_val = new Float32Array(memory.buffer, coo_val_index, anz);

 
  create_COO_from_MM(mm_info, coo_row, coo_col, coo_val, mm_info.row, mm_info.col, mm_info.val); 
  quick_sort(coo_row, coo_col, coo_val, 0, anz-1);      

  // CSR memory allocation
  var csr_row_index = coo_val_index + coo_val.byteLength;
  let csr_row = new Int32Array(memory.buffer, csr_row_index, mm_info.nrows + 1);
  var csr_col_index = csr_row_index + csr_row.byteLength;
  let csr_col = new Int32Array(memory.buffer, csr_col_index, anz);
  var csr_val_index = csr_col_index + csr_col.byteLength;
  let csr_val = new Float32Array(memory.buffer, csr_val_index, anz); 

  //convert COO to CSR
  coo_csr(coo_row, coo_col, coo_val, mm_info.nrows, anz, csr_row, csr_col, csr_val);
  //get DIA info
  var result = num_diags(mm_info.nrows, csr_row, csr_col);
  var nd = result[0];
  var stride = result[1];

  //get ELL info
  var nc = num_cols(csr_row, mm_info.nrows);

  console.log(memory.buffer.byteLength / bytesPerPage);
  //grow memory buffer size for DIA and ELL
  var dia_length = Int32Array.BYTES_PER_ELEMENT * nd + Float32Array.BYTES_PER_ELEMENT * nd * stride; 
  var ell_length = Int32Array.BYTES_PER_ELEMENT * nc * mm_info.nrows + Float32Array.BYTES_PER_ELEMENT * nc * mm_info.nrows;
  var grow_num_pages = Math.ceil((dia_length + ell_length)/bytesPerPage);
  //memory.grow(grow_num_pages);
  var offset_index = malloc_instance.exports._malloc(dia_length + ell_length);
  console.log(offset_index);
  //console.log('grow num pages', grow_num_pages);
  console.log(memory.buffer.byteLength / bytesPerPage);

  //re-attach the CSR array buffers
  /* Note: Since an ArrayBuffer’s byteLength is immutable, 
  after a successful Memory.prototype.grow() operation the 
  buffer getter will return a new ArrayBuffer object 
  (with the new byteLength) and any previous ArrayBuffer 
  objects become “detached”, or disconnected from the 
  underlying memory they previously pointed to.*/ 
  csr_row = new Int32Array(memory.buffer, csr_row_index, mm_info.nrows + 1);
  csr_col = new Int32Array(memory.buffer, csr_col_index, anz);
  csr_val = new Float32Array(memory.buffer, csr_val_index, anz);

  var indices_index, ell_data_index, dia_data_index;

  if((nd*stride < Math.pow(2,27)) && (nc*mm_info.nrows < Math.pow(2,27))) {
  // DIA memory allocation
  //var offset_index = csr_val_index + csr_val.byteLength;
  let offset = new Int32Array(memory.buffer, offset_index, nd);
  dia_data_index = offset_index + offset.byteLength;
  let dia_data = new Float32Array(memory.buffer, dia_data_index, nd * stride);
  console.log("allocated memory");

  // ELL memory allocation
  indices_index = dia_data_index + dia_data.byteLength; 
  let indices = new Int32Array(memory.buffer, indices_index, nc * mm_info.nrows);
  ell_data_index = indices_index + indices.byteLength; 
  let ell_data = new Float32Array(memory.buffer,ell_data_index, nc * mm_info.nrows);

  //convert CSR to DIA
  csr_dia(csr_row, csr_col, csr_val, offset, dia_data, anz, mm_info.nrows, stride);


  //convert CSR to ELL
  csr_ell(csr_row, csr_col, csr_val, indices, ell_data, anz, mm_info.nrows);
  } 
  // vector x and y allocation
  var x_index = csr_val_index + csr_val.byteLength;
  console.log("x index is ", x_index);
  let x = new Float32Array(memory.buffer, x_index, mm_info.ncols);
  var y_index = x_index + x.byteLength;
  console.log("y index is ", y_index);
  let y = new Float32Array(memory.buffer, y_index, mm_info.nrows);


  // initialize x array
  for(var i = 0; i < mm_info.ncols; i++){
    x[i] = i;
  } 

  var A_coo = new sswasm_COO_t(coo_row_index, coo_col_index, coo_val_index, anz);
  var A_csr = new sswasm_CSR_t(csr_row_index, csr_col_index, csr_val_index, mm_info.nrows, anz);
  var A_dia = new sswasm_DIA_t(offset_index, dia_data_index, nd, mm_info.nrows, stride, anz);
  var A_ell = new sswasm_ELL_t(indices_index, ell_data_index, nc, mm_info.nrows, anz);

  var x_view = new sswasm_x_t(x, x_index);

  var y_view = new sswasm_y_t(y, y_index);

  return [A_coo, A_csr, A_dia, A_ell, x_view, y_view];
}

function spmv_test(files, callback)
{
  var mm_info = new sswasm_MM_info();
  read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  get_inner_max();

  var A_coo, A_csr, A_dia, A_ell, x_view, y_view;
  [A_coo, A_csr, A_dia, A_ell, x_view, y_view] = allocate_memory_test(mm_info);

  WebAssembly.compileStreaming(fetch('spmv_32.wasm'))
  .then(module => {
  WebAssembly.instantiate(module, { js: { mem: memory }, 
    console: { log: function(arg) {
      console.log(arg);}} 
  })
  .then(instance => {
    sparse_instance = instance;
    coo_test(A_coo, x_view, y_view);
    csr_test(A_csr, x_view, y_view);
    dia_test(A_dia, x_view, y_view);
    ell_test(A_ell, x_view, y_view);
    console.log("done seqential");
    callback();
  })
  });
}

var load_files = function(fileno, files, num, callback1, callback2){
  console.log(typeof callback1 == "function");
  console.log(callback1);
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
