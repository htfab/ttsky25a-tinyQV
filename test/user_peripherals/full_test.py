# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

PERIPHERAL_NUM = 14

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # Reset
    await tqv.reset()

    dut._log.info("Test project behavior")

    # Test register write and read back
    await tqv.write_word_reg(0, 0x12345678)
    assert await tqv.read_byte_reg(0) == 0x78
    assert await tqv.read_byte_reg(0) == 0x79
    assert await tqv.read_byte_reg(0) == 0x7a
    assert await tqv.read_byte_reg(0) == 0x7b
    assert await tqv.read_hword_reg(0) == 0x567c
    assert await tqv.read_hword_reg(0) == 0x567d
    assert await tqv.read_hword_reg(0) == 0x567e
    assert await tqv.read_hword_reg(0) == 0x567f
    assert await tqv.read_word_reg(0) == 0x12345680
    assert await tqv.read_word_reg(0) == 0x12345681
    assert await tqv.read_word_reg(0) == 0x12345682
    assert await tqv.read_word_reg(0) == 0x12345683
    assert await tqv.read_word_reg(4) == 0x12345684
    assert await tqv.read_word_reg(4) == 0x12345685
    assert await tqv.read_word_reg(4) == 0x12345686
    assert await tqv.read_word_reg(4) == 0x12345687
