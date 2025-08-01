; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --check-globals none --filter-out-after "^scalar.ph:" --version 4
; RUN: opt -passes=loop-vectorize -enable-epilogue-vectorization=false -mattr=+i8mm,+dotprod --vectorizer-maximize-bandwidth -S < %s | FileCheck %s
; RUN: opt -passes=loop-vectorize -enable-epilogue-vectorization=false -mattr=+dotprod -S --vectorizer-maximize-bandwidth < %s | FileCheck %s --check-prefix=CHECK-NOI8MM

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-none-unknown-elf"

define i32 @sudot(ptr %a, ptr %b) #0 {
; CHECK-LABEL: define i32 @sudot(
; CHECK-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = mul nuw i64 [[TMP0]], 16
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = mul nuw i64 [[TMP2]], 16
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 1024, [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 1024, [[N_MOD_VF]]
; CHECK-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP5:%.*]] = mul nuw i64 [[TMP4]], 16
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP6]], i32 0
; CHECK-NEXT:    [[TMP8:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP9:%.*]] = mul nuw i64 [[TMP8]], 8
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr i8, ptr [[TMP6]], i64 [[TMP9]]
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 8 x i8>, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <vscale x 8 x i8>, ptr [[TMP10]], align 1
; CHECK-NEXT:    [[TMP11:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP12:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD2]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP14:%.*]] = getelementptr i8, ptr [[TMP13]], i32 0
; CHECK-NEXT:    [[TMP15:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP16:%.*]] = mul nuw i64 [[TMP15]], 8
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr i8, ptr [[TMP13]], i64 [[TMP16]]
; CHECK-NEXT:    [[WIDE_LOAD3:%.*]] = load <vscale x 8 x i8>, ptr [[TMP14]], align 1
; CHECK-NEXT:    [[WIDE_LOAD4:%.*]] = load <vscale x 8 x i8>, ptr [[TMP17]], align 1
; CHECK-NEXT:    [[TMP18:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD3]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP19:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD4]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP20:%.*]] = mul <vscale x 8 x i32> [[TMP18]], [[TMP11]]
; CHECK-NEXT:    [[TMP21:%.*]] = mul <vscale x 8 x i32> [[TMP19]], [[TMP12]]
; CHECK-NEXT:    [[PARTIAL_REDUCE]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI]], <vscale x 8 x i32> [[TMP20]])
; CHECK-NEXT:    [[PARTIAL_REDUCE5]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI1]], <vscale x 8 x i32> [[TMP21]])
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP5]]
; CHECK-NEXT:    [[TMP22:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP22]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = add <vscale x 2 x i32> [[PARTIAL_REDUCE5]], [[PARTIAL_REDUCE]]
; CHECK-NEXT:    [[TMP23:%.*]] = call i32 @llvm.vector.reduce.add.nxv2i32(<vscale x 2 x i32> [[BIN_RDX]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 1024, [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_EXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
;
; CHECK-NOI8MM-LABEL: define i32 @sudot(
; CHECK-NOI8MM-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NOI8MM-NEXT:  entry:
; CHECK-NOI8MM-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP1:%.*]] = mul nuw i64 [[TMP0]], 16
; CHECK-NOI8MM-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK-NOI8MM:       vector.ph:
; CHECK-NOI8MM-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP3:%.*]] = mul nuw i64 [[TMP2]], 16
; CHECK-NOI8MM-NEXT:    [[N_MOD_VF:%.*]] = urem i64 1024, [[TMP3]]
; CHECK-NOI8MM-NEXT:    [[N_VEC:%.*]] = sub i64 1024, [[N_MOD_VF]]
; CHECK-NOI8MM-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP5:%.*]] = mul nuw i64 [[TMP4]], 16
; CHECK-NOI8MM-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK-NOI8MM:       vector.body:
; CHECK-NOI8MM-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI1:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP6]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP8:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP9:%.*]] = mul nuw i64 [[TMP8]], 8
; CHECK-NOI8MM-NEXT:    [[TMP10:%.*]] = getelementptr i8, ptr [[TMP6]], i64 [[TMP9]]
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 8 x i8>, ptr [[TMP7]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD2:%.*]] = load <vscale x 8 x i8>, ptr [[TMP10]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP11:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP12:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD2]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP13:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP14:%.*]] = getelementptr i8, ptr [[TMP13]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP15:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP16:%.*]] = mul nuw i64 [[TMP15]], 8
; CHECK-NOI8MM-NEXT:    [[TMP17:%.*]] = getelementptr i8, ptr [[TMP13]], i64 [[TMP16]]
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD3:%.*]] = load <vscale x 8 x i8>, ptr [[TMP14]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD4:%.*]] = load <vscale x 8 x i8>, ptr [[TMP17]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP18:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD3]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP19:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD4]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP20:%.*]] = mul <vscale x 8 x i32> [[TMP18]], [[TMP11]]
; CHECK-NOI8MM-NEXT:    [[TMP21:%.*]] = mul <vscale x 8 x i32> [[TMP19]], [[TMP12]]
; CHECK-NOI8MM-NEXT:    [[PARTIAL_REDUCE]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI]], <vscale x 8 x i32> [[TMP20]])
; CHECK-NOI8MM-NEXT:    [[PARTIAL_REDUCE5]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI1]], <vscale x 8 x i32> [[TMP21]])
; CHECK-NOI8MM-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP5]]
; CHECK-NOI8MM-NEXT:    [[TMP24:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NOI8MM-NEXT:    br i1 [[TMP24]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK-NOI8MM:       middle.block:
; CHECK-NOI8MM-NEXT:    [[BIN_RDX:%.*]] = add <vscale x 2 x i32> [[PARTIAL_REDUCE5]], [[PARTIAL_REDUCE]]
; CHECK-NOI8MM-NEXT:    [[TMP23:%.*]] = call i32 @llvm.vector.reduce.add.nxv2i32(<vscale x 2 x i32> [[BIN_RDX]])
; CHECK-NOI8MM-NEXT:    [[CMP_N:%.*]] = icmp eq i64 1024, [[N_VEC]]
; CHECK-NOI8MM-NEXT:    br i1 [[CMP_N]], label [[FOR_EXIT:%.*]], label [[SCALAR_PH]]
; CHECK-NOI8MM:       scalar.ph:
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %accum = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %gep.a = getelementptr i8, ptr %a, i64 %iv
  %load.a = load i8, ptr %gep.a, align 1
  %ext.a = zext i8 %load.a to i32
  %gep.b = getelementptr i8, ptr %b, i64 %iv
  %load.b = load i8, ptr %gep.b, align 1
  %ext.b = sext i8 %load.b to i32
  %mul = mul i32 %ext.b, %ext.a
  %add = add i32 %mul, %accum
  %iv.next = add i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, 1024
  br i1 %exitcond.not, label %for.exit, label %for.body

for.exit:                        ; preds = %for.body
  ret i32 %add
}

define i32 @usdot(ptr %a, ptr %b) #0 {
; CHECK-LABEL: define i32 @usdot(
; CHECK-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = mul nuw i64 [[TMP0]], 16
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = mul nuw i64 [[TMP2]], 16
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 1024, [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 1024, [[N_MOD_VF]]
; CHECK-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP5:%.*]] = mul nuw i64 [[TMP4]], 16
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP6]], i32 0
; CHECK-NEXT:    [[TMP8:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP9:%.*]] = mul nuw i64 [[TMP8]], 8
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr i8, ptr [[TMP6]], i64 [[TMP9]]
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 8 x i8>, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <vscale x 8 x i8>, ptr [[TMP10]], align 1
; CHECK-NEXT:    [[TMP11:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP12:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD2]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP14:%.*]] = getelementptr i8, ptr [[TMP13]], i32 0
; CHECK-NEXT:    [[TMP15:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP16:%.*]] = mul nuw i64 [[TMP15]], 8
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr i8, ptr [[TMP13]], i64 [[TMP16]]
; CHECK-NEXT:    [[WIDE_LOAD3:%.*]] = load <vscale x 8 x i8>, ptr [[TMP14]], align 1
; CHECK-NEXT:    [[WIDE_LOAD4:%.*]] = load <vscale x 8 x i8>, ptr [[TMP17]], align 1
; CHECK-NEXT:    [[TMP18:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD3]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP19:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD4]] to <vscale x 8 x i32>
; CHECK-NEXT:    [[TMP20:%.*]] = mul <vscale x 8 x i32> [[TMP18]], [[TMP11]]
; CHECK-NEXT:    [[TMP21:%.*]] = mul <vscale x 8 x i32> [[TMP19]], [[TMP12]]
; CHECK-NEXT:    [[PARTIAL_REDUCE]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI]], <vscale x 8 x i32> [[TMP20]])
; CHECK-NEXT:    [[PARTIAL_REDUCE5]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI1]], <vscale x 8 x i32> [[TMP21]])
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP5]]
; CHECK-NEXT:    [[TMP22:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP22]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = add <vscale x 2 x i32> [[PARTIAL_REDUCE5]], [[PARTIAL_REDUCE]]
; CHECK-NEXT:    [[TMP23:%.*]] = call i32 @llvm.vector.reduce.add.nxv2i32(<vscale x 2 x i32> [[BIN_RDX]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 1024, [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_EXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
;
; CHECK-NOI8MM-LABEL: define i32 @usdot(
; CHECK-NOI8MM-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR0]] {
; CHECK-NOI8MM-NEXT:  entry:
; CHECK-NOI8MM-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP1:%.*]] = mul nuw i64 [[TMP0]], 16
; CHECK-NOI8MM-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK-NOI8MM:       vector.ph:
; CHECK-NOI8MM-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP3:%.*]] = mul nuw i64 [[TMP2]], 16
; CHECK-NOI8MM-NEXT:    [[N_MOD_VF:%.*]] = urem i64 1024, [[TMP3]]
; CHECK-NOI8MM-NEXT:    [[N_VEC:%.*]] = sub i64 1024, [[N_MOD_VF]]
; CHECK-NOI8MM-NEXT:    [[TMP4:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP5:%.*]] = mul nuw i64 [[TMP4]], 16
; CHECK-NOI8MM-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK-NOI8MM:       vector.body:
; CHECK-NOI8MM-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI1:%.*]] = phi <vscale x 2 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP6]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP8:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP9:%.*]] = mul nuw i64 [[TMP8]], 8
; CHECK-NOI8MM-NEXT:    [[TMP10:%.*]] = getelementptr i8, ptr [[TMP6]], i64 [[TMP9]]
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 8 x i8>, ptr [[TMP7]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD2:%.*]] = load <vscale x 8 x i8>, ptr [[TMP10]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP11:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP12:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD2]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP13:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP14:%.*]] = getelementptr i8, ptr [[TMP13]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP15:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NOI8MM-NEXT:    [[TMP16:%.*]] = mul nuw i64 [[TMP15]], 8
; CHECK-NOI8MM-NEXT:    [[TMP17:%.*]] = getelementptr i8, ptr [[TMP13]], i64 [[TMP16]]
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD3:%.*]] = load <vscale x 8 x i8>, ptr [[TMP14]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD4:%.*]] = load <vscale x 8 x i8>, ptr [[TMP17]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP18:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD3]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP19:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD4]] to <vscale x 8 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP20:%.*]] = mul <vscale x 8 x i32> [[TMP18]], [[TMP11]]
; CHECK-NOI8MM-NEXT:    [[TMP21:%.*]] = mul <vscale x 8 x i32> [[TMP19]], [[TMP12]]
; CHECK-NOI8MM-NEXT:    [[PARTIAL_REDUCE]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI]], <vscale x 8 x i32> [[TMP20]])
; CHECK-NOI8MM-NEXT:    [[PARTIAL_REDUCE5]] = call <vscale x 2 x i32> @llvm.experimental.vector.partial.reduce.add.nxv2i32.nxv8i32(<vscale x 2 x i32> [[VEC_PHI1]], <vscale x 8 x i32> [[TMP21]])
; CHECK-NOI8MM-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP5]]
; CHECK-NOI8MM-NEXT:    [[TMP24:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NOI8MM-NEXT:    br i1 [[TMP24]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK-NOI8MM:       middle.block:
; CHECK-NOI8MM-NEXT:    [[BIN_RDX:%.*]] = add <vscale x 2 x i32> [[PARTIAL_REDUCE5]], [[PARTIAL_REDUCE]]
; CHECK-NOI8MM-NEXT:    [[TMP23:%.*]] = call i32 @llvm.vector.reduce.add.nxv2i32(<vscale x 2 x i32> [[BIN_RDX]])
; CHECK-NOI8MM-NEXT:    [[CMP_N:%.*]] = icmp eq i64 1024, [[N_VEC]]
; CHECK-NOI8MM-NEXT:    br i1 [[CMP_N]], label [[FOR_EXIT:%.*]], label [[SCALAR_PH]]
; CHECK-NOI8MM:       scalar.ph:
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %accum = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %gep.a = getelementptr i8, ptr %a, i64 %iv
  %load.a = load i8, ptr %gep.a, align 1
  %ext.a = sext i8 %load.a to i32
  %gep.b = getelementptr i8, ptr %b, i64 %iv
  %load.b = load i8, ptr %gep.b, align 1
  %ext.b = zext i8 %load.b to i32
  %mul = mul i32 %ext.b, %ext.a
  %add = add i32 %mul, %accum
  %iv.next = add i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, 1024
  br i1 %exitcond.not, label %for.exit, label %for.body

for.exit:                        ; preds = %for.body
  ret i32 %add
}

define i32 @sudot_neon(ptr %a, ptr %b) #1 {
; CHECK-LABEL: define i32 @sudot_neon(
; CHECK-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i8, ptr [[TMP0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr i8, ptr [[TMP0]], i32 16
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <16 x i8>, ptr [[TMP1]], align 1
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <16 x i8>, ptr [[TMP2]], align 1
; CHECK-NEXT:    [[TMP3:%.*]] = zext <16 x i8> [[WIDE_LOAD]] to <16 x i32>
; CHECK-NEXT:    [[TMP4:%.*]] = zext <16 x i8> [[WIDE_LOAD2]] to <16 x i32>
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[TMP5]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP5]], i32 16
; CHECK-NEXT:    [[WIDE_LOAD3:%.*]] = load <16 x i8>, ptr [[TMP6]], align 1
; CHECK-NEXT:    [[WIDE_LOAD4:%.*]] = load <16 x i8>, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[TMP8:%.*]] = sext <16 x i8> [[WIDE_LOAD3]] to <16 x i32>
; CHECK-NEXT:    [[TMP9:%.*]] = sext <16 x i8> [[WIDE_LOAD4]] to <16 x i32>
; CHECK-NEXT:    [[TMP10:%.*]] = mul <16 x i32> [[TMP8]], [[TMP3]]
; CHECK-NEXT:    [[TMP11:%.*]] = mul <16 x i32> [[TMP9]], [[TMP4]]
; CHECK-NEXT:    [[PARTIAL_REDUCE]] = call <4 x i32> @llvm.experimental.vector.partial.reduce.add.v4i32.v16i32(<4 x i32> [[VEC_PHI]], <16 x i32> [[TMP10]])
; CHECK-NEXT:    [[PARTIAL_REDUCE5]] = call <4 x i32> @llvm.experimental.vector.partial.reduce.add.v4i32.v16i32(<4 x i32> [[VEC_PHI1]], <16 x i32> [[TMP11]])
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 32
; CHECK-NEXT:    [[TMP12:%.*]] = icmp eq i64 [[INDEX_NEXT]], 1024
; CHECK-NEXT:    br i1 [[TMP12]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP6:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = add <4 x i32> [[PARTIAL_REDUCE5]], [[PARTIAL_REDUCE]]
; CHECK-NEXT:    [[TMP13:%.*]] = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> [[BIN_RDX]])
; CHECK-NEXT:    br label [[FOR_EXIT:%.*]]
; CHECK:       scalar.ph:
;
; CHECK-NOI8MM-LABEL: define i32 @sudot_neon(
; CHECK-NOI8MM-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NOI8MM-NEXT:  entry:
; CHECK-NOI8MM-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK-NOI8MM:       vector.ph:
; CHECK-NOI8MM-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK-NOI8MM:       vector.body:
; CHECK-NOI8MM-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI:%.*]] = phi <16 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP12:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI1:%.*]] = phi <16 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP13:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[TMP0:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP1:%.*]] = getelementptr i8, ptr [[TMP0]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP2:%.*]] = getelementptr i8, ptr [[TMP0]], i32 16
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD:%.*]] = load <16 x i8>, ptr [[TMP1]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD2:%.*]] = load <16 x i8>, ptr [[TMP2]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP3:%.*]] = zext <16 x i8> [[WIDE_LOAD]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP4:%.*]] = zext <16 x i8> [[WIDE_LOAD2]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[TMP5]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP5]], i32 16
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD3:%.*]] = load <16 x i8>, ptr [[TMP6]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD4:%.*]] = load <16 x i8>, ptr [[TMP7]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP8:%.*]] = sext <16 x i8> [[WIDE_LOAD3]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP9:%.*]] = sext <16 x i8> [[WIDE_LOAD4]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP10:%.*]] = mul <16 x i32> [[TMP8]], [[TMP3]]
; CHECK-NOI8MM-NEXT:    [[TMP11:%.*]] = mul <16 x i32> [[TMP9]], [[TMP4]]
; CHECK-NOI8MM-NEXT:    [[TMP12]] = add <16 x i32> [[TMP10]], [[VEC_PHI]]
; CHECK-NOI8MM-NEXT:    [[TMP13]] = add <16 x i32> [[TMP11]], [[VEC_PHI1]]
; CHECK-NOI8MM-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 32
; CHECK-NOI8MM-NEXT:    [[TMP14:%.*]] = icmp eq i64 [[INDEX_NEXT]], 1024
; CHECK-NOI8MM-NEXT:    br i1 [[TMP14]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP6:![0-9]+]]
; CHECK-NOI8MM:       middle.block:
; CHECK-NOI8MM-NEXT:    [[BIN_RDX:%.*]] = add <16 x i32> [[TMP13]], [[TMP12]]
; CHECK-NOI8MM-NEXT:    [[TMP15:%.*]] = call i32 @llvm.vector.reduce.add.v16i32(<16 x i32> [[BIN_RDX]])
; CHECK-NOI8MM-NEXT:    br label [[FOR_EXIT:%.*]]
; CHECK-NOI8MM:       scalar.ph:
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %accum = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %gep.a = getelementptr i8, ptr %a, i64 %iv
  %load.a = load i8, ptr %gep.a, align 1
  %ext.a = zext i8 %load.a to i32
  %gep.b = getelementptr i8, ptr %b, i64 %iv
  %load.b = load i8, ptr %gep.b, align 1
  %ext.b = sext i8 %load.b to i32
  %mul = mul i32 %ext.b, %ext.a
  %add = add i32 %mul, %accum
  %iv.next = add i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, 1024
  br i1 %exitcond.not, label %for.exit, label %for.body

for.exit:                        ; preds = %for.body
  ret i32 %add
}

define i32 @usdot_neon(ptr %a, ptr %b) #1 {
; CHECK-LABEL: define i32 @usdot_neon(
; CHECK-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[PARTIAL_REDUCE5:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i8, ptr [[TMP0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr i8, ptr [[TMP0]], i32 16
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <16 x i8>, ptr [[TMP1]], align 1
; CHECK-NEXT:    [[WIDE_LOAD2:%.*]] = load <16 x i8>, ptr [[TMP2]], align 1
; CHECK-NEXT:    [[TMP3:%.*]] = sext <16 x i8> [[WIDE_LOAD]] to <16 x i32>
; CHECK-NEXT:    [[TMP4:%.*]] = sext <16 x i8> [[WIDE_LOAD2]] to <16 x i32>
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[TMP5]], i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP5]], i32 16
; CHECK-NEXT:    [[WIDE_LOAD3:%.*]] = load <16 x i8>, ptr [[TMP6]], align 1
; CHECK-NEXT:    [[WIDE_LOAD4:%.*]] = load <16 x i8>, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[TMP8:%.*]] = zext <16 x i8> [[WIDE_LOAD3]] to <16 x i32>
; CHECK-NEXT:    [[TMP9:%.*]] = zext <16 x i8> [[WIDE_LOAD4]] to <16 x i32>
; CHECK-NEXT:    [[TMP10:%.*]] = mul <16 x i32> [[TMP8]], [[TMP3]]
; CHECK-NEXT:    [[TMP11:%.*]] = mul <16 x i32> [[TMP9]], [[TMP4]]
; CHECK-NEXT:    [[PARTIAL_REDUCE]] = call <4 x i32> @llvm.experimental.vector.partial.reduce.add.v4i32.v16i32(<4 x i32> [[VEC_PHI]], <16 x i32> [[TMP10]])
; CHECK-NEXT:    [[PARTIAL_REDUCE5]] = call <4 x i32> @llvm.experimental.vector.partial.reduce.add.v4i32.v16i32(<4 x i32> [[VEC_PHI1]], <16 x i32> [[TMP11]])
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 32
; CHECK-NEXT:    [[TMP12:%.*]] = icmp eq i64 [[INDEX_NEXT]], 1024
; CHECK-NEXT:    br i1 [[TMP12]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP8:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = add <4 x i32> [[PARTIAL_REDUCE5]], [[PARTIAL_REDUCE]]
; CHECK-NEXT:    [[TMP13:%.*]] = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> [[BIN_RDX]])
; CHECK-NEXT:    br label [[FOR_EXIT:%.*]]
; CHECK:       scalar.ph:
;
; CHECK-NOI8MM-LABEL: define i32 @usdot_neon(
; CHECK-NOI8MM-SAME: ptr [[A:%.*]], ptr [[B:%.*]]) #[[ATTR1]] {
; CHECK-NOI8MM-NEXT:  entry:
; CHECK-NOI8MM-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK-NOI8MM:       vector.ph:
; CHECK-NOI8MM-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK-NOI8MM:       vector.body:
; CHECK-NOI8MM-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI:%.*]] = phi <16 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP12:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[VEC_PHI1:%.*]] = phi <16 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP13:%.*]], [[VECTOR_BODY]] ]
; CHECK-NOI8MM-NEXT:    [[TMP0:%.*]] = getelementptr i8, ptr [[A]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP1:%.*]] = getelementptr i8, ptr [[TMP0]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP2:%.*]] = getelementptr i8, ptr [[TMP0]], i32 16
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD:%.*]] = load <16 x i8>, ptr [[TMP1]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD2:%.*]] = load <16 x i8>, ptr [[TMP2]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP3:%.*]] = sext <16 x i8> [[WIDE_LOAD]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP4:%.*]] = sext <16 x i8> [[WIDE_LOAD2]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP5:%.*]] = getelementptr i8, ptr [[B]], i64 [[INDEX]]
; CHECK-NOI8MM-NEXT:    [[TMP6:%.*]] = getelementptr i8, ptr [[TMP5]], i32 0
; CHECK-NOI8MM-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr [[TMP5]], i32 16
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD3:%.*]] = load <16 x i8>, ptr [[TMP6]], align 1
; CHECK-NOI8MM-NEXT:    [[WIDE_LOAD4:%.*]] = load <16 x i8>, ptr [[TMP7]], align 1
; CHECK-NOI8MM-NEXT:    [[TMP8:%.*]] = zext <16 x i8> [[WIDE_LOAD3]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP9:%.*]] = zext <16 x i8> [[WIDE_LOAD4]] to <16 x i32>
; CHECK-NOI8MM-NEXT:    [[TMP10:%.*]] = mul <16 x i32> [[TMP8]], [[TMP3]]
; CHECK-NOI8MM-NEXT:    [[TMP11:%.*]] = mul <16 x i32> [[TMP9]], [[TMP4]]
; CHECK-NOI8MM-NEXT:    [[TMP12]] = add <16 x i32> [[TMP10]], [[VEC_PHI]]
; CHECK-NOI8MM-NEXT:    [[TMP13]] = add <16 x i32> [[TMP11]], [[VEC_PHI1]]
; CHECK-NOI8MM-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 32
; CHECK-NOI8MM-NEXT:    [[TMP14:%.*]] = icmp eq i64 [[INDEX_NEXT]], 1024
; CHECK-NOI8MM-NEXT:    br i1 [[TMP14]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP8:![0-9]+]]
; CHECK-NOI8MM:       middle.block:
; CHECK-NOI8MM-NEXT:    [[BIN_RDX:%.*]] = add <16 x i32> [[TMP13]], [[TMP12]]
; CHECK-NOI8MM-NEXT:    [[TMP15:%.*]] = call i32 @llvm.vector.reduce.add.v16i32(<16 x i32> [[BIN_RDX]])
; CHECK-NOI8MM-NEXT:    br label [[FOR_EXIT:%.*]]
; CHECK-NOI8MM:       scalar.ph:
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %accum = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %gep.a = getelementptr i8, ptr %a, i64 %iv
  %load.a = load i8, ptr %gep.a, align 1
  %ext.a = sext i8 %load.a to i32
  %gep.b = getelementptr i8, ptr %b, i64 %iv
  %load.b = load i8, ptr %gep.b, align 1
  %ext.b = zext i8 %load.b to i32
  %mul = mul i32 %ext.b, %ext.a
  %add = add i32 %mul, %accum
  %iv.next = add i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, 1024
  br i1 %exitcond.not, label %for.exit, label %for.body

for.exit:                        ; preds = %for.body
  ret i32 %add
}

!7 = distinct !{!7, !8, !9, !10}
!8 = !{!"llvm.loop.mustprogress"}
!9 = !{!"llvm.loop.vectorize.predicate.enable", i1 true}
!10 = !{!"llvm.loop.vectorize.enable", i1 true}
attributes #0 = { vscale_range(1,16) "target-features"="+sve" }
attributes #1 = { "target-features"="+neon" }
