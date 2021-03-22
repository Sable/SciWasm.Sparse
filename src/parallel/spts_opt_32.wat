(module
  (import "js" "mem" (memory 1))
  (import "console" "log" (func $logf (param f32)))
  (import "console" "log" (func $logi (param i32)))

  (func $spts_csr (export "spts_csr") (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $len i32)
    (local $i i32)
    (local $j i32)
    (local $end i32)
    (local $temp f32)
    (local.get $len)
    (i32.const 0)
    (tee_local $i)
    (i32.le_s)
    if
      (return)
    end
    (i32.load (local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_col)
    (i32.add)
    (local.set $csr_col)
    (i32.load (local.get $csr_rowptr))
    (i32.const 2)
    (i32.shl)
    (local.get $csr_val)
    (i32.add)
    (local.set $csr_val)
    (loop $outer_loop
      ;; check if there are non-diagonals elements in the row.
      (i32.load (i32.add (local.get $csr_rowptr) (i32.const 4)))
      (i32.const 1)
      (i32.sub)
      (tee_local $end)
      (i32.load (local.get $csr_rowptr))
      (tee_local $j)
      (i32.gt_s)
      if
        (f32.load (local.get $y))
        (local.set $temp)
        (loop $inner_loop
          (local.get $temp)
          (f32.load (local.get $csr_val))
          (f32.load (i32.add (local.get $x) (i32.shl (i32.load (local.get $csr_col)) (i32.const 2))))
          (f32.mul)
	  (f32.sub)
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
      (local.get $len)
      (i32.ne)     
      (br_if $outer_loop)
    )
  )

  (func $spts_level_csr (export "spts_level_csr") (param $id i32) (param $level_ptr i32) (param $csr_rowptr i32) (param $csr_col i32) (param $csr_val i32) (param $x i32) (param $y i32) (param $nlevels i32) (param $barrier i32) (param $nthreads i32)
    (local $i i32)
    (local $nrows i32)
    (local $len i32)
    (local $rem i32)
    (local $start i32)
    (local $this_y i32)
    ;; check if the number of levels is less than or equal to zero.
    (local.get $nlevels)
    (i32.const 0)
    (local.tee $i)
    (i32.le_s)
    if
      (return)
    end
    (loop $level_loop
      ;; At each level, calculate the rows partition for each thread using id.
      ;; This is to avoid calls (equal to the number of levels) between the master 
      ;; JavaScript thread and worker WebAssembly threads.
      (i32.load (i32.add (local.get $level_ptr) (i32.const 4)))
      (i32.load (local.get $level_ptr))
      (i32.sub)
      (tee_local $nrows)
      (local.get $nthreads)
      (i32.div_u)
      (local.set $len)

      (local.get $len)
      (i32.const 0)
      (i32.ne)
      (if
      (then
        (local.get $nrows)
        (local.get $nthreads)
        (i32.rem_u)
	(tee_local $rem)
	(local.get $id)
	(i32.gt_s)
	(if
	(then
          (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $id)) (i32.const 2))))
          (local.get $len)
	  (i32.const 1)
          (i32.add)	
          (local.set $len)
	)
	(else
          (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.add (i32.mul (local.get $id) (local.get $len)) (local.get $rem)) (i32.const 2))))
	))
        (i32.add (local.get $csr_rowptr) (local.get $start)) 
        (local.get $csr_col)
        (local.get $csr_val)
        (local.get $y)
        (i32.add (local.get $y) (local.get $start)) 
        (local.get $len)
        (call $spts_csr)
      )
      (else
        (local.get $nrows) 
	(local.get $id)
	(i32.gt_s)
	if
	  (i32.const 1)
	  (local.set $len)
          (local.set $start (i32.shl (i32.add (i32.load (local.get $level_ptr)) (i32.mul (local.get $id) (local.get $len)) (i32.const 2))))
          (i32.add (local.get $csr_rowptr) (local.get $start)) 
          (local.get $csr_col)
          (local.get $csr_val)
          (local.get $y)
          (i32.add (local.get $y) (local.get $start)) 
          (local.get $len)
          (call $spts_csr)
	end
      ))
      ;; Increment the barrier value using atomic read-modify-write operation 
      ;; (returns value read from memory before the modify operation was performed).
      ;; Check if the return value is one less than number of threads to reset the barrier value.
      (local.get $nthreads)
      (i32.atomic.rmw.add (local.get $barrier) (i32.const 1)) 
      (i32.sub)
      (i32.const 1)
      (i32.eq)
      (if
      (then
        (i32.atomic.store (local.get $barrier) (i32.const 0))  
      )
      (else
        (loop $barrier_loop
          (i32.load (local.get $barrier))
          (i32.const 0)
          (i32.ne)
          (br_if $barrier_loop)
        )
      ))
      (local.set $level_ptr (i32.add (local.get $level_ptr) (i32.const 4)))
      (tee_local $i (i32.add (local.get $i) (i32.const 1)))
      (local.get $nlevels)
      (i32.ne)     
      (br_if $level_loop)
    )
  )
)

