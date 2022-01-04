export var coo_mflops = -1, csr_mflops = -1, dia_mflops = -1, ell_mflops = -1;
export var coo_sum=-1, csr_sum=-1, dia_sum=-1, ell_sum=-1;
export var coo_sd=-1, csr_sd=-1, dia_sd=-1, ell_sd=-1;
var coo_flops = [], csr_flops = [], dia_flops = [], ell_flops = [];
var variance;
export var inner_max = 1000000, outer_max = 30;
export var N, anz;

import * as swasmsModule from './spmv32.js';

function get_inner_max(anz)
{
  if(anz > 1000000) inner_max = 5;
  else if (anz > 100000) inner_max = 100;
  else if (anz > 50000) inner_max = 500;
  else if(anz > 10000) inner_max = 1000;
  else if(anz > 2000) inner_max = 5000;
  else if(anz > 100) inner_max = 50000;
  inner_max *= 5;
}

function allocate_memory_test(mm_info)
{
  //const bytesPerPage = 64 * 1024;
  //var max_pages = 16384;
  
  var A_coo = swasmsModule.allocate_COO(mm_info);
  swasmsModule.create_COO_from_MM(mm_info, A_coo); 

  var A_csr = swasmsModule.allocate_CSR(mm_info);
  //convert COO to CSR
  swasmsModule.coo_csr(A_coo, A_csr);

  //get DIA info
  var result = swasmsModule.num_diags(A_csr);
  var nd = result[0];
  var stride = result[1];
  //get ELL info
  var nc = swasmsModule.num_cols(A_csr);
  var A_dia, A_ell;
  
  console.log((stride * nd)/mm_info.anz);

  if(nd*stride < Math.pow(2,27) && (((stride * nd)/mm_info.anz) <= 5)){ 
    A_dia = swasmsModule.allocate_DIA(mm_info, nd, stride);
    //convert CSR to DIA
    swasmsModule.csr_dia(A_csr, A_dia);
  }

  if((nc*mm_info.nrows < Math.pow(2,27)) && (((mm_info.nrows * nc)/mm_info.anz) <= 5)){
    A_ell = swasmsModule.allocate_ELL(mm_info, nc);
    //convert CSR to ELL
    swasmsModule.csr_ell(A_csr, A_ell);
  } 

  var x = swasmsModule.allocate_x(mm_info);
  swasmsModule.init_x(x);

  var y = swasmsModule.allocate_y(mm_info);
  swasmsModule.clear_y(y);

  return [A_coo, A_csr, A_dia, A_ell, x, y];
}

function free_memory_test(A_coo, A_csr, A_dia, A_ell, x, y)
{
  swasmsModule.free_COO(A_coo);
  swasmsModule.free_CSR(A_csr);
  swasmsModule.free_DIA(A_dia);
  swasmsModule.free_ELL(A_ell);
  swasmsModule.free_x(x);
  swasmsModule.free_y(y);
}

function spmv_csr_test(files, callback)
{
  // create an instance of swasms_MM_info object type
  var mm_info = new swasmsModule.sswasm_MM_info();
  // read matrix data from file into mm_info
  swasmsModule.read_matrix_MM_files(files, num, mm_info, callback);
  get_inner_max(mm_info.anz);
  N = mm_info.nrows;
  anz = mm_info.anz;

  var A_coo, A_csr, x, y;

  // allocate memory for COO format
  A_coo = swasmsModule.allocate_COO(mm_info);
  // fill COO with matrix data
  swasmsModule.create_COO_from_MM(mm_info, A_coo);
  console.log("COO allocated");

  // allocate memory for CSR format
  A_csr = swasmsModule.allocate_CSR(mm_info);
  //convert COO to CSR
  swasmsModule.coo_csr(A_coo, A_csr);
  //free COO
  swasmsModule.free_COO(A_coo);
  console.log("CSR allocated");

  x = swasmsModule.allocate_x(mm_info);
  swasmsModule.init_x(x);
  y = swasmsModule.allocate_y(mm_info);
  swasmsModule.clear_y(y);

  // test SpMV CSR
  csr_test(A_csr, x, y);
  //free CSR, x and y
  swasmsModule.free_CSR(A_csr);
  swasmsModule.free_x(x);
  swasmsModule.free_y(y);
  console.log("done");
  callback();
}

function coo_test(A_coo, x, y)
{
  console.log("COO");
  if(typeof A_coo === "undefined"){
    console.log("matrix is undefined");
    return;
  }
  if(typeof x === "undefined"){
    console.log("vector x is undefined");
    return;
  }
  if(typeof y === "undefined"){
    console.log("vector y is undefined");
    return;
  }

  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    swasmsModule.clear_y(y);
    swasmsModule.swasms_spmv_coo(A_coo, x, y, inner_max);
  }

  for(var i = 0; i < outer_max; i++){
    swasmsModule.clear_y(y);
    t1 = Date.now();
    swasmsModule.swasms_spmv_coo(A_coo, x, y, inner_max);
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
  coo_sum = swasmsModule.fletcher_sum_y(y);

  console.log('coo sum is ', coo_sum);
  console.log('coo mflops is ', coo_mflops);
  console.log('coo sd is ', coo_sd);
}

function csr_test(A_csr, x, y)
{
  console.log("CSR");
  if(typeof A_csr === "undefined"){
    console.log("matrix is undefined");
    return;
  }
  if(typeof x === "undefined"){
    console.log("vector x is undefined");
    return;
  }
  if(typeof y === "undefined"){
    console.log("vector y is undefined");
    return;
  }

  var t1, t2, tt = 0.0;

  // warm up runs
  for(var i = 0; i < 10; i++){
    swasmsModule.clear_y(y);
    swasmsModule.swasms_spmv_csr(A_csr, x, y, inner_max);
  }

  for(var i = 0; i < outer_max; i++){
    swasmsModule.clear_y(y);
    t1 = Date.now();
    swasmsModule.swasms_spmv_csr(A_csr, x, y, inner_max);
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
  csr_sum = swasmsModule.fletcher_sum_y(y);

  console.log('csr sum is ', csr_sum);
  console.log('csr mflops is ', csr_mflops);
  console.log('csr sd is ', csr_sd);
}

function dia_test(A_dia, x, y)
{
  console.log("DIA");
  if(typeof A_dia === "undefined"){
    console.log("matrix is undefined");
    return;
  }
  if(typeof x === "undefined"){
    console.log("vector x is undefined");
    return;
  }
  if(typeof y === "undefined"){
    console.log("vector y is undefined");
    return;
  }
  if((A_dia.nrows * A_dia.ndiags)/A_dia.nnz > 5){
    console.log("too many elements in dia data array to compute spmv");
    return;
  }
  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    swasmsModule.clear_y(y);
    swasmsModule.swasms_spmv_dia(A_dia, x, y, inner_max);
  }

  for(var i = 0; i < outer_max; i++){
    swasmsModule.clear_y(y);
    t1 = Date.now();
    swasmsModule.swasms_spmv_dia(A_dia, x, y, inner_max);
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
  dia_sum = swasmsModule.fletcher_sum_y(y);

  console.log('dia mflops is ', dia_mflops);
  console.log('dia sum is ', dia_sum);
  console.log('dia sd is ', dia_sd);
}

function ell_test(A_ell, x, y)
{
  console.log("ELL");
  if(typeof A_ell === "undefined"){
    console.log("matrix is undefined");
    return;
  }
  if(typeof x === "undefined"){
    console.log("vector x is undefined");
    return;
  }
  if(typeof y === "undefined"){
    console.log("vector y is undefined");
    return;
  }
  var t1, t2, tt = 0.0;
  for(var i = 0; i < 10; i++){
    swasmsModule.clear_y(y);
    swasmsModule.swasms_spmv_ell(A_ell, x, y, inner_max);
  }

  for(var i = 0; i < outer_max; i++){
    swasmsModule.clear_y(y);
    t1 = Date.now();
    swasmsModule.swasms_spmv_ell(A_ell, x, y, inner_max);
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
  ell_sum = swasmsModule.fletcher_sum_y(y);

  console.log('ell mflops is ', ell_mflops);
  console.log('ell sum is ', ell_sum);
  console.log('ell sd is ', ell_sd);
}

function spmv_test(files, callback)
{
  var mm_info = new swasmsModule.sswasm_MM_info();
  swasmsModule.read_matrix_MM_files(files, num, mm_info, callback);
  N = mm_info.nrows;
  anz = mm_info.anz;
  get_inner_max(anz);

  var A_coo, A_csr, A_dia, A_ell, x, y;
  [A_coo, A_csr, A_dia, A_ell, x, y] = allocate_memory_test(mm_info);

  coo_test(A_coo, x, y);
  csr_test(A_csr, x, y);
  dia_test(A_dia, x, y);
  ell_test(A_ell, x, y);
  free_memory_test(A_coo, A_csr, A_dia, A_ell, x, y);
  console.log("done");
  callback();
}



function spts_test(files, callback)
{
  //var mm_info = new swasmsModule.sswasm_MM_info();
  var mm_info = new sswasm_MM_info();
  //swasmsModule.read_matrix_MM_files(files, num, mm_info, callback);
  read_matrix_MM_files(files, num, mm_info, callback);
  var N = mm_info.nrows;
  get_inner_max();
  
  var A_coo, A_csc, x_view, y_view;
  //A_coo = swasmsModule.create_LCOO_from_MM(mm_info);
  A_coo = create_LCOO_from_MM(mm_info);
  console.log("COO allocated");
  //pretty_print_COO(A_coo);

  //A_csc = swasmsModule.allocate_CSC(mm_info);
  A_csc = allocate_CSC(mm_info);
  //convert COO to CSC
  //swasmsModule.coo_csc(A_coo, A_csc);
  coo_csc(A_coo, A_csc);
  if(typeof A_coo !== 'undefined'){
    //swasmsModule.malloc_instance.exports._free(A_coo.row_index);
    //swasmsModule.malloc_instance.exports._free(A_coo.col_index);
    //swasmsModule.malloc_instance.exports._free(A_coo.val_index);
    malloc_instance.exports._free(A_coo.row_index);
    malloc_instance.exports._free(A_coo.col_index);
    malloc_instance.exports._free(A_coo.val_index);
  }
  console.log("CSC allocated");
  //x_view = swasmsModule.allocate_x(mm_info);
  x_view = allocate_x(mm_info);
  //swasmsModule.spts_init_x(x_view);
  spts_init_x(x_view);
  //y_view = swasmsModule.allocate_y(mm_info);
  y_view = allocate_y(mm_info);
  //swasmsModule.spts_init_y(y_view);
  spts_init_y(y_view);

  //swasmsModule.spts_csc_test(A_csc, x_view, y_view);
  spts_csc_test(A_csc, x_view, y_view);
  console.log("x");
  //pretty_print_x(x_view);
  console.log("y");
  //pretty_print_y(y_view);

  if(typeof A_csc !== 'undefined'){
    //swasmsModule.malloc_instance.exports._free(A_csc.row_index);
    //swasmsModule.malloc_instance.exports._free(A_csc.col_index);
    //swasmsModule.malloc_instance.exports._free(A_csc.val_index);
    malloc_instance.exports._free(A_csc.row_index);
    malloc_instance.exports._free(A_csc.col_index);
    malloc_instance.exports._free(A_csc.val_index);
  }
  if(typeof x_view !== 'undefined')
    //swasmsModule.malloc_instance.exports._free(x_view.x_index);
    malloc_instance.exports._free(x_view.x_index);

  if(typeof y_view !== 'undefined')
    swasmsModule.malloc_instance.exports._free(y_view.y_index);
    malloc_instance.exports._free(y_view.y_index);
  console.log("done");
  callback();
}

export function spmv(callback)
{
  let promise = swasmsModule.load_file();
  promise.then(
    files => spmv_test(files, callback),
    //files => spmv_csr_test(files, callback),
    error => callback()
  );
}

export function spts(callback)
{
  let promise = swasmsModule.load_file();
  promise.then(
    files => spts_test(files, callback),
    error => callback()
  );
}
