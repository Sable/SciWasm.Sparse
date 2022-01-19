(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f32)))
  (import "console" "log" (func $logi (param i32)))

  (func $spts_csc (export "spts_csc") (param $csc_colptr i32) (param $csc_row i32) (param $csc_val i32) (param $x i32) (param $y i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $temp_y i32)
    (local $end i32)
    (local $temp f32)
    (local.get $N)
    (i32.const 0)
    (tee_local $j)
    (i32.le_s)
    if
      (return)
    end
    (local.get $y)
    (local.set $temp_y)
    (loop $copy_x_to_y 
      (local.get $temp_y)
      (f32.load (local.get $x))
      (f32.store)
      (local.set $x (i32.add (local.get $x) (i32.const 4)))
      (local.set $temp_y (i32.add (local.get $temp_y) (i32.const 4)))
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $N)
      (i32.ne)
      (br_if $copy_x_to_y)
    )
    (i32.const 0)
    (local.set $j)
    (loop $outer_loop
      (local.get $y)
      (f32.load (local.get $y))
      (f32.load (local.get $csc_val))
      (f32.div)
      (f32.store)
      (local.set $csc_val (i32.add (local.get $csc_val) (i32.const 4)))
      (local.set $csc_row (i32.add (local.get $csc_row) (i32.const 4)))
      (i32.add (local.get $csc_colptr) (i32.const 4))
      (i32.load)
      (tee_local $end)
      (i32.add (i32.load (local.get $csc_colptr)) (i32.const 1))
      (tee_local $i)
      (i32.gt_s)
      if
        (loop $inner_loop
          (i32.add (local.get $y) (i32.shl (i32.sub (i32.load(local.get $csc_row)) (local.get $j)) (i32.const 2)))
          (i32.add (local.get $y) (i32.shl (i32.sub (i32.load(local.get $csc_row)) (local.get $j)) (i32.const 2)))
          (f32.load)
          (f32.load (local.get $csc_val))
          (f32.load (local.get $y))
          (f32.mul)
          (f32.sub)
          (f32.store)
          (local.set $csc_row (i32.add (local.get $csc_row) (i32.const 4)))
          (local.set $csc_val (i32.add (local.get $csc_val) (i32.const 4)))
          (tee_local $i (i32.add (local.get $i) (i32.const 1)))
          (local.get $end)
          (i32.ne)
          (br_if $inner_loop)
        )
      end
      (local.set $y (i32.add (local.get $y) (i32.const 4)))
      (i32.add (local.get $csc_colptr) (i32.const 4))
      (local.set $csc_colptr)
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $N)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "spts_csc_wrapper") (param $csc_col i32) (param $csc_row i32) (param $csc_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inner_max i32)
    (local $i i32)
    (local.get $inner_max)
    i32.const 0
    tee_local $i
    i32.le_s
    if
      (return)
    end
    (loop $top
      local.get $csc_col
      local.get $csc_row
      local.get $csc_val
      local.get $x
      local.get $y
      local.get $len
      call $spts_csc
      (local.get $inner_max)
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (i32.ne)
      (br_if $top)
    )
  )

  (func $spmv_coo (export "spmv_coo") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $this_y i32)
    local.get $len
    i32.const 0
    tee_local $i
    i32.le_s
    if
      (return) 
    end
    (loop $top
        (i32.add (local.get $y) (i32.shl (i32.load (local.get $coo_row)) (i32.const 2))) 
        (tee_local $this_y)
        (f32.load (local.get $coo_val))
        (i32.add (local.get $x) (i32.shl (i32.load (local.get $coo_col)) (i32.const 2)))
        f32.load 
        f32.mul 
        (local.get $this_y)
        f32.load
        f32.add
        f32.store
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $len)
        i32.ne
        br_if $top      
    )
  )
  (func (export "spmv_coo_wrapper") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32) (param $inner_max i32)
    (local $i i32)
    (local.get $inner_max)
    i32.const 0
    tee_local $i
    i32.le_s
    if
      (return)
    end
    (loop $top
      local.get $coo_row
      local.get $coo_col
      local.get $coo_val
      local.get $x
      local.get $y
      local.get $len
      call $spmv_coo
      (local.get $inner_max)
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (i32.ne)
      (br_if $top)
    )
  )

  (func $spmv_csr (export "spmv_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $temp f32)
    (local $end i32)
    (local.get $N)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $outer_loop
      (i32.add (local.get $csr_rowptr) (i32.const 4))
      (i32.load)
      (tee_local $end)
      (i32.load (local.get $csr_rowptr)) 
      (tee_local $j)
      (i32.gt_s)
      if
        (f32.load (local.get $y))
        (local.set $temp)
        (loop $inner_loop
          (f32.load (local.get $csr_val))
          (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2)))
          (f32.load) 
          (f32.mul) 
          (local.get $temp)
          (f32.add)
          (local.set $temp)
          (local.set $csr_col (i32.add (local.get $csr_col) (i32.const 4)))
          (local.set $csr_val (i32.add (local.get $csr_val) (i32.const 4)))
          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $end)
          (i32.ne)
          (br_if $inner_loop)
        )
        (local.get $y)
        (local.get $temp)
        (f32.store)
      end
      (local.set $y (i32.add (local.get $y) (i32.const 4)))
      (i32.add (local.get $csr_rowptr) (i32.const 4))
      (local.set $csr_rowptr)
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $N)
      (i32.ne)     
      (br_if $outer_loop)
    )
  )
  (func (export "spmv_csr_wrapper") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $N i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))        
      local.get $csr_rowptr
      local.get $csr_col
      local.get $csr_val
      local.get $x
      local.get $y
      local.get $N
      call $spmv_csr
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
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
    (local $exp4 i32)
    (local.get $nd)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)
    (local.get $N)
    (i32.const 1)
    (i32.sub)
    (local.set $exp2)
    (i32.const 0)
    (local.set $exp3)
    (loop $outer_loop
      (i32.load (local.get $offset))
      local.set $k
      i32.const 0
      local.set $index
      (if (result i32) (i32.lt_s (local.get $k) (i32.const 0)) 
        (then 
          local.get $exp1
          local.set $index
          (i32.sub (i32.const 0)(local.get $k))
        )
        (else
          i32.const 0 
        )
      ) 
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $exp2) (i32.sub (local.get $exp2) (local.get $k)))
        (then 
          (local.get $exp2)
        )
        (else
          (i32.sub (local.get $exp2) (local.get $k))
        )
      ) 
      (local.set $iend)
      (i32.sub (local.get $exp3) (local.get $index))
      (local.set $exp4) 
      (loop $inner_loop
        (i32.add (local.get $y) (i32.shl (local.get $n) (i32.const 2)))
        (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp4) (local.get $n)) (i32.const 2)))
        f32.load 
        (i32.add (local.get $x) (i32.shl (i32.add (local.get $n) (local.get $k)) (i32.const 2)))
        f32.load 
        f32.mul
        (f32.load (i32.add (local.get $y) (i32.shl (local.get $n) (i32.const 2))))
        f32.add
        f32.store
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $iend) 
        (i32.le_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp3) (local.get $stride))
      (local.set $exp3)
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nd)
      (i32.ne)     
      (br_if $outer_loop)
    )
  )

  (func (export "spmv_dia_wrapper") (param $offset i32) (param $data i32) (param $N i32) (param $nd i32) (param $stride i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $offset
      local.get $data
      local.get $N
      local.get $nd
      local.get $stride
      local.get $x
      local.get $y
      call $spmv_dia
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )
  (func $spmv_ell (export "spmv_ell") (param $indices i32) (param $data i32) (param $N i32) (param $nc i32) (param $x i32) (param $y i32)
    (local $i i32)
    (local $j i32)
    (local $exp1 i32) ;; j * N
    (local $exp2 i32) ;; j * N + i
    (local.get $nc)
    i32.const 0
    tee_local $j
    i32.gt_s
    (local.get $N)
    i32.const 0
    i32.gt_s 
    i32.and
    i32.eqz
    if
      (return)
    end
    (i32.const 0)
    (local.set $exp1)
    (loop $outer_loop
      i32.const 0
      local.set $i
      (i32.shl (local.get $exp1) (i32.const 2))
      (local.set $exp2)
      (loop $inner_loop
        (i32.add (local.get $y) (i32.shl (local.get $i) (i32.const 2)))
        (i32.add (local.get $data) (local.get $exp2))
        f32.load
        (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (local.get $exp2))) (i32.const 2)))
        f32.load
        f32.mul
        (i32.add (local.get $y) (i32.shl (local.get $i) (i32.const 2)))
        f32.load
        f32.add
        f32.store
        (i32.add (local.get $exp2) (i32.const 4))
        (local.set $exp2)
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne) 
        (br_if $inner_loop)
      )
      (i32.add (local.get $exp1) (local.get $N))
      (local.set $exp1)
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $nc)
      (i32.ne) 
      (br_if $outer_loop)
    )
  )    
   
        
  (func (export "spmv_ell_wrapper") (param $indices i32) (param $data i32) (param $N i32) (param $nc i32) (param $x i32) (param $y i32) (param $inside_max i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (block $break (loop $top
      (br_if $break (i32.eq (local.get $i) (local.get $inside_max)))
      local.get $indices
      local.get $data
      local.get $N
      local.get $nc
      local.get $x
      local.get $y
      call $spmv_ell
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (br $top)
    ))
  )    
)

