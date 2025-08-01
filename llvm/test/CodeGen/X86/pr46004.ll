; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64

; OSS Fuzz: https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=22357
define void @fuzz22357(i128 %a0) {
; X86-LABEL: fuzz22357:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    .cfi_def_cfa_offset 8
; X86-NEXT:    .cfi_offset %ebp, -8
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    .cfi_def_cfa_register %ebp
; X86-NEXT:    andl $-16, %esp
; X86-NEXT:    subl $16, %esp
; X86-NEXT:    movb $0, (%eax)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    .cfi_def_cfa %esp, 4
; X86-NEXT:    retl
;
; X64-LABEL: fuzz22357:
; X64:       # %bb.0:
; X64-NEXT:    movb $0, (%rax)
; X64-NEXT:    retq
  %1 = add i128 %a0, 170141183460469231731687303715884105727
  %2 = add nuw nsw i128 %1, 22222
  %3 = getelementptr i8, ptr undef, i128 %2
  store i8 0, ptr %3, align 1
  ret void
}

; OSS Fuzz: https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=22723
define void @fuzz22723(i128 %a0) {
; X86-LABEL: fuzz22723:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    .cfi_def_cfa_offset 8
; X86-NEXT:    .cfi_offset %ebp, -8
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    .cfi_def_cfa_register %ebp
; X86-NEXT:    andl $-16, %esp
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    .cfi_def_cfa %esp, 4
; X86-NEXT:    retl
;
; X64-LABEL: fuzz22723:
; X64:       # %bb.0:
; X64-NEXT:    retq
  %1 = add i128 %a0, 170141183460469231731687303715884105727
  %2 = getelementptr ptr, ptr undef, i128 %1
  store ptr undef, ptr %2, align 8
  ret void
}
