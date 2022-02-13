(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f32)))
  (import "console" "log" (func $logi (param i32)))
  (import "math" "expm1" (func $expm1f (param f32) (result f32)))
  (import "math" "log1p" (func $log1pf (param f32) (result f32)))
  (import "math" "sin" (func $sinf (param f32) (result f32)))
  (import "math" "tan" (func $tanf (param f32) (result f32)))
  (import "math" "pow" (func $powf (param f32) (param f32) (result f32)))

  (func $spts_csc (export "spts_csc") (param $csc_colptr i32) (param $csc_row i32) (param $csc_val i32) (param $x i32) (param $y i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $temp_y i32)
    (local $temp f32)
    (local $end i32)
    (local $y_index v128)
    (local $temp_v v128)
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
    (local.get $y)
    (local.set $temp_y)
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
        (local.get $end)
	(local.get $i)
	(i32.sub)
	(i32.const 4)
	(i32.rem_u)
	(tee_local $k)
	(i32.const 0)
	(i32.gt_s)
	if
          (loop $inner_loop
            (i32.add (local.get $temp_y) (i32.shl (i32.load(local.get $csc_row)) (i32.const 2)))
            (i32.add (local.get $temp_y) (i32.shl (i32.load(local.get $csc_row)) (i32.const 2)))
            (f32.load)
            (f32.load (local.get $csc_val))
            (f32.load (local.get $y))
            (f32.mul)
            (f32.sub)
            (f32.store)
            (local.set $csc_row (i32.add (local.get $csc_row) (i32.const 4)))
            (local.set $csc_val (i32.add (local.get $csc_val) (i32.const 4)))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            (tee_local $k (i32.sub (local.get $k) (i32.const 1)))
            (i32.const 0)
            (i32.ne)
            (br_if $inner_loop)
          )
        end
        (local.get $end)
	(local.get $i)
        (i32.gt_s)
	if
          (loop $vector_inner_loop
            (i32x4.splat(local.get $temp_y))
            (v128.load (local.get $csc_row))
	    (i32.const 2)
	    (i32x4.shl)
	    (i32x4.add)
	    (local.set $y_index)

            (f32x4.replace_lane 3
              (f32x4.replace_lane 2
                (f32x4.replace_lane 1
                  (f32x4.replace_lane 0
                    (f32x4.splat(f32.const 0.0))
                    (f32.load (i32x4.extract_lane 0 (local.get $y_index)))
                  )
                  (f32.load (i32x4.extract_lane 1 (local.get $y_index)))
                )
                (f32.load (i32x4.extract_lane 2 (local.get $y_index)))
              )
              (f32.load (i32x4.extract_lane 3 (local.get $y_index)))
            )

            (v128.load (local.get $csc_val))
            (f32x4.splat (f32.load (local.get $y)))
            (f32x4.mul)
            (f32x4.sub)
	    (local.set $temp_v)

	    (i32x4.extract_lane 0 (local.get $y_index))
	    (f32x4.extract_lane 0 (local.get $temp_v))
            (f32.store)
	    (i32x4.extract_lane 1 (local.get $y_index))
	    (f32x4.extract_lane 1 (local.get $temp_v))
            (f32.store)
	    (i32x4.extract_lane 2 (local.get $y_index))
	    (f32x4.extract_lane 2 (local.get $temp_v))
            (f32.store)
	    (i32x4.extract_lane 3 (local.get $y_index))
	    (f32x4.extract_lane 3 (local.get $temp_v))
            (f32.store)

            (local.set $csc_row (i32.add (local.get $csc_row) (i32.const 16)))
            (local.set $csc_val (i32.add (local.get $csc_val) (i32.const 16)))
            (tee_local $i (i32.add (local.get $i) (i32.const 4)))
            (local.get $end)
            (i32.lt_s)
            (br_if $vector_inner_loop)
          )
	end
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
      )))
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

  (func (export "count_nonzeros_coo") (param $val i32) (param $nnz i32) (result i32)
    (local $i i32)
    (local $count i32)
    i32.const 0
    local.set $i
    (i32.const 0)
    (local.set $count)
    (loop $loop
      (if (i32.or (f32.gt (f32.load (local.get $val)) (f32.const 0.0)) (f32.lt (f32.load (local.get $val)) (f32.const 0.0)))
        (then
          (local.set $count (i32.add (local.get $count) (i32.const 1)))
	)
      )
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
    (local.get $count)
    (return)
  )

  (func (export "copy_nonzeros_coo") (param $in_row i32) (param $in_col i32) (param $in_val i32) (param $out_row i32) (param $out_col i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (if (i32.or (f32.gt (f32.load (local.get $in_val)) (f32.const 0.0)) (f32.lt (f32.load (local.get $in_val)) (f32.const 0.0)))
        (then
          (f32.store (local.get $out_row) (f32.load (local.get $in_row)))
          (f32.store (local.get $out_col) (f32.load (local.get $in_col)))
          (f32.store (local.get $out_val) (f32.load (local.get $in_val)))
          (local.set $out_row (i32.add (local.get $out_row) (i32.const 4)))
          (local.set $out_col (i32.add (local.get $out_col) (i32.const 4)))
          (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        )
      )
      (local.set $in_row (i32.add (local.get $in_row) (i32.const 4)))
      (local.set $in_col (i32.add (local.get $in_col) (i32.const 4)))
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  ) 

  (func (export "self_expm1_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $val)
      (f32.load (local.get $val))
      (call $expm1f)
      (f32.store)
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_log1p_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $val)
      (f32.load (local.get $val))
      (call $log1pf)
      (f32.store)
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_sin_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $val)
      (f32.load (local.get $val))
      (call $sinf)
      (f32.store)
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_tan_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $val)
      (f32.load (local.get $val))
      (call $tanf)
      (f32.store)
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_pow_coo") (param $p f32) (param $val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $val)
      (f32.load (local.get $val))
      (local.get $p)
      (call $powf)
      (f32.store)
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "self_deg2rad_coo") (param $pi f32) (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    (local $pi_on_180 f32)
    i32.const 0
    local.set $i
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then 
      (loop $loop
        (local.get $val)
        (f32.load (local.get $val))
        (local.get $pi_on_180)
        (f32.mul)
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then 
      (loop $vector_loop
        (local.get $val)
        (v128.load (local.get $val))
        (f32x4.splat (local.get $pi_on_180))
        (f32x4.mul)
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )


  (func (export "self_rad2deg_coo") (param $pi f32) (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    (local $pi_on_180 f32)
    i32.const 0
    local.set $i
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then 
      (loop $loop
        (local.get $val)
        (f32.load (local.get $val))
        (local.get $pi_on_180)
        (f32.div)
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then 
      (loop $vector_loop
        (local.get $val)
        (v128.load (local.get $val))
        (f32x4.splat (local.get $pi_on_180))
        (f32x4.div)
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_multiply_scalar_coo") (param $scalar f32) (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then 
      (loop $loop
        (local.get $val)
        (f32.load (local.get $val))
        (local.get $scalar)
        (f32.mul)
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then 
      (loop $vector_loop
        (local.get $val)
        (v128.load (local.get $val))
        (f32x4.splat (local.get $scalar))
        (f32x4.mul)
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_abs_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then 
      (loop $loop
        (local.get $val)
        (f32.abs (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then 
      (loop $vector_loop
        (local.get $val)
        (f32x4.abs (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_neg_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f32.neg (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f32x4.neg (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_sqrt_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f32.sqrt (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f32x4.sqrt (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_ceil_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f32.ceil (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f32x4.ceil (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )


  (func (export "self_floor_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f32.floor (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f32x4.floor (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_trunc_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f32.trunc (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f32x4.trunc (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_nearest_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $val)
        (f32.nearest (f32.load (local.get $val)))
        (f32.store)
        (local.set $val (i32.add (local.get $val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $val)
        (f32x4.nearest (v128.load (local.get $val)))
        (v128.store)
        (local.set $val (i32.add (local.get $val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "self_sign_coo") (param $val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $val)
      (if (result f32) (f32.gt (f32.load (local.get $val)) (f32.const 0.0))
        (then
	(f32.const 1)
	)
	(else
	(f32.const -1)
	)
      )
      (f32.store)
      (local.set $val (i32.add (local.get $val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "sign_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $out_val)
      (if (result f32) (f32.gt (f32.load (local.get $in_val)) (f32.const 0.0))
        (then
	(f32.const 1)
	)
	(else
	(f32.const -1)
	)
      )
      (f32.store)
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )
  
  (func (export "expm1_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $out_val)
      (f32.load (local.get $in_val))
      (call $expm1f)
      (f32.store)
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "log1p_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $out_val)
      (f32.load (local.get $in_val))
      (call $log1pf)
      (f32.store)
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "sin_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $out_val)
      (f32.load (local.get $in_val))
      (call $sinf)
      (f32.store)
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "tan_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $out_val)
      (f32.load (local.get $in_val))
      (call $tanf)
      (f32.store)
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "pow_coo") (param $p f32) (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    i32.const 0
    local.set $i
    (loop $loop
      (local.get $out_val)
      (f32.load (local.get $in_val))
      (local.get $p)
      (call $powf)
      (f32.store)
      (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
      (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nnz)
      (i32.ne)
      (br_if $loop)
    )
  )

  (func (export "deg2rad_coo") (param $pi f32) (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    (local $pi_on_180 f32)
    i32.const 0
    local.set $i
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.load (local.get $in_val))
        (local.get $pi_on_180)
        (f32.mul)
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (v128.load (local.get $in_val))
        (f32x4.splat (local.get $pi_on_180))
        (f32x4.mul)
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "rad2deg_coo") (param $pi f32) (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    (local $pi_on_180 f32)
    i32.const 0
    local.set $i
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.load (local.get $in_val))
        (local.get $pi_on_180)
        (f32.div)
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (v128.load (local.get $in_val))
        (f32x4.splat (local.get $pi_on_180))
        (f32x4.div)
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )


  (func (export "abs_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.abs (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.abs (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "neg_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.neg (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.neg (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "sqrt_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.sqrt (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.sqrt (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "ceil_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.ceil (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.ceil (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "floor_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.floor (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.floor (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "trunc_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.trunc (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.trunc (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "nearest_coo") (param $in_val i32) (param $out_val i32) (param $nnz i32)
    (local $i i32)
    (local $rem i32)
    i32.const 0
    local.set $i
    (local.get $nnz)
    (i32.const 4)
    (i32.rem_u)
    (local.set $rem)
    (local.get $i)
    (local.get $rem)
    (i32.lt_s)
    (if
    (then
      (loop $loop
        (local.get $out_val)
        (f32.nearest (f32.load (local.get $in_val)))
        (f32.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 4)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $rem)
        (i32.ne)
        (br_if $loop)
      )
    ))
    (local.get $i)
    (local.get $nnz)
    (i32.lt_s)
    (if
    (then
      (loop $vector_loop
        (local.get $out_val)
        (f32x4.nearest (v128.load (local.get $in_val)))
        (v128.store)
        (local.set $in_val (i32.add (local.get $in_val) (i32.const 16)))
        (local.set $out_val (i32.add (local.get $out_val) (i32.const 16)))
        (tee_local $i (i32.add (local.get $i) (i32.const 4)))
        (local.get $nnz)
        (i32.ne)
        (br_if $vector_loop)
      )
    ))
  )

  (func (export "memcpy") (param $src i32) (param $dst i32) (param $size i32)
    (local.get $dst)
    (local.get $src)
    (local.get $size)
    (memory.copy)	
  )

  (func (export "diagonal_coo") (param $k i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $coo_diag i32) (param $N i32) (param $nnz i32)
    (local $i i32)
    (local $val i32)
    (local $start i32)
    (local $end i32)
    i32.const 0
    local.set $i
    (if (result i32 i32) (i32.lt_s (local.get $k) (i32.const 0)) 
      (then 
        (local.get $N)
        (i32.sub (i32.const 0)(local.get $k))
      )
      (else
        (i32.sub (local.get $N) (local.get $k))
        i32.const 0 
      )
    ) 
    (local.set $start)
    (local.set $end)
    ;; bring coo_row pointer to the same row as start
    (loop $init
      (local.get $start)
      (i32.load (local.get $coo_row))
      (i32.gt_s)
      if
        (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
        (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
        (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $nnz)
        (i32.ne)
	if
          (br $init)
	end
	(return)
      end
    )
    (loop $diag_loop
      (loop $row_loop
        ;; if start and coo_row point have the same row number
        (i32.load (local.get $coo_row))
        (local.get $start)
        (i32.eq)
        if 
          (i32.load (local.get $coo_col))
          (i32.load (local.get $coo_row))
	  (i32.sub)
	  (local.get $k)
          (i32.ne)
          if
            (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
            (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
            (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
            (tee_local $i (i32.add (local.get $i) (i32.const 1)))
            (local.get $nnz)
            (i32.ne)
	    if
              (br $row_loop)
	    end
	    (return)
	  end
	  ;; found! 
          (local.get $coo_diag)
          (f32.load (local.get $coo_val))
	  (f32.store)
          ;; bring coo_row pointer to the next row
          (loop $next
            (local.get $start)
            (i32.load (local.get $coo_row))
            (i32.eq)
            if
              (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
              (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
              (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
              (tee_local $i (i32.add (local.get $i) (i32.const 1)))
              (local.get $nnz)
              (i32.ne)
	      if
                (br $next)
	      end
	      (return)
            end
          )
        end
      )
      (local.set $coo_diag (i32.add (local.get $coo_diag) (i32.const 4)))
      (tee_local $start (i32.add (local.get $start) (i32.const 1)))
      (local.get $end)
      (i32.ne)
      (br_if $diag_loop)
    )
  )

  (func (export "sum_coo") (param $axis i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $sum i32) (param $N i32) (param $nnz i32)
    (local $i i32)
    (local $temp f32)
    
    (local.get $axis)
    (i32.const 1)
    (i32.eq)
    if
      (i32.const 0)
      (local.set $i)
      (loop $sum_loop_1
        (f32.const 0)
        (local.set $temp)
        (loop $row_loop_1
          ;; if i and coo_row point have the same row number
          (i32.load (local.get $coo_row))
          (local.get $i)
          (i32.eq)
          if
	    (local.get $temp)
            (f32.load (local.get $coo_val))
	    (f32.add)
	    (local.set $temp)
            (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
            (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
            (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
            (tee_local $i (i32.add (local.get $i) (i32.const 1)))
            (local.get $nnz)
            (i32.ne)
            if
              (br $row_loop_1)
            end
            (return)
          end
        )
	(local.get $sum)
	(local.get $temp)
	(f32.store)
        (local.set $sum (i32.add (local.get $sum) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $sum_loop_1)
      )
    end
  )

  (func (export "min_coo") (param $axis i32) (param $coo_row i32) (param $coo_col i32) (param $coo_val i32) (param $min i32) (param $N i32) (param $nnz i32)
    (local $i i32)
    (local $j i32)
    (local $n i32)
    (local $temp f32)
    (i32.const 0)
    (local.set $j)

    (local.get $axis)
    (i32.const 1)
    (i32.eq)
    if
      (i32.const 0)
      (local.set $i)
      (loop $min_loop_1
        (i32.const 0)
        (local.set $n)
        ;; if i and coo_row point have the same row number
        (i32.load (local.get $coo_row))
        (local.get $i)
        (i32.eq)
	if
          ;; load first val into temp
          (f32.load (local.get $coo_val))
          (local.set $temp)
          (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
          (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
          (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
          (local.set $n (i32.add (local.get $n) (i32.const 1)))
          (tee_local $j (i32.add (local.get $j) (i32.const 1)))
          (local.get $nnz)
	  (i32.eq)
	  if
	    (return)
	  end
	end
        (loop $row_loop_1
          ;; if i and coo_row point have the same row number
          (i32.load (local.get $coo_row))
          (local.get $i)
          (i32.eq)
          if
            (local.get $temp)
            (f32.load (local.get $coo_val))
	    (f32.gt)
	    if
              (f32.load (local.get $coo_val))
              (local.set $temp)
	    end
            (local.set $coo_row (i32.add (local.get $coo_row) (i32.const 4)))
            (local.set $coo_col (i32.add (local.get $coo_col) (i32.const 4)))
            (local.set $coo_val (i32.add (local.get $coo_val) (i32.const 4)))
            (local.set $n (i32.add (local.get $n) (i32.const 1)))
            (tee_local $j (i32.add (local.get $j) (i32.const 1)))
            (local.get $nnz)
            (i32.ne)
            if
              (br $row_loop_1)
            end
            (local.get $n)
	    (local.get $N)
	    (i32.lt_s)
	    if
              (f32.const 0)
	      (local.get $temp)
	      (f32.lt)
              if
                (f32.const 0)
	        (local.set $temp)
	      end
	    end
            (local.get $min)
            (local.get $temp)
            (f32.store)
            (return)
          end
        )
        (local.get $n)
	(local.get $N)
	(i32.lt_s)
	if
          (f32.const 0)
	  (local.get $temp)
	  (f32.lt)
          if
            (f32.const 0)
	    (local.set $temp)
	  end
	end
        (local.get $min)
        (local.get $temp)
        (f32.store)
        (local.set $min (i32.add (local.get $min) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $min_loop_1)
      )
    end
  )

  (func (export "self_expm1_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)

      (loop $inner_loop
        (local.get $this_data)
        (f32.load (local.get $this_data))
        (call $expm1f)
        (f32.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3) 
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)     
      (br_if $outer_loop)
    )
  )

  (func (export "expm1_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)

      (loop $inner_loop
        (local.get $this_out_data)
        (f32.load (local.get $this_in_data))
        (call $expm1f)
        (f32.store)
        (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
        (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_log1p_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)

      (loop $inner_loop
        (local.get $this_data)
        (f32.load (local.get $this_data))
        (call $log1pf)
        (f32.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "log1p_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)

      (loop $inner_loop
        (local.get $this_out_data)
        (f32.load (local.get $this_in_data))
        (call $log1pf)
        (f32.store)
        (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
        (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_sin_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)

      (loop $inner_loop
        (local.get $this_data)
        (f32.load (local.get $this_data))
        (call $sinf)
        (f32.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "sin_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)

      (loop $inner_loop
        (local.get $this_out_data)
        (f32.load (local.get $this_in_data))
        (call $sinf)
        (f32.store)
        (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
        (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_tan_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)

      (loop $inner_loop
        (local.get $this_data)
        (f32.load (local.get $this_data))
        (call $tanf)
        (f32.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "tan_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)

      (loop $inner_loop
        (local.get $this_out_data)
        (f32.load (local.get $this_in_data))
        (call $tanf)
        (f32.store)
        (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
        (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_pow_dia") (param $p f32) (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)

      (loop $inner_loop
        (local.get $this_data)
        (f32.load (local.get $this_data))
        (local.get $p)
        (call $powf)
        (f32.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "pow_dia") (param $p f32) (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)

      (loop $inner_loop
        (local.get $this_out_data)
        (f32.load (local.get $this_in_data))
        (local.get $p)
        (call $powf)
        (f32.store)
        (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
        (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_sign_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)

      (loop $inner_loop
        (local.get $this_data)
        (if (result f32) (f32.eq (f32.load (local.get $this_data)) (f32.const 0.0))
	(then
	  (f32.const 0)
	  )
	  (else
          (if (result f32) (f32.gt (f32.load (local.get $this_data)) (f32.const 0.0))
            (then
	    (f32.const 1)
	    )
	    (else
	    (f32.const -1)
	  ))
	))
        (f32.store)
        (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3) 
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)     
      (br_if $outer_loop)
    )
  )

  (func (export "sign_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)

      (loop $inner_loop
        (local.get $this_out_data)
        (if (result f32) (f32.eq (f32.load (local.get $this_in_data)) (f32.const 0.0))
        (then
          (f32.const 0)
          )
          (else
          (if (result f32) (f32.gt (f32.load (local.get $this_in_data)) (f32.const 0.0))
            (then
            (f32.const 1)
            )
            (else
            (f32.const -1)
          ))
        ))
        (f32.store)
        (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
        (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
        (tee_local $n (i32.add (local.get $n) (i32.const 1)))
        (local.get $end)
        (i32.lt_s)
        (br_if $inner_loop)
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func (export "self_abs_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.abs)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.abs)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "abs_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.abs)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.abs)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_neg_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.neg)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.neg)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "neg_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.neg)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.neg)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_sqrt_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.sqrt)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.sqrt)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "sqrt_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.sqrt)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.sqrt)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )
  
  (func (export "self_ceil_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.ceil)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.ceil)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "ceil_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.ceil)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.ceil)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_floor_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.floor)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.floor)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "floor_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.floor)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.floor)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_trunc_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.trunc)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.trunc)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "trunc_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.trunc)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.trunc)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_nearest_dia") (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (f32.nearest)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.nearest)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "nearest_dia") (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)

    (i32.const 0)
    (local.set $i)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (f32.nearest)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.nearest)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_deg2rad_dia") (param $pi f32) (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)
    (local $pi_on_180 f32)

    (i32.const 0)
    (local.set $i)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (local.get $pi_on_180)
          (f32.mul)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.splat (local.get $pi_on_180))
          (f32x4.mul)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "deg2rad_dia") (param $pi f32) (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)
    (local $pi_on_180 f32)

    (i32.const 0)
    (local.set $i)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (local.get $pi_on_180)
          (f32.mul)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.splat (local.get $pi_on_180))
          (f32x4.mul)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "self_rad2deg_dia") (param $pi f32) (param $offset i32) (param $data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_data i32)
    (local $pi_on_180 f32)

    (i32.const 0)
    (local.set $i)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then 
        (loop $inner_loop
          (local.get $this_data)
          (f32.load (local.get $this_data))
          (local.get $pi_on_180)
          (f32.div)
          (f32.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then 
	(loop $vector_inner_loop
          (local.get $this_data)
          (v128.load (local.get $this_data))
          (f32x4.splat (local.get $pi_on_180))
          (f32x4.div)
          (v128.store)
          (local.set $this_data (i32.add (local.get $this_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "rad2deg_dia") (param $pi f32) (param $offset i32) (param $in_data i32) (param $out_data i32) (param $ndiags i32) (param $stride i32) (param $N i32)
    (local $i i32)
    (local $k i32)
    (local $n i32)
    (local $end i32)
    (local $new_end i32)
    (local $exp1 i32) ;; N - stride
    (local $exp2 i32) ;; i * stride
    (local $exp3 i32) ;; exp2 - exp1
    (local $this_in_data i32)
    (local $this_out_data i32)
    (local $pi_on_180 f32)

    (i32.const 0)
    (local.set $i)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (local.get $N)
    (local.get $stride)
    (i32.sub)
    (local.set $exp1)

    (i32.const 0)
    (local.set $exp2)

    (loop $outer_loop
      ;; diagonal offset
      (i32.load (local.get $offset))
      (local.set $k)
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
      ;; start position
      (local.set $n)
      (if (result i32) (i32.lt_s (local.get $N) (i32.sub (local.get $N) (local.get $k)))
        (then
          (local.get $N)
        )
        (else
          (i32.sub (local.get $N) (local.get $k))
        )
      )
      ;; end position
      (local.set $end)
      (local.get $end)
      (local.get $n)
      (i32.sub)
      (i32.const 4)
      (i32.rem_u)
      (local.get $n)
      (i32.add)
      (local.set $new_end)
      (i32.add (local.get $in_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_in_data)
      (i32.add (local.get $out_data) (i32.shl (i32.add (local.get $exp3) (local.get $n)) (i32.const 2)))
      (local.set $this_out_data)
      (local.get $n)
      (local.get $new_end)
      (i32.lt_s)
      (if
        (then
        (loop $inner_loop
          (local.get $this_out_data)
          (f32.load (local.get $this_in_data))
          (local.get $pi_on_180)
          (f32.div)
          (f32.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 4)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 4)))
          (tee_local $n (i32.add (local.get $n) (i32.const 1)))
          (local.get $new_end)
          (i32.lt_s)
          (br_if $inner_loop)
        ))
      )
      (local.get $new_end)
      (local.get $end)
      (i32.lt_s)
      (if
        (then
        (loop $vector_inner_loop
          (local.get $this_out_data)
          (v128.load (local.get $this_in_data))
          (f32x4.splat (local.get $pi_on_180))
          (f32x4.div)
          (v128.store)
          (local.set $this_in_data (i32.add (local.get $this_in_data) (i32.const 16)))
          (local.set $this_out_data (i32.add (local.get $this_out_data) (i32.const 16)))
          (tee_local $n (i32.add (local.get $n) (i32.const 4)))
          (local.get $end)
          (i32.lt_s)
          (br_if $vector_inner_loop)
        ))
      )
      (local.set $offset (i32.add (local.get $offset) (i32.const 4)))
      (i32.add (local.get $exp2) (local.get $stride))
      (local.tee $exp2)
      (local.set $exp3)
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $ndiags)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $self_abs_ell (export "self_abs_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s) 
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
	(f32.abs)
	(f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne) 
      (br_if $outer_loop)
    )
  )

  (func (export "abs_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.abs)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $self_neg_ell (export "self_neg_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (f32.neg)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "neg_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.neg)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_sqrt_ell (export "self_sqrt_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (f32.sqrt)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "sqrt_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.sqrt)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_ceil_ell (export "self_ceil_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (f32.ceil)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "ceil_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.ceil)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_floor_ell (export "self_floor_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (f32.floor)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "floor_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.floor)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_trunc_ell (export "self_trunc_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (f32.trunc)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "trunc_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.trunc)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_nearest_ell (export "self_nearest_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (f32.nearest)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "nearest_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (f32.nearest)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_deg2rad_ell (export "self_deg2rad_ell") (param $pi f32) (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $pi_on_180 f32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (local.get $pi_on_180)
        (f32.mul)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "deg2rad_ell") (param $pi f32) (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $pi_on_180 f32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (local.get $pi_on_180)
        (f32.mul)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_rad2deg_ell (export "self_rad2deg_ell") (param $pi f32) (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $pi_on_180 f32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
        (local.get $pi_on_180)
        (f32.div)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "rad2deg_ell") (param $pi f32) (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)
    (local $pi_on_180 f32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)
    (local.get $pi)
    (f32.const 180)
    (f32.div)
    (local.set $pi_on_180)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (local.get $pi_on_180)
        (f32.div)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_sign_ell (export "self_sign_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
	(if (result f32) (f32.eq (f32.load (local.get $data)) (f32.const 0.0))
        (then
          (f32.const 0)
          )
        (else
          (if (result f32) (f32.gt (f32.load (local.get $data)) (f32.const 0.0))
          (then
            (f32.const 1)
            )
          (else
            (f32.const -1)
          ))
        ))
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "sign_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (if (result f32) (f32.eq (f32.load (local.get $in_data)) (f32.const 0.0))
        (then
          (f32.const 0)
          )
        (else
          (if (result f32) (f32.gt (f32.load (local.get $in_data)) (f32.const 0.0))
          (then
            (f32.const 1)
            )
          (else
            (f32.const -1)
          ))
        ))
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )


  (func $self_expm1_ell (export "self_expm1_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
	(call $expm1f)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "expm1_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (call $expm1f)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $self_log1p_ell (export "self_log1p_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
	(call $log1pf)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "log1p_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (call $log1pf)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $self_sin_ell (export "self_sin_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
	(call $sinf)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "sin_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (call $sinf)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $self_tan_ell (export "self_tan_ell") (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
	(call $tanf)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "tan_ell") (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
        (call $tanf)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func $self_pow_ell (export "self_pow_ell") (param $p f32) (param $data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $data)
        (f32.load (local.get $data))
	(local.get $p)
	(call $powf)
        (f32.store)
        (local.set $data (i32.add (local.get $data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )

  (func (export "pow_ell") (param $p f32) (param $in_data i32) (param $out_data i32) (param $ncols i32) (param $N i32)
    (local $i i32)
    (local $j i32)

    (local.get $ncols)
    (i32.const 0)
    (i32.gt_s)
    (local.get $N)
    (i32.const 0)
    (i32.gt_s)
    (i32.and)
    (i32.eqz)
    if
      (return)
    end
    (i32.const 0)
    (local.set $j)

    (loop $outer_loop
      (i32.const 0)
      (local.set $i)
      (loop $inner_loop
        (local.get $out_data)
        (f32.load (local.get $in_data))
	(local.get $p)
	(call $powf)
        (f32.store)
        (local.set $in_data (i32.add (local.get $in_data) (i32.const 4)))
        (local.set $out_data (i32.add (local.get $out_data) (i32.const 4)))
        (tee_local $i (i32.add (local.get $i) (i32.const 1)))
        (local.get $N)
        (i32.ne)
        (br_if $inner_loop)
      )
      (tee_local $j (i32.add (local.get $j) (i32.const 1)))
      (local.get $ncols)
      (i32.ne)
      (br_if $outer_loop)
    )
  )
)
