(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f64)))
  (import "console" "log" (func $logi (param i32)))
  (func $spmv_coo (export "spmv_coo") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $len)))        
        (i32.add (get_local $y) (i32.mul (i32.load (get_local $coo_row)) (i32.const 8))) 
        (f64.load (get_local $coo_val))
        (i32.add (get_local $x) (i32.mul (i32.load (get_local $coo_col)) (i32.const 8)))
        f64.load 
        f64.mul 
        (f64.load (i32.add (get_local $y) (i32.mul (i32.load (get_local $coo_row)) (i32.const 8)))) 
        f64.add
        f64.store
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (set_local $coo_row (i32.add (get_local $coo_row) (i32.const 4)))
        (set_local $coo_col (i32.add (get_local $coo_col) (i32.const 4)))
        (set_local $coo_val (i32.add (get_local $coo_val) (i32.const 8)))
        (br $top)
    ))
  )
  (func (export "spmv_coo_wrapper") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))        
      get_local $coo_row
      get_local $coo_col
      get_local $coo_val
      get_local $x
      get_local $y
      get_local $len
      call $spmv_coo
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )

  (func $spmv_csr (export "spmv_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $temp f64)
    (i32.const 0)
    (set_local $i)
    (block $outer (loop $outer_loop
      (br_if $outer (i32.eq (get_local $i) (get_local $N)))        
      (get_local $y)
      (f64.load (get_local $y))
      (set_local $temp)
      (i32.load (get_local $csr_rowptr)) 
      (set_local $j)
      (block $inner (loop $inner_loop
        (br_if $inner (i32.eq (get_local $j) (i32.load (i32.add (get_local $csr_rowptr) (i32.const 4)))))
        (f64.load (get_local $csr_val))
        (i32.add (get_local $x) (i32.mul (i32.load (get_local $csr_col)) (i32.const 8)))
        f64.load 
        f64.mul 
        (get_local $temp)
        f64.add
        (set_local $temp)
        (set_local $j (i32.add (get_local $j) (i32.const 1)))
        (set_local $csr_col (i32.add (get_local $csr_col) (i32.const 4)))
        (set_local $csr_val (i32.add (get_local $csr_val) (i32.const 8)))
        (br $inner_loop)
      ))
      (get_local $temp)
      f64.store
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (set_local $csr_rowptr (i32.add (get_local $csr_rowptr) (i32.const 4)))
      (set_local $y (i32.add (get_local $y) (i32.const 8)))
      (br $outer_loop)
    ))
  )
  (func (export "spmv_csr_wrapper") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $N i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))        
      get_local $csr_rowptr
      get_local $csr_col
      get_local $csr_val
      get_local $x
      get_local $y
      get_local $N
      call $spmv_csr
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )


  (func $spmv_dia (export "spmv_dia") (param $offset i32) (param $data i32) (param $N i32) (param $nd i32) (param $stride i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $istart i32)
    (local $iend i32)
    (local $index i32)
    i32.const 0
    set_local $i
    (block $outer (loop $outer_loop
      (br_if $outer (i32.eq (get_local $i) (get_local $nd)))        
      (i32.load (get_local $offset))
      set_local $k
      i32.const 0
      set_local $index
      (if (result i32) (i32.lt_s (i32.const 0) (i32.sub (i32.const 0)(get_local $k))) 
        (then 
          get_local $N
          get_local $stride
          i32.sub
          set_local $index
          (i32.sub (i32.const 0)(get_local $k))
        )
        (else
          i32.const 0 
        )
      ) 
      (set_local $istart)
      (if (result i32) (i32.lt_s (i32.sub (get_local $N) (i32.const 1)) (i32.sub (i32.sub (get_local $N) (get_local $k)) (i32.const 1)))
        (then 
          (i32.sub (get_local $N) (i32.const 1))
        )
        (else
          (i32.sub (i32.sub (get_local $N) (get_local $k)) (i32.const 1))
        )
      ) 
      (set_local $iend)
      get_local $istart
      set_local $n
      (block $inner (loop $inner_loop
        (br_if $inner (i32.gt_s (get_local $n) (get_local $iend)))
        (i32.add (get_local $y) (i32.mul (get_local $n) (i32.const 8)))
        (i32.add (get_local $data) (i32.mul (i32.sub (i32.add (i32.mul (get_local $i) (get_local $stride)) (get_local $n)) (get_local $index)) (i32.const 8)))
        f64.load 
        (i32.add (get_local $x) (i32.mul (i32.add (get_local $n) (get_local $k)) (i32.const 8)))
        f64.load 
        f64.mul
        (f64.load (i32.add (get_local $y) (i32.mul (get_local $n) (i32.const 8))))
        f64.add
        f64.store
        (set_local $n (i32.add (get_local $n) (i32.const 1)))
        (br $inner_loop)
      ))
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (set_local $offset (i32.add (get_local $offset) (i32.const 4)))
      (br $outer_loop)
    ))
  )

  (func (export "spmv_dia_wrapper") (param $offset i32) (param $data i32) (param $N i32) (param $nd i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $offset
      get_local $data
      get_local $N
      get_local $nd
      get_local $stride
      get_local $x
      get_local $y
      call $spmv_dia
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )
  (func $spmv_ell (export "spmv_ell") (param $indices i32) (param $data i32) (param $N i32) (param $nc i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $j i32)
    i32.const 0
    set_local $j
    (block $outer (loop $outer_loop
      (br_if $outer (i32.eq (get_local $j) (get_local $nc)))
      i32.const 0
      set_local $i
      (block $inner (loop $inner_loop
        (br_if $inner (i32.eq (get_local $i) (get_local $N)))
        (i32.add (get_local $y) (i32.mul (get_local $i) (i32.const 8)))
        (i32.add (get_local $data) (i32.mul (i32.add (i32.mul (get_local $j) (get_local $N)) (get_local $i)) (i32.const 8)))
        f64.load
        (i32.add (get_local $x) (i32.mul (i32.load (i32.add (get_local $indices) (i32.mul (i32.add (i32.mul (get_local $j) (get_local $N)) (get_local $i)) (i32.const 4)))) (i32.const 8)))
        f64.load
        f64.mul
        (i32.add (get_local $y) (i32.mul (get_local $i) (i32.const 8)))
        f64.load
        f64.add
        f64.store
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (br $inner_loop)
      ))
      (set_local $j (i32.add (get_local $j) (i32.const 1)))
      (br $outer_loop)
    ))
  )    
   
        
  (func (export "spmv_ell_wrapper") (param $indices i32) (param $data i32) (param $N i32) (param $nc i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $inside_max)))
      get_local $indices
      get_local $data
      get_local $N
      get_local $nc
      get_local $x
      get_local $y
      call $spmv_ell
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $top)
    ))
  )    
)

