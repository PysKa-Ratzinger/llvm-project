; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=amdgcn < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx900 < %s | FileCheck -check-prefix=GFX9 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1030 < %s | FileCheck -check-prefix=GFX10 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 -mattr=+real-true16 < %s | FileCheck -check-prefixes=GFX11-TRUE16 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 -mattr=-real-true16 < %s | FileCheck -check-prefixes=GFX11-FAKE16 %s

declare i32 @llvm.amdgcn.alignbyte(i32, i32, i32) #0

define amdgpu_kernel void @v_alignbyte_b32(ptr addrspace(1) %out, i32 %src1, i32 %src2, i32 %src3) #1 {
; GCN-LABEL: v_alignbyte_b32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0xb
; GCN-NEXT:    s_load_dwordx2 s[4:5], s[4:5], 0x9
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, -1
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    v_mov_b32_e32 v0, s1
; GCN-NEXT:    v_mov_b32_e32 v1, s2
; GCN-NEXT:    v_alignbyte_b32 v0, s0, v0, v1
; GCN-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; GCN-NEXT:    s_endpgm
;
; GFX9-LABEL: v_alignbyte_b32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x2c
; GFX9-NEXT:    s_load_dwordx2 s[6:7], s[4:5], 0x24
; GFX9-NEXT:    v_mov_b32_e32 v0, 0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, s1
; GFX9-NEXT:    v_mov_b32_e32 v2, s2
; GFX9-NEXT:    v_alignbyte_b32 v1, s0, v1, v2
; GFX9-NEXT:    global_store_dword v0, v1, s[6:7]
; GFX9-NEXT:    s_endpgm
;
; GFX10-LABEL: v_alignbyte_b32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_clause 0x1
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x2c
; GFX10-NEXT:    s_load_dwordx2 s[4:5], s[4:5], 0x24
; GFX10-NEXT:    v_mov_b32_e32 v1, 0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    v_mov_b32_e32 v0, s2
; GFX10-NEXT:    v_alignbyte_b32 v0, s0, s1, v0
; GFX10-NEXT:    global_store_dword v1, v0, s[4:5]
; GFX10-NEXT:    s_endpgm
;
; GFX11-TRUE16-LABEL: v_alignbyte_b32:
; GFX11-TRUE16:       ; %bb.0:
; GFX11-TRUE16-NEXT:    s_clause 0x1
; GFX11-TRUE16-NEXT:    s_load_b128 s[0:3], s[4:5], 0x2c
; GFX11-TRUE16-NEXT:    s_load_b64 s[4:5], s[4:5], 0x24
; GFX11-TRUE16-NEXT:    v_mov_b32_e32 v1, 0
; GFX11-TRUE16-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-TRUE16-NEXT:    v_mov_b16_e32 v0.l, s2
; GFX11-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-TRUE16-NEXT:    v_alignbyte_b32 v0, s0, s1, v0.l
; GFX11-TRUE16-NEXT:    global_store_b32 v1, v0, s[4:5]
; GFX11-TRUE16-NEXT:    s_endpgm
;
; GFX11-FAKE16-LABEL: v_alignbyte_b32:
; GFX11-FAKE16:       ; %bb.0:
; GFX11-FAKE16-NEXT:    s_clause 0x1
; GFX11-FAKE16-NEXT:    s_load_b128 s[0:3], s[4:5], 0x2c
; GFX11-FAKE16-NEXT:    s_load_b64 s[4:5], s[4:5], 0x24
; GFX11-FAKE16-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-FAKE16-NEXT:    v_dual_mov_b32 v1, 0 :: v_dual_mov_b32 v0, s2
; GFX11-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-FAKE16-NEXT:    v_alignbyte_b32 v0, s0, s1, v0
; GFX11-FAKE16-NEXT:    global_store_b32 v1, v0, s[4:5]
; GFX11-FAKE16-NEXT:    s_endpgm
  %val = call i32 @llvm.amdgcn.alignbyte(i32 %src1, i32 %src2, i32 %src3) #0
  store i32 %val, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @v_alignbyte_b32_2(ptr addrspace(1) %out, ptr addrspace(1) %src1, ptr addrspace(1) %src2, i32 %src3) #1 {
; GCN-LABEL: v_alignbyte_b32_2:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; GCN-NEXT:    s_load_dwordx2 s[8:9], s[4:5], 0xd
; GCN-NEXT:    s_load_dword s16, s[4:5], 0xf
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s14, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GCN-NEXT:    v_mov_b32_e32 v1, 0
; GCN-NEXT:    s_mov_b32 s15, s7
; GCN-NEXT:    s_mov_b64 s[10:11], s[14:15]
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b64 s[12:13], s[2:3]
; GCN-NEXT:    buffer_load_dword v2, v[0:1], s[12:15], 0 addr64 glc
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    buffer_load_dword v0, v[0:1], s[8:11], 0 addr64 glc
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    s_mov_b32 s6, -1
; GCN-NEXT:    s_mov_b32 s4, s0
; GCN-NEXT:    s_mov_b32 s5, s1
; GCN-NEXT:    v_alignbyte_b32 v0, v2, v0, s16
; GCN-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; GCN-NEXT:    s_endpgm
;
; GFX9-LABEL: v_alignbyte_b32_2:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    s_load_dwordx2 s[6:7], s[4:5], 0x34
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v1, v0, s[2:3] glc
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v0, s[6:7] glc
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_load_dword s2, s[4:5], 0x3c
; GFX9-NEXT:    v_mov_b32_e32 v0, 0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    v_alignbyte_b32 v1, v1, v2, s2
; GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; GFX10-LABEL: v_alignbyte_b32_2:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_clause 0x1
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    s_load_dwordx2 s[6:7], s[4:5], 0x34
; GFX10-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX10-NEXT:    v_mov_b32_e32 v2, 0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dword v1, v0, s[2:3] glc dlc
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    global_load_dword v0, v0, s[6:7] glc dlc
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    s_load_dword s2, s[4:5], 0x3c
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    v_alignbyte_b32 v0, v1, v0, s2
; GFX10-NEXT:    global_store_dword v2, v0, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-TRUE16-LABEL: v_alignbyte_b32_2:
; GFX11-TRUE16:       ; %bb.0:
; GFX11-TRUE16-NEXT:    s_clause 0x1
; GFX11-TRUE16-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-TRUE16-NEXT:    s_load_b64 s[6:7], s[4:5], 0x34
; GFX11-TRUE16-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-TRUE16-NEXT:    v_mov_b32_e32 v2, 0
; GFX11-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_2)
; GFX11-TRUE16-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX11-TRUE16-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-TRUE16-NEXT:    global_load_b32 v1, v0, s[2:3] glc dlc
; GFX11-TRUE16-NEXT:    s_waitcnt vmcnt(0)
; GFX11-TRUE16-NEXT:    global_load_b32 v0, v0, s[6:7] glc dlc
; GFX11-TRUE16-NEXT:    s_waitcnt vmcnt(0)
; GFX11-TRUE16-NEXT:    s_load_b32 s2, s[4:5], 0x3c
; GFX11-TRUE16-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-TRUE16-NEXT:    v_alignbyte_b32 v0, v1, v0, s2
; GFX11-TRUE16-NEXT:    global_store_b32 v2, v0, s[0:1]
; GFX11-TRUE16-NEXT:    s_endpgm
;
; GFX11-FAKE16-LABEL: v_alignbyte_b32_2:
; GFX11-FAKE16:       ; %bb.0:
; GFX11-FAKE16-NEXT:    s_clause 0x1
; GFX11-FAKE16-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-FAKE16-NEXT:    s_load_b64 s[6:7], s[4:5], 0x34
; GFX11-FAKE16-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-FAKE16-NEXT:    v_mov_b32_e32 v2, 0
; GFX11-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_2)
; GFX11-FAKE16-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX11-FAKE16-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-FAKE16-NEXT:    global_load_b32 v1, v0, s[2:3] glc dlc
; GFX11-FAKE16-NEXT:    s_waitcnt vmcnt(0)
; GFX11-FAKE16-NEXT:    global_load_b32 v0, v0, s[6:7] glc dlc
; GFX11-FAKE16-NEXT:    s_waitcnt vmcnt(0)
; GFX11-FAKE16-NEXT:    s_load_b32 s2, s[4:5], 0x3c
; GFX11-FAKE16-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-FAKE16-NEXT:    v_alignbyte_b32 v0, v1, v0, s2
; GFX11-FAKE16-NEXT:    global_store_b32 v2, v0, s[0:1]
; GFX11-FAKE16-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %a.gep = getelementptr inbounds i32, ptr addrspace(1) %src1, i32 %tid
  %b.gep = getelementptr inbounds i32, ptr addrspace(1) %src2, i32 %tid
  %a.val = load volatile i32, ptr addrspace(1) %a.gep
  %b.val = load volatile i32, ptr addrspace(1) %b.gep

  %val = call i32 @llvm.amdgcn.alignbyte(i32 %a.val, i32 %b.val, i32 %src3) #0
  store i32 %val, ptr addrspace(1) %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
