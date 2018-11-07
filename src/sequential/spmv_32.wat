(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f32)))
  (import "console" "log" (func $logi (param i32)))
  (func $spmv_coo (export "spmv_coo") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    i32.const 0
    set_local $i
    (block $break (loop $top
      (br_if $break (i32.eq (get_local $i) (get_local $len)))        
        (i32.add (get_local $y) (i32.mul (i32.load (get_local $coo_row)) (i32.const 4))) 
        (f32.load (get_local $coo_val))
        (i32.add (get_local $x) (i32.mul (i32.load (get_local $coo_col)) (i32.const 4)))
        f32.load 
        f32.mul 
        (f32.load (i32.add (get_local $y) (i32.mul (i32.load (get_local $coo_row)) (i32.const 4)))) 
        f32.add
        f32.store
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (set_local $coo_row (i32.add (get_local $coo_row) (i32.const 4)))
        (set_local $coo_col (i32.add (get_local $coo_col) (i32.const 4)))
        (set_local $coo_val (i32.add (get_local $coo_val) (i32.const 4)))
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
    (local $temp f32)
    (i32.const 0)
    (set_local $i)
    (block $outer (loop $outer_loop
      (br_if $outer (i32.eq (get_local $i) (get_local $N)))        
      (get_local $y)
      (f32.load (get_local $y))
      (set_local $temp)
      (i32.load (get_local $csr_rowptr)) 
      (set_local $j)
      (block $inner (loop $inner_loop
        (br_if $inner (i32.eq (get_local $j) (i32.load (i32.add (get_local $csr_rowptr) (i32.const 4)))))
        (f32.load (get_local $csr_val))
        (i32.add (get_local $x) (i32.mul (i32.load (get_local $csr_col)) (i32.const 4)))
        f32.load 
        f32.mul 
        (get_local $temp)
        f32.add
        (set_local $temp)
        (set_local $j (i32.add (get_local $j) (i32.const 1)))
        (set_local $csr_col (i32.add (get_local $csr_col) (i32.const 4)))
        (set_local $csr_val (i32.add (get_local $csr_val) (i32.const 4)))
        (br $inner_loop)
      ))
      (get_local $temp)
      f32.store
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (set_local $csr_rowptr (i32.add (get_local $csr_rowptr) (i32.const 4)))
      (set_local $y (i32.add (get_local $y) (i32.const 4)))
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
)
