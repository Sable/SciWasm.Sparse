let memModule = await import('/static/libs/matmachjs-lib.js');
let memory = memModule.Module['wasmMemory'];
let obj = await WebAssembly.instantiateStreaming(fetch('/static/libs/matmachjs.wasm'), memModule.Module);
const malloc_instance = obj.instance;
var importObject = { js: { mem: memory }, console: { log: function(arg) {console.log(arg);}}, math: { expm1: function(arg) { return Math.expm1(arg);}, log1p: function(arg) { return Math.log1p(arg);}, pow: function(arg1, arg2) { return Math.pow(arg1, arg2);}, sin: function(arg) { return Math.sin(arg);}, tan: function(arg) { return Math.tan(arg);}}}
obj = await WebAssembly.instantiateStreaming(fetch('/static/src/spmv_simd_32.wasm'), importObject);
const sparse_instance = obj.instance;

/* Constructor function to create an object sparse_MM_info to
 * represent the matrix data from a Matrix-Market format input file */
export function sparse_MM_info()
{
  this.field = '';
  this.symmetry = '';
  this.nrows = 0;
  this.ncols = 0;
  this.nentries = 0;
  this.row;
  this.col;
  this.val;
  this.nnz = 0;
}

export function sparse_COO_t(row_index, col_index, val_index, N, nnz)
{
  this.row;
  this.col;
  this.val;
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nnz = nnz;
  this.N = N;

  // element-wise methods
  this.expm1 = sparse_self_expm1_coo;
  this.log1p = sparse_self_log1p_coo;
  this.sin = sparse_self_sin_coo;
  this.tan = sparse_self_tan_coo;
  this.pow = sparse_self_pow_coo;
  this.deg2rad = sparse_self_deg2rad_coo;
  this.rad2deg = sparse_self_rad2deg_coo;
  this.sign = sparse_self_sign_coo;
  this.multiply = sparse_self_multiply_coo;
  this.abs = sparse_self_abs_coo;
  this.neg = sparse_self_neg_coo;
  this.sqrt = sparse_self_sqrt_coo;
  this.ceil = sparse_self_ceil_coo;
  this.floor = sparse_self_floor_coo;
  this.trunc = sparse_self_trunc_coo;
  this.nearest = sparse_self_nearest_coo;

  // other methods
  this.transpose = sparse_self_transpose_coo;
  this.diagonal = sparse_self_diagonal_coo;
  this.min = sparse_self_min_coo;
}

export function sparse_CSR_t(row_index, col_index, val_index, nnz_row_index, N, nnz)
{
  this.row;
  this.col;
  this.val;
  this.row_index = row_index;
  this.col_index = col_index;
  this.val_index = val_index;
  this.nnz_row_index = nnz_row_index;
  this.N = N;
  this.nnz = nnz;
  this.permutation_index;
  this.permutation;
  this.num_zero_rows = 0;
  this.num_one_rows = 0;
  this.num_two_rows = 0;
  this.num_three_rows = 0;

  //methods
  this.expm1 = sparse_self_expm1_csr;
  this.log1p = sparse_self_log1p_csr;
  this.sin = sparse_self_sin_csr;
  this.tan = sparse_self_tan_csr;
  this.pow = sparse_self_pow_csr;
  this.deg2rad = sparse_self_deg2rad_csr;
  this.rad2deg = sparse_self_rad2deg_csr;
  this.sign = sparse_self_sign_csr;
  this.abs = sparse_self_abs_csr;
  this.neg = sparse_self_neg_csr;
  this.sqrt = sparse_self_sqrt_csr;
  this.ceil = sparse_self_ceil_csr;
  this.floor = sparse_self_floor_csr;
  this.trunc = sparse_self_trunc_csr;
  this.nearest = sparse_self_nearest_csr;
}

function sparse_CSC_t(col_index, row_index, val_index, ncols, nnz){
  this.col;
  this.row;
  this.val;
  this.col_index = col_index;
  this.row_index = row_index;
  this.val_index = val_index;
  this.ncols = ncols;
  this.nnz = nnz;
}

function sparse_DIA_t(offset_index, data_index, ndiags, stride, N, nnz){
  this.offset;
  this.data;
  this.offset_index = offset_index;
  this.data_index = data_index;;
  this.ndiags = ndiags;
  this.N = N;
  this.stride = stride;
  this.nnz = nnz;

  // element-wise methods
  this.expm1 = sparse_self_expm1_dia;
  this.log1p = sparse_self_log1p_dia;
  this.sin = sparse_self_sin_dia;
  this.tan = sparse_self_tan_dia;
  this.pow = sparse_self_pow_dia;
  this.sign = sparse_self_sign_dia;
  this.abs = sparse_self_abs_dia;
  this.neg = sparse_self_neg_dia;
  this.sqrt = sparse_self_sqrt_dia;
  this.ceil = sparse_self_ceil_dia;
  this.floor = sparse_self_floor_dia;
  this.trunc = sparse_self_trunc_dia;
  this.nearest = sparse_self_nearest_dia;
  this.deg2rad = sparse_self_deg2rad_dia;
  this.rad2deg = sparse_self_rad2deg_dia;
}

function sparse_ELL_t(indices_index, data_index, ncols, N, nnz){
  this.indices;
  this.data;
  this.indices_index = indices_index;
  this.data_index = data_index;
  this.ncols = ncols;
  this.N = N;
  this.nnz = nnz;

  // element-wise methods
  this.expm1 = sparse_self_expm1_ell;
  this.log1p = sparse_self_log1p_ell;
  this.sin = sparse_self_sin_ell;
  this.tan = sparse_self_tan_ell;
  this.pow = sparse_self_pow_ell;
  this.sign = sparse_self_sign_ell;
  this.abs = sparse_self_abs_ell;
  this.neg = sparse_self_neg_ell;
  this.sqrt = sparse_self_sqrt_ell;
  this.ceil = sparse_self_ceil_ell;
  this.floor = sparse_self_floor_ell;
  this.trunc = sparse_self_trunc_ell;
  this.nearest = sparse_self_nearest_ell;
  this.deg2rad = sparse_self_deg2rad_ell;
  this.rad2deg = sparse_self_rad2deg_ell;
}

export function sparse_vec_t(vec_index, vec_nelem){
  this.vec;
  this.vec_index = vec_index;
  this.vec_nelem = vec_nelem;
}

function sparse_x_t(x_index, x_nelem){
  this.x;
  this.x_index = x_index;
  this.x_nelem = x_nelem;
}

function sparse_y_t(y_index, y_nelem){
  this.y;
  this.y_index = y_index;
  this.y_nelem = y_nelem;
}

// COO in_place operations

function sparse_self_expm1_coo()
{
  sparse_instance.exports.self_expm1_coo(this.val_index, this.nnz);
}

function sparse_self_log1p_coo()
{
  sparse_instance.exports.self_log1p_coo(this.val_index, this.nnz);
}

function sparse_self_sin_coo()
{
  sparse_instance.exports.self_sin_coo(this.val_index, this.nnz);
}

function sparse_self_tan_coo()
{
  sparse_instance.exports.self_tan_coo(this.val_index, this.nnz);
}

function sparse_self_pow_coo(p)
{
  sparse_instance.exports.self_pow_coo(p, this.val_index, this.nnz);
}

function sparse_self_deg2rad_coo()
{
  sparse_instance.exports.self_deg2rad_coo(Math.PI, this.val_index, this.nnz);
}

function sparse_self_rad2deg_coo()
{
  sparse_instance.exports.self_rad2deg_coo(Math.PI, this.val_index, this.nnz);
}

function sparse_self_sign_coo()
{
  sparse_instance.exports.self_sign_coo(this.val_index, this.nnz);
}

function sparse_self_multiply_coo(other)
{
  if(typeof other === 'number')
    sparse_instance.exports.self_multiply_scalar_coo(other, this.val_index, this.nnz);
  if((typeof other === 'object') && (other instanceof sparse_vec_t))
    sparse_instance.exports.self_multiply_vector_coo(other, this.val_index, this.nnz);
}

function sparse_self_abs_coo()
{
  sparse_instance.exports.self_abs_coo(this.val_index, this.nnz);
}

function sparse_self_neg_coo()
{
  sparse_instance.exports.self_neg_coo(this.val_index, this.nnz);
}

function sparse_self_sqrt_coo()
{
  sparse_instance.exports.self_sqrt_coo(this.val_index, this.nnz);
}

function sparse_self_ceil_coo()
{
  sparse_instance.exports.self_ceil_coo(this.val_index, this.nnz);
}

function sparse_self_floor_coo()
{
  sparse_instance.exports.self_floor_coo(this.val_index, this.nnz);
}

function sparse_self_trunc_coo()
{
  sparse_instance.exports.self_trunc_coo(this.val_index, this.nnz);
}

function sparse_self_nearest_coo()
{
  sparse_instance.exports.self_nearest_coo(this.val_index, this.nnz);
}

function sparse_self_transpose_coo()
{
  var row_index = this.row_index;
  var col_index = this.col_index;

  // switch row and col vectors
  this.col_index = row_index;
  this.row_index = col_index;

  quick_sort_COO(this, 0, this.nnz - 1);
}

function sparse_self_diagonal_coo(offset)
{
  if(this.N - Math.abs(offset) <= 0)
    return;
  var diag_vec = allocate_vec(this.N - Math.abs(offset));
  sparse_instance.exports.diagonal_coo(offset, this.row_index, this.col_index, this.val_index, diag_vec.vec_index, this.N, this.nnz);
  return diag_vec;
}

function sparse_self_min_coo(axis)
{
  var min_vec = allocate_vec(this.N);
  sparse_instance.exports.min_coo(axis, this.row_index, this.col_index, this.val_index, min_vec.vec_index, this.N, this.nnz);
  return min_vec;
}

// CSR in-place element-wise operations

function sparse_self_expm1_csr()
{
  sparse_instance.exports.self_expm1_coo(this.val_index, this.nnz);
}

function sparse_self_log1p_csr()
{
  sparse_instance.exports.self_log1p_coo(this.val_index, this.nnz);
}

function sparse_self_sin_csr()
{
  sparse_instance.exports.self_sin_coo(this.val_index, this.nnz);
}

function sparse_self_tan_csr()
{
  sparse_instance.exports.self_tan_coo(this.val_index, this.nnz);
}

function sparse_self_pow_csr(p)
{
  sparse_instance.exports.self_pow_coo(p, this.val_index, this.nnz);
}

function sparse_self_deg2rad_csr()
{
  sparse_instance.exports.self_deg2rad_coo(Math.PI, this.val_index, this.nnz);
}

function sparse_self_rad2deg_csr()
{
  sparse_instance.exports.self_rad2deg_coo(Math.PI, this.val_index, this.nnz);
}

function sparse_self_sign_csr()
{
  sparse_instance.exports.self_sign_coo(this.val_index, this.nnz);
}

function sparse_self_abs_csr()
{
  sparse_instance.exports.self_abs_coo(this.val_index, this.nnz);
}

function sparse_self_neg_csr()
{
  sparse_instance.exports.self_neg_coo(this.val_index, this.nnz);
}

function sparse_self_sqrt_csr()
{
  sparse_instance.exports.self_sqrt_coo(this.val_index, this.nnz);
}

function sparse_self_ceil_csr()
{
  sparse_instance.exports.self_ceil_coo(this.val_index, this.nnz);
}

function sparse_self_floor_csr()
{
  sparse_instance.exports.self_floor_coo(this.val_index, this.nnz);
}

function sparse_self_trunc_csr()
{
  sparse_instance.exports.self_trunc_coo(this.val_index, this.nnz);
}

function sparse_self_nearest_csr()
{
  sparse_instance.exports.self_nearest_coo(this.val_index, this.nnz);
}

// DIA in-place element-wise operations

function sparse_self_expm1_dia()
{
  sparse_instance.exports.self_expm1_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_log1p_dia()
{
  sparse_instance.exports.self_log1p_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_sin_dia()
{
  sparse_instance.exports.self_sin_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_tan_dia()
{
  sparse_instance.exports.self_tan_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_pow_dia(p)
{
  sparse_instance.exports.self_pow_dia(p, this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_abs_dia()
{
  sparse_instance.exports.self_abs_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_neg_dia()
{
  sparse_instance.exports.self_neg_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_sqrt_dia()
{
  sparse_instance.exports.self_sqrt_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_ceil_dia()
{
  sparse_instance.exports.self_ceil_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_floor_dia()
{
  sparse_instance.exports.self_floor_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_trunc_dia()
{
  sparse_instance.exports.self_trunc_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_nearest_dia()
{
  sparse_instance.exports.self_nearest_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_deg2rad_dia()
{
  sparse_instance.exports.self_deg2rad_dia(Math.PI, this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_rad2deg_dia()
{
  sparse_instance.exports.self_rad2deg_dia(Math.PI, this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

function sparse_self_sign_dia()
{
  sparse_instance.exports.self_sign_dia(this.offset_index, this.data_index, this.ndiags, this.stride, this.N);
}

// ELL in-place element-wise operations

function sparse_self_expm1_ell()
{
  sparse_instance.exports.self_expm1_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_log1p_ell()
{
  sparse_instance.exports.self_log1p_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_sin_ell()
{
  sparse_instance.exports.self_sin_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_tan_ell()
{
  sparse_instance.exports.self_tan_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_pow_ell(p)
{
  sparse_instance.exports.self_pow_ell(p, this.data_index, this.ncols, this.N);
}

function sparse_self_abs_ell()
{
  sparse_instance.exports.self_abs_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_neg_ell()
{
  sparse_instance.exports.self_neg_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_sqrt_ell()
{
  sparse_instance.exports.self_sqrt_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_ceil_ell()
{
  sparse_instance.exports.self_ceil_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_floor_ell()
{
  sparse_instance.exports.self_floor_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_trunc_ell()
{
  sparse_instance.exports.self_trunc_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_nearest_ell()
{
  sparse_instance.exports.self_nearest_ell(this.data_index, this.ncols, this.N);
}

function sparse_self_deg2rad_ell()
{
  sparse_instance.exports.self_deg2rad_ell(Math.PI, this.data_index, this.ncols, this.N);
}

function sparse_self_rad2deg_ell()
{
  sparse_instance.exports.self_rad2deg_ell(Math.PI, this.data_index, this.ncols, this.N);
}

function sparse_self_sign_ell()
{
  sparse_instance.exports.self_sign_ell(this.data_index, this.ncols, this.N);
}

// element-wise operations

export function expm1(A_in)
{
  console.log("expm1 called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.expm1_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.expm1_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function log1p(A_in)
{
  console.log("log1p called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.log1p_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) {
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.log1p_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function sin(A_in)
{
  console.log("sin called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.sin_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) {
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.sin_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function tan(A_in)
{
  console.log("tan called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.tan_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) {
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.tan_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function pow(A_in, p)
{
  console.log("pow called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.pow_coo(p, A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) {
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.pow_coo(p, A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function deg2rad(A_in)
{
  console.log("deg2rad called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.deg2rad_coo(Math.PI, A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) {
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.deg2rad_coo(Math.PI, A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function rad2deg(A_in)
{
  console.log("rad2deg called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.rad2deg_coo(Math.PI, A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) {
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.rad2deg_coo(Math.PI, A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function sign(A_in)
{
  console.log("sign called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.sign_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.sign_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function abs(A_in)
{
  console.log("abs called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.abs_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.abs_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function neg(A_in)
{
  console.log("neg called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.neg_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.neg_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function sqrt(A_in)
{
  console.log("sqrt called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.sqrt_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.sqrt_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function ceil(A_in)
{
  console.log("ceil called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.ceil_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.ceil_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function floor(A_in)
{
  console.log("floor called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.ceil_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.ceil_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function trunc(A_in)
{
  console.log("trunc called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.trunc_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.trunc_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

export function nearest(A_in)
{
  console.log("nearest called");
  if(A_in instanceof sparse_COO_t) {
    var A_out = allocate_copy_COO(A_in);
    memcpy_aux_coo(A_in, A_out);
    sparse_instance.exports.nearest_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
  else if(A_in instanceof sparse_CSR_t) { 
    var A_out = allocate_copy_CSR(A_in);
    memcpy_aux_csr(A_in, A_out);
    sparse_instance.exports.nearest_coo(A_in.val_index, A_out.val_index, A_in.nnz);
    return A_out;
  }
}

function memcpy_aux_coo(A_coo_in, A_coo_out)
{
  sparse_instance.exports.memcpy(A_coo_in.row_index, A_coo_out.row_index, Int32Array.BYTES_PER_ELEMENT * A_coo_in.nnz);
  sparse_instance.exports.memcpy(A_coo_in.col_index, A_coo_out.col_index, Int32Array.BYTES_PER_ELEMENT * A_coo_in.nnz);
}

function memcpy_aux_csr(A_csr_in, A_csr_out)
{
  sparse_instance.exports.memcpy(A_csr_in.row_index, A_csr_out.row_index, Int32Array.BYTES_PER_ELEMENT * (A_csr_in.N + 1));
  sparse_instance.exports.memcpy(A_csr_in.col_index, A_csr_out.col_index, Int32Array.BYTES_PER_ELEMENT * A_csr_in.nnz);
}

export function spmv(A_in, x_view, y_view, inner_max=1)
{
  if(A_in === undefined){
    console.log("spmv input : undefined");
    return;
  }
  if(A_in instanceof sparse_COO_t) {
    sparse_spmv_coo(A_in, x_view, y_view, inner_max);
    console.log("spmv COO");
  }
  if(A_in instanceof sparse_CSR_t) {
    sparse_spmv_csr(A_in, x_view, y_view, inner_max);
    console.log("spmv CSR");
  }
  if(A_in instanceof sparse_DIA_t) {
    sparse_spmv_dia(A_in, x_view, y_view, inner_max);
    console.log("spmv DIA");
  }
  if(A_in instanceof sparse_ELL_t) {
    sparse_spmv_ell(A_in, x_view, y_view, inner_max);
    console.log("spmv ELL");
  }
  
}

function sparse_spmv_coo(A_coo, x_view, y_view, inner_max)
{
    sparse_instance.exports.spmv_coo_wrapper(A_coo.row_index, A_coo.col_index, A_coo.val_index, x_view.x_index, y_view.y_index, A_coo.nnz, inner_max);
}

function sparse_spmv_csr(A_csr, x_view, y_view, inner_max)
{
  sparse_instance.exports.spmv_csr_wrapper(A_csr.row_index, A_csr.col_index, A_csr.val_index, x_view.x_index, y_view.y_index, A_csr.N, inner_max);
}

function sparse_spmv_dia(A_dia, x_view, y_view, inner_max)
{
  sparse_instance.exports.spmv_dia_wrapper(A_dia.offset_index, A_dia.data_index, A_dia.N, A_dia.ndiags, A_dia.stride, x_view.x_index, y_view.y_index, inner_max);
}

function sparse_spmv_ell(A_ell, x_view, y_view, inner_max)
{
  sparse_instance.exports.spmv_ell_wrapper(A_ell.indices_index, A_ell.data_index, A_ell.N, A_ell.ncols, x_view.x_index, y_view.y_index, inner_max);
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

export function fletcher_sum_y(y_view)
{
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  return parseInt(fletcher_sum(y));
}

export function init_x(x_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  for(var i = 0; i < x_view.x_nelem; i++)
    x[i] = i;
}

export function clear_y(y_view){
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  y.fill(0);
}

function copy_x_to_y(x_view, y_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  for(var i = 0; i < y_view.y_nelem; i++)
    y[i] = x[i];
}

export function pretty_print(obj){
  if(typeof obj === undefined){
    console.log("pretty print object: undefined");
    return;
  }
  if(obj instanceof sparse_COO_t){
    pretty_print_COO(obj);
    console.log("pretty print object: COO");
  }
  else if(obj instanceof sparse_CSR_t){
    pretty_print_CSR(obj);
    console.log("pretty print object: CSR");
  }
  else if(obj instanceof sparse_DIA_t){
    pretty_print_DIA(obj);
    console.log("pretty print object: DIA");
  }
  else if(obj instanceof sparse_ELL_t){
    pretty_print_ELL(obj);
    console.log("pretty print object: ELL");
  }
  else if(obj instanceof sparse_x_t){
    pretty_print_x(obj);
    console.log("pretty print object: x");
  }
  else if(obj instanceof sparse_y_t){
    pretty_print_y(obj);
    console.log("pretty print object: y");
  }
}

function pretty_print_COO(A_coo){
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var coo_val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 
  
  console.log("nnz : ", A_coo.nnz); 
  console.log("coo_row_index :", A_coo.row_index);
  console.log("coo_col_index :", A_coo.col_index);
  console.log("coo_val_index :", A_coo.val_index);
  for(var i = 0; i < A_coo.nnz; i++)
    console.log(coo_row[i], coo_col[i], coo_val[i]);
}

function pretty_print_CSR(A_csr){
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 
  
  console.log("nnz : ", A_csr.nnz); 
  console.log("N : ", A_csr.N); 
  console.log("csr_row_index :", A_csr.row_index);
  console.log("csr_col_index :", A_csr.col_index);
  console.log("csr_val_index :", A_csr.val_index);
  for(var i = 0; i < A_csr.N; i++){
    for(var j = csr_row[i]; j < csr_row[i+1] ; j++)
      console.log(i, csr_col[j], csr_val[j]);
  }
}

function pretty_print_DIA(A_dia)
{
  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float32Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);
  console.log("ndiags : ", A_dia.ndiags);
  console.log("offset_index : ", A_dia.offset_index);
  console.log("data_index : ", A_dia.data_index);
  for(var i = 0; i < A_dia.ndiags; i++){
    var k = offset[i];
    var index = 0;
    var istart = (k < 0) ? (index = A_dia.N - A_dia.stride, -k) : 0;
    var iend = (A_dia.N < A_dia.N-k) ? A_dia.N : A_dia.N-k;
    for(var j = istart; j < iend; j++){
      console.log(j, k+j, data[i*A_dia.stride + j - index]);
    }
  }
}

function pretty_print_ELL(A_ell)
{
  var indices = new Int32Array(memory.buffer, A_ell.indices_index, A_ell.ncols * A_ell.N);
  var data = new Float32Array(memory.buffer, A_ell.data_index, A_ell.ncols * A_ell.N);
  console.log("ncols : ", A_ell.ncols);
  console.log("indices_index : ", A_ell.indices_index);
  console.log("data_index : ", A_ell.data_index);
  for(var j = 0; j < A_ell.ncols; j++){
    for(var i = 0; i < A_ell.N; i++){
      console.log(i, indices[j*A_ell.N+i], data[j*A_ell.N+i]);
    }
  }
}

function pretty_print_x(x_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  console.log("x_index :", x_view.x_index); 
  for(var i = 0; i < x_view.x_nelem; i++)
    console.log(x[i]);
}


function pretty_print_y(y_view){
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  console.log("y_index :", y_view.y_index); 
  for(var i = 0; i <y_view.y_nelem; i++)
    console.log(y[i]);
}

function pretty_print_vec(vec_view){
  if(vec_view === undefined){
    console.log("input_paramter : undefined");
    return;
  }
  if(!(vec_view instanceof sparse_vec_t)){
    console.log("input_paramter : incompatible object");
    return;
  }
  var v = new Float32Array(memory.buffer, vec_view.vec_index, vec_view.vec_nelem);
  console.log("vec_index :", vec_view.vec_index);
  for(var i = 0; i < vec_view.vec_nelem; i++)
    console.log(v[i]);
}


export function num_cols(A_csr)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1); 
  var N = A_csr.N;
  var temp, max = 0;
  for(var i = 0; i < N ; i++){
    temp = csr_row[i+1] - csr_row[i];
    if (max < temp)
      max = temp;
  }
  return max;
}

export function csr_ell(A_csr)
{
  var nnz = A_csr.nnz; 
  var N = A_csr.N;
  var nc = num_cols(A_csr);
  var A_ell;
  
  // allocate memory for A_ell
  if((nc*N < Math.pow(2,27)) && (((nc*N)/nnz) <= 5)){
    A_ell = allocate_ELL(N, nnz, nc);
  } 
  else{
    console.log("not efficient to store this matrix in ELL");
    return;
  }

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var indices = new Int32Array(memory.buffer, A_ell.indices_index, A_ell.ncols * A_ell.N);
  var data = new Float32Array(memory.buffer, A_ell.data_index, A_ell.ncols * A_ell.N);

  var i, j, k, temp, max = 0;
  for(i = 0; i < N; i++){
    k = 0;
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      data[k*N+i] = csr_val[j];
      indices[k*N+i] = csr_col[j];
      k++;
    }
  }
  return A_ell;
}

export function num_diags(A_csr)
{
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var N = A_csr.N;
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
  var stride = N - min;
  //stride = N;
  return [num_diag,stride];
}


export function csr_dia(A_csr)
{
  var nnz = A_csr.nnz; 
  var N = A_csr.N;
  var result = num_diags(A_csr);
  var nd = result[0];
  var stride = result[1];
  var A_dia;

  //allocate memory for A_dia
  if(nd*stride < Math.pow(2,27) && (((stride * nd)/nnz) <= 5)){ 
    A_dia = allocate_DIA(N, nnz, nd, stride);
  }
  else{
    console.log("not efficient to store this matrix in DIA");
    return;
  }

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 

  var offset = new Int32Array(memory.buffer, A_dia.offset_index, A_dia.ndiags);
  var data = new Float32Array(memory.buffer, A_dia.data_index, A_dia.ndiags * A_dia.stride);

  var ind = new Int32Array(2*N-1);
  var i, j, k, move;
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
  return A_dia;
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

function coo_csc(A_coo, A_csc)
{
  var row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

  var csc_col = new Int32Array(memory.buffer, A_csc.col_index, A_csc.ncols + 1); 
  var csc_row = new Int32Array(memory.buffer, A_csc.row_index, A_csc.nnz); 
  var csc_val = new Float32Array(memory.buffer, A_csc.val_index, A_csc.nnz); 
  csc_row.fill(0);
  csc_col.fill(0);
  csc_val.fill(0);

  var nz = A_csc.nnz; 
  var N = A_csc.ncols;

  var j;
  for(j = 0; j < nz; j++){
    csc_col[col[j]]++; 
  }

  var i = 0, i0 = 0;
  for(j = 0; j < N; j++){
    i0 = csc_col[j];
    csc_col[j] = i;
    i += i0;
  }

  for(j = 0; j < nz; j++){
    i = csc_col[col[j]];
    csc_row[i] = row[j];
    csc_val[i] = val[j];
    csc_col[col[j]]++;
  }

  for(j = N-1; j > 0; j--){
    csc_col[j] = csc_col[j-1]; 
  }
  csc_col[0] = 0;
  csc_col[N] = nz;
  for(j = 0; j < N; j++)
    sort(csc_col[j], csc_col[j+1], csc_row, csc_val); 
}

// return A_csr
export function coo_csr(A_coo)
{
  var A_csr = allocate_CSR(A_coo.N, A_coo.nnz);

  var row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz); 
  var col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz); 
  var val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz); 

  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1); 
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz); 
  var csr_val = new Float32Array(memory.buffer, A_csr.val_index, A_csr.nnz); 
  csr_row.fill(0);
  csr_col.fill(0);
  csr_val.fill(0);
 
  var nz = A_csr.nnz; 
  var N = A_csr.N;

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

  return A_csr;
}


function sort_rows_by_nnz(A_csr)
{
  var N = A_csr.N;
  var nz = A_csr.nnz;
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1);
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
  var A_csr_new = new sparse_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, N, nz);
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

  var csr_row_new = new Int32Array(memory.buffer, A_csr_new.row_index, A_csr_new.N + 1);
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
     //csr_col_new[j] = 0;
     csr_val_new[j++] = csr_val[k++];
     temp--;
   }
  }
  //pretty_print_CSR(A_csr_new);
  return A_csr_new;
}

function sort_y_rows_by_nnz(y_view, A_csr)
{
  var N = A_csr.N;
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  var permutation = new Int32Array(memory.buffer, A_csr.permutation_index, N);

  var y_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * N);
  var y_new = new Float32Array(memory.buffer, y_index, N);

  for(i = 0; i < N; i++){
    y_new[permutation[i]] = y[i];
  }

  y_view.y_index = y_index;
}


function calculate_csr_locality_index(A_csr)
{
  var N = A_csr.N;
  var nz = A_csr.nnz;
  var csr_row = new Int32Array(memory.buffer, A_csr.row_index, A_csr.N + 1);
  var csr_col = new Int32Array(memory.buffer, A_csr.col_index, A_csr.nnz);
  var tot_num_lines = Math.floor(N/16)+1;
  console.log("total number of cache lines : ", tot_num_lines);
  var last_used = new Int32Array(tot_num_lines);
  last_used.fill(-1);
  var i, j, distance, sum = 0;
  var reuse_distance = new Int32Array(N);
  reuse_distance.fill(0);

  for(i = 0; i < N; i++){
    for(j = csr_row[i]; j < csr_row[i+1]; j++){
      if(last_used[Math.floor(csr_col[j]/16)] == -1){
        last_used[Math.floor(csr_col[j]/16)] = i;
        continue;
      }
      distance = i - last_used[Math.floor(csr_col[j]/16)];
      if(distance <= i)
        reuse_distance[distance]++;
      last_used[Math.floor(csr_col[j]/16)] = i;
    }
  }
  for(i = 0; i < 16; i++){
    sum += reuse_distance[i];
  }
  return (sum*100)/nz;
}


function spts_csc_test(A_csc, x_view, y_view)
{
  console.log("CSC");
  if(typeof A_csc === undefined){
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
  for(var i = 0; i < 10; i++){
    clear_y(y_view);
    sparse_instance.exports.spts_csc_wrapper(A_csc.col_index, A_csc.row_index, A_csc.val_index, x_view.x_index, y_view.y_index, A_csc.ncols, inner_max);
  }
  for(var i = 0; i < outer_max; i++){
    clear_y(y_view);
    t1 = Date.now();
    sparse_instance.exports.spts_csc_wrapper(A_csc.col_index, A_csc.row_index, A_csc.val_index, x_view.x_index, y_view.y_index, A_csc.ncols, inner_max);
    t2 = Date.now();
    csr_flops[i] = 1/Math.pow(10,6) * inner_max * (2 * A_csc.nnz - A_csc.ncols)/((t2 - t1)/1000);
    tt = tt + t2 - t1;
  }
  tt = tt/1000; 
  csr_mflops = 1/Math.pow(10,6) * (2 * A_csc.nnz - A_csc.ncols) * inner_max * outer_max/ tt;
  variance = 0;
  for(var i = 0; i < outer_max; i++)
    variance += (csr_mflops - csr_flops[i]) * (csr_mflops - csr_flops[i]);
  variance /= outer_max;
  csr_sd = Math.sqrt(variance);
  csr_sum = fletcher_sum_y(y_view);
  console.log('csr sum is ', csr_sum);
  console.log('csr mflops is ', csr_mflops);
  console.log('csr sd is ', csr_sd);
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
  for(var j = start; index < file.length; index++){
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
            mm_info.nnz++; 
          // two non-zeros for each non-diagonal entry
          else
            mm_info.nnz = mm_info.nnz + 2;
        }
      }
      else{
        if(mm_info.row[j] == mm_info.col[j])
          mm_info.nnz++; 
        else
          mm_info.nnz = mm_info.nnz + 2;
      } 
    }
    else{
      if(mm_info.field != "pattern"){
        mm_info.val[j] = Number(coord[2]);
         // exclude explicit zero entries
        if(mm_info.val[j] < 0 || mm_info.val[j] > 0)
          mm_info.nnz++;
      }
    }
    j++;
  }
  return j;
}

export function read_matrix_MM_files(files, num, mm_info)
{ 
  var start = 0;
  mm_info.nnz = 0;
  for(var i = 0; i < num; i++){
    var file = files[i];
    var index = 0;
    if(i == 0){
      index = read_MM_header(file, mm_info);
      if(mm_info.nentries > Math.pow(2,27)){
        console.log("entries : cannot allocate this much");
	throw new Error('entries : invalid length, cannot allocate');
      }
      mm_info.row = new Int32Array(mm_info.nentries);
      mm_info.col = new Int32Array(mm_info.nentries);
      if(mm_info.field != "pattern")
        mm_info.val = new Float64Array(mm_info.nentries);
    }
    start = calculate_actual_nnz(file, index, start, mm_info)
  }
  if(mm_info.nnz == 0){
    mm_info.nnz = mm_info.nentries;
  }
  console.log(mm_info.nnz);
  if(mm_info.nnz > Math.pow(2,28)){
    console.log("nnz : cannot allocate this much");
    throw new Error('nnz : invalid length, cannot allocate');
  }
}

function create_LCOO_from_MM(mm_info)
{
  var row = mm_info.row;
  var col = mm_info.col;
  var val = mm_info.val;
  var L_nnz = mm_info.nrows;

  if(mm_info.symmetry == "symmetric"){
    if(mm_info.field == "pattern"){
      for(var n = 0; n < mm_info.nentries; n++) {
        if(row[n] != col[n])
          L_nnz++;
      }
    }
    else{
      for(var n = 0; n < mm_info.nentries; n++) {
        if(row[n] != col[n] && (val[n] > 0 || val[n] < 0))
          L_nnz++;
      }
    }
  }
  else{
    if(mm_info.field == "pattern"){
      for(var n = 0; n < mm_info.nentries; n++) {
        if((row[n] > col[n]))
          L_nnz++;
      }
    }
    else{
      for(var n = 0; n < mm_info.nentries; n++) {
        if((row[n] > col[n]) && (val[n] > 0 || val[n] < 0))
          L_nnz++;
      }
    }
  }

  mm_info.nnz = L_nnz;
  var A_coo = allocate_COO(mm_info);
  var coo_row = new Int32Array(memory.buffer, A_coo.row_index, A_coo.nnz);
  var coo_col = new Int32Array(memory.buffer, A_coo.col_index, A_coo.nnz);
  var coo_val = new Float32Array(memory.buffer, A_coo.val_index, A_coo.nnz);
  var i = 0;

  if(mm_info.symmetry == "symmetric"){
    if(mm_info.field == "pattern"){
      for(var n = 0; n < mm_info.nentries; n++) {
        if(row[n] > col[n]){
          coo_row[i] = Number(row[n] - 1);
          coo_col[i] = Number(col[n] - 1);
          coo_val[i] = 1.0;
          i++;
        }
        else if(row[n] < col[n]){
          coo_row[i] = Number(col[n] - 1);
          coo_col[i] = Number(row[n] - 1);
          coo_val[i] = 1.0;
          i++;
        }
      }
    }
    else{
      for(var n = 0; n < mm_info.nentries; n++) {
        if(val[n] < 0 || val[n] > 0){
          if(row[n] > col[n]){
            coo_row[i] = Number(row[n] - 1);
            coo_col[i] = Number(col[n] - 1);
            coo_val[i] = Number(val[n]);
            i++;
          }
          else if(row[n] < col[n]){
            coo_row[i] = Number(col[n] - 1);
            coo_col[i] = Number(row[n] - 1);
            coo_val[i] = Number(val[n]);
            i++;
          }
        }
      }
    }
  }
  else{
    if(mm_info.field == "pattern"){
      for(n = 0; n < mm_info.nentries; n++) {
        if(row[n] > col[n]){
          coo_row[i] = Number(row[n] - 1);
          coo_col[i] = Number(col[n] - 1);
          coo_val[i] = 1.0;
          i++;
        }
      }
    }
    else{
      var count_zero = 0;
      console.log("general real");
      for(var n = 0; n < mm_info.nentries; n++) {
        if(val[n] < 0 || val[n] > 0){
          if(row[n] > col[n]){
            coo_row[i] = Number(row[n] - 1);
            if(coo_row[i] == 0)
              count_zero++;
            coo_col[i] = Number(col[n] - 1);
            coo_val[i] = Number(val[n]);
            i++;
          }
        }
      }
      console.log("read", i, mm_info.nnz, mm_info.nrows, count_zero);
    }
  }
  for(var n = 0; n < mm_info.nrows; n++){
    coo_row[i] = n;
    coo_col[i] = n;
    coo_val[i] = 1.0;
    i++;
  }
  quick_sort_COO(A_coo, 0, mm_info.nnz-1);
  return A_coo;
}


export function create_COO_from_MM(mm_info, A_coo)
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
          //if(!(Number.isSafeInteger(val[n])))
            //val[n] = 0.0
          coo_val[i] = Number(val[n]);
          if(row[n] == col[n])
            i++;
          else{
            coo_row[i+1] = Number(col[n] - 1);
            coo_col[i+1] = Number(row[n] - 1);
            //if(!(Number.isSafeInteger(val[n])))
              //val[n] = 0.0
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
          //if(!(Number.isSafeInteger(val[n])))
            //val[n] = 0.0
          coo_val[i] = Number(val[n]);
          i++;
        }
      }
    }
  }
  quick_sort_COO(A_coo, 0, mm_info.nnz-1);      
}

export function allocate_copy_COO(A_coo_in)
{
  // COO memory allocation
  var coo_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * A_coo_in.nnz);
  var coo_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * A_coo_in.nnz);
  var coo_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * A_coo_in.nnz);
  var A_coo_out = new sparse_COO_t(coo_row_index, coo_col_index, coo_val_index, A_coo_in.N, A_coo_in.nnz);
  return A_coo_out;
}

export function allocate_COO(mm_info)
{
  // COO memory allocation
  var coo_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * mm_info.nnz);
  var coo_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * mm_info.nnz);
  var coo_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * mm_info.nnz);
  var A_coo = new sparse_COO_t(coo_row_index, coo_col_index, coo_val_index, mm_info.nrows, mm_info.nnz); 
  return A_coo;
}

export function free(obj)
{
  if(typeof obj === undefined){
    console.log("free object: undefined"); 
    return;
  }

  if(obj instanceof sparse_COO_t){
    free_COO(obj);
    console.log("free object: COO"); 
  }
  else if(obj instanceof sparse_CSR_t){
    free_CSR(obj);
    console.log("free object: CSR"); 
  }
  else if(obj instanceof sparse_DIA_t){
    free_DIA(obj);
    console.log("free object: DIA"); 
  }
  else if(obj instanceof sparse_ELL_t){
    free_ELL(obj);
    console.log("free object: ELL"); 
  }
  else if(obj instanceof sparse_x_t){
    free_x(obj);
    console.log("free object: x"); 
  }
  else if(obj instanceof sparse_y_t){
    free_y(obj);
    console.log("free object: y"); 
  }
  else if(obj instanceof sparse_vec_t){
    free_vec(obj);
    console.log("free object: vec"); 
  }
}


function free_COO(A_coo)
{
  // COO memory free
  if(typeof A_coo !== undefined){
    malloc_instance.exports._free(A_coo.row_index);
    malloc_instance.exports._free(A_coo.col_index);
    malloc_instance.exports._free(A_coo.val_index);
  }
}

export function allocate_copy_CSR(A_csr_in)
{
  // CSR memory allocation
  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (A_csr_in.N + 1));
  var csr_nnz_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * A_csr_in.N);
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * A_csr_in.nnz);
  var csr_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * A_csr_in.nnz);
  var A_csr_out = new sparse_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, A_csr_in.N, A_csr_in.nnz);
  return A_csr_out;
}

export function allocate_CSR(nrows, nnz)
{
  // CSR memory allocation
  var csr_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (nrows + 1));
  var csr_nnz_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * nrows);
  var csr_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * nnz);
  var csr_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * nnz);
  var A_csr = new sparse_CSR_t(csr_row_index, csr_col_index, csr_val_index, csr_nnz_row_index, nrows, nnz);
  return A_csr;
}

function free_CSR(A_csr)
{
  // CSR memory free
  if(typeof A_csr !== undefined){
    malloc_instance.exports._free(A_csr.row_index);
    malloc_instance.exports._free(A_csr.col_index);
    malloc_instance.exports._free(A_csr.val_index);
    malloc_instance.exports._free(A_csr.nnz_row_index);
  }
}

function allocate_CSC(mm_info)
{
  // CSC memory allocation
  var csc_col_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * (mm_info.ncols + 1));
  var csc_row_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * mm_info.nnz);
  var csc_val_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * mm_info.nnz);
  var A_csc = new sparse_CSC_t(csc_col_index, csc_row_index, csc_val_index, mm_info.nrows, mm_info.nnz);
  return A_csc;
}

export function allocate_DIA(N, nnz, ndiags, stride)
{
  // DIA memory allocation
  var offset_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ndiags);
  var dia_data_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * ndiags * stride);
  var A_dia = new sparse_DIA_t(offset_index, dia_data_index, ndiags, stride, N, nnz);
  return A_dia;
}

function free_DIA(A_dia)
{
  if(typeof A_dia !== undefined){ 
    malloc_instance.exports._free(A_dia.offset_index);
    malloc_instance.exports._free(A_dia.data_index);
  }
}

export function allocate_ELL(N, nnz, ncols)
{
  // ELL memory allocation
  var indices_index = malloc_instance.exports._malloc(Int32Array.BYTES_PER_ELEMENT * ncols * N);
  var ell_data_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * ncols * N);
  var A_ell = new sparse_ELL_t(indices_index, ell_data_index, ncols, N, nnz);
  return A_ell;
}

function free_ELL(A_ell)
{
  if(typeof A_ell !== undefined){ 
    malloc_instance.exports._free(A_ell.indices_index);
    malloc_instance.exports._free(A_ell.data_index);
  }
}

export function allocate_x(N)
{
  var x_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * N);
  var x_view = new sparse_x_t(x_index, N);
  return x_view;
}

function free_x(x_view)
{
  if(typeof x_view !== undefined)
    malloc_instance.exports._free(x_view.x_index);
}

export function allocate_y(N)
{
  var y_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * N);
  var y_view = new sparse_y_t(y_index, N);
  return y_view;
}

function free_y(y_view)
{
  if(typeof y_view !== undefined)
    malloc_instance.exports._free(y_view.y_index);
}

export function allocate_vec(nelem, val = 0)
{
  var vec_index = malloc_instance.exports._malloc(Float32Array.BYTES_PER_ELEMENT * nelem);
  var vec_view = new sparse_vec_t(vec_index, nelem);
  var vec = new Float32Array(memory.buffer, vec_index, nelem);
  for(var i = 0; i < nelem; i++)
    vec[i] = val;
  return vec_view;
}

function free_vec(vec_view)
{
  if(typeof vec_view !== undefined)
    malloc_instance.exports._free(vec_view.vec_index);
}


/* Note: Since an ArrayBuffer’s byteLength is immutable, 
after a successful Memory.prototype.grow() operation the 
buffer getter will return a new ArrayBuffer object 
(with the new byteLength) and any previous ArrayBuffer 
objects become “detached”, or disconnected from the 
underlying memory they previously pointed to.*/ 


function spts_init_x(x_view){
  var x = new Float32Array(memory.buffer, x_view.x_index, x_view.x_nelem);
  for(var i = 0; i < x_view.x_nelem; i++)
    x[i] = 1.0;
}
function spts_init_y(y_view){
  var y = new Float32Array(memory.buffer, y_view.y_index, y_view.y_nelem);
  for(var i = 0; i < y_view.y_nelem; i++)
    y[i] = 1.0;
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

export var load_file = function(filename){
  return new Promise(function(resolve, reject) {
    console.log(filename);
    fetch(filename)
    .then(response => response.blob())
    .then(blob => {
      try{
        // 32MB slice size
        var limit = 32 * 1024 * 1024;
        var size = blob.size;
        console.log("size of file : ", size);
        var num = Math.ceil(size/limit);
        console.log("num of slices : ", num);
        var files = new Array(num);
        var data = "";

        load_file_slice(0);

        function load_file_slice(i){
          if(i >= num){
            return resolve([files, num]);
	  }
          var start = i * limit;
          var end = ((i+1) * limit) > size ? size : (i+1) * limit;
          console.log(start, end);
          var slice = blob.slice(start, end);
          slice.text().then(text => {
	    data = data.concat(text);
	    var last_index = data.lastIndexOf('\n');
	    var portion = data.substring(0, last_index);
	    files[i] = portion.split('\n');
	    data = data.substring(last_index + 1);
	    load_file_slice(i+1);
	  });
        }
      }
      catch(e){
        console.log('Error : ', e);
        reject(new Error(e));
      }
    });
  });
}

export async function mmread(filename)
{
  var v = await load_file(filename);
  // create an instance of sparse_MM_info object type
  var mm_info = new sparse_MM_info();
  // read matrix data from file into mm_info
  read_matrix_MM_files(v[0], v[1], mm_info);
  // allocate memory for COO format
  var A_coo = allocate_COO(mm_info);
  // fill COO with matrix data
  create_COO_from_MM(mm_info, A_coo); 
  return A_coo;
}
