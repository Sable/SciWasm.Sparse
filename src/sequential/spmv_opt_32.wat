(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f32)))
  (import "console" "log" (func $logi (param i32)))
  (func $spmv_coo (export "spmv_coo") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $this_y i32)
    get_local $len
    i32.const 0
    tee_local $i
    i32.le_s
    if
      return 
    end
    (loop $top
        (i32.add (get_local $y) (i32.shl (i32.load (get_local $coo_row)) (i32.const 2))) 
        (tee_local $this_y)
        (f32.load (get_local $coo_val))
        (i32.add (get_local $x) (i32.shl (i32.load (get_local $coo_col)) (i32.const 2)))
        f32.load 
        f32.mul 
        (get_local $this_y)
        f32.load
        f32.add
        f32.store
        (set_local $coo_row (i32.add (get_local $coo_row) (i32.const 4)))
        (set_local $coo_col (i32.add (get_local $coo_col) (i32.const 4)))
        (set_local $coo_val (i32.add (get_local $coo_val) (i32.const 4)))
        (tee_local $i (i32.add (get_local $i) (i32.const 1)))
        (get_local $len)
        i32.ne
        br_if $top      
    )
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
    (local $end i32)
    (get_local $N)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $outer_loop
      (i32.load (i32.add (get_local $csr_rowptr) (i32.const 4)))
      (tee_local $end)
      (i32.load (get_local $csr_rowptr)) 
      (tee_local $j)
      (i32.le_s)
      if
        (set_local $y (i32.add (get_local $y) (i32.const 4)))
        (set_local $csr_rowptr (i32.add (get_local $csr_rowptr) (i32.const 4)))
        (tee_local $i (i32.add (get_local $i) (i32.const 1)))
        (get_local $N)
        (i32.ne)     
        (br_if $outer_loop) 
      end
      (f32.load (get_local $y))
      (set_local $temp)
      (loop $inner_loop
        (f32.load (get_local $csr_val))
        (i32.add (get_local $x) (i32.shl (i32.load (get_local $csr_col)) (i32.const 2)))
        (f32.load) 
        (f32.mul) 
        (get_local $temp)
        (f32.add)
        (set_local $temp)
        (set_local $csr_col (i32.add (get_local $csr_col) (i32.const 4)))
        (set_local $csr_val (i32.add (get_local $csr_val) (i32.const 4)))
        (tee_local $j (i32.add (get_local $j) (i32.const 1)))
        (get_local $end)
        (i32.ne)
        (br_if $inner_loop)
      )
      (get_local $y)
      (get_local $temp)
      (f32.store)
      (set_local $y (i32.add (get_local $y) (i32.const 4)))
      (set_local $csr_rowptr (i32.add (get_local $csr_rowptr) (i32.const 4)))
      (tee_local $i (i32.add (get_local $i) (i32.const 1)))
      (get_local $N)
      (i32.ne)     
      (br_if $outer_loop)
    )
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
    (local $iend i32)
    (local $index i32)
    (local $exp1 i32)
    (local $exp2 i32)
    (local $exp3 i32)
    (get_local $nd)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
    (get_local $N)
    (get_local $stride)
    (i32.sub)
    (set_local $exp1)
    (get_local $N)
    (i32.const 1)
    (i32.sub)
    (set_local $exp2)
    (loop $outer_loop
      (i32.load (get_local $offset))
      set_local $k
      i32.const 0
      set_local $index
      (if (result i32) (i32.lt_s (get_local $k) (i32.const 0)) 
        (then 
          get_local $exp1
          set_local $index
          (i32.sub (i32.const 0)(get_local $k))
        )
        (else
          i32.const 0 
        )
      ) 
      (set_local $n)
      (if (result i32) (i32.lt_s (get_local $exp2) (i32.sub (get_local $exp2) (get_local $k)))
        (then 
          (get_local $exp2)
        )
        (else
          (i32.sub (get_local $exp2) (get_local $k))
        )
      ) 
      (set_local $iend)
      (i32.sub (i32.mul (get_local $i) (get_local $stride)) (get_local $index))
      (set_local $exp3) 
      (loop $inner_loop
        (i32.add (get_local $y) (i32.mul (get_local $n) (i32.const 4)))
        (i32.add (get_local $data) (i32.shl (i32.add (get_local $exp3) (get_local $n)) (i32.const 2)))
        f32.load 
        (i32.add (get_local $x) (i32.shl (i32.add (get_local $n) (get_local $k)) (i32.const 2)))
        f32.load 
        f32.mul
        (f32.load (i32.add (get_local $y) (i32.shl (get_local $n) (i32.const 2))))
        f32.add
        f32.store
        (tee_local $n (i32.add (get_local $n) (i32.const 1)))
        (get_local $iend) 
        (i32.le_s)
        (br_if $inner_loop)
      )
      (set_local $offset (i32.add (get_local $offset) (i32.const 4)))
      (tee_local $i (i32.add (get_local $i) (i32.const 1)))
      (get_local $nd)
      (i32.ne)     
      (br_if $outer_loop)
    )
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
        (i32.add (get_local $y) (i32.mul (get_local $i) (i32.const 4)))
        (i32.add (get_local $data) (i32.mul (i32.add (i32.mul (get_local $j) (get_local $N)) (get_local $i)) (i32.const 4)))
        f32.load
        (i32.add (get_local $x) (i32.mul (i32.load (i32.add (get_local $indices) (i32.mul (i32.add (i32.mul (get_local $j) (get_local $N)) (get_local $i)) (i32.const 4)))) (i32.const 4)))
        f32.load
        f32.mul
        (i32.add (get_local $y) (i32.mul (get_local $i) (i32.const 4)))
        f32.load
        f32.add
        f32.store
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

