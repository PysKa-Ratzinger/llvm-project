//===- SparseTensorInterfaces.cpp - SparseTensor interfaces impl ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/SparseTensor/IR/SparseTensorInterfaces.h"
#include "mlir/Dialect/SparseTensor/IR/SparseTensor.h"
#include "mlir/Dialect/SparseTensor/IR/SparseTensorType.h"
#include "mlir/IR/PatternMatch.h"

using namespace mlir;
using namespace mlir::sparse_tensor;

#include "mlir/Dialect/SparseTensor/IR/SparseTensorInterfaces.cpp.inc"

/// Stage the operations into a sequence of simple operations as follow:
/// op -> unsorted_coo +
/// unsorted_coo -> sorted_coo +
/// sorted_coo -> dstTp.
///
/// return `tmpBuf` if a intermediate memory is allocated.
LogicalResult sparse_tensor::detail::stageWithSortImpl(
    StageWithSortSparseOp op, PatternRewriter &rewriter, Value &tmpBufs) {
  if (!op.needsExtraSort())
    return failure();

  Location loc = op.getLoc();
  Type finalTp = op->getOpResult(0).getType();
  SparseTensorType dstStt(cast<RankedTensorType>(finalTp));
  Type srcCOOTp = dstStt.getCOOType(/*ordered=*/false);

  // Clones the original operation but changing the output to an unordered COO.
  Operation *cloned = rewriter.clone(*op.getOperation());
  rewriter.modifyOpInPlace(cloned, [cloned, srcCOOTp]() {
    cloned->getOpResult(0).setType(srcCOOTp);
  });
  Value srcCOO = cloned->getOpResult(0);

  // -> sort
  Type dstCOOTp = dstStt.getCOOType(/*ordered=*/true);
  Value dstCOO = ReorderCOOOp::create(rewriter, loc, dstCOOTp, srcCOO,
                                      SparseTensorSortKind::HybridQuickSort);

  // -> dest.
  if (dstCOO.getType() == finalTp) {
    rewriter.replaceOp(op, dstCOO);
  } else {
    // Need an extra conversion if the target type is not COO.
    auto c = rewriter.replaceOpWithNewOp<ConvertOp>(op, finalTp, dstCOO);
    rewriter.setInsertionPointAfter(c);
    // Informs the caller about the intermediate buffer we allocated. We can not
    // create a bufferization::DeallocateTensorOp here because it would
    // introduce cyclic dependency between the SparseTensorDialect and the
    // BufferizationDialect. Besides, whether the buffer need to be deallocated
    // by SparseTensorDialect or by BufferDeallocationPass is still TBD.
    tmpBufs = dstCOO;
  }

  return success();
}
