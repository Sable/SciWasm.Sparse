(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f32)))
  (import "console" "log" (func $logi (param i32)))
  (func $spmv_coo (export "spmv_coo") (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $this_y i32)
    (i32.add (local.get $coo_val) (i32.shl (i32.sub (local.get $len) (i32.const 1)) (i32.const 2))) 
    local.tee $len
    local.get $coo_val
    i32.lt_s
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
        (local.tee $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
        (local.get $len)
        i32.le_s
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
    (local $j i32)
    (local $temp f32)
    (i32.add (local.get $y) (i32.shl (i32.sub (local.get $N) (i32.const 1)) (i32.const 2))) 
    local.tee $N
    local.get $y
    (i32.lt_s)
    if
      (return)
    end
    (loop $outer_loop
      (local.set $j (i32.load (local.get $csr_rowptr)))
      (local.set $csr_rowptr (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (local.get $j)
      (i32.load (local.get $csr_rowptr))
      (i32.lt_s)
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
          (local.get $csr_rowptr)
          (i32.load)
          (i32.ne)
          (br_if $inner_loop)
        )
        (local.get $y)
        (local.get $temp)
        (f32.store)
      end
      (local.tee $y (i32.add (local.get $y) (i32.const 4)))
      (local.get $N)
      (i32.le_s)     
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
    (local $new_end i32)
    (local $exp1 i32)
    (local $exp2 i32)
    (local $exp3 i32)
    (local $this_y i32)
    (local $this_x i32)
    (local $this_data i32)
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
    (i32.const 0)
    (local.set $exp2)
    (loop $outer_loop
      (i32.load (local.get $offset))
      local.set $k
      (if (result i32) (i32.lt_s (local.get $k) (i32.const 0)) 
        (then 
          (i32.sub (local.get $exp2) (local.get $exp1))
          (local.set $exp3) 
          (i32.sub (i32.const 0)(local.get $k))
        )
        (else
          i32.const 0 
        )
      ) 
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then 
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      ) 
      (local.set $iend)
      (local.get $iend)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $y) (i32.shl (local.get $n) (i32.const 2)))
      (local.set $this_y)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (i32.add (local.get $x) (i32.shl (i32.add (local.get $n) (local.get $k)) (i32.const 2)))
      (local.set $this_x)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
      (loop $inner_loop
        (local.get $this_y)
        (local.get $this_data)
        f32.load 
        (local.get $this_x)
        f32.load 
        f32.mul
        (f32.load (local.get $this_y))
        f32.add
        f32.store
        (local.set $this_y (i32.add (local.get $this_y) (i32.const 4)))
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (local.set $this_x (i32.add (local.get $this_x) (i32.const 4)))
        (local.tee $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $new_end) 
        (i32.lt_s)
        (br_if $inner_loop)
      )))
      (local.get $new_end)
      (local.get $iend)
      (i32.lt_s)
      (if
        (then 
      (loop $inner_loop1
        (local.get $this_y)
        (local.get $this_data)
        (v128.load)
        (local.get $this_x)
        (v128.load)
        (f32x4.mul)
        (v128.load (local.get $this_y))
        (f32x4.add)
        (v128.store)
        (local.set $this_y (i32.add (local.get $this_y) (i32.const 16)))
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
        (local.set $this_x (i32.add (local.get $this_x) (i32.const 16)))
        (local.tee $n (i32.add (local.get $n) (i32.const 4)))
        (local.get $iend) 
        (i32.lt_s)
        (br_if $inner_loop1)
      )
      )
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3) 
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
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
    (local $this_y i32)
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
      (i32.shl (local.get $exp1) (i32.const 2))
      (local.set $exp2)
      i32.const 0
      local.set $i
      (local.set $this_y (local.get $y))
      (loop $inner_loop
        (local.get $this_y)
        (i32.add (local.get $data) (local.get $exp2))
        f32.load
        (i32.add (local.get $x) (i32.shl (i32.load (i32.add (local.get $indices) (local.get $exp2))) (i32.const 2)))
        f32.load
        f32.mul
        (local.get $this_y)
        f32.load
        f32.add
        f32.store
        (i32.add (local.get $exp2) (i32.const 4))
        (local.set $exp2)
        (set_local $this_y (i32.add (local.get $this_y) (i32.const 4)))
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

