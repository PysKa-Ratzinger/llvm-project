//===- MC/MCAsmInfoXCOFF.cpp - XCOFF asm properties ------------ *- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCAsmInfoXCOFF.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/MC/MCSectionXCOFF.h"
#include "llvm/Support/CommandLine.h"

using namespace llvm;

namespace llvm {
extern cl::opt<cl::boolOrDefault> UseLEB128Directives;
}

MCAsmInfoXCOFF::MCAsmInfoXCOFF() {
  IsAIX = true;
  IsLittleEndian = false;

  PrivateGlobalPrefix = "L..";
  PrivateLabelPrefix = "L..";
  SupportsQuotedNames = false;
  if (UseLEB128Directives == cl::BOU_UNSET)
    HasLEB128Directives = false;
  ZeroDirective = "\t.space\t";
  AsciiDirective = nullptr; // not supported
  AscizDirective = nullptr; // not supported
  CharacterLiteralSyntax = ACLS_SingleQuotePrefix;

  // Use .vbyte for data definition to avoid directives that apply an implicit
  // alignment.
  Data16bitsDirective = "\t.vbyte\t2, ";
  Data32bitsDirective = "\t.vbyte\t4, ";

  COMMDirectiveAlignmentIsInBytes = false;
  LCOMMDirectiveAlignmentType = LCOMM::Log2Alignment;
  HasDotTypeDotSizeDirective = false;
  ParseInlineAsmUsingAsmParser = true;

  ExceptionsType = ExceptionHandling::AIX;
}

bool MCAsmInfoXCOFF::isAcceptableChar(char C) const {
  // QualName is allowed for a MCSymbolXCOFF, and
  // QualName contains '[' and ']'.
  if (C == '[' || C == ']')
    return true;

  // For AIX assembler, symbols may consist of numeric digits,
  // underscores, periods, uppercase or lowercase letters, or
  // any combination of these.
  return isAlnum(C) || C == '_' || C == '.';
}

bool MCAsmInfoXCOFF::useCodeAlign(const MCSection &Sec) const {
  return static_cast<const MCSectionXCOFF &>(Sec).getKind().isText();
}
