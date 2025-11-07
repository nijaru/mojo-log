#!/usr/bin/env mojo
# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
# ===----------------------------------------------------------------------=== #

"""Test to verify build setup works."""

from testing import assert_equal


fn test_basic_operations() raises:
    """Test basic Mojo operations work."""
    var x = 42
    assert_equal(x, 42)

    var s = String("hello")
    assert_equal(s, "hello")

    print("✓ Basic operations work")


fn main() raises:
    test_basic_operations()
    print("✓ All setup tests passed")
