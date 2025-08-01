// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// -----

func.func @a_is_2d(%a : vector<2x2xi32>, %b : vector<4x4xi8>) -> vector<2x2xi32> {
    // expected-error@+1 {{operand `a` should be 1-dimensional}}
    %0 = arm_neon.2d.sdot %a, %b, %b : vector<4x4xi8>, vector<4x4xi8> to vector<2x2xi32>
    return %0 : vector<2x2xi32>
}

// -----

func.func @b_is_3d(%a : vector<4xi32>, %b : vector<1x4x4xi8>) -> vector<4xi32> {
    // expected-error@+1 {{operand `b` should be 2-dimensional}}
    %0 = arm_neon.2d.sdot %a, %b, %b : vector<1x4x4xi8>, vector<1x4x4xi8> to vector<4xi32>
    return %0 : vector<4xi32>
}

// -----

func.func @b_has_2_columns(%a : vector<4xi32>, %b : vector<4x2xi8>) -> vector<4xi32> {
    // expected-error@+1 {{operand `b` should have 4 columns}}
    %0 = arm_neon.2d.sdot %a, %b, %b : vector<4x2xi8>, vector<4x2xi8> to vector<4xi32>
    return %0 : vector<4xi32>
}

// -----

func.func @b_has_2_rows_but_a_has_length_4(%a : vector<4xi32>, %b : vector<2x4xi8>) -> vector<4xi32> {
    // expected-error@+1 {{operand `b` should have as many rows as the size of operand `a`}}
    %0 = arm_neon.2d.sdot %a, %b, %b : vector<2x4xi8>, vector<2x4xi8> to vector<4xi32>
    return %0 : vector<4xi32>
}

// -----

func.func @smmla_invalid_input_types(%a: vector<4xi32>,
                                     %b: vector<16xi4>,
                                     %c: vector<16xi4>) -> vector<4xi32> {
  // expected-error@+1 {{op operand #1 must be a vector with length 16 of 8-bit signless integer values, but got 'vector<16xi4>'}}
  %0 = arm_neon.intr.smmla %a, %b, %c : vector<16xi4> to vector<4xi32>
  return %0 : vector<4xi32>
}

// -----

func.func @smmla_invalid_dimensions(%a: vector<8xi32>,
                                    %b: vector<32xi8>,
                                    %c: vector<32xi8>) -> vector<8xi32> {
  // expected-error@+1 {{op operand #0 must be a vector with length 4 of 32-bit signless integer values, but got 'vector<8xi32>'}}
  %0 = arm_neon.intr.smmla %a, %b, %c : vector<32xi8> to vector<8xi32>
  return %0 : vector<8xi32>
}

// -----

func.func @ummla_invalid_input_types(%a: vector<4xi32>,
                                     %b: vector<16xi4>,
                                     %c: vector<16xi4>) -> vector<4xi32> {
  // expected-error@+1 {{op operand #1 must be a vector with length 16 of 8-bit signless integer values, but got 'vector<16xi4>'}}
  %0 = arm_neon.intr.ummla %a, %b, %c : vector<16xi4> to vector<4xi32>
  return %0 : vector<4xi32>
}

// -----

func.func @ummla_invalid_dimensions(%a: vector<8xi32>,
                                    %b: vector<32xi8>,
                                    %c: vector<32xi8>) -> vector<8xi32> {
  // expected-error@+1 {{op operand #0 must be a vector with length 4 of 32-bit signless integer values, but got 'vector<8xi32>'}}
  %0 = arm_neon.intr.ummla %a, %b, %c : vector<32xi8> to vector<8xi32>
  return %0 : vector<8xi32>
}

// -----

func.func @usmmla_invalid_input_types(%a: vector<4xi32>,
                                      %b: vector<16xi4>,
                                      %c: vector<16xi4>) -> vector<4xi32> {
  // expected-error@+1 {{op operand #1 must be a vector with length 16 of 8-bit signless integer values, but got 'vector<16xi4>'}}
  %0 = arm_neon.intr.usmmla %a, %b, %c : vector<16xi4> to vector<4xi32>
  return %0 : vector<4xi32>
}

// -----

func.func @usmmla_invalid_dimensions(%a: vector<8xi32>,
                                     %b: vector<32xi8>,
                                     %c: vector<32xi8>) -> vector<8xi32> {
  // expected-error@+1 {{op operand #0 must be a vector with length 4 of 32-bit signless integer values, but got 'vector<8xi32>'}}
  %0 = arm_neon.intr.usmmla %a, %b, %c : vector<32xi8> to vector<8xi32>
  return %0 : vector<8xi32>
}

// -----

func.func @bfmmla_invalid_element_type_lhs_rhs(%acc: vector<4xf32>,
                                               %lhs: vector<8xf16>,
                                               %rhs: vector<8xf16>) -> vector<4xf32> {
  // expected-error@+1 {{operand #1 must be a vector with length 8 of bfloat16 type values, but got 'vector<8xf16>'}}
  %0 = arm_neon.intr.bfmmla %acc, %lhs, %rhs : vector<8xf16> to vector<4xf32>
  return %0 : vector<4xf32>
}

// -----

func.func @bfmmla_invalid_dimension_lhs_rhs(%acc: vector<4xf32>,
                                            %lhs: vector<4xbf16>,
                                            %rhs: vector<4xbf16>) -> vector<4xf32> {
  // expected-error@+1 {{operand #1 must be a vector with length 8 of bfloat16 type values, but got 'vector<4xbf16>'}}
  %0 = arm_neon.intr.bfmmla %acc, %lhs, %rhs : vector<4xbf16> to vector<4xf32>
  return %0 : vector<4xf32>
}

// -----

func.func @bfmmla_scalable_dimension_lhs_rhs(%acc: vector<4xf32>,
                                             %lhs: vector<[8]xbf16>,
                                             %rhs: vector<[8]xbf16>) -> vector<4xf32> {
  // expected-error@+1 {{operand #1 must be a vector with length 8 of bfloat16 type values, but got 'vector<[8]xbf16>'}}
  %0 = arm_neon.intr.bfmmla %acc, %lhs, %rhs : vector<[8]xbf16> to vector<4xf32>
  return %0 : vector<4xf32>
}

// -----

func.func @bfmmla_invalid_element_type_acc(%acc: vector<4xi32>,
                                           %lhs: vector<8xbf16>,
                                           %rhs: vector<8xbf16>) -> vector<4xi32> {
  // expected-error@+1 {{op operand #0 must be a vector with length 4 of 32-bit float values, but got 'vector<4xi32>'}}
  %0 = arm_neon.intr.bfmmla %acc, %lhs, %rhs : vector<8xbf16> to vector<4xi32>
  return %0 : vector<4xi32>
}

// -----

func.func @bfmmla_invalid_dimension_acc(%acc: vector<8xf32>,
                                        %lhs: vector<8xbf16>,
                                        %rhs: vector<8xbf16>) -> vector<8xf32> {
  // expected-error@+1 {{op operand #0 must be a vector with length 4 of 32-bit float values, but got 'vector<8xf32>'}}
  %0 = arm_neon.intr.bfmmla %acc, %lhs, %rhs : vector<8xbf16> to vector<8xf32>
  return %0 : vector<8xf32>
}

// -----

func.func @bfmmla_scalable_dimension_acc(%acc: vector<[4]xf32>,
                                         %lhs: vector<8xbf16>,
                                         %rhs: vector<8xbf16>) -> vector<[4]xf32> {
  // expected-error@+1 {{op operand #0 must be a vector with length 4 of 32-bit float values, but got 'vector<[4]xf32>'}}
  %0 = arm_neon.intr.bfmmla %acc, %lhs, %rhs : vector<8xbf16> to vector<[4]xf32>
  return %0 : vector<[4]xf32>
}
